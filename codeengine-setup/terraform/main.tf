# Random project suffix
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  project_name = "${var.project_name}"
  resource_group = "${var.resource_group}-${random_string.suffix.result}"
  cr_namespace = "${var.cr_namespace}"
  secret = "${var.cr_secret}"
  imagename = "${var.cr_imagename}"
  buildname = "${var.ce_buildname}"
  appname = "${var.ce_appname}"
  project_id = data.external.project_search.result.exists == "true" ? data.external.project_search.result.project_id : ibm_code_engine_project.code_engine_project_instance[0].id
}

data "ibm_iam_auth_token" "tokendata" {}

provider "restapi" {
  uri                  = "https://api.${var.region}.codeengine.cloud.ibm.com/"
  debug                = true
  write_returns_object = true
  headers = {
    Authorization = data.ibm_iam_auth_token.tokendata.iam_access_token
  }
}

data "ibm_resource_group" "group" {
  name = "${var.resource_group}"
}

# Grab the project_id if it exists
data "external" "project_search" {
  program = ["bash", "${path.module}/scripts/fetch_projectid.sh", "${var.project_name}", data.ibm_iam_auth_token.tokendata.iam_access_token]
}

# Create a code engine project if it's needed
resource "ibm_code_engine_project" "code_engine_project_instance" {
  depends_on = [ data.external.project_search ]
  count             = data.external.project_search.result.exists == "false" ? 1 : 0
  name              = local.project_name
  resource_group_id = data.ibm_resource_group.group.id
}

# Grab a list of namespaces in the RG
data "ibm_cr_namespaces" "get_rg_namespace" {}

# Determine if a cr_namespace exists, if it does, use it, otherwise create it.
locals {
  existing_namespace = [for ns in data.ibm_cr_namespaces.get_rg_namespace.namespaces : ns if ns.name == local.cr_namespace]
  namespace_exists = length(local.existing_namespace) > 0
}

# Create a cr_namespace
resource "ibm_cr_namespace" "rg_namespace" {
  depends_on = [ data.ibm_cr_namespaces.get_rg_namespace ]
  count             = local.namespace_exists ? 0 : 1
  name              = local.cr_namespace
  resource_group_id = data.ibm_resource_group.group.id
}

# Create a secret in code engine for pulling the image
resource "ibm_code_engine_secret" "code_engine_secret_instance" {
  project_id = local.project_id
  name = local.secret
  format = "registry"
  data = {
      username="iamapikey"
      password="${var.ibmcloud_api_key}"
      server="us.icr.io"
      email=""
    }
}

# Create a build instance
resource "ibm_code_engine_build" "code_engine_build_instance" {
  project_id    = local.project_id
  name          = local.buildname
  output_image  = "us.icr.io/${local.cr_namespace}/${local.imagename}"
  output_secret = ibm_code_engine_secret.code_engine_secret_instance.name
  source_url    = "${var.source_url}"
  source_revision = "${var.source_revision}"
  source_context_dir = "${var.source_context_dir}"
  strategy_type = "dockerfile"
  strategy_spec_file = "Dockerfile"
}

# Create a build run
resource "restapi_object" "buildrun" {
  path     = "/v2/projects/${local.project_id}/build_runs"
  data = jsonencode(
    {
      name = "rag-llm-build-run"
      output_image  = "${ibm_code_engine_build.code_engine_build_instance.output_image}:latest"
      output_secret = ibm_code_engine_secret.code_engine_secret_instance.name
      source_url    = "${var.source_url}"
      source_revision = "${var.source_revision}"
      source_context_dir = "${var.source_context_dir}"
      strategy_type = "dockerfile"
      strategy_spec_file = "Dockerfile"
      timeout = 3600
    }
  )
  id_attribute = "name"
}

# Waiting a flat 5min to make sure the build_run completes.
# Check the status of the build in the build images tab in the project.
resource "time_sleep" "wait_for_build" {
  create_duration = "5m"

  depends_on = [
    restapi_object.buildrun
  ]
}

# Create an application and use the image built in the build_run
# Sets the env variables
resource "ibm_code_engine_app" "code_engine_app_instance" {
  depends_on = [
    time_sleep.wait_for_build
  ]

  project_id      = local.project_id
  name            = local.appname
  image_reference = "${ibm_code_engine_build.code_engine_build_instance.output_image}:latest"
  image_secret = local.secret
  image_port = "4050"
  scale_initial_instances = "1"
  scale_max_instances = "1"


  run_env_variables {
    type  = "literal"
    name  = "COS_IBM_CLOUD_API_KEY"
    value = var.cos_ibm_cloud_api_key
  }
  run_env_variables {
    type  = "literal"
    name  = "COS_INSTANCE_ID"
    value = var.cos_instance_id
  }
  run_env_variables {
    type  = "literal"
    name  = "COS_ENDPOINT_URL"
    value = var.cos_endpoint_url
  }
  run_env_variables {
    type  = "literal"
    name  = "RAG_APP_API_KEY"
    value = var.rag_app_api_key
  }
  run_env_variables {
    type  = "literal"
    name  = "IBM_CLOUD_API_KEY"
    value = var.ibmcloud_api_key
  }
  run_env_variables {
    type  = "literal"
    name  = "WX_PROJECT_ID"
    value = var.wx_project_id
  }
  run_env_variables {
    type  = "literal"
    name  = "WX_URL"
    value = var.wx_url
  }
  run_env_variables {
    type  = "literal"
    name  = "WXD_USERNAME"
    value = var.wxd_username
  }
  run_env_variables {
    type  = "literal"
    name  = "WXD_PASSWORD"
    value = var.wxd_password
  }
  run_env_variables {
    type  = "literal"
    name  = "WXD_URL"
    value = var.wxd_url
  }
  run_env_variables {
    type  = "literal"
    name  = "WD_API_KEY"
    value = var.wd_api_key
  }
  run_env_variables {
    type  = "literal"
    name  = "WD_URL"
    value = var.wd_url
  }
}

