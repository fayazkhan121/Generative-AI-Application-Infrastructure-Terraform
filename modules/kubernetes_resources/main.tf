# Namespace for the application
resource "kubernetes_namespace" "genai_app" {
  metadata {
    name = "genai-app"
    
    labels = {
      name        = "genai-app"
      environment = var.environment
    }
  }
}

# Secret for PostgreSQL credentials
resource "kubernetes_secret" "postgres_credentials" {
  metadata {
    name      = "postgres-credentials"
    namespace = kubernetes_namespace.genai_app.metadata[0].name
  }
  
  data = {
    username = var.postgres_username
    password = var.postgres_password
    host     = var.postgres_host
    port     = var.postgres_port
    dbname   = var.postgres_db_name
  }
  
  type = "Opaque"
}

# Secret for MSK (Kafka) bootstrap servers
resource "kubernetes_secret" "msk_bootstrap_servers" {
  metadata {
    name      = "msk-bootstrap-servers"
    namespace = kubernetes_namespace.genai_app.metadata[0].name
  }
  
  data = {
    bootstrap_servers = var.msk_bootstrap_servers
  }
  
  type = "Opaque"
}

# ConfigMap for application configuration
resource "kubernetes_config_map" "genai_app_config" {
  metadata {
    name      = "genai-app-config"
    namespace = kubernetes_namespace.genai_app.metadata[0].name
  }
  
  data = {
    "config.json" = jsonencode({
      environment           = var.environment
      logLevel              = var.environment == "production" ? "info" : "debug"
      metricsEnabled        = true
      prometheusEndpoint    = var.prometheus_endpoint
      databaseType          = "postgres"
      timeseriesDBType      = "kafka"
      apiBaseUrl            = "/api"
      enableServiceMesh     = var.enable_service_mesh
      enableGpuAcceleration = true
    })
  }
}

# Service account for the application
resource "kubernetes_service_account" "genai_app" {
  metadata {
    name      = "genai-app"
    namespace = kubernetes_namespace.genai_app.metadata[0].name
    
    annotations = {
      "eks.amazonaws.com/role-arn" = var.service_account_role_arn
    }
  }
  
  automount_service_account_token = true
}

# GPU resource quota
resource "kubernetes_resource_quota" "gpu_quota" {
  metadata {
    name      = "gpu-quota"
    namespace = kubernetes_namespace.genai_app.metadata[0].name
  }
  
  spec {
    hard = {
      "requests.nvidia.com/gpu" = var.environment == "production" ? 8 : 2
      "limits.nvidia.com/gpu"   = var.environment == "production" ? 8 : 2
    }
  }
}

# Deployment for the API component
resource "kubernetes_deployment" "genai_api" {
  metadata {
    name      = "genai-api"
    namespace = kubernetes_namespace.genai_app.metadata[0].name
    
    labels = {
      app         = "genai-api"
      component   = "api"
      environment = var.environment
    }
  }
  
  spec {
    replicas = var.environment == "production" ? 3 : 1
    
    selector {
      match_labels = {
        app       = "genai-api"
        component = "api"
      }
    }
    
    template {
      metadata {
        labels = {
          app         = "genai-api"
          component   = "api"
          environment = var.environment
        }
      }
      
      spec {
        service_account_name = kubernetes_service_account.genai_app.metadata[0].name
        
        container {
          name  = "api"
          image = "genai/api:latest"  # Placeholder for the actual image
          
          port {
            container_port = 8080
          }
          
          env {
            name = "POSTGRES_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_credentials.metadata[0].name
                key  = "username"
              }
            }
          }
          
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_credentials.metadata[0].name
                key  = "password"
              }
            }
          }
          
          env {
            name = "POSTGRES_HOST"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_credentials.metadata[0].name
                key  = "host"
              }
            }
          }
          
          env {
            name = "POSTGRES_PORT"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_credentials.metadata[0].name
                key  = "port"
              }
            }
          }
          
          env {
            name = "POSTGRES_DBNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_credentials.metadata[0].name
                key  = "dbname"
              }
            }
          }
          
          env {
            name = "MSK_BOOTSTRAP_SERVERS"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.msk_bootstrap_servers.metadata[0].name
                key  = "bootstrap_servers"
              }
            }
          }
          
          env {
            name  = "ENVIRONMENT"
            value = var.environment
          }
          
          resources {
            limits = {
              cpu    = "1000m"
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
          
          volume_mount {
            name       = "config-volume"
            mount_path = "/app/config"
          }
          
          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          
          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            
            initial_delay_seconds = 30
            period_seconds        = 30
          }
        }
        
        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map.genai_app_config.metadata[0].name
          }
        }
      }
    }
  }
}

