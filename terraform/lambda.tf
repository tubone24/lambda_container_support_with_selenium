resource "aws_lambda_function" "attend_selenium" {
  image_uri = var.image_uri
  package_type = "Image"
  function_name = "attend_selenium"
  role = var.role
  description = "Send a screen capture for your other slack attend to your slack channel"
  # handler = "app.handler"
  timeout = 300
  memory_size = 1024

  vpc_config {
    security_group_ids = var.lambda_sg
    subnet_ids = var.lambda_subnet_ids
  }

  environment {
    variables = {
      SLACK_TOKEN = var.slack_token
      SLACK_CHANNEL_ID = var.slack_channel_id
      SLACK_USERNAME = var.slack_username
      SLACK_PASSWORD = var.slack_password
      SLACK_LOGIN_URL = var.slack_login_url
      SLACK_ATTEND_CHANNEL_URL = var.slack_attend_channel_url
      TZ = "Asia/Tokyo"
    }
  }
}