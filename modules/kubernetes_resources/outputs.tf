output "genai_app_namespace" {
  description = "GenAI application namespace"
  value       = kubernetes_namespace.genai_app.metadata[0].name
}

output "monitoring_namespace" {
  description = "Monitoring namespace"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "genai_api_service_name" {
  description = "GenAI API service name"
  value       = kubernetes_service.genai_api.metadata[0].name
}

output "genai_model_inference_service_name" {
  description = "GenAI model inference service name"
  value       = kubernetes_service.genai_model_inference.metadata[0].name
}

output "genai_web_service_name" {
  description = "GenAI web service name"
  value       = kubernetes_service.genai_web.metadata[0].name
}

output "istio_enabled" {
  description = "Whether Istio is enabled"
  value       = var.enable_service_mesh
}

output "gpu_operator_enabled" {
  description = "Whether GPU Operator is enabled"
  value       = var.enable_gpu_operator
}

output "external_dns_enabled" {
  description = "Whether External DNS is enabled"
  value       = var.enable_external_dns
}

output "cert_manager_enabled" {
  description = "Whether cert-manager is enabled"
  value       = var.enable_cert_manager
}

output "load_balancer_controller_enabled" {
  description = "Whether AWS Load Balancer Controller is enabled"
  value       = var.aws_load_balancer_controller_enabled
}