variable "alarm_email" {
    description = "Email that receives the alarm"
    type        = string
    default     = "lika027@student.kristiania.no"
}

variable "prefix" {
    type    = string
    default = "cand11"
}

variable "threshold" {
    type    = string
    default = "180"
}