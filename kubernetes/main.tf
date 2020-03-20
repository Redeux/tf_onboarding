provider "kubernetes" {}
provider "helm" {}

resource "kubernetes_namespace" "tfc-operator" {
    metadata {
        name = var.TERRAFORM_K8S_NAMESPACE
    }
    provisioner "local-exec" {
        when = destroy
        command = "kubectl delete crd workspaces.app.terraform.io"
    }
}

resource "kubernetes_secret" "tfc-api-token" {
    metadata {
        name = "terraformrc"
        namespace = kubernetes_namespace.tfc-operator.metadata[0].name
    }

    data = {
        credentials = file(var.TFC_CREDENTIALS)
    }
}

resource "kubernetes_secret" "workspace-secret" {
    metadata {
        name = "workspacesecrets"
        namespace = kubernetes_namespace.tfc-operator.metadata[0].name
    }

    data = {
        AWS_ACCESS_KEY_ID = var.AWS_ACCESS_KEY_ID
        AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
    }
}

resource "helm_release" "tfc-operator-helm" {
    name = var.TERRAFORM_K8S_HELM_RELEASE
    namespace = kubernetes_namespace.tfc-operator.metadata[0].name
    chart = var.TERRAFORM_K8S_HELM_CHART
}