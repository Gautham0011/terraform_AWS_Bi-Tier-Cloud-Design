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

module "rds" {
  source       = "../modules/database"
  project_name = var.project_name
  pvt_subnetA  = module.vpc.priv_subA_id
  pvt_subnetB  = module.vpc.priv_subB_id
  db_sg_id     = module.security.db_sg_id
  db_name      = var.db_name
  db_username  = var.db_username
  db_password  = var.db_password

}

module "alb" {
  source             = "../modules/load_balancer"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_A_id = module.vpc.pub_subA_id
  public_subnet_B_id = module.vpc.pub_subB_id
  alb_sg_id          = module.security.alb_sg_id

  depends_on = [module.rds]

}

module "asg" {
  source             = "../modules/auto_scaling"
  project_name       = var.project_name
  public_subnet_A_id = module.vpc.pub_subA_id
  public_subnet_B_id = module.vpc.pub_subB_id
  target_group_arn   = module.alb.tg_arn
  asg_sg_id          = module.security.asg_sg_id
  enable_autscaling  = true
  server_port        = 80
  db_name            = module.rds.db_name
  db_address         = module.rds.database_host
  db_endpoint        = module.rds.db_endpoint
  db_port            = module.rds.db_port
  db_az              = module.rds.database_az
  replica_name       = module.rds.replica_name
  replica_address    = module.rds.replica_host
  replica_port       = module.rds.replica_port
  replica_az         = module.rds.replica_az



  depends_on = [module.alb]


}