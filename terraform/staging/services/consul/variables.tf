# The AMI to use for consul cluster.
variable "ami" {
  description = "AMI to use"
}

# The region to deploy cluster into.
variable "region" {
  description = "Region to deploy the consul cluster into"
}

# The public key to use for SSH access.
variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

# This map defines which AZ to put 'Public Subnet A' in, based on the region defined.
variable "subnetaz1" {
  type = "map"

  default = {
    us-east-1      = "us-east-1a"
    us-east-2      = "us-east-2a"
    us-west-1      = "us-west-1a"
    us-west-2      = "us-west-2a"
    eu-west-1      = "eu-west-1a"
    eu-west-2      = "eu-west-2a"
    eu-central-1   = "eu-central-1a"
    ap-southeast-1 = "ap-southeast-1a"
  }
}

# This map defines which AZ to put 'Public Subnet B' in, based on the region defined.
variable "subnetaz2" {
  type = "map"

  default = {
    us-east-1      = "us-east-1b"
    us-east-2      = "us-east-2b"
    us-west-1      = "us-west-1b"
    us-west-2      = "us-west-2b"
    eu-west-1      = "eu-west-1b"
    eu-west-2      = "eu-west-2b"
    eu-central-1   = "eu-central-1b"
    ap-southeast-1 = "ap-southeast-1b"
  }
}

# This map defines which AZ to put 'Public Subnet C' in, based on the region defined.
variable "subnetaz3" {
  type = "map"

  default = {
    us-east-1      = "us-east-1c"
    us-east-2      = "us-east-2c"
    us-west-1      = "us-west-1c"
    us-west-2      = "us-west-2c"
    eu-west-1      = "eu-west-1c"
    eu-west-2      = "eu-west-2c"
    eu-central-1   = "eu-central-1c"
    ap-southeast-1 = "ap-southeast-1c"
  }
}
