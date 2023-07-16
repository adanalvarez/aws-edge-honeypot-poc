output "ip_set_id" {
  description = "The ID of the IP Set"
  value       = aws_wafv2_ip_set.honeypot_ip_blocklist.id
}