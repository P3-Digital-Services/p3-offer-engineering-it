resource "azurerm_user_assigned_identity" "uai" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = var.name
  tags                = var.tags
}


data "azurerm_resource_group" "runner_rg" {
  name = var.resource_group_name
}

data "azurerm_resource_group" "builder_rg" {
  name = var.builder_resource_group_name
}
// Aaddding necessary role assignments

# Custom role creation
resource "azurerm_role_definition" "custom_vm_image_manager" {
  role_definition_id = "59080b5e-741b-938a-286d-08dbd0ca1527"
  name               = "Custom VM Image Creator"
  scope              = data.azurerm_resource_group.builder_rg.id
  permissions {
    actions   = ["Microsoft.Compute/images/*","Microsoft.VirtualMachineImages/imageTemplates/*"]
    not_actions = []
  }
  assignable_scopes = ["${data.azurerm_resource_group.builder_rg.id}"]
}

# Role assignment to service principal for the resource group
resource "azurerm_role_assignment" "image_role_assignment" {
  principal_id   = azurerm_user_assigned_identity.uai.principal_id
  role_definition_name = azurerm_role_definition.custom_vm_image_manager.name
  scope          = data.azurerm_resource_group.builder_rg.id
  depends_on = [ azurerm_role_definition.custom_vm_image_manager ]
}

resource "azurerm_role_assignment" "compute_gallery_artifacts_publisher" {
  scope                = data.azurerm_resource_group.runner_rg.id
  role_definition_name = "Compute Gallery Artifacts Publisher"
  principal_id         = azurerm_user_assigned_identity.uai.principal_id
}

resource "azurerm_role_assignment" "builder_rg_compute_gallery_artifacts_publisher" {
  scope                = data.azurerm_resource_group.builder_rg.id
  role_definition_name = "Compute Gallery Artifacts Publisher"
  principal_id         = azurerm_user_assigned_identity.uai.principal_id
}

resource "azurerm_role_assignment" "compute_gallery_image_reader" {
  scope                = data.azurerm_resource_group.runner_rg.id
  role_definition_name = "Compute Gallery Image Reader"
  principal_id         = azurerm_user_assigned_identity.uai.principal_id
}

resource "azurerm_role_assignment" "contributor" {
  scope                = data.azurerm_resource_group.runner_rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.uai.principal_id
}

resource "azurerm_role_assignment" "virtual_machine_contributor" {
  scope                = data.azurerm_resource_group.builder_rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_user_assigned_identity.uai.principal_id
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = data.azurerm_resource_group.builder_rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.uai.principal_id
}

resource "azurerm_role_assignment" "managed_identity_operator" {
  scope                = data.azurerm_resource_group.builder_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.uai.principal_id
}
resource "azurerm_role_assignment" "managed_identity_operator_runner" {
  scope                = data.azurerm_resource_group.runner_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.uai.principal_id
}