# Deployment for the model inference component with GPU
resource "kubernetes_deployment" "genai_model_inference" {
  metadata {
    name      = "genai-model-inference"
    namespace = kubernetes_namespace.genai_app.metadata[0].name
    
    labels = {
      app         = "genai-model-inference"
      component   = "model-inference"
      environment = var.environment
    }
  }
  
  spec {
    replicas = var.environment == "production" ? 2 : 1
    
    selector {
      match_labels = {
        app       = "genai-model-inference"
        component = "model-inference"
      }
    }
    
    template {
      metadata {
        labels = {
          app         = "genai-model-inference"
          component   = "model-inference"
          environment = var.environment
        }
      }
      
      spec {
        service_account_name = kubernetes_service_account.genai_app.metadata[0].name
        
        # Schedule on GPU nodes
        node_selector = {
          "workload" = "gpu"
        }
        
        container {
          name  = "model-inference"
          image = "genai/model-inference:latest"  # Placeholder for the actual image
          
          port {
            container_port = 8000
          }
          
          env {
            name  = "ENVIRONMENT"
            value = var.environment
          }
          
          env {
            name  = "MODEL_TYPE"
            value = "generative"
          }
          
          resources {
            limits = {
              cpu               = "4000m"
              memory            = "16Gi"
              "nvidia.com/gpu" = 1
            }
            requests = {
              cpu               = "2000m"
              memory            = "8Gi"
              "nvidia.com/gpu" = 1
            }
          }
          
          volume_mount {
            name       = "config-volume"
            mount_path = "/app/config"
          }
          
          readiness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            
            initial_delay_seconds = 30
            period_seconds        = 10
          }
          
          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            
            initial_delay_seconds = 60
            period_seconds        = 30
          }
        }
        
        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map.genai_app_config.metadata[0].name
          }
        }
      }
    }
  }
}

# Deployment for the web frontend component
resource "kubernetes_deployment" "genai_web" {
  metadata {
    name      = "genai-web"
    namespace = kubernetes_namespace.genai_app.metadata[0].name
    
    labels = {
      app         = "genai-web"
      component   = "web"
      environment = var.environment
    }
  }
  
  spec {
    replicas = var.environment == "production" ? 3 : 1
    
    selector {
      match_labels = {
        app       = "genai-web"
        component = "web"
      }
    }
    
    template {
      metadata {
        labels = {
          app         = "genai-web"
          component   = "web"
          environment = var.environment
        }
      }
      
      spec {
        service_account_name = kubernetes_service_account.genai_app.metadata[0].name
        
        container {
          name  = "web"
          image = "genai/web:latest"  # Placeholder for the actual image
          
          port {
            container_port = 80
          }
          
          env {
            name  = "ENVIRONMENT"
            value = var.environment
          }
          
          env {
            name  = "API_URL"
            value = "http://genai-api:8080"
          }
          
          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }
          
          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            
            initial_delay_seconds = 5
            period_seconds        = 10
          }
          
          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            
            initial_delay_seconds = 15
            period_seconds        = 20
          }
        }
      }
    }
  }
}

# Service for the API component
resource "kubernetes_service" "genai_api" {
  metadata {
    name      = "genai-api"
    namespace = kubernetes_namespace.genai_app.metadata[0].name
    
    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "8080"
      "prometheus.io/path"   = "/metrics"
    }
  }
  
  spec {
    selector = {
      app       = "genai-api"
      component = "api"
    }
    
    port {
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
      name        = "http"
    }
    
    type = "ClusterIP"
  }
}

# Service for the model inference component
resource "kubernetes_service" "genai_model_inference" {
  metadata {
    name      = "genai-model-inference"
    namespace = kubernetes_namespace.genai_app.metadata[0].name
    
    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port"   = "8000"
      "prometheus.io/path"   = "/metrics"
    }
  }
  
  spec {
    selector = {
      app       = "genai-model-inference"
      component = "model-inference"
    }
    
    port {
      port        = 8000
      target_port = 8000
      protocol    = "TCP"
      name        = "http"
    }
    
    type = "ClusterIP"
  }
}

# Service for the web frontend component
resource "kubernetes_service" "genai_web" {
  metadata {
    name      = "genai-web"
    namespace = kubernetes_namespace.genai_app.metadata[0].name
  }
  
  spec {
    selector = {
      app       = "genai-web"
      component = "web"
    }
    
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
      name        = "http"
    }
    
    type = "ClusterIP"
  }
}

