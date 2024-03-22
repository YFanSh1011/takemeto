provider "aws" {
  region = lookup(var.region-city-mapping, var.launch-region, "sydney")
}