output "ip_set_id" {
  description = "The ID of the IP Set"
  value       = aws_wafv2_ip_set.honeypot_ip_blocklist.id
}

output "cloudfront_url" {
  description = "The URL of the CloudFront distribution"
  value       = "https://${aws_cloudfront_distribution.honeypot_distribution.domain_name}"
}

