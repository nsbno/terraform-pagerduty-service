variable "service_name" {
  type        = string
  description = "The name of your service"
}

variable "sub_name" {
  type        = string
  description = "Which part of the service triggers this alarm"
}

variable "description" {
  type        = string
  description = "Description for your alarm"
}

variable "escalation_policy_name" {
  type        = string
  description = "Existing PagerDuty escalation policy name"
}

variable "incident_alarm_urgency" {
  type        = string
  default     = "low"
  description = "The urgency of incidents that happen"
}

variable "business_service_name" {
  type        = string
  default     = null
  description = "The business service your service will be associated with"
}