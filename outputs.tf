/*output "private_subnets" {
  value = aws_subnet.private_subnets[*].id
}
*/
/*
output "public_subnet" {
  value = { for idx,value in local.rt_subnet_az : value.rt => value.subnet  }
}*/
/*
output "nat_az" {
  value = local.subnet_rt_map
}
*/
/*
output "rt_subnet_association" {
  value = local.rt_subnet_az
}
*/
/*
output "nat_gateways" {
  value = aws_nat_gateway.ngateway 
}
*/
/*
output "subnet_nats" {
  value = local.matching_subnets
}
*/
##### OUTPUTS PARA DEBUG #####
/*
# Imprime as subnets PUBLICAS criadas
output "public_subnets" {
   value = {for key,value in aws_subnet.public_subnets : key => value}
}
*/
/*
# Imprime as subnets PRIVADAS criadas
output "private_subnets" {
   value = {for key,value in aws_subnet.private_subnets : key => value}
}
*/
/*
# Imprime o resultado dos 3 for aninhados do local.subnets
output "subnets_list" {
  value = { for key,value in local.subnets : key => value if value.subnet_num == 0 }
}
*/
/*
output "routes" {
  description = "route tables"
  value = aws_route_table.private_route_table
}
*/

/*# Debug para printar a lista dinamica de TODAS subnets criadas
  # NÃO É MAIS UTILIZADO!!! Porém o resource dinamica está comentado em aws-eks-vpc.tf
output "subnet_list" {
  description = "Imprime a lista de subnets criadas para a VPC do cluster k8s"
  value = {for key,value in aws_subnet.subnet_list : key => value}
}
*/
