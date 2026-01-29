terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = merge(local.tags, { Name = "${local.name_prefix}-vpc" })
}

####################################
## DHCP Options Set & Association ##
####################################
resource "aws_vpc_dhcp_options" "dhcp_options_set" {
  domain_name         = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS", ]
  tags                = merge(local.tags, { Name = "${local.name_prefix}-dhcp" })
}

resource "aws_vpc_dhcp_options_association" "association" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options_set.id
}

##############################
## Internet Gatewat Default ##
##############################
resource "aws_internet_gateway" "gw_default" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "${local.name_prefix}-igw" })
}

#########################
## Default route table ##
#########################
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  tags                   = merge(local.tags, { Name = "${local.name_prefix}-default-dont-use" })
}

########################################################
## Main (Public) Route Table associated with VPC.  1A ##
########################################################
resource "aws_route_table" "rt_public_1a" {
  vpc_id = aws_vpc.main.id

  route = [
    {
      cidr_block = var.rt_public_route1_cidr_block
      gateway_id = aws_internet_gateway.gw_default.id

      carrier_gateway_id         = null
      destination_prefix_list_id = null
      egress_only_gateway_id     = null
      instance_id                = null
      ipv6_cidr_block            = null
      local_gateway_id           = null
      nat_gateway_id             = null
      network_interface_id       = null
      transit_gateway_id         = null
      vpc_endpoint_id            = null
      vpc_peering_connection_id  = null
      core_network_arn           = null
    },
  ]
  tags = merge(local.tags, { Name = "${local.name_prefix}-public-1a" })
}


########################################################
## Main (Public) Route Table associated with VPC.  1B ##
########################################################
resource "aws_route_table" "rt_public_1b" {
  vpc_id = aws_vpc.main.id

  route = [
    {
      cidr_block = var.rt_public_route1_cidr_block
      gateway_id = aws_internet_gateway.gw_default.id

      carrier_gateway_id         = null
      destination_prefix_list_id = null
      egress_only_gateway_id     = null
      instance_id                = null
      ipv6_cidr_block            = null
      local_gateway_id           = null
      nat_gateway_id             = null
      network_interface_id       = null
      transit_gateway_id         = null
      vpc_endpoint_id            = null
      vpc_peering_connection_id  = null
      core_network_arn           = null
    },
  ]
  tags = merge(local.tags, { Name = "${local.name_prefix}-public-1b" })
}

########################################################
## Main (Public) Route Table associated with VPC.  1C ##
########################################################
resource "aws_route_table" "rt_public_1c" {
  vpc_id = aws_vpc.main.id

  route = [
    {
      cidr_block = var.rt_public_route1_cidr_block
      gateway_id = aws_internet_gateway.gw_default.id

      carrier_gateway_id         = null
      destination_prefix_list_id = null
      egress_only_gateway_id     = null
      instance_id                = null
      ipv6_cidr_block            = null
      local_gateway_id           = null
      nat_gateway_id             = null
      network_interface_id       = null
      transit_gateway_id         = null
      vpc_endpoint_id            = null
      vpc_peering_connection_id  = null
      core_network_arn           = null
    },
  ]
  tags = merge(local.tags, { Name = "${local.name_prefix}-public-1c" })
}

#########################################################
## Main (PRIVATE) Route Table associated with VPC.  1A ##
#########################################################

resource "aws_route_table" "rt_private_1a" {
  vpc_id = aws_vpc.main.id

  route = flatten([
    [
      {
        nat_gateway_id             = aws_nat_gateway.nat_gateway_1a.id
        cidr_block                 = "0.0.0.0/0"
        carrier_gateway_id         = null
        destination_prefix_list_id = null
        egress_only_gateway_id     = null
        gateway_id                 = null
        instance_id                = null
        ipv6_cidr_block            = null
        local_gateway_id           = null
        network_interface_id       = null
        transit_gateway_id         = null
        vpc_endpoint_id            = null
        vpc_peering_connection_id  = null
        core_network_arn           = null
      }
    ],
    var.extra_routes_a
  ])
  tags = merge(local.tags, { Name = "${local.name_prefix}-private-1a" })
}



#########################################################
## NAT Gateway associated with Private Route Table. 1A ##
#########################################################
resource "aws_nat_gateway" "nat_gateway_1a" {
  subnet_id     = aws_subnet.subnet_public_1a.id
  allocation_id = aws_eip.eip_1a.id
  tags          = merge(local.tags, { Name = "${local.name_prefix}-nat-1a" })

  depends_on = [aws_internet_gateway.gw_default]
}

################################################
## Elastic IP associated with NAT Gateway. 1A ##
################################################
resource "aws_eip" "eip_1a" {
  domain = "vpc"
  tags   = merge(local.tags, { Name = "${local.name_prefix}-nat-1a" })
}


#########################################################
## Main (PRIVATE) Route Table associated with VPC.  1B ##
#########################################################

