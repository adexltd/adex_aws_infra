resource "aws_cloudwatch_log_group" "server_logs" {
  name              = "Sparrow-${var.env}-server-log"
  retention_in_days = 90
}
