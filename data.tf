
# Este arquivo contém data sources para buscar recursos criados dinamicamente.

# Data source para buscar ALB criado pelo AWS Load Balancer Controller
# Comentado temporariamente até que o ingress seja deployado
# data "aws_lb" "ingress_alb" {
#   depends_on = [null_resource.container_insights_auto]
#
#   tags = {
#     "elbv2.k8s.aws/cluster" = module.eks.k8s_name
#     "ingress.k8s.aws/stack" = "default/nginx-ingress"
#   }
# }


# Data source para pegar AZs disponíveis
data "aws_availability_zones" "available" {
  state = "available"
}
