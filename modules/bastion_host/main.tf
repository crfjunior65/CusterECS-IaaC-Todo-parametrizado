#
# Data Sources
#

# Data source para IP Elástico existente
data "aws_eip" "existing_eip" {
  # Filtro por IP público
  public_ip = var.aws_eip_public_ip

  # OU por Allocation ID
  # id = "eipalloc-01d8a6715b38cfd01"

  # OU por tags (se o IP tiver tags)
  # filter {
  #   name   = "tag:Name"
  #   values = ["meu-ip-producao"]
  # }
}


data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Dono das AMIs (Amazon)
}

#
# Criacao KeyPair para acesso SSH ao Bastion Host
# Criar a Key Pair via Terraform
#

resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name   = "aws-key-terraform" # Nome da Key Pair
  public_key = tls_private_key.bastion_key.public_key_openssh
}

# Salvar a chave privada localmente (opcional)
resource "local_file" "private_key" {
  content         = tls_private_key.bastion_key.private_key_pem
  filename        = "${path.root}/aws-key-terraform.pem"
  file_permission = "0400"
}

#
# IAM Role and Instance Profile for SSM e SSH
#

resource "aws_iam_role" "ssm_role" {
  name = "${var.prefix}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

# Anexar a política gerenciada AmazonSSMManagedInstanceCore ao Role
resource "aws_iam_role_policy_attachment" "ssm_managed_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Data source para IAM Policy de acesso ao S3
resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "${var.prefix}-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

#
# security group for bastion host
#

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_host"
  description = "Security group for Bastion Host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.prefix}-bastion-host_sg"
  })
}

resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.bastion_instance_type
  key_name      = aws_key_pair.bastion_key_pair.key_name
  subnet_id     = var.public_subnet_id

  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_instance_profile.name
  /*
  user_data = templatefile("${path.root}/user_data/user_data_bastion_template.sh", {
    terraform_public_key = tls_private_key.bastion_key.public_key_openssh
    dev_keys             = var.dev_public_keys
    rds_endpoint         = "postgres.cybw0osiizjg.us-east-1.rds.amazonaws.com"
  })
*/
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id,
    var.rds_security_group_id
  ]

  tags = merge(var.tags, {
    Name = "${var.prefix}-bastion-host-${var.environment}"
  })

  depends_on = [aws_key_pair.bastion_key_pair]
}

# Associação do IP Elástico existente
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.bastion_host.id
  allocation_id = data.aws_eip.existing_eip.id
}
