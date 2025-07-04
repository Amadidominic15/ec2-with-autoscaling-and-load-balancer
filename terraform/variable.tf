
variable "vpc_region" {
  default     = "us-west-1"
  description = "vpc region"
}

variable "vpc_availability_zones" {
  description = "Availability Zones"
  default     = ["us-west-1a", "us-west-1c"]
}