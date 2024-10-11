
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template#instance-profileTemplate
# Documentacao para resource launch_template
# Template para criação do ASG
/*
resource "aws_launch_template" "asg_template" {
  depends_on = [ 
    aws_vpc.vpc,
    aws_subnet.subnet_list,
    aws_route_table.private_route_table,
    aws_route_table.public_route_table,
    aws_internet_gateway.igateway,
    aws_route_table_association.private_rta,
    aws_route_table_association.public_rta,
    aws_security_group.security_group
  ]
  name                   = "asg-k8s-cluster"
  image_id               = var.ami_id
  #instance_type = var.ec2_type
  #instance_type = "t2.micro"
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = ["${aws_security_group.security_group.id}"]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#launch_template
# Documentacao para resource autoscaling_group
resource "aws_autoscaling_group" "asg" {
  depends_on = [ 
    aws_vpc.vpc,
    aws_subnet.subnet_list,
    aws_route_table.private_route_table,
    aws_route_table.public_route_table,
    aws_internet_gateway.igateway,
    aws_route_table_association.private_rta,
    aws_route_table_association.public_rta,
    aws_security_group.security_group,
    aws_launch_template.asg_template
  ]
  max_size            = 6
  min_size            = 3
  desired_capacity    = 3
  vpc_zone_identifier = values(local.public_subnets_ids)      #vpc_zone_identifier exige uma lista, logo a função value() retorna uma lista dos values de um map

    mixed_instances_policy {
      instances_distribution {
        on_demand_allocation_strategy = "lowest-price"
        #spot_allocation_strategy = "price-capacity-optimized"
      }

      # quando utilizamos o mixed_instances_policy, é obrigatório o uso do launch_template junto com o launch_template_specification
      # além disso, quando utilizamos essa estrutura de mixed_instances, é obrigatório o uso do override caso não declaramos o instance_type no resource launch_template
      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.asg_template.id
          version = "$Latest"
        }
      }
    }
}
*/ 
        # ec2_types é uma lista de maps, logo "override.value" é um map, onde o lookup busca o value da chave "instance_type". Caso não exista, retorna null
/*        dynamic "override" {
          for_each = var.ec2_types
            content {
              instance_type = lookup(override.value, "instance_type", null)
            }
        }*/



/*
O bloco override no contexto do mixed_instances_policy dentro do recurso aws_autoscaling_group do Terraform é utilizado para personalizar a configuração das instâncias dentro de um Auto Scaling Group (ASG) que utiliza uma política de instâncias mistas. Ele permite que você especifique diferentes tipos de instâncias e suas capacidades ponderadas para um mesmo grupo.

Principais Usos do Bloco override
Especificar Tipos de Instâncias: O bloco override permite que você defina tipos específicos de instâncias que serão utilizados dentro do ASG. Isso é útil quando você deseja misturar diferentes tipos de instâncias para atender a requisitos específicos de carga de trabalho.

Definir Capacidade Ponderada: Você pode atribuir uma weighted_capacity a cada tipo de instância. Isso ajuda o AWS Auto Scaling a decidir quantas instâncias de cada tipo serão provisionadas, baseando-se na capacidade ponderada total definida. Isso é especialmente útil em cenários onde você está misturando instâncias com diferentes capacidades.

Personalizar Configurações: O override permite que você ajuste parâmetros de configuração de instâncias, como o tipo de instância, sem alterar o modelo de lançamento subjacente. Isso dá flexibilidade para implementar diferentes tipos de instâncias que podem ter configurações de custo e desempenho variadas.


https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_spot_price
Data Source: aws_ec2_spot_price


https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request
Resource: aws_spot_instance_request


resource "aws_autoscaling_group" "demospot" {
  name_prefix = "demospot"

  desired_capacity = "10"
  max_size = "20"
  min_size = "5"

  capacity_rebalance  = true

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 25
      spot_allocation_strategy                 = "capacity-optimized"
    }

   # lowest-price: Spot instances come from the pool with the lowest price (default)
   # capacity-optimized: Spot instances come from the pool with optimal capacity for the number of instances that need to me launched
   # capacity-optimized-prioritized: It is used to give certain instance types a higher chance of launching first (when the ASG has several instance types configured)

   # Spot instances will be terminated as soon as the spot price goes beyond our bid price, so whatever 
   #   we are running on the instance we need to make sure it can be stopped at any time

   # We might want to adjust the on_demand_base_capacity and on_demand_percentage_above_base_capacity to 
   #   make sure we have a minimum number of on demand instances so the application it is running is not affected when the spot instances are terminated

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.demo.id
        version = "$Latest"
      }
    }
  }

  (...)
}

Principais Usos do Bloco override
Especificar Tipos de Instâncias: O bloco override permite que você defina tipos específicos de instâncias que serão utilizados dentro do ASG. Isso é útil quando você deseja misturar diferentes tipos de instâncias para atender a requisitos específicos de carga de trabalho.

Definir Capacidade Ponderada: Você pode atribuir uma weighted_capacity a cada tipo de instância. Isso ajuda o AWS Auto Scaling a decidir quantas instâncias de cada tipo serão provisionadas, baseando-se na capacidade ponderada total definida. Isso é especialmente útil em cenários onde você está misturando instâncias com diferentes capacidades.

Personalizar Configurações: O override permite que você ajuste parâmetros de configuração de instâncias, como o tipo de instância, sem alterar o modelo de lançamento subjacente. Isso dá flexibilidade para implementar diferentes tipos de instâncias que podem ter configurações de custo e desempenho variadas.

allowed_instance_types - (Optional) List of instance types to apply your specified attributes against. 
All other instance types are ignored, even if they match your specified attributes. You can use strings with one or 
more wild cards, represented by an asterisk (*), to allow an instance type, size, or generation. The following are 
examples: m5.8xlarge, c5*.*, m5a.*, r*, *3*. For example, if you specify c5*, you are allowing the entire C5 instance 
family, which includes all C5a and C5n instance types. If you specify m5a.*, you are allowing all the M5a instance types, 
but not the M5n instance types. Maximum of 400 entries in the list; each entry is limited to 30 characters. Default is all instance types.
*/


