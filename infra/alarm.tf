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
    evaluation_periods  = 2 
    metric_name         = "ApproximateAgeOfOldestMessage" 
    namespace           = "AWS/SQS" 
    period              = 300
    statistic           = "Maximum" 
    threshold           = var.threshold
    dimensions          = { 
      QueueName = aws_sqs_queue.my_queue.name
    } 
    alarm_actions       = [ aws_sns_topic.alert_topic.arn ]
}