resource "aws_route_table" "rt_private_1b" {
  vpc_id = aws_vpc.main.id

  route = flatten([
    [
      {
        nat_gateway_id             = aws_nat_gateway.nat_gateway_1b.id
        cidr_block                 = "0.0.0.0/0"
        carrier_gateway_id         = null
        destination_prefix_list_id = null
        egress_only_gateway_id     = null
        gateway_id                 = null
        instance_id                = null
        ipv6_cidr_block            = null
        local_gateway_id           = null
        network_interface_id       = null
        transit_gateway_id         = null
        vpc_endpoint_id            = null
        vpc_peering_connection_id  = null
        core_network_arn           = null
      }
    ],
    var.extra_routes_b
  ])
  tags = merge(local.tags, { Name = "${local.name_prefix}-private-1b" })
}

#####################################################
## NAT Gateway associated with Private Route Table ##
#####################################################
resource "aws_nat_gateway" "nat_gateway_1b" {
  subnet_id     = aws_subnet.subnet_public_1b.id
  allocation_id = aws_eip.eip_1b.id
  tags          = merge(local.tags, { Name = "${local.name_prefix}-nat-1b" })

  depends_on = [aws_internet_gateway.gw_default]
}

############################################
## Elastic IP associated with NAT Gateway ##
############################################
resource "aws_eip" "eip_1b" {
  domain = "vpc"
  tags   = merge(local.tags, { Name = "${local.name_prefix}-nat-1b" })
}

#########################################################
## Main (PRIVATE) Route Table associated with VPC.  1B ##
#########################################################

resource "aws_route_table" "rt_private_1c" {
  vpc_id = aws_vpc.main.id

  route = flatten([
    [
      {
        nat_gateway_id             = aws_nat_gateway.nat_gateway_1c.id
        cidr_block                 = "0.0.0.0/0"
        carrier_gateway_id         = null
        destination_prefix_list_id = null
        egress_only_gateway_id     = null
        gateway_id                 = null
        instance_id                = null
        ipv6_cidr_block            = null
        local_gateway_id           = null
        network_interface_id       = null
        transit_gateway_id         = null
        vpc_endpoint_id            = null
        vpc_peering_connection_id  = null
        core_network_arn           = null
      }
    ],
    var.extra_routes_c
  ])
  tags = merge(local.tags, { Name = "${local.name_prefix}-private-1c" })
}

########################################################
## NAT Gateway associated with Private Route Table 1C ##
########################################################
resource "aws_nat_gateway" "nat_gateway_1c" {
  subnet_id     = aws_subnet.subnet_public_1c.id
  allocation_id = aws_eip.eip_1c.id
  tags          = merge(local.tags, { Name = "${local.name_prefix}-nat-1c" })

  depends_on = [aws_internet_gateway.gw_default]
}

###############################################
## Elastic IP associated with NAT Gateway 1C ##
###############################################
resource "aws_eip" "eip_1c" {
  domain = "vpc"
  tags   = merge(local.tags, { Name = "${local.name_prefix}-nat-1c" })
}

############################################
## Private and public association a and b ##
############################################
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.subnet_private_1a.id
  route_table_id = aws_route_table.rt_private_1a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.subnet_private_1b.id
  route_table_id = aws_route_table.rt_private_1b.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.subnet_private_1c.id
  route_table_id = aws_route_table.rt_private_1c.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.subnet_public_1a.id
  route_table_id = aws_route_table.rt_public_1a.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.subnet_public_1b.id
  route_table_id = aws_route_table.rt_public_1b.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.subnet_public_1c.id
  route_table_id = aws_route_table.rt_public_1c.id
}

##################################
## 3 Public & 3 Private Subnets ##
##################################
resource "aws_subnet" "subnet_public_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_public_1a_cidr_block
  availability_zone = "${local.region}a"

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-public-1a",
    Tier = "Public"
  })

}

resource "aws_subnet" "subnet_public_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_public_1b_cidr_block
  availability_zone = "${local.region}b"
  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-public-1b",
      Tier = "Public"
    }
  )

}

resource "aws_subnet" "subnet_public_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_public_1c_cidr_block
  availability_zone = "${local.region}c"
  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-public-1c",
      Tier = "Public"
    }
  )

}

resource "aws_subnet" "subnet_private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_1a_cidr_block
  availability_zone = "${local.region}a"

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-private-1a",
    Tier = "Private"
  })
}

resource "aws_subnet" "subnet_private_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_1b_cidr_block
  availability_zone = "${local.region}b"

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-private-1b",
    Tier = "Private"
  })
}

resource "aws_subnet" "subnet_private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_1c_cidr_block
  availability_zone = "${local.region}c"

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-private-1c",
    Tier = "Private"
  })

}

