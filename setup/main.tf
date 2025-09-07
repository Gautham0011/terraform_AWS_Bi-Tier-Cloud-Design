module "vpc" {
  source           = "../modules/networking"
  project_name     = var.project_name
  aws_region       = var.aws_region
  vpc_cidr         = var.vpc_cidr
  private_subnet_A = var.private_subnet_A
  private_subnet_B = var.private_subnet_B
  public_subnet_A  = var.public_subnet_A
  public_subnet_B  = var.public_subnet_B

}

module "security" {
  source       = "../modules/security_groups"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  pvt_subnetA  = var.private_subnet_A
  pvt_subnetB  = var.private_subnet_B

}

module "alb" {
  source             = "../modules/load_balancer"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_A_id = module.vpc.pub_subA_id
  public_subnet_B_id = module.vpc.pub_subB_id
  alb_sg_id          = module.security.alb_sg_id

}

module "asg" {
  source             = "../modules/auto_scaling"
  project_name       = var.project_name
  public_subnet_A_id = module.vpc.pub_subA_id
  public_subnet_B_id = module.vpc.pub_subB_id
  target_group_arn   = module.alb.tg_arn
  asg_sg_id          = module.security.asg_sg_id
  enable_autscaling  = true

}

module "rds" {
  source       = "../modules/database"
  project_name = var.project_name
  pvt_subnetA  = module.vpc.priv_subA_id
  pvt_subnetB  = module.vpc.priv_subB_id
  db_sg_id     = module.security.db_sg_id
  db_name      = "rds"
  db_username  = var.db_username
  db_password  = var.db_password

}