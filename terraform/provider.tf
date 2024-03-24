provider "aws" {
  region = lookup(var.region-city-mapping, var.launch-region, var.default-region)
}