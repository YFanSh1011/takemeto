resource "aws_security_group" "sg-vpn-server" {
    name = "vpn-server"
    description = "Allow SSH, ping and VPN traffic"
}

resource "aws_vpc_security_group_ingress_rule" "allow-tcp" {
    security_group_id = aws_security_group.sg-vpn-server.id
    ip_protocol = "tcp"
    
    # Iterate through all tcp ports
    count = length(var.server-ports-tcp)
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = var.server-ports-tcp[count.index]
    to_port           = var.server-ports-tcp[count.index]

    tags = {
      Name: "allow-tcp-${var.server-ports-tcp[count.index]}"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow-udp" {
    security_group_id = aws_security_group.sg-vpn-server.id
    ip_protocol = "udp"
    
    # Iterate through all udp ports
    count = length(var.server-ports-udp)
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = var.server-ports-udp[count.index]
    to_port           = var.server-ports-udp[count.index]

    tags = {
      Name: "allow-udp-${var.server-ports-udp[count.index]}"
    }
}

resource "aws_security_group_rule" "allow_icmp" {
  type              = "ingress"
  security_group_id = aws_security_group.sg-vpn-server.id
  protocol          = "icmp"
  from_port         = -1  
  to_port           = -1  
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow ICMP traffic from anywhere"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.sg-vpn-server.id
  ip_protocol = -1
  cidr_ipv4 = "0.0.0.0/0"
  description = "Allow all egress traffic"
}