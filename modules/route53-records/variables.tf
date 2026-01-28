
variable "zone_id" {
  type        = string
  description = "Route53 Hosted Zone ID"
}

variable "records" {
  type = map(object({
    type            = string
    alias           = bool
    target          = string
    zone_id         = optional(string)
    ttl             = optional(number, 300)
    evaluate_health = optional(bool)
    priority        = optional(number)
  }))
}

