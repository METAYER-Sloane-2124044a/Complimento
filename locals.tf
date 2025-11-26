# Local variables for shared environment configuration
locals {
  shared_env = {
    REGION_NAME           = "${var.REGION_NAME}"
    AWS_ACCESS_KEY_ID     = "${var.AWS_ACCESS_KEY_ID}"
    AWS_SECRET_ACCESS_KEY = "${var.AWS_SECRET_ACCESS_KEY}"
  }
}