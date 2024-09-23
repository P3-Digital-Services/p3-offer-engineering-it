locals {
  tags           = {
    ProjectName    = "cariad-runner-management"
    Environment    = "demo"
    created-by     = "luka.beslac@p3-group.com"
    owner          = "luka.beslac@p3-group.com"
  }
  resource_group = {
    name           = "cariad-runner-management-demo"
    location       = "Sweden Central"
  }
}