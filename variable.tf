variable "ENDPOINT_URL" {
  type = string
}

variable "ENDPOINT_URL_LAMBDA" {
  type = string
}

variable "REGION_NAME" {
  type = string
}

variable "AWS_ACCESS_KEY_ID" {
  type = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}

variable "INDEX_PAGE" {
  type    = string
  default = "index.html"
}

variable "DIR_IMG_S3" {
  type    = string
  default = "assets/images"
}

variable "PATH_IMG_LOCAL" {
  type    = string
  default = "web/assets/images"
}