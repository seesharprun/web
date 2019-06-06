---
title: Deploying Sample Applications to an Azure Web App
tags: [azure, azure-resoruce-manager, app-service, web-apps, devops]
---

When was the last time you saw a demo application at a conference or during a webcast that you want to try out? Many times you may see someone post a web application project to GitHub and invite you to download the source. While you could download the code and modify the project locally, what if you just needed to deploy the project and validate it? With Azure App Service's continuous deployment feature, you can test out code from a variety of source control providers. Today we are going to focus on trying out code that's available on **public** GitHub repos.

There are two primary ways to accomplish this. You can either deploy the sample app to an existing Web App or use an ARM template to deploy the sample app to an isolated Web App and App Service Plan.

## Continuous Deployment in an Existing Web App

If you have an existing web application, you can deploy code from a public GitHub repo directly to the web app manually. This is done by locating the **Deployment** section in your Web App's blade and clicking the **Continuous Deployment** tile. This same procedure can be used for either API or Mobile Apps.

![](/content/img/import_080415_0005_DeployingSa1.png)

In the **Continous Deployment** blade, select **External Repository** as your source and provide a GitHub URL and a branch. For our sample, we will use a sample SignalR and Knockout application that was created by James Still and described in this blog post: [http://www.squarewidget.com/signalr-mvc-knockout-web-api](http://www.squarewidget.com/signalr-mvc-knockout-web-api). We are using the **master** branch and the URL for this repo is:

[https://github.com/jamesstill/SignalRDemo.git](https://github.com/jamesstill/SignalRDemo.git)

![](/content/img/import_080415_0005_DeployingSa2-1.png)

Once configured, you will be able to click the same tile to see a list of deployments. The engine driving this app (KUDU) has went out and got the latest version of the application from the specified URL and branch.

![](/content/img/import_080415_0005_DeployingSa3-1.png)

This is continuous deployment, so future check-ins will cause a new deployment of your web application. You can open the browser and immediately see the sample web application running.

![](/content/img/import_080415_0005_DeployingSa4-1.png)

To test the application, you can open another browser (or new browser window) and create messages in real-time.

![](/content/img/import_080415_0005_DeployingSa5.png)

## Integrated Deployment through Azure Resource Manager

A more interesting way to test a web application is to do so in an isolated and immutable manner. Use an ARM template, you can deploy a resource group containing an App Service Plan and a Web App that are created purposefully to host the sample web application code. The template to accomplish this is very simple and is available in the public Azure Quickstarts GitHub repo: [https://github.com/Azure/azure-quickstart-templates/blob/master/201-web-app-github-deploy/azuredeploy.json](https://github.com/Azure/azure-quickstart-templates/blob/master/201-web-app-github-deploy/azuredeploy.json). There is also an article on Azure.com that describes deploying a web application using GitHub and an ARM template: [https://azure.microsoft.com/en-us/documentation/articles/app-service-web-arm-from-github-provision/](https://azure.microsoft.com/en-us/documentation/articles/app-service-web-arm-from-github-provision/). For this sample, we will use a sample application developed by Christophe Coenraets and described in this blog post: [http://coenraets.org/blog/2013/04/sample-application-with-backbone-js-and-twitter-bootstrap-updated-and-improved/](http://coenraets.org/blog/2013/04/sample-application-with-backbone-js-and-twitter-bootstrap-updated-and-improved/).

To start, click on the link below to create a new Azure Resource Manager template deployment in the portal and pass in a JSON file as the template.

[![Deploy to Azure](http://bit.ly/azbtnsm)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-web-app-github-deploy%2Fazuredeploy.json)

Let's look at the structure of this url:

```
https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-web-app-github-deploy%2Fazuredeploy.json
```

{: .my-4 .table .table-sm .table-hover}
| Segment | Description |
| --- | --- |
| ``https://portal.azure.com`` | This is the URL to the Azure Preview Portal |
| ``/#create/Microsoft.Template`` | This is a deep-link that indicates that the "Create new ARM Template Deployment" blade should appear |
| ``/uri/`` | This indicates that the template will be provided by a JSON file at the specified URI |
| ``https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-web-app-github-deploy%2Fazuredeploy.json`` | This is the URL encoded URI for the JSON template. This should be a text file that is anonymously accessible. |

This simple URL was able to open the portal, show the create ARM template scaffolding and provide a JSON for the template. You can change the encoded URI at the end of this to deploy any type of template you want. Simply upload the JSON file to a publically accessible location (such as a public GitHub repo).

![](/content/img/import_080415_0005_DeployingSa7.png)

Once the template is saved, you can now specify the parameters for the template. These parameters are parsed directly from the template. You can provide any value you want for most of the fields but you do want to provide the following values to use the sample Backbone.js application from GitHub:

- **Repo URL**: https://github.com/ccoenraets/directory-backbone-bootstrap.git 
- **Branch**: master

![](/content/img/import_080415_0005_DeployingSa8.png)

Once you save the template and parameters, you simply need to provide a Resource Group name, location, accept the legal terms and then click Create.

A resource group will be created with a new app service plan and new web app. Shortly after they are created, the code from the sample app will be deployed to the web app.

![](/content/img/import_080415_0005_DeployingSa9.png)

Once created, you can view the sample application in your browser.

![](/content/img/import_080415_0005_DeployingSa10.png)

If you are deploying a .NET application with multiple solutions, you will need to provide a **.deployment** file at the root of your repo. This file is a simple file that tells the deployment engine which project it should build. The solution can then be easily determined once KUDU understands which project it should build and deployed. A sample **.deployment** file would look like this:
    
```
[config]
project=src/DirectoryOfWebApplication/
```

## Conclusion

To wrap-up, you can either use ARM or the portal to configure deployment of a web application from a public GitHub repo to your Web App instance. This method can be used with JavaScript web applications, ASP.NET applications and many other types of applications supported in the App Service environment.