locals {
  cleaned_service_name = lower(replace(var.service_name, " ", ""))
  cleaned_sub_name     = lower(replace(var.sub_name, " ", ""))
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
 Pagerduty Business Service
*/

data "pagerduty_business_service" "this" {
  count = var.business_service_name != null ? 1 : 0
  name  = var.business_service_name
}

resource "pagerduty_service_dependency" "foo" {
  count = var.business_service_name != null ? 1 : 0
  dependency {
    dependent_service {
      id   = data.pagerduty_business_service.this[count.index].id
      type = data.pagerduty_business_service.this[count.index].type
    }
    supporting_service {
      id   = pagerduty_service.this.id
      type = pagerduty_service.this.type
    }
  }
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

  acknowledgement_timeout = var.acknowledgement_timeout
  auto_resolve_timeout    = var.auto_resolve_timeout
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