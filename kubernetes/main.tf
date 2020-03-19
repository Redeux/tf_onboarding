provider "kubernetes" {

}

provider "helm" {

}

resource "kubernetes_namespace" "tfc-operator" {
    metadata {
        name = "tfc-operator"
    }
}

resource "kubernetes_secret" "tfc-api-token" {
    metadata {
        name = "terraformrc"
        namespace = kubernetes_namespace.tfc-operator.metadata[0].name
    }

    data = {
        credentials = file("/Users/philsautter/Code/tfc/tf-eco-k8s-vmw/credentials")
    }
}

resource "kubernetes_secret" "workspace-secret" {
    metadata {
        name = "workspacesecrets"
        namespace = kubernetes_namespace.tfc-operator.metadata[0].name
    }

    data = {
        secret_key = "abc123"
    }
}

resource "helm_release" "tfc-operator-helm" {
    name = "tfc-operator-release"
    namespace = kubernetes_namespace.tfc-operator.metadata[0].name
    chart = "/Users/philsautter/Code/terraform-helm"
    timeout = 1200
}