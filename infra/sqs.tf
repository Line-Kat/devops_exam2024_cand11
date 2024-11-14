# Opprett SQS-kø
resource "aws_sqs_queue" "my_queue" {
    name = "my_sqs-queue"
}