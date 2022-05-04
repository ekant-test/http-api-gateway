# create the SSL ccertificate for the loadbalancer and create the Cname in dns zone with its record to verify the certificate.
resource "aws_acm_certificate" "this" {
  domain_name               = "*.api.ekant.com" ## Replace with your domain name ##
  validation_method         = "DNS"
  lifecycle {
      create_before_destroy = true
    }
  tags = {
      Name = "ekant-test"
    }
}
