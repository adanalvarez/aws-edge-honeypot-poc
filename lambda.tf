resource "aws_iam_role" "waf_lambda_role" {
  name = "waf_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          "Service" : [
            "edgelambda.amazonaws.com",
            "lambda.amazonaws.com"
          ]
        }
      },
    ]
  })
}

resource "aws_iam_policy" "waf_lambda_policy" {
  name        = "waf_lambda_policy"
  description = "Allows Lambda to access WAF"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "wafv2:GetIPSet",
          "wafv2:UpdateIPSet"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "waf_lambda_policy_attach" {
  role       = aws_iam_role.waf_lambda_role.name
  policy_arn = aws_iam_policy.waf_lambda_policy.arn
}

resource "aws_iam_policy" "lambda_logs" {
  name        = "LambdaLogs"
  description = "Allows Lambda function to write logs to CloudWatch"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attach" {
  role       = aws_iam_role.waf_lambda_role.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}


data "archive_file" "waf_lambda_zip" {
  type        = "zip"
  source_file = "waf_lambda_function.py"
  output_path = "waf_lambda_function.zip"
}

resource "aws_lambda_function" "waf_lambda" {
  filename      = data.archive_file.waf_lambda_zip.output_path
  function_name = "honeypot_detector_lambda"
  role          = aws_iam_role.waf_lambda_role.arn
  handler       = "waf_lambda_function.lambda_handler"

  source_code_hash = data.archive_file.waf_lambda_zip.output_base64sha256

  runtime = "python3.8"

  publish = true
}

resource "aws_lambda_function_event_invoke_config" "waf_lambda_config" {
  function_name                = aws_lambda_function.waf_lambda.function_name
  maximum_retry_attempts       = 2
  maximum_event_age_in_seconds = 60
}

resource "aws_lambda_alias" "waf_lambda_alias" {
  name             = "latest"
  function_name    = aws_lambda_function.waf_lambda.function_name
  function_version = "$LATEST"
}