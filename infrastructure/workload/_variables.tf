variable "location" {
  type = string
  # GPT-4 is only available in certain regions.
  default = "francecentral"
}

variable "suffix" {
  type = string
}

variable "target_resource_group_name" {
  type = string
}

variable "target_acr_name" {
  type = string
}

variable "container_image_tag" {
  type = string
}


