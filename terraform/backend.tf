terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-0007"
    key            = "ec2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}
