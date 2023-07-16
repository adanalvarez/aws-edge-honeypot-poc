resource "aws_wafv2_web_acl" "honeypot_waf_acl" {
  name        = "honeypot_waf_acl"
  description = "WebACL for Honeypot Protection"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "block_honeypot_requests"
    priority = 1

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.honeypot_ip_blocklist.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "honeypot_block_request_metric"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "honeypot_waf_metric"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_ip_set" "honeypot_ip_blocklist" {
  name               = "honeypot_ip_blocklist"
  description        = "IP Blocklist for Honeypot Protection"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"

  addresses = []
}