# Ingress for the web frontend
resource "kubernetes_ingress_v1" "genai_web" {
  count = var.aws_load_balancer_controller_enabled ? 1 : 0
  
  metadata {
    name      = "genai-web-ingress"
    namespace = kubernetes_namespace.genai_app.metadata[0].name
    
    annotations = {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/healthcheck-port"     = "traffic-port"
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/"
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTPS\":443}, {\"HTTP\":80}]"
      "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
      "alb.ingress.kubernetes.io/certificate-arn"      = var.domain_certificate_arn
      "alb.ingress.kubernetes.io/group.name"           = "genai-app"
      "external-dns.alpha.kubernetes.io/hostname"      = var.domain_name
    }
  }
  
  spec {
    rule {
      host = var.domain_name
      
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          
          backend {
            service {
              name = kubernetes_service.genai_web.metadata[0].name
              
              port {
                number = 80
              }
            }
          }
        }
        
        path {
          path      = "/api"
          path_type = "Prefix"
          
          backend {
            service {
              name = kubernetes_service.genai_api.metadata[0].name
              
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}

# Deploy Prometheus and Grafana
resource "helm_release" "prometheus_stack" {
  name       = "prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "45.10.1"
  
  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          remoteWrite = [
            {
              url             = "${var.prometheus_endpoint}api/v1/remote_write"
              sigv4           = { region = "us-west-2" }
              queueConfig     = { capacity = 5000, maxShards = 200 }
              metadataConfig  = { send = true }
            }
          ]
        }
      }
      grafana = {
        enabled = true
        adminPassword = "admin"  # Change this in production
        ingress = {
          enabled = true
          annotations = {
            "kubernetes.io/ingress.class" = "alb"
            "alb.ingress.kubernetes.io/scheme" = "internal"
            "alb.ingress.kubernetes.io/target-type" = "ip"
          }
          hosts = ["grafana.${var.domain_name}"]
        }
        dashboardProviders = {
          dashboardproviders.yaml = {
            apiVersion = 1
            providers = [
              {
                name = "default"
                orgId = 1
                folder = ""
                type = "file"
                disableDeletion = false
                editable = true
                options = {
                  path = "/var/lib/grafana/dashboards/default"
                }
              }
            ]
          }
        }
        dashboards = {
          default = {
            genai-dashboard = {
              json = file("${path.module}/dashboards/genai-dashboard.json")
            }
          }
        }
      }
    })
  ]
  
  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

# Create monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    
    labels = {
      name        = "monitoring"
      environment = var.environment
    }
  }
}

# Install NVIDIA GPU Operator if enabled
resource "helm_release" "gpu_operator" {
  count      = var.enable_gpu_operator ? 1 : 0
  name       = "gpu-operator"
  repository = "https://nvidia.github.io/gpu-operator"
  chart      = "gpu-operator"
  namespace  = kubernetes_namespace.gpu_resources.metadata[0].name
  version    = "v22.9.0"
  
  set {
    name  = "operator.defaultRuntime"
    value = "containerd"
  }
  
  depends_on = [
    kubernetes_namespace.gpu_resources
  ]
}

# Create GPU resources namespace
resource "kubernetes_namespace" "gpu_resources" {
  metadata {
    name = "gpu-resources"
    
    labels = {
      name        = "gpu-resources"
      environment = var.environment
    }
  }
}

# Install Istio Service Mesh if enabled
resource "helm_release" "istio_base" {
  count      = var.enable_service_mesh ? 1 : 0
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = kubernetes_namespace.istio_system[0].metadata[0].name
  version    = "1.16.2"
  
  depends_on = [
    kubernetes_namespace.istio_system
  ]
}

resource "helm_release" "istiod" {
  count      = var.enable_service_mesh ? 1 : 0
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace.istio_system[0].metadata[0].name
  version    = "1.16.2"
  
  depends_on = [
    helm_release.istio_base
  ]
}

resource "helm_release" "istio_ingress" {
  count      = var.enable_service_mesh ? 1 : 0
  name       = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = kubernetes_namespace.istio_system[0].metadata[0].name
  version    = "1.16.2"
  
  depends_on = [
    helm_release.istiod
  ]
}

# Create Istio System namespace
resource "kubernetes_namespace" "istio_system" {
  count = var.enable_service_mesh ? 1 : 0
  
  metadata {
    name = "istio-system"
    
    labels = {
      name        = "istio-system"
      environment = var.environment
    }
  }
}

# Install AWS Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {
  count      = var.aws_load_balancer_controller_enabled ? 1 : 0
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.4"
  
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.service_account_role_arn
  }
  
  set {
    name  = "region"
    value = "us-west-2"  # Update with your region
  }
  
  set {
    name  = "vpcId"
    value = var.vpc_id
  }
}

# Install External DNS if enabled
resource "helm_release" "external_dns" {
  count      = var.enable_external_dns ? 1 : 0
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = "6.12.2"
  
  set {
    name  = "provider"
    value = "aws"
  }
  
  set {
    name  = "aws.region"
    value = "us-west-2"  # Update with your region
  }
  
  set {
    name  = "aws.zoneType"
    value = "public"
  }
  
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  
  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }
  
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.service_account_role_arn
  }
  
  set {
    name  = "policy"
    value = "sync"
  }
  
  set {
    name  = "domainFilters[0]"
    value = var.domain_name
  }
}

# Install Cert Manager if enabled
resource "helm_release" "cert_manager" {
  count      = var.enable_cert_manager ? 1 : 0
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager[0].metadata[0].name
  version    = "v1.11.0"
  
  set {
    name  = "installCRDs"
    value = "true"
  }
  
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  
  set {
    name  = "serviceAccount.name"
    value = "cert-manager"
  }
  
  depends_on = [
    kubernetes_namespace.cert_manager
  ]
}

# Create Cert Manager namespace
resource "kubernetes_namespace" "cert_manager" {
  count = var.enable_cert_manager ? 1 : 0
  
  metadata {
    name = "cert-manager"
    
    labels = {
      name        = "cert-manager"
      environment = var.environment
    }
  }
}