# Steps to Connect this Application to watsonx Assistant

You connect your assistant by using the api specification to add a custom extension.

### Download the api specification

Download the [rag-app-openapi.json](./rag-app-openapi.json) specification file. 

Use this specification file to create and add the extension to your assistant.

### Build and add extension

1.  In your assistant, on the **Integrations** page, click **Build custom extension** and use the `rag-app-openapi.json` specification file to build a custom extension named `RAG LLM App`. For general instructions on building any custom extension, see [Building the custom extension](https://cloud.ibm.com/docs/watson-assistant?topic=watson-assistant-build-custom-extension#building-the-custom-extension).

1.  After you build the extension, and it appears on your **Integrations** page, click **Add** to add it to your assistant. For general instructions on adding any custom extension, see [Adding an extension to your assistant](https://cloud.ibm.com/docs/watson-assistant?topic=watson-assistant-add-custom-extension).

1.  In **Authentication**, choose **OAuth 2.0**. Select **Custom apikey** as the grant type in the next dropdown, and then copy and paste the value you set for **RAG_APP_API_KEY** in your environment variables.

1.  In **Servers**, under **Server Variables**, add the url (without the https) for your hosted application as `llm_route`. 

If you add apis and capabilities to this application, feel free to add them to the openapi specification. The application is intended to be an example of how to get started. If you add APIs after the Actions have been loaded, you will need to download your Actions, upload the new Open API spec and re-upload your Actions.

## Upload sample actions

This utility includes [a JSON file with sample actions](./rag-app-actions.json) that are configured to use the `rag-app` extension.

Use **Actions Global Settings** (see wheel icon top right of **Actions** page) to upload the `RAG-LLM-App-action.json` to your assistant. For more information, see [Uploading](https://cloud.ibm.com/docs/watson-assistant?topic=watson-assistant-admin-backup-restore#backup-restore-import). You may also need to refresh the action **Preview** chat, after uploading, to get all the session variables initialized before these actions will work correctly.

Under **Variables->Created by you** within the **Actions** page, set the `es_index_name` session variable.

**NOTE**: If you import the actions _before_ configuring the extension, you will see errors on the actions because it could not find the extension. Configure the extension (as described [above](#prerequisites)), and re-import the action JSON file.

| Action                        | Description                                                                                                                                                                                   |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Query ES + LLM | Connects to the `queryLLM` API which queries Elasticsearch using user inputted question and passes resulting documents into LLM for a natural language response. |
| Query WD + LLM | Connects to the `queryWDLLM` API which queries Watson Discovery using user inputted question and passes resulting documents into LLM for a natural language response.  |
| No Action Matches | This is created by watsonx Assistant, but for this starter kit it is configured to trigger the "Query ES + LLM" as a sub-action using the defaults and the user input. |


### Session variables

These are the session variables used in this example.

Elasticsearch only:
- `es_index_name`: Name of the Elasticsearch index. **Required**
- `es_index_text_field`: Text field containing document text. **Required**
- `es_model_name`: Name of model used to create embeddings in Elasticsearch index. **Required**
- `es_model_text_field`: Name of field containing the text embeddings. **Required**

Watson Discovery only:
- `wd_project_id`: ID for project to use. To find the project id, go to the **Integrate and deploy** page within the Watson Discovery Application and open the **API Information** tab. **Required**
- `wd_collection_id`: ID for document collection to search in. If not specified, all collections will be searched. To get your collection id, you can run:
    ```
    curl -X GET -u "apikey:<apikey>"  "<wd_url>/v2/projects/<wd_project_id>/collections?version=2023-03-31"
    ```
    To find the **Watson Discovery** URL, open the service instance and look under **Service credentials**.
    
- `wd_document_names`: Specific set of documents to search in.
- `wd_return_params`: Fields to return from document
- `wd_version`: URL version. Defaults to `2023-03-31`.

Common variables for both APIs:
- `llm_instructions`: Prompt to send in to LLM
- `model_id`: The ID of the watsonx model that you select for this action. Defaults to `ibm/granite-13b-chat-v2`.
- `model_input`: Additional input for the model.
- `model_parameters_max_new_tokens` : The maximum number of new tokens to be generated. Defaults to 300.
- `model_parameters_min_new_tokens`: The minimum number of the new tokens to be generated. Defaults to 1.
- `model_parameters_temperature` : The value used to control the next token probabilities. The range is from 0.05 to 1.00; 0 makes it _mostly_ deterministic. Defaults to .7
- `model_parameters_repetition_penalty`: Represents the penalty for penalizing tokens that have already been generated or belong to the context. The range is 1.0 to 2.0 and defaults to 1.1.
- `model_parameters_stop_sequences`: Stop sequences are one or more strings which will cause the text generation to stop if/when they are produced as part of the output. Stop sequences encountered prior to the minimum number of tokens being generated will be ignored. The list may contain up to 6 strings. Defaults to `["\n\n"]`
- `model_parameters_decoding_method`: The strategy used for picking the tokens during generation of the output text. Defaults to `greedy`
- `model_parameters_include_stop_sequence`: The value to control presence of matched stop sequences from the end of the output text.
- `model_parameters_random_seed`: A random number generator seed to use in sampling mode for experimental repeatability.
- `model_parameters_time_limit`: The amount of time in milliseconds to wait before stopping generation.
- `model_parameters_top_k`: The number of highest probability vocabulary tokens to keep for top-k-filtering.
- `model_parameters_top_p`: Similar to top_k except the candidates to generate the next token are the most likely tokens with probabilities that add up to at least top_p.
- `num_results`: Maximum nmber of references to return from search and pass into LLM.
- `model_response`: Response from LLM
