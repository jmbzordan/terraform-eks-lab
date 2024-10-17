# Monta um map com n keys para cada availability zone, conforme quantidade informada na variável subnet_per_az
locals {                                                        
   subnets = { for idx, subnet in flatten(
                [ for az, count in var.subnet_per_az : 
                   [ for i in range(count) : { az = az, subnet_num  = i }]
                ]) : "${subnet.az}-${subnet.subnet_num}" => subnet }

/*
Passos do local.subnets:
EXEMPLO
input:
subnet_per_az = {
    "sa-east-1a" = 2  # x subnets para AZ 'a'
    "sa-east-1b" = 2  # y subnets para AZ 'b'
    "sa-east-1c" = 2  # z subnets para AZ 'c'
}
output: 
{ "sa-east-1a-0" = { az = "sa-east-1a", subnet_num = 0 },
  "sa-east-1a-1" = { az = "sa-east-1a", subnet_num = 1 },
  "sa-east-1b-0" = { az = "sa-east-1b", subnet_num = 0 },
  "sa-east-1b-1" = { az = "sa-east-1b", subnet_num = 1 },
  "sa-east-1c-0" = { az = "sa-east-1c", subnet_num = 0 },
  "sa-east-1c-1" = { az = "sa-east-1c", subnet_num = 1 } }
*/


 #Local que monta um map com a route table e a subnet ID privada na mesma AZ da subnet associada ao nat gateway da route table e que devem ser utilizadas na route table association
  rt_subnet_az = { for idx,subnet in aws_subnet.private_subnets : idx => 
                    [ for key,rt in aws_route_table.private_route_table : 
                       { rt=rt.id, subnet=subnet.id } if rt.tags["AZ"] == subnet.availability_zone][0] }

#Exemplo de output do local:
/*
rt_subnet_az = {
  "0" = { "rt" = "rtb-0449539498bceff37", "subnet" = "subnet-075620ac76f3fc31e" }
  "1" = { "rt" = "rtb-0449539498bceff37", "subnet" = "subnet-0e513052e60ffc56e" }
  "2" = { "rt" = "rtb-0449539498bceff37", "subnet" = "subnet-0a6c67a0d5f4981de" }
  "3" = { "rt" = "rtb-038d84a2cbd2723a3", "subnet" = "subnet-0b3183076d2a8f899" }
  "4" = { "rt" = "rtb-038d84a2cbd2723a3", "subnet" = "subnet-059fb5d68bf85da23" }
  "5" = { "rt" = "rtb-038d84a2cbd2723a3", "subnet" = "subnet-083592832f563b9ad" }
  */
  #Transforma o mapa de subnets publica em uma lista de subnet IDs utilizada na declaração do cluster EKS
  public_subnet_list = [ for key,value in aws_subnet.public_subnets : value.id ]
  
  private_subnet_list = [ for key,value in aws_subnet.private_subnets : value.id ]
}
