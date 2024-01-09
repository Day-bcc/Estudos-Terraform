
# Terraform Modules

#Ambiente HUB
module "Ambiente_HUB" {
  source = "./Ambiente_HUB"
  depends_on = [module.Ambiente_HML,module.Ambiente_DEV,module.Ambiente_PRD]
}
output "rg_ids_hub1" {
  value = module.Ambiente_HUB.rg_ids_hub1
}
output "rg_ids_hub2" {
  value = module.Ambiente_HUB.rg_ids_hub2
}
output "rg_ids_hub3" {
  value = module.Ambiente_HUB.rg_ids_hub3
}
output "vnet_ids_hub1" {
  value = module.Ambiente_HUB.vnet_ids_hub1
}
output "vnet_ids_hub2" {
  value = module.Ambiente_HUB.vnet_ids_hub2
}
output "vnet_ids_hub3" {
  value = module.Ambiente_HUB.vnet_ids_hub3
}

#Ambiente HML
module "Ambiente_HML" {
  source = "./Ambiente_HML"
}
output "rg_ids_hml1" {
  value = module.Ambiente_HML.rg_ids_hml1
}
output "rg_ids_hml2" {
  value = module.Ambiente_HML.rg_ids_hml2
}
output "vnet_ids_hml1" {
  value = module.Ambiente_HML.vnet_ids_hml1
}
output "vnet_ids_hml2" {
  value = module.Ambiente_HML.vnet_ids_hml2
}

#Ambiente DEV
module "Ambiente_DEV" {
  source = "./Ambiente_DEV"
}
output "rg_ids_dev1" {
  value = module.Ambiente_DEV.rg_ids_dev1
}
output "rg_ids_dev2" {
  value = module.Ambiente_DEV.rg_ids_dev2
}
output "vnet_ids_dev1" {
  value = module.Ambiente_DEV.vnet_ids_dev1
}
output "vnet_ids_dev2" {
  value = module.Ambiente_DEV.vnet_ids_dev2
}

#Ambiente PRD
module "Ambiente_PRD" {
  source = "./Ambiente_PRD"
}
output "rg_ids_prd" {
  value = module.Ambiente_PRD.rg_ids_prd
}
output "vnet_ids_prd" {
  value = module.Ambiente_PRD.vnet_ids_prd
}
