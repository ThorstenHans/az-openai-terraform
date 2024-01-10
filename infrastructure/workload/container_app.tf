resource "azurerm_container_app_environment" "acaenv" {
  name                = "acaenv-azopenai"
  resource_group_name = data.azurerm_resource_group.target.name
  location            = data.azurerm_resource_group.target.location

  infrastructure_subnet_id   = azurerm_subnet.apps.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

resource "azurerm_container_app" "app" {
  name                = "sample-app"
  resource_group_name = data.azurerm_resource_group.target.name

  container_app_environment_id = azurerm_container_app_environment.acaenv.id
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acapull.id]
  }

  ingress {
    external_enabled = true
    target_port      = 8000
    traffic_weight {

      latest_revision = true
      percentage      = 100
    }
  }

  registry {
    server   = data.azurerm_container_registry.target.login_server
    identity = azurerm_user_assigned_identity.acapull.id
  }

  secret {
    name  = "azure-open-ai-key"
    value = azurerm_cognitive_account.openai.primary_access_key
  }
  template {
    container {
      name  = "sample_app"
      image = "${data.azurerm_container_registry.target.name}.azurecr.io/sample_app:${var.container_image_tag}"

      cpu    = 1
      memory = "2Gi"

      env {
        name        = "OPENAI_API_KEY"
        secret_name = "azure-open-ai-key"
      }

      env {
        name  = "OPENAI_API_VERSION"
        value = "2023-03-15-preview"
      }

      env {
        name  = "OPENAI_API_URL"
        value = "https://${azurerm_cognitive_account.openai.custom_subdomain_name}.openai.azure.com"
      }

      env {
        name  = "DEPLOYMENT_NAME"
        value = azurerm_cognitive_deployment.gpt4.name
      }
      liveness_probe {
        initial_delay    = 20
        interval_seconds = 30
        path             = "/healthz/liveness"
        port             = 8000
        transport        = "HTTP"
      }

      readiness_probe {
        path      = "/healthz/readiness"
        port      = 8000
        transport = "HTTP"
      }
    }
  }
}
