resource "aws_instance" "vpn-server" {
    instance_type = var.instance-type
    ami = data.aws_ami.openvpn_ami.image_id

    key_name = aws_key_pair.openvpn_keypair.key_name
    associate_public_ip_address = true

    user_data = <<-EOF
    admin_user=${split("\n", file(var.vpn-credential-path))[0]}
    admin_pw=${split("\n", file(var.vpn-credential-path))[1]}
    reroute_gw=1
    reroute_dns=1
    EOF

    vpc_security_group_ids = [ aws_security_group.sg-vpn-server.id ]
}

resource "aws_key_pair" "openvpn_keypair" {
  key_name   = "openvpn_keypair"
  public_key = file(var.public-key-file-path)
}