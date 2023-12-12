variable "rg" {
  type = string
  description = "Nome do grupo de recurso"
}


variable "container" {
  type = string
  description = "Nome do container dentro do storage account"
}


variable "blob" {
  type = string
  description = "Nome do blob dentro do storage account"
}


variable "prefix" {
  default = "estudostf"
  type = string
  description = "xxxxxx xxx xxx xx"
}