variable "instance-type" {
  type = string
}

variable "public-key-file-path" {
  type = string
}

variable "launch-region" {
  default = "sydney"
  type = string
}

variable "server-ports-tcp" {
  type = list(number)
  default = [ 22, 443, 943, 945 ]
}

variable "server-ports-udp" {
  type = list(number)
  default = [ 1194 ]
}

variable "vpn-credential-path" {
  type = string
  default = "../credentials.txt"
}

variable "region-city-mapping" {
  type = map(string)
  default = {
    "n.virginia" = "us-east-1"
    "ohio" = "us-east-2"
    "s.california" = "us-west-1"
    "oregon" = "us-west-2"
    "canada" = "ca-central-1"
    "tokyo" = "ap-northeast-1"
    "seoul" = "ap-northeast-2"
    "singapore" = "ap-southeast-1"
    "sydney" = "ap-southeast-2"
    "frankfurt" = "eu-central-1"
    "ireland" = "eu-west-1"
    "london" = "eu-west-2"
    "paris" = "eu-west-3"
    "stockholm" = "eu-north-1"
    "saopaulo" = "sa-east-1"
  }
  
}