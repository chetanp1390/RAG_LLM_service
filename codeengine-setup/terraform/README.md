# Deploy the RAG LLM Application to Code Engine

This terraform code will create and deploy the RAG-LLM Service appplication code onto **IBM Cloud Code Engine**. A Code Engine project is created and used for deploying the application. The container image is built and pushed to the IBM Cloud Container Registry. The application is created with a single instance. Changes can be made to the applicaton deployment as needed.


## Using a Schematics workspace on IBM Cloud

### Step 1 

In `cloud.ibm.com`, search on **Schematics**.  Click on **Create a workspace**

### Step 2 

Set the following:
- **GitHub, GitLab or Bitbucket repository URL**: `https://github.com/ibm-build-lab/RAG-LLM-Service`
- **Branch**: `main`
- **Folder**: `codeengine-setup/terraform` 

Click **Create**
### Step 3

Edit the values for desired environment variables. To edit a variable, select the 3 dot menu at the end of the variable. Select **Edit**, uncheck **Use default**, enter new value and save
### Step 4
Run `Generate Plan` to make sure there aren't any errors

Run `Apply Plan`

**Optional**: If the build times out before the Application is created, the application can be created manually within Code Engine. To do so: 

- Search **Code Engine** in the top search bar on the IBM Cloud console.
- Once in **Code Engine**, open **Projects**, and go into your project. Navigate to the **Applications** tab within **Code Engine** on the left side. See if there is an application created. If not, click **Create** and follow next steps.
- Provide a name for the Application, i.e. rag-llm-app
- Choose **Use an existing container image**. For **Image reference** enter the image name created from the terraform automation, i.e. `us.icr.io/<cr_namespace>/<ce_imagename>:latest`
- Change the **Ephemeral storage** to 2.04
- Limit the instance scaling to 1 and 1
- Select **Domain mappings** to **Public**.
- Under the **Optional settings**->**Environment variables**, create the variables with the credentials based on the `env` file located in the `application` directory
- Under **Optional settings**->**Image start options** change the **Listening port** to 4050
- click **Create**


## Using local Terraform

Required: 
    [terraform cli](https://developer.hashicorp.com/terraform/install)

1. Change into the directory `cd codeengine-terraform-setup`
3. Edit the `terraform.tfvars` file and fill in all the required values. Note for this api, the WD variables are unnecessary and can be left as default.
5. Run `terraform init` to initialize your terraform environment
6. Run `terraform plan` to see what resources will be created
7. Run `terraform apply` to create the resources

Verify that this has created a **Code Engine** project and application. 

- From the IBM Cloud search bar, search on `Code Engine` to bring up the service
- Go to `Projects` and search for the project you specified in the `terraform.tfvars` file
- Within the project you should see an application running with a `Ready` status

## Accessing the URL on Code Engine

Wait for the build to complete and access the public URL by selecting the **Domain mappings** tab of the open **Application** pane.  Or go into the project by selecting **Projects** from the **Code Engine** side menu. Open the project, then select **Applications**. You will see a URL link under the **Application Link**.
    
## How to Access Swagger Once Deployed

A quick sanity check with `<url>/docs` will take you to the swagger ui.

