resource "aws_cloudwatch_event_rule" "scheduled_attend_selenium" {
  is_enabled = false
  name = "attend_selenium"
  description = "Execute attend_selenium"
  schedule_expression = "cron(30 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "attend_selenium" {
  depends_on  = [aws_cloudwatch_event_rule.scheduled_attend_selenium]
  rule = aws_cloudwatch_event_rule.scheduled_attend_selenium.name
  arn = aws_lambda_function.attend_selenium.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_attend_selenium" {
  statement_id  = "AllowExecutionAttendSeleniumFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.attend_selenium.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled_attend_selenium.arn
}