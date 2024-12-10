terraform {
  backend "s3" {
    bucket         = "manasvistatebucket"
    key            = "aws-cloud/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}
 