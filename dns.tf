data "aws_route53_zone" "selected" {
  name         = "botkit.run."
  private_zone = false
}

resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "botkit.run."
  type    = "A"
  


    alias {
        name = aws_lb.node_echo_http.dns_name
        zone_id = aws_lb.node_echo_http.zone_id
        evaluate_target_health = false
    }

    depends_on = [
        data.aws_route53_zone.selected
    ]
}