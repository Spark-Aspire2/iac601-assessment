### Variables Declaration ###############
variable "rg_name" {
  description = "resource group name"
  default     = "SparkIAC-rg"
}

variable "location" {
  description = "location of resource group"
  default     = "Australia East"
}

variable "vnet_1_name" {
  description = "name of network"
  default     = "SparkIAC.vnet"
}

variable "vnet_1_cidr" {
  description = "Network range"
  default     = ["10.10.0.0/16"]
}

variable "subnet_1_name" {
  description = "name of sub-network"
  default     = "Subnet-1-Spark"
}
variable "subnet_1_cidr" {
  description = "subnet range"
  default     = ["10.10.0.0/24"]
}
variable "subnet_2_name" {
  description = "name of sub-network"
  default     = "Subnet-2-Spark"
}
variable "subnet_2_cidr" {
  description = "subnet range"
  default     = ["10.10.1.0/24"]
}


variable "admin_username" {
  default = "spark"
}
variable "admin_password" {

}

variable "public_ip_1_name" {
  default = "SparkIAC-public-ip"
}

variable "network_interface_1_name" {
  default = "SparkIAC-nic"
}

variable "security_group_name" {
  default = "SparkIAC-nsg"
}

variable "virtual_machine_1_name" {
  default = "SparkIAC-vm"
}

variable "time_zone" {
  default = "New Zealand Standard Time"
}

variable "mysql_root" {
  default = "spark"
}

variable "mysql_password" {

}

variable "mysql_dns_name" {
  default = "SparkIAC.mysql.database.azure.com"
}

variable "dns_network_link_name" {
  default = "dns-network-link"
}

variable "mysql_server_name" {
  default = "Spark-mysqlfs-iac601"
}