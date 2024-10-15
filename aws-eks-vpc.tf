#VERIFICAR ARQUIVO aws-vpc-reqs.txt PARA REQUISITOS DE VPC PARA EKS DA AWS

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true                #VPC necessita DNS hostname e suporte DNS para os nodes conseguirem se registrar no cluster
  enable_dns_support   = true
  tags                 = { Name = "${var.project_name}-vpc" }
}


resource "aws_subnet" "public_subnets" {
  for_each                   = { for key,value in local.subnets : key => value if value.subnet_num == 0 }
     vpc_id                  = aws_vpc.vpc.id
     cidr_block              = cidrsubnet( var.cidr_block, 8, (each.value.subnet_num * 2) + index(var.availability_zones, each.value.az) ) 
     availability_zone       = each.value.az
     map_public_ip_on_launch = true
     tags                    = { 
                                 Name = "${var.project_name}-subnet-${each.value.az}-pub-${each.value.subnet_num + 1}",
                                 "kubernetes.io/role/elb" = 1 
                               }
}


resource "aws_subnet" "private_subnets" {
  for_each                   = { for key,value in local.subnets : key => value if value.subnet_num != 0 }
     vpc_id                  = aws_vpc.vpc.id
     cidr_block              = cidrsubnet( var.cidr_block, 8, (each.value.subnet_num * 2) + index(var.availability_zones, each.value.az) ) 
     availability_zone       = each.value.az
     map_public_ip_on_launch = false
     tags                    = { 
                                 Name = "${var.project_name}-subnet-${each.value.az}-priv-${each.value.subnet_num + 1}",
                                 "kubernetes.io/role/internal-elb" = 1 
                               }
}


# Cria internet gateway que será associada as subnets publicas nas route tables, para rotas externas
# É criado somente um para toda a VPC
resource "aws_internet_gateway" "igateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "${var.project_name}-internet-gateway" }
}


# Toda nat_gateway necessita se atrelada a um elastic IP. Logo, cria-se tantos quantos for o número de nat_gateways (CARAI TA CERTA ESSA FRASE?)
resource "aws_eip" "elastic_ips" {
  for_each  = { for idx,az in var.availability_zones : idx => az }
     domain = "vpc"
     tags   = { Name = "${var.project_name}-elastic-ip-${each.value}" }
}


# Nat gateway são utilizadas pelas subnets privadas para chegar ao internet gateway e ter acesso externo. É criada uma para cada availability zone
# sendo utilizada como rota para todas as subnets daquela availability zone. OBS: São criadas nas subnets publicas!!
resource "aws_nat_gateway" "ngateway" {
  for_each         = { for idx,az in var.availability_zones : idx => az }
     allocation_id = aws_eip.elastic_ips[each.key].allocation_id
     subnet_id     = values(aws_subnet.public_subnets)[each.key].id 
     tags          = { 
                       Name = "${var.project_name}-nat-gateway-${each.value}",
                       "AZ" = "${each.value}" 
                     }
}


# Route Table publica da VPC, associada ao cidr 0.v.0.0/0 que é o da internet
resource "aws_route_table" "public_route_table" {
  vpc_id       = aws_vpc.vpc.id
  route { 
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igateway.id
  }
  tags         = { Name = "${var.project_name}-public-routetable" }
}


# Route Table privada da VPC, ASSOCIA-SE AS NAT_GATEWAYS??? NAO SEI AINDA
resource "aws_route_table" "private_route_table" {
  for_each            = aws_nat_gateway.ngateway
     vpc_id           = aws_vpc.vpc.id
     route {
       cidr_block     = "0.0.0.0/0"
       nat_gateway_id = each.value.id
     }
     tags             = { 
                          Name = "${var.project_name}-private-routetable-${each.value.tags["AZ"]}" 
                          "AZ" = "${each.value.tags["AZ"]}" 
                        }
}


# Cria dinamicamente as rtas publicas conforme mapa de subnets que possuem o parametro map_public_ip_on_launch ativado
 # # Possibilidade de iterar diretamente sem o locals, porém menos elegante.
 # for_each = { for key,value in aws_subnet.subnet_list : key => value if value.map_public_ip_on_launch }
resource "aws_route_table_association" "public_rta" {
  for_each          = aws_subnet.public_subnets
     route_table_id = aws_route_table.public_route_table.id
     subnet_id      = "${each.value.id}"
}

# Cria dinamicamente as rtas privadas conforme mapa de subnets quem não possuem o parametro map_public_on_launch ativado
 # # Possibilidade de iterar diretamente sem o locals, porém menos elegante

resource "aws_route_table_association" "private_rta" {
  for_each         = local.rt_subnet_az
    subnet_id      = each.value.subnet
    route_table_id = each.value.rt
}

/*
resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.vpc.id
  name   = "eks-securitygroup"
  tags   = { Name = "${var.project_name}-security-group" }
}
*/