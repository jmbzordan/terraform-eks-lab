# variável que define a quantidade de réplicas de um resource que serão criadas. Esse número é comum a recursos como
# private e public subnets, availability zones, nodes kubernetes
/*variable "availability_zones" {
  description = "Lista de Availability Zones com a quantidade de subnets desejadas para cada zone"
  type = map(number)

  default = {}
}*/

variable "project_name" {
  description = "Nome do projeto utilizado para nomear as tags Name dos resources"
  type        = string
}

variable "subnet_per_az" {
  description = "Define o número de subnets por availability zone"
  type        = map(number)
}

variable "availability_zones" {
  description = "Lista de availability zones"
  type        = list(string)
}

variable "cidr_block" {
  description = "CDIR block de rede informada para criação da VPC" 
  type        = string
}

variable "ami_id" {
  description = "Image id das instancias que serão criadas no ASG"
  type        = string  
}

variable "ec2_types" {
  description = "Tipos das instancia ec2 que serao criadas no ASG"
  type        = list(map(string))
}