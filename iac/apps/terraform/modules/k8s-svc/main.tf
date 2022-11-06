resource "kubernetes_deployment" "app_deployment" {
  metadata {
    name      = var.appname
    namespace = var.namespace
  }

  spec {
    selector {
      match_labels = {
        app = var.appname
      }
    }
    template {
      metadata {
        labels = {
          app = var.appname
        }
      }
      spec {
        container {
          name  = var.appname
          image = var.image
          
          liveness_probe {
            http_get {
              path = "/actuator/health"
              port = "http"
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
        }
      }
      
    }
  }
  
}
