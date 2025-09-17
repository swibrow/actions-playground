terraform {
  backend "s3" {
    region = "eu-central-1"
  }
}

resource "random_pet" "this" {
  length = 2
}

resource "random_id" "this" {
  byte_length = 4
}

output "random_pet" {
  value = random_pet.this.id
}

output "random_id" {
  value = random_id.this.id
}

output "test" {
  value = "Test"
}

module "k8s_platform" {
  source  = "tx-pts-dai/kubernetes-platform/aws"
  version = "5.0.2+1.33"

  name = var.name

  cluster_admins = {
    cicd = {
      role_name = "cicd-iac"
    }
  }

  tags = var.tags

  vpc = {
    vpc_id          = local.vpc_id
    private_subnets = local.private_subnets
    intra_subnets   = local.intra_subnets
  }

  karpenter = {
    subnet_cidrs     = data.terraform_remote_state.network.outputs.network.grouped_networks.platform_stack_1
    replicas         = var.karpenter_replicas
    data_volume_size = var.karpenter_data_volume_size
    pod_annotations = {
      "ad.datadoghq.com/controller.checks" = jsonencode(
        {
          "karpenter" : {
            "init_config" : {},
            "instances" : [{ "openmetrics_endpoint" : "http://%%host%%:8000/metrics" }]
          }
        }
      )
    }
    memory_request = "768Mi"
  }

  enable_downscaler = var.enable_downscaler
}
