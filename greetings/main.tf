provider "kubernetes" {}

/*
resource "kubernetes_config_map" "aws-configMap" {
  # This should work but doesn't!
  metadata {
    name      = "greetings-aws-configration"
    namespace = var.OPERATOR_NAMESPACE
  }

  data = {
    region = var.AWS_REGION
  }
}
*/

resource "null_resource" "aws-configMap" {
  # Apply configMap
  provisioner "local-exec" {
    command = "kubectl -n ${var.OPERATOR_NAMESPACE} apply -f configmap.yaml"
  }

  # Delete configMap
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl -n ${var.OPERATOR_NAMESPACE} delete configmap greetings-aws-configuration"
  }
}

resource "null_resource" "workspace" {
  # Deploy Custom Resource
  provisioner "local-exec" {
    command = "kubectl -n ${var.OPERATOR_NAMESPACE} apply -f workspace_registry.yaml"
  }

  # Delete Custom Resource
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl -n ${var.OPERATOR_NAMESPACE} delete workspace greetings"
  }

  depends_on = [
    null_resource.aws-configMap,
  ]
}

resource "kubernetes_job" "greetings" {
  metadata {
    name      = "greetings"
    namespace = var.OPERATOR_NAMESPACE
    labels = {
      app = "greetings"
    }
  }
  spec {
    template {
      metadata {
        labels = {
          app = "greetings"
        }
      }

      spec {
        restart_policy = "Never"
        container {
          name    = "greetings"
          image   = "joatmon08/aws-sqs-test"
          command = ["./message.sh"]
          env {
            name = "QUEUE_URL"
            value_from {
              config_map_key_ref {
                name = "greetings-outputs"
                key  = "url"
              }
            }
          }
          env {
            name = "AWS_DEFAULT_REGION"
            value_from {
              config_map_key_ref {
                name = "greetings-aws-configuration"
                key  = "region"
              }
            }
          }
          volume_mount {
            name       = "sensitivevars"
            mount_path = "/tmp/secrets"
            read_only  = "true"
          }
        }
        volume {
          name = "sensitivevars"
          secret {
            secret_name = "workspacesecrets"
          }
        }
      }
    }
  }

  depends_on = [
    null_resource.workspace,
  ]
}
