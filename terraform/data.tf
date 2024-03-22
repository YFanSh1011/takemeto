data "aws_ami" "openvpn_ami" {
    owners = ["aws-marketplace"]
    most_recent = true

    filter {
        name = "product-code"
        values = ["f2ew2wrz425a1jagnifd02u5t"]
    }  

    filter {
      name = "product-code.type"
      values = ["marketplace"]
    }
}
