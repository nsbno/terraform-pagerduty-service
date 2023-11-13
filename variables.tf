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

variable "acknowledgement_timeout" {
  type        = string
  default     = "null"
  description = "Time in seconds that an incident changes to the Triggered State after being Acknowledged"
}

variable "auto_resolve_timeout" {
  type        = string
  default     = "null"
  description = "Time in seconds that an incident is automatically resolved if left open for that long"
}