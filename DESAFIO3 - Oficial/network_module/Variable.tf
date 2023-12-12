# Bloco de Variáveis Locais do Terraform
locals {
  subnet_names = ["AppGateway", "Firewall", "Other"]
  subnet_cidr_base = "10.0.0.0/8"
  subnet_prefix_lengths = [24, 24, 24]
}