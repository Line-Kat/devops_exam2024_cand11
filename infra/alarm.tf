variable "alarm_email" {
    description = "Email that receives the alarm"
    type        = string 
}

variable "prefix" {
    type = string
}

variable "threshold" {
    type    = string
    default = "180"
}

resource "aws_sns_topic" "alert_topic" {
    name = "${var.prefix}-sqs-cloudwatch-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" { 
    topic_arn = aws_sns_topic.alert_topic.arn 
    protocol  = "email" 
    endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "sqs_age_of_oldest_message" { 
    alarm_name          = "${var.prefix}-SQS-OldestMessageAge-High" 
    comparison_operator = "GreaterThanThreshold" 
    evaluation_periods  = 2 
    metric_name         = "ApproximateAgeOfOldestMessage" 
    namespace           = "AWS/SQS" 
    period              = 300
    statistic           = "Maximum" 
    threshold           = var.threshold
    description         =  "This alarm goes off when the oldest message age in the SQS queue exceeds threshold"
    dimensions          = { 
      QueueName = aws_sqs_queue.my_queue.name
    } 
    alarm_actions       = [ aws_sns_topic.alert_topic.arn ]
}