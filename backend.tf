terraform {
  backend "s3" {
    bucket         = "terraform-jenkins-ansible"
    key            = "ec2/terraform.tfstate"
    region         = "us-east-1"
//    dynamodb_table = "terraform-lock"
  }
}
