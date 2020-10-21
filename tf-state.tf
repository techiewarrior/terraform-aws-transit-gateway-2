terraform {
  backend "s3" {
    bucket         = "my-bucket-name"
    key            = "tgw-test.tfstate"
    region         = "us-west-2"
    encrypt        = "true"
    dynamodb_table = "terraform-state-lock-dynamo"
  }
}

resource "aws_s3_bucket" "terraform-state-storage-s3" {
  bucket = "my-bucket-name"

  # enable with caution, makes deleting S3 buckets tricky
  versioning {
    enabled = false
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    name = "S3 Remote Terraform State Store"
  }
}

# create a DynamoDB table for locking the state file
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "terraform-state-lock-dynamo"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    name = "DynamoDB Terraform State Lock Table"
  }
}
