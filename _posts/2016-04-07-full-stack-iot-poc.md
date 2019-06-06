---
title: Deploying A Full-Stack IoT Proof of Concept in Azure
featured: true
tags: [azure, iot, azure-resource-manager]
---

I have traveled to a few user groups lately demonstrating a full-stack IoT solution that uses AngularJS, Azure Search and Chart.js for the front-end. The instructions below will help you set up a similar environment for your own team to use as you learn more about Event Hubs and Stream Analytics.

## Deploying the ARM Template

We are going to start with a simple ARM template. This template saves the steps of creating every resource manually. You can opt to create these resources manually if you prefer.

To deploy the ARM template, simply click the link below:

[![Deploy to Azure](http://bit.ly/azbtnsm)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fgist.githubusercontent.com%2Fseesharprun%2F18359d735af35fe19a1d25c18b0acd23%2Fraw%2F8a8bbd9380cdfa384fe9af68e23b83318b3c35a0%2Fazuredeploy.json)

> Alternatively, you can copy the JSON file embedded below and deploy that manually using the **Template deployment** template in the Azure portal. To do this, navigate to https://portal.azure.com/#create/Microsoft.Template. This is the wizard to crate an Azure Resource Group from a JSON template. You simply copy the contents of the *azuredeploy.json* file and paste it in the editor.

Once you have clicked the link, you will need to provide two parameters:

    - **AccountNamesPrefix:** The 2-letter prefix to use before each unique service name. It is best to use your 2-letter initials here.
    - **Location:** Specify a location where you would like all of your resources to be deployed.

For the purposes of these steps, I have named my resource group **IoTDemo**.

``` html
<script src="https://gist.github.com/seesharprun/18359d735af35fe19a1d25c18b0acd23.js?file=azuredeploy.json"></script>
```

The template deploys an Azure Resource Group in the new portal with the following resources:

    -   Storage Account
    -   DocumentDB Account
    -   Streaming Analytics Job
    -   Service Bus Namespace (Messaging)
    -   Azure Search Account
    -   App Service Plan
    -   Web App

> The new portal doesn't support creating Event Hubs in an automated manner yet but that feature is coming very soon. Later in these steps, we will create the Event Hub manually.

## Reviewing Our Solution

Before we begin the rest of the deployment. Let's review our solution.

### Stream Analytics

Here is the Stream Analytics query. This query takes in data from an Event Hub and outputs it to both Table Storage and a DocumentDB account. I still recommend DocDB as you can use it with an automatic indexer on Azure Search to make search queries tremendously easier than with either storage type (search engines for queries, databases for storage):

### Web Solution

I have implemented a web solution using the DEAN stack (DocumentDB, Express, Angular, Node). The web app demonstrates various ways that you can visualize the data and various ways to query the data so that your developers will have enough examples to build their own solutions. The solution comprises of two Node.js applications, one to show the resulting data and one to populate the Event Hub with data. Data flows as such:

![Architecture](/content/img/import_image1.png)

The Node.js WebJob is fired manually and will enter a configurable amount of events (with configurable delay between events) into the Event Hubs queue. Stream Analytics uses the Event Hub queue as an “input” source and performs the query over the raw Event Hub data. The result of this query is put into the two “output” destinations, a Storage Table and a Document DB collection. Azure Search has an indexer configured that runs hourly (configurable) and updates the search index with any new or changed DocumentDB records (this is done by looking at the built-in incrementing *_ts* field). The Web App uses the search REST API for its various visualizations.

## Configuring Application and Resources

Let's begin configuring our resources. The below configuration steps will require you to use both portals as some features work on one portal or the other.

1.  Check the Current Portal (<http://portal.azure.com>). Hopefully your **IoTDemo** resource group in your subscription will be ready by now. It typically takes about 5 minutes to complete. If not, wait until the resource group is ready before continuing.

### Configure DocumentDB

2.  Go into your resource group and locate your new DocumentDB instance.

3.  Within the DocumentDB instance, create a new database. Now create a new collection within that database. Record the name of your database and collection.

    > This information will be used later in these steps.

### Configure Event Hub

4.  Use the Classic Portal (<http://manage.windowsazure.com>) and access your newly created Service Bus namespace. Record the name of the namespace.

5.  Within the namespace, use the **Event Hubs** tab to create a new Event Hub instance. Record the name of your Event Hub instance. You can specify any value for partition count and retention for the purposes of this project.

6.  Within the Event Hub instance, use the **Configure** tab to create a new **Shared Access Policy**. Give it **Send** and **Listen** permissions. Once you save the new policy, record the value of the policy’s name and key.

    > With your production application, you would create separate policies for Send or Listen.

### Configure Stream Analytics

1.  Locate your new Stream Analytics job in the same portal.

2.  Within the Stream Analytics job, click on the **Inputs** tab and click the **Add an Input** option.

3.  Select the **Data stream** option, select **Event Hub**, and then select the option to use the Event Hub from your current subscription. Ensure that the policy name is set to the new policy your created. Also ensure that the alias for this input is named **ehinput**. Leave the remaining settings to their default values and then create the new input.

    > Inputs and outputs are automatically tested for validity after you create them.

1.  Click on the **Outputs** tab and click the **Add an Output** option.

2.  Select the **Table storage** option and then select to use your existing storage account. The TableName does not matter as it will be created automatically for you. Ensure that the PartitionKey is set to **paritionkey**, the alias is set to **tablestoroutput** and the RowKey is set to **rowkey**.

    > There is a reported bug where sometimes Stream Analytics can’t find your Storage account. This occurs because we are using v2 storage accounts in our deployment instead of classic. You can choose to create a separate, new storage account at this point to store your table data. If you would like to use the same Storage Account, you simply need to locate the “Name” and “Primary Access Key” for your storage account. All of this information is available on the Preview Portal and you can see an example of inputting this information below:

    ![Step1](/content/img/import_image2.png)

    ![Step2](/content/img/import_image3.png)

1.  Create an additional output.

2.  For this output, use the type **DocumentDB**, and select your existing account. Ensure that the *Partition Key* is set to **paritionkey**, the *Collection Name Pattern* is set to the **name of your DocDB collection created earlier**, the *alias* is set to **docdboutput** and the *Document ID* is set to **rowkey**.

3.  Once both outputs are created and tested, go to the **Query** tab. Copy and paste the below query into the editor. Save the query.

    ``` html
    <script src="https://gist.github.com/seesharprun/18359d735af35fe19a1d25c18b0acd23.js?file=streamquery.sql"></script>
    ```

    > This query reads data from an Event Hub (input source) named "ehinput" and outputs the data to DocDB and Table Storage (output sources) named "docdboutput" and "tablestoroutput". The query uses a tumbling window that aggregates data from each unique sensor and recording type into 5 second windows. For example, if a sensor named "out-therm-d" creates three records of reading type "temp-f" (fahrenheit temperature) within 5 seconds, it will take the average of those readings and also output other aggregate data that is useful. I have also created the time buckets in a manner that is consistent between both Table Storage and DocumentDB. I recommend DocumentDB because it integrates automatically with Azure Search (free tier) where Table Storage does not have that level of integration.

4. (**Optional**) This is a sample of the sample data that I sent to the Event Hub using its REST API. An “event” consists of a unique identifier for the sensor (**sensorid**), the type of event (**sensor**) and the value (**value**):

    ``` html
    <script src="https://gist.github.com/seesharprun/18359d735af35fe19a1d25c18b0acd23.js?file=uapp.json"></script>
    ```

    You can optionally test your query in Stream Analytics yourself. To do so, download the following **testdata.json** file and click the **Test** button in the Stream Analytics editor. This will show you what the query does:

    ``` html
    <script src="https://gist.github.com/seesharprun/18359d735af35fe19a1d25c18b0acd23.js?file=testdata.json"></script>
    ```

4.  Click **Start** to begin processing of your events. Start immediately by selecting the **Job Start Time** option.

### Configure GitHub Repository

5.  Temporarily, create a new tab in your browser. In order to set up Continuous Integration, you will need a **GitHub** account. Use the GitHub to create a free GitHub account. Once your account is created, navigate to the following url: <https://github.com/seesharprun/ehsavalidation>

6.  Click the **Fork** button to create a clone of this repository in your account. There is one file you should update. You can update the file directly in the browser using the GitHub editor:

	![GitHub Clone](/content/img/import_image4.png)
    
1.  In the **/App_Data/jobs/triggered/datainput** directory, edit the **config.json** file.

2.  Replace the values for the **namespace**, **eventHub**, **name** and **secret** fields with your namespace name, event hub name, shared access policy name and shared access policy key respectively.

3.  Commit the file (Save)

4.  Do not close the GitHub tab as you will use this later.

### Configure Continuous Deployment

1.  Return to the Current Portal (<http://portal.azure.com>) 

1.  Locate your **IoTDemo** resource group and locate your new **Web App** instance.

2.  On the **Settings** blade, click the **Deployment Source** option.

3.  Configure your GitHub account and choose your repository (most likely named **ehsavalidation**). Once the deployment has finished, Node.js code will be deployed to your website and a new Node.js job will be created. The website is not yet ready to view.

    > You can alternatively manually deploy using FTP but it is not recommended. This method is recommended as you will have your own private version of this demo that you can tweak without affecting the original source.

### Start IoT Simulator Web job

    > This WebJob simulates and IoT device by sending events to the Event Hub.

1.  On the **Settings** blade, click the **WebJobs** option.

2.  Right-click the new **WebJob** and click the **Run** option.

3. (**Optional**) There is a hyperlink to the right of the WebJob entry. If you click on this link, you will go to the WebJob dashboard that contains metadata and logs for the run durations. This WebJob is populating your Event Hub instance with events. The number of events is determined by the **config.json** file in your repository. Feel free to run this WebJob as often as you like, you can even set it up to run indefinitely (not recommended due to billing implications). As configured, it will add an event to the event hub every 0.15 seconds for approximately ten minutes. These settings can be easily changed.

    > It is recommended to let the data populate for at least ten minutes before moving to the next step.

## Configure Azure Search

2.  Locate your **IoTDemo** resource group and open the **Search** instance.

3.  At the top of the blade that opens, click the **Import Data** button to create an indexer. 

    a. Create a data source and connect the indexer to your DocumentDB instance, database and collection created earlier. You can leave the query field blank as it is not required. 

    b. Customize your target index by selecting the **id** field as the **Key** and selecting all checkboxes for every field.  In a production workload, you would make tactical decisions about which fields to filter, make searchable or make facetable. For the purposes of this demo, it is important to enable all features for all fields.

    c. You can name your index whatever you like but you must record the name of your **index** and **search account name**. 

    d. Once the index is created, specify that your indexer should run hourly, go to advanced options and select **Base-64 Encode Keys** and name your indexer whatever you like. 

    e. Save the new indexer.

4.  Click the new index to see the index’s options. Click the **CORS options** tile.

5.  Configure **CORS** to allow cross-origin requests from **ALL** origins.

    > This setting allows your web application to query this service from another host (origin).

1.  Wait about five minutes for your indexer to finish executing.

    > You can use the **Search Explorer** on your index if you want to see the search index’s documents as they populate.

1.  Click the **Keys** button in the storage account to see your account credentials. Record your **Primary Admin Key**.

    > In production, you would typically create a query key with only Read/Query permissions.

### Configure Sample Web App

1.  Return to your repository in **GitHub**.

2.  Edit one more file to set up the demo web application

    ![GitHub Editing](/content/img/import_image5.png)

    a.  In the **/public/angular/** directory, edit the **angular-config.js** file.

    b.  Replace the values for the **searchName**, **searchIndexName** and **apiKey** fields with your search account name, index name and primary admin key respectively.

    c.  Commit the file (Save)

3.  Return to the Current Portal (<http://portal.azure.com>)

4.  Locate your **Web App** instance in the **IoTDemo** resource group.

1.  In the **Settings** blade, click on the **Deployment Source** option.

1.  If you wait, shortly a new deployment will be created for the changes you just made in GitHub. One the changes are deployed, move to the final step.

1.  Click the **Browse** button at the top of the **Web App** blade.

## Conclusion

At this point, you can try out the sample web application and view the data visualization. You can also run the WebJob again to put more data into your Event Hubs instance and view it (within minutes) on the sample web application.