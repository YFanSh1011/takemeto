resource "aws_instance" "vpn-server" {
  instance_type = var.instance-type
  ami           = data.aws_ami.openvpn_ami.image_id

  key_name                    = aws_key_pair.openvpn_keypair.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    admin_user=${var.vpn-admin-username}
    admin_pw=${var.vpn-admin-password}
    reroute_gw=1
    reroute_dns=1
    EOF

  vpc_security_group_ids = [aws_security_group.sg-vpn-server.id]
}

resource "aws_key_pair" "openvpn_keypair" {
  key_name   = "openvpn_keypair"
  public_key = file(var.public-key-file-path)
}