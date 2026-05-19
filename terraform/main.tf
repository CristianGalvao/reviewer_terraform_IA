provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro" 

  tags = {
    Name        = "dev-web-server"
    Environment = "Development"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic from internal network only"

  ingress {
    description      = "SSH from corporate network"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"] 
  }
}

variable "db_password" {
  type        = string
  description = "Senha do banco"
  sensitive   = true
}

resource "aws_db_instance" "postgres_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro"
  db_name              = "producao_db"
  username             = "admin"
  password             = var.db_password
  publicly_accessible  = false 
  skip_final_snapshot  = true
}

resource "aws_s3_bucket" "secure_data" {
  bucket = "empresa-dados-sensiveis-clientes-protegidos"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.secure_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_block" {
  bucket = aws_s3_bucket.secure_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_ebs_volume" "data_volume" {
  availability_zone = "us-east-1a"
  size              = 500
  type              = "gp3" 
  encrypted         = true  
}