variable "alarm_email" {
    description = "Email that receives the alarm"
    type        = string
    default     = "lika027@student.kristiania.no"
}

variable "prefix" {
    type = string
    default     = "cand11"
}

variable "threshold" {
    type    = string
    #default = "180"
    default = "1000"
}

resource "aws_sns_topic" "alert_topic" {
    name = "${var.prefix}-sqs-cloudwatch-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" { 
    topic_arn = aws_sns_topic.alert_topic.arn 
    protocol  = "email" 
    endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "sqs_age_of_oldest_message" { 
    alarm_name          = "${var.prefix}-SQS-OldestMessageAge-High" 
    comparison_operator = "GreaterThanThreshold" 
    evaluation_periods  = 1
    #evaluation_periods  = 2 
    metric_name         = "ApproximateAgeOfOldestMessage" 
    namespace           = "AWS/SQS" 
    period = 60
    #period              = 300
    statistic           = "Maximum" 
    threshold           = var.threshold
    dimensions          = { 
      QueueName = aws_sqs_queue.my_queue.name
    } 
    alarm_actions       = [ aws_sns_topic.alert_topic.arn ]
}
