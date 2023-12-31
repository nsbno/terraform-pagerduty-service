terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    pagerduty = {
      source  = "pagerduty/pagerduty"
      version = ">= 3.0.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "pagerduty_token" {
  source = "github.com/nsbno/terraform-pagerduty-provider-setup?ref=0.0.1"
}

provider "pagerduty" {
  token = module.pagerduty_token.token
}

module "pagerduty_service" {
  source = "../"

  service_name = "Traffic Notifier"
  sub_name     = "Excessive API Errors"
  description  = "Error when API is having errors"

  # Use existing or create your escalation policy in Pagerduty website
  escalation_policy_name = "Test Escalation Policy"
}

resource "aws_cloudwatch_metric_alarm" "error_count" {
  alarm_name        = "_alarm/error-count"
  alarm_description = "Traffic Notifier is logging API errors"

  metric_name = "ErrorCount"
  namespace   = "traffic-notifier/error-count"
  dimensions = {
    Endpoint = "POST"
  }

  statistic           = "Sum"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  period              = 60
  evaluation_periods  = 1

  alarm_actions = [module.pagerduty_service.sns_topic_arn]
}
