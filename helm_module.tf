# Test renovate update

module "eks_blueprints_addon" {
  source = "aws-ia/eks-blueprints-addon/aws"
  version = "~> 1.0" #ensure to update this to the latest/desired version

  chart         = "metrics-server"
  chart_version = "3.8.2"
  repository    = "https://kubernetes-sigs.github.io/metrics-server/"
  description   = "Metric server helm Chart deployment configuration"
  namespace     = "kube-system"

  values = [
    <<-EOT
      podDisruptionBudget:
        maxUnavailable: 1
      metrics:
        enabled: true
    EOT
  ]

  set = [
    {
      name  = "replicas"
      value = 3
    }
  ]
}

module "prometheus_operator_crds" {
  source = "./modules/addon"

  create = var.create_addons && var.enable_prometheus_stack

  chart         = "prometheus-operator-crds"
  chart_version = "13.0.2"
  repository    = "https://prometheus-community.github.io/helm-charts"
  description   = "Prometheus Operator CRDs"
  namespace     = local.monitoring_namespace

  create_namespace = true

  depends_on = [
    module.eks
  ]
}
