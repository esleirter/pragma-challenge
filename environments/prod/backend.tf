terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
  #   backend "s3" {
  #     bucket         = "my-terraform-states"         # Nombre del bucket S3 donde se guarda el estado
  #     key            = "prod/frontend/terraform.tfstate"  # Ruta (key) dentro del bucket
  #     region         = "us-east-1"
  #     encrypt        = true                            # Cifra el estado en S3
  #     dynamodb_table = "terraform-locks"               # Tabla de bloqueo para concurrencia
  #   }
}

provider "aws" {
  region = "us-east-1"
}
