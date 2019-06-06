---
title: Quickly Creating a Virtual Machine using Windows Azure Powershell
tags: [azure, powershell]
---

​I have recently been demoing Quick virtual machine build-up using Powershell and Windows Azure.  My demos are based upon the excellent tutorial for the New-AzureQuickVM functionality described here ([http://msdn.microsoft.com/en-us/library/windowsazure/jj835085.aspx](http://msdn.microsoft.com/en-us/library/windowsazure/jj835085.aspx#bk_Quick)).  I thought it would be useful to share the script of my demo and the slight modifications I have made to the tutorial if it will help anyone else out.

To begin, the PowerShell cmdlets should be installed from the Windows Azure website ([https://www.windowsazure.com/en-us/manage/downloads/](https://www.windowsazure.com/en-us/manage/downloads/)).  This is a simple install that uses Web Platform Installer.  Remind everyone that the cmdlets only wrap calls to the Azure RESTful web service.  All of this could be accomplished using a browser or [Fiddler](http://www.fiddler2.com/).

Now you should give the audience a heads up that Powershell command prompt needs to be opened as an Administrator.  You will need to set the execution policy to RemoteSigned and this requires administrator privileges.  This is done by simply running `Set-ExecutionPolicy RemoteSigned`.  At this point we can import the azure functionality by calling `Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\Powershell\Azure\Azure.psd1"`.  You would omit the **(x86)** moniker if you are on an 32-bit machine.  Here you would explain that the psd1 file has been signed by a trusted publisher (Microsoft) but was downloaded from the internet, so you would need to upgrade your ExecutionPolicy to run it.  Someone may ask if it's possible to use **AllSigned** or **Unrestricted** and of course it is possible, but we always try to apply the [Principle of least privilege](http://en.wikipedia.org/wiki/Principle_of_least_privilege).

Next, you can go into a small spill about Windows Azure publish settings.  You have two viable options for selecting the publish settings, either manual or by using a.publishsettings file.  You would have to set specific variables to appopriate values if you wished to accomplish this manually, however the demo will use the automated method.  The publish settings file should be familiar to anyone who have used WebDeploy in the past, especially with Windows Azure.  To get the file, you would run the `Get-AzurePublishSettingsFile` function.  This function will open the browser to a special Windows Azure website that will download your file automatically.  If you're not logged in, it will prompt for a Windows Live ID login.  An important note to make is that it will download the first subscription's settings it finds.  If you are a co-administrator on multiple subscriptions, which is very likely in the enterprise, than this would not be a viable option.  The next step is easy.  Just call the `Import-AzurePublishSettingsFile` function with the location of the file as the first unnamed parameter.

Now that we are connected to our Azure subscription, we can start querying VM images and locations.  The logic I use to pull down my example VM image and Azure datacenter location is:

``` powershell
$tmName = ( `
        (Get-AzureVMImage | Select) `
        | Where { $_.Label -eq "Windows Server 2012, December 2012" } `
        | Select -First 1 `
    ).ImageName $lcName = ( `
        (Get-AzureLocation | Select) `
        | Where { $_.DisplayName -eq "East US" } | Select -First 1 `
    ).Name
```

We can break this down using the VM templates as an example.  First, the `Get-AzureVMImage` function returns a list of VM templates available for you in your Azure subscription.  This is a combination of the default templates and any template you create yourself and associate with your subscription.  If you try to perform a query directly against the function you will find that filtering is not performed at all.  We avoid this issue by enumerating the entire list of VM templates and then apply filtering (observe the subquery using `| Select`).  The rest of the logic is a very basic query that returns the first result of a match filter.  You can mention that this is not the most efficient query, but it is a great academic example.  The `Get-AzureVMImage` and `Get-AzureLocation` functions have parameters that can perform filtering for you.  The same logic is applied to the `Get-AzureLocation` function.

Now you can establish a couple of variables by using `$svName = "TestService"` and `$vmName = $svName + "VM"`.  Before we create the VM, we need to make sure that our Azure service name is globally unique.  We can call the `Test-AzureName` function and use the named parameter **Service** to accomplish this goal.  The function returns a boolean indicating whether the name is globally unique which is useful for Powershell scripts.  The actual call would be `Test-AzureName –Service $svName`.

Finally we can create the VM using the below command:

``` powershell
New-AzureQuickVM -Windows -name "SomeTestNameHere" -ImageName $tmName -ServiceName $svName -Location $lcName -Password "Test.1234"
```

If this command fails, it is commonly because you do not have a "default" storage account set.  That can be done using this command:

``` powershell
Set-AzureSubscription –SubscriptionName "AzureSubscriptionName" -CurrentStorageAccount "StorageName"
```

The actual provisioning does not happen until you start the VM, either using Powershell or the management interface.  At this point, I log into the Azure management portal ([http://manage.windowsazure.com](http://manage.windowsazure.com)) and show the audience the newly created VM.  I then start the VM so it cycles through the provisioning process on-screen.  After the VM is created, you should also be able to find the associated cloud service.  In reverse, if you want to make sure you **fully** remove the VM, you should remove the Virtual Machine Instance, Virtual Machine Disk (.vhd), Cloud Service, Storage Container and then Storage instance.  It is very common to find remnant storage instances and VM disks from past demos and cleaning up is an important process for both your sanity and your credit card's sanity.  I hope this script is helpful for anyone who wants to run through the process on their own time.
