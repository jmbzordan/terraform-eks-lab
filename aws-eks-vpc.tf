#VERIFICAR ARQUIVO aws-vpc-reqs.txt PARA REQUISITOS DE VPC PARA EKS DA AWS

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true                #VPC necessita DNS hostname e suporte DNS para os nodes conseguirem se registrar no cluster
  enable_dns_support   = true
  tags                 = { Name = "k8s-vpc" }
}

# Cria dinamicamente um mapa de subnets por availability zone conforme especificado pelo usuario nas variaveis
# Divide igualmente a quantidade de subnets entre publica e privada ---> Possível problema de a quantidade não for multipla de 2 e também não multipla 
# do número de availability Zones. Mas isso no caso de ser utilizado como módulo
resource "aws_subnet" "subnet_list" {
  for_each = local.subnets
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = cidrsubnet("10.0.0.0/16", 8, each.value.subnet_num + index(var.availability_zones, each.value.az) * 2) 
    availability_zone       = each.value.az
    map_public_ip_on_launch = ((((each.value.subnet_num + 1) % 2) == 0) ? false : true)    # Se true a subnet é publica, ou seja, quando um recurso cair nessa subnet, automaticamente ele ganha um IP público. Senão é privado
    tags                    = { Name = "eks-subnet-${each.value.az}-${each.value.subnet_num}" }
}

# Cria internet gateway que será associada as subnets publicas nas route tables, para rotas externas
# É criado somente um para toda a VPC
resource "aws_internet_gateway" "igateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = { Name = "eks-internet-gateway" }
}

# Toda nat_gateway necessita se atrelada a um elastic IP. Logo, cria-se tantos quantos for o número de nat_gateways (CARAI TA CERTA ESSA FRASE?)
resource "aws_eip" "elastic_ip" {
  for_each = {for idx,az in var.availability_zones : idx => az}
    domain = "vpc"
    tags   = { Name = "eks-elastic-ip-${each.value}" }
}


# Nat gateway são utilizadas pelas subnets privadas para chegar ao internet gateway e ter acesso externo. É criada uma para cada availability zone
# sendo utilizada como rota para todas as subnets daquela availability zone. OBS: São criadas nas subnets publicas!!
resource "aws_nat_gateway" "ngateway" {
  count = length(var.availability_zones)
    allocation_id = aws_eip.elastic_ip[count.index].allocation_id
    subnet_id     = values(local.public_subnets)[count.index].id
    tags          = { Name = "k8s-nat-gateway-${count.index}" }
}

#Criação de routetable de forma dinamica. Funciona, mas acredito ser melhor declarar independentemente com nomes public e private
# devido a possivel necessidade de outros resources iterar apenas com as publicas ou apenas com as privadas e não com toda a lista
/*
resource "aws_route_table" "routetable" {
  count = 2
  vpc_id = aws_vpc.vpc.id
  dynamic "route" {
    for_each = (count.index == 0 ? [1] : [])
    content {  
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gateway.id
    }
  }
}
*/

# Route Table publica da VPC, associada ao cidr 0.v.0.0/0 que é o da internet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route { 
    gateway_id = aws_internet_gateway.igateway.id
    cidr_block = "0.0.0.0/0"
  }
  tags = { Name = "eks-public-routetable" }
}

# Route Table privada da VPC, ASSOCIA-SE AS NAT_GATEWAYS??? NAO SEI AINDA
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
#  route {
#    nat_gateway_id = aws_nat_gateway.ngateway.id
#  }
  tags = { Name = "eks-private-routetable" }
}

# Cria dinamicamente as rtas publicas conforme mapa de subnets que possuem o parametro map_public_ip_on_launch ativado
 # # Possibilidade de iterar diretamente sem o locals, porém menos elegante.
 # for_each = { for key,value in aws_subnet.subnet_list : key => value if value.map_public_ip_on_launch }
resource "aws_route_table_association" "public_rta" {
  for_each = local.public_subnets
    route_table_id = aws_route_table.public_route_table.id
    subnet_id      = "${each.value.id}"
}


# Cria dinamicamente as rtas privadas conforme mapa de subnets quem não possuem o parametro map_public_on_launch ativado
 # # Possibilidade de iterar diretamente sem o locals, porém menos elegante.
 # for_each = { for key,value in aws_subnet.subnet_list : key => value if !value.map_public_ip_on_launch }
resource "aws_route_table_association" "private_rta" {
  for_each = local.private_subnets
    route_table_id = aws_route_table.private_route_table.id
    subnet_id      = "${each.value.id}"
}

resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.vpc.id
  name   = "k8s-securitygroup"
  tags   = { Name = "eks-security-group" }
}
