provider "aws" {
  region = "eu-west-1"
}


provider "pagerduty" {
  token = jsondecode(data.aws_secretsmanager_secret_version.secret_version.secret_string)["pagerduty_token"]
}

locals {
  cleaned_service_name = lower(replace(var.service_name, " ", ""))
  cleaned_sub_name     = lower(replace(var.sub_name, " ", "" ))
}

resource "aws_sns_topic" "alarm" {
  name = "_alarms-${local.cleaned_service_name}-${local.cleaned_sub_name}"
}


resource "aws_sns_topic_subscription" "alarms_to_pagerduty" {
  topic_arn = aws_sns_topic.alarm.arn

  protocol = "https"

  endpoint               = "https://events.pagerduty.com/integration/${pagerduty_service_integration.cloudwatch.integration_key}/enqueue"
  endpoint_auto_confirms = true
}

/*
  Retrieve Secrets Manager Pagerduty token
*/

data "aws_secretsmanager_secret" "this" {
  arn = "arn:aws:secretsmanager:eu-west-1:061938725231:secret:pagerdutyToken-hLgcOp"
}

data "aws_secretsmanager_secret_version" "secret_version" {
  secret_id = data.aws_secretsmanager_secret.this.id
}

/*
 Pagerduty service
*/

data "pagerduty_escalation_policy" "this" {
  name = var.escalation_policy_name
}

resource "pagerduty_service" "this" {
  name        = "${var.service_name} - ${var.sub_name}"
  description = var.description

  incident_urgency_rule {
    type    = "constant"
    urgency = var.incident_alarm_urgency
  }

  escalation_policy = data.pagerduty_escalation_policy.this.id
}

# Connect a pagerduty endpoint for Cloudwatch

data "pagerduty_vendor" "cloudwatch" {
  name = "Cloudwatch"
}

resource "pagerduty_service_integration" "cloudwatch" {
  name    = data.pagerduty_vendor.cloudwatch.name
  service = pagerduty_service.this.id
  vendor  = data.pagerduty_vendor.cloudwatch.id
}