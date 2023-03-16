variable "root_id" {
  description = "Specifies the id of the root."
  type        = string
  sensitive   = false
}

variable "root_name" {
  description = "Specifies the name of the root."
  type        = string
  sensitive   = false
}

variable "default_location" {
  type        = string
  default     = "eastus"
  description = "Specifies the default location for resources, including references to location within Policy templates."
}