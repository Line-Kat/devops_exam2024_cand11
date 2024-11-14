# Opprett Lambda-funksjonen
resource "aws_lambda_function" "lambda_sqs" {
  function_name    = "lambda_sqs_function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_sqs.lambda_handler"
  runtime          = "python3.9"
  timeout          = 15

  # Pakke Lambdafunksjonen til en zip-fil
  filename = "${path.module}/lambda_sqs.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_sqs.zip")

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.my_queue.url
      BUCKET_NAME   = "pgr301-couch-explorers"
    }
  }
  depends_on = [aws_iam_policy.lambda_policy]
}

# Legg til SQS-kø som en kilde for Lambda
resource "aws_lambda_event_source_mapping" "sqs_event" {
  event_source_arn  = aws_sqs_queue.my_queue.arn
  function_name     = aws_lambda_function.lambda_sqs.arn
  batch_size        = 10
}