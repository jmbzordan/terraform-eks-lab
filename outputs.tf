/*# Debug para printar a lista de subnets criadas
output "subnet_list" {
  description = "Imprime a lista de subnets criadas para a VPC do cluster k8s"
  value = {for key,value in aws_subnet.subnet_list : key => value}
}
*/
/*
output "route_tables" {
  description = "Imprime a Route Table criada"
  value = {for key,value in aws_route_table_association.public_rta : key => value}
}
*/
# Imprime os IDs das subnets criadas
output "public_subnets" {
   value = {for key,value in aws_subnet.public_subnets : key => value}
}

output "private_subnets" {
   value = {for key,value in aws_subnet.private_subnets : key => value}
}
/*
# debug de tentativa de criaçao dinamica de lista de subnets
output "subnets_list" {
  value = local.subnets
}
*/


/*
output "routes" {
  description = "route tables"
  value = [for i in aws_route_table.routetable : aws_route_table.routetable]
}
*/