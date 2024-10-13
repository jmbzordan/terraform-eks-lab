# Monta um map com n keys para cada availability zone, conforme quantidade informada na variável subnet_per_az
locals {                                                        
  subnets = {
    for idx, subnet in flatten([for az, count in var.subnet_per_az : [for i in range(count) : { az = az, subnet_num  = i }]]) : "${subnet.az}-${subnet.subnet_num}" => subnet}

    #for_each         = aws_subnet.private_subnets
      #route_table_id = aws_route_table.private_routez_table.id
      #subnet_id      = "${each.value.id}"

  rt_subnet_az = { for idx,subnet in aws_subnet.private_subnets : subnet.id => [for key,rt in aws_route_table.private_route_table : rt.id if rt.tags["AZ"] == subnet.availability_zone][0] }
  
}
/*
Passos do local.subnets:
EXEMPLO
input:
subnet_per_az = {
    "sa-east-1a" = 2  # x subnets para AZ 'a'
    "sa-east-1b" = 2  # y subnets para AZ 'b'
    "sa-east-1c" = 2  # z subnets para AZ 'c'
}
depois dos dois fors internos:
[ { az = "sa-east-1a", subnet_num = 0 },
  { az = "sa-east-1a", subnet_num = 1 },
  { az = "sa-east-1b", subnet_num = 0 },
  { az = "sa-east-1b", subnet_num = 1 },
  { az = "sa-east-1c", subnet_num = 0 },
  { az = "sa-east-1c", subnet_num = 1 } ] 

Depois do for externo:
{ "sa-east-1a-0" = { az = "sa-east-1a", subnet_num = 0 },
  "sa-east-1a-1" = { az = "sa-east-1a", subnet_num = 1 },
  "sa-east-1b-0" = { az = "sa-east-1b", subnet_num = 0 },
  "sa-east-1b-1" = { az = "sa-east-1b", subnet_num = 1 },
  "sa-east-1c-0" = { az = "sa-east-1c", subnet_num = 0 },
  "sa-east-1c-1" = { az = "sa-east-1c", subnet_num = 1 } }
*/
   
  /* # LOCALS NÃO MAIS UTILIZADOS
  # Porém ficam salvos para aprendizado
  
  # Monta um map de subnets privadas, baseado no argumento booleano map_public_ip_on_launch que é definida como true se a subnet for publica
  ##### Como o map de subnets foi dividido, esse local não será mais utilizado #####
  public_subnets = {
    for name,subnet in aws_subnet.subnet_list : 
      "${name}" => subnet if subnet.map_public_ip_on_launch
  }
  
  # Monta um map de subnets privadas, baseado no argumento booleano map_public_ip_on_launch que é definida como true se a subnet for publica
  ##### Como o map de subnets foi dividido, esse local não será mais utilizado #####
  private_subnets = {
    for name,subnet in aws_subnet.subnet_list : 
      "${name}" => subnet if !subnet.map_public_ip_on_launch        # ! testa se variavel é false
  }*/