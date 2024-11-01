variable "step_function_arn" {}

resource "aws_iam_role" "eventbridge_step_function_role" {
  name = "gutendex-eventbridge-step-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eventbridge_step_function_policy" {
  name = "gutendex-eventbridge-step-function-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution",
          "states:StopExecution",
          "states:GetExecutionHistory",
          "states:GetExecution",
          "states:DescribeStateMachine",
          "states:ListStateMachines",
          "states:CreateStateMachine",
          "states:DeleteStateMachine",
          "states:UpdateStateMachine",
          "states:ListStateMachineExecutions",
          "states:ListStateMachineVersions",
          "states:CreateStateMachineVersion",
          "states:DeleteStateMachineVersion",
          "states:UpdateStateMachineVersion",
          "states:GetStateMachineInput",
          "states:GetStateMachineOutput",
          "states:SendTaskHeartbeat",
          "states:RecordExecutionHistory",
          "states:StopExecution",
          "states:CancelExecution",
          "states:ResetStateMachine",
          "states:ListTagsForResource",
          "states:TagResource",
          "states:UntagResource",
          "states:PutEventSourceMapping",
          "states:GetEventSourceMapping",
          "states:ListEventSourceMappings",
          "states:RemoveEventSourceMapping",
          "states:DescribeEventConfiguration",
          "states:PutEventConfiguration",
          "states:GetEventConfiguration",
          "states:ListEventConfigurations"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "scheduler:ScheduleAction",
          "scheduler:DescribeSchedule",
          "scheduler:ListSchedules",
          "scheduler:CreateSchedule",
          "scheduler:UpdateSchedule",
          "scheduler:DeleteSchedule"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "event_bridge_attach" {
  role       = aws_iam_role.eventbridge_step_function_role.name
  policy_arn = aws_iam_policy.eventbridge_step_function_policy.arn
}

resource "aws_scheduler_schedule" "example" {
  name       = "gutendex-eb-schedule"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(24 hours)"

  target {
    arn      = var.step_function_arn
    role_arn = aws_iam_role.eventbridge_step_function_role.arn
  }
}