##################################
## RESOURCES DEFAULT ACL AND SG ##
##################################
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id
  subnet_ids = [
    aws_subnet.subnet_public_1a.id,
    aws_subnet.subnet_public_1b.id,
    aws_subnet.subnet_public_1c.id,
    aws_subnet.subnet_private_1a.id,
    aws_subnet.subnet_private_1b.id,
    aws_subnet.subnet_private_1c.id,
  ]
  tags = merge(local.tags, { Name = "acl-deafult-${local.name_prefix}-dont-use" })

  egress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    icmp_code  = 0
    icmp_type  = 0
    protocol   = "-1"
    rule_no    = 100
    to_port    = 0
  }

  ingress {
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 22
    icmp_code  = 0
    icmp_type  = 0
    protocol   = 6
    rule_no    = 96
    to_port    = 22
  }
  ingress {
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 3389
    icmp_code  = 0
    icmp_type  = 0
    protocol   = 6
    rule_no    = 97
    to_port    = 3389
  }


  ingress {
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    icmp_code  = 0
    icmp_type  = 0
    protocol   = 6
    rule_no    = 98
    to_port    = 22
  }
  ingress {
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 3389
    icmp_code  = 0
    icmp_type  = 0
    protocol   = 6
    rule_no    = 99
    to_port    = 3389
  }

  ingress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    icmp_code  = 0
    icmp_type  = 0
    protocol   = "-1"
    rule_no    = 100
    to_port    = 0
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "${local.name_prefix}-default-dont_use" })
}

########################
## Logs in Cloudwatch ##
########################

resource "aws_kms_key" "cloudwatch" {
  enable_key_rotation                = true
  tags                               = local.tags
  bypass_policy_lockout_safety_check = true
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "key-default-1",
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogsAccess"
        Effect = "Allow"
        Principal = {
          Service = "logs.${local.region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/logs/*"
          },
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}


resource "aws_kms_alias" "cloudwatch" {
  name          = "alias/cloudwatch-loggroup/${local.name_prefix}"
  target_key_id = aws_kms_key.cloudwatch.key_id
}

resource "aws_cloudwatch_log_group" "vpc" {
  depends_on        = [aws_kms_key.cloudwatch]
  name              = "/aws/vpc/logs/${local.name_prefix}"
  retention_in_days = 400
  tags              = local.tags
  kms_key_id        = aws_kms_key.cloudwatch.arn
}

resource "aws_flow_log" "vpc" {
  iam_role_arn    = aws_iam_role.vpc.arn
  log_destination = aws_cloudwatch_log_group.vpc.arn
  traffic_type    = "REJECT"
  vpc_id          = aws_vpc.main.id
  tags            = merge(local.tags, { Name = "vpc-${local.name_prefix}-cloud-watch-logs" })
}

######################
## VPC ENDPOINT EC2 ##
######################
resource "aws_security_group" "sg-principal" {
  #checkov:skip=CKV_AWS_260:"Public range"
  name        = "${local.name_prefix}-sg-principal"
  description = "Principal security group for ${local.name_prefix}"
  vpc_id      = aws_vpc.main.id
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "10.17.0.0/16",
      ]
      description      = "All traffic from VPC Tigo"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "FOR HTTPS"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = 6
      security_groups  = []
      self             = false
      to_port          = 443
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "FOR HTTP"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = 6
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks = [
        var.vpc_cidr_block,
      ]
      description      = "All traffic from ${local.name_prefix}"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  tags = merge(local.tags, { Name = "${local.name_prefix}-vpc-endpoints" })
}

resource "aws_vpc_endpoint" "ec2" {
  depends_on          = [aws_route_table.rt_private_1a, aws_route_table.rt_private_1b, aws_route_table.rt_private_1c]
  count               = length(var.vpcEndpoints)
  private_dns_enabled = true
  route_table_ids     = []
  security_group_ids = [
    aws_security_group.sg-principal.id,
  ]
  service_name      = "com.amazonaws.${local.region}.${var.vpcEndpoints[count.index]}"
  subnet_ids        = var.vpcEndpoints[count.index] == "ssm-contacts" ? [aws_subnet.subnet_private_1a.id] : [aws_subnet.subnet_private_1a.id, aws_subnet.subnet_private_1b.id, aws_subnet.subnet_private_1c.id]
  tags              = merge(local.tags, { Name = "${local.name_prefix}-${var.vpcEndpoints[count.index]}" })
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.main.id
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  timeouts {}
}

####################
## VPC GATEWAY S3 ##
####################
resource "aws_vpc_endpoint" "s3" {
  private_dns_enabled = false
  route_table_ids = [
    aws_route_table.rt_private_1a.id,
    aws_route_table.rt_private_1b.id,
    aws_route_table.rt_private_1c.id,
  ]
  service_name      = "com.amazonaws.${local.region}.s3"
  tags              = merge(local.tags, { Name = "${local.name_prefix}-s3" })
  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.main.id
  policy = jsonencode(
    {
      Version = "2008-10-17",
      Statement = [
        {
          Action    = "*"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "*"
        },
      ]
    }
  )
  timeouts {}
}

resource "aws_iam_role" "vpc" {
  name               = "role-${local.name_prefix}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc" {
  name = "policy-${local.name_prefix}"
  role = aws_iam_role.vpc.id
  #tfsec:ignore:aws-iam-no-policy-wildcards
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_cloudwatch_log_group.vpc.arn}:*",
        "${aws_cloudwatch_log_group.vpc.arn}"
      ]
    }
  ]
}
EOF
}
