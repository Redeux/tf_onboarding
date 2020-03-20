provider "kubernetes" {}

resource "kubernetes_namespace" "greetings" {
    metadata {
        name = "greetings"
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