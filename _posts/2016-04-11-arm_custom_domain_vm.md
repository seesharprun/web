---
title: Mapping a Custom Domain to an Azure ARM (v2) Virtual Machine
featured: true
tags: [azure, iaas]
---

Back when using Cloud Services, every Virtual Machine resided within a Cloud Service and the service stood as both a networking and security scope for Virtual Machines. You could easily assign a friendly name to a Cloud Service and see it used as your **Fully-Qualified Domain Name (FQDN)**. For example, a Cloud Service named **demoapp** would be hosted at *http://demoapp.cloudapp.net*

Now that we have moved to Azure Resource Manager, and Virtual Machines no longer need Cloud Services, how do we assign a domain name to our Virtual Machines? Turns out, it's simpler than it was in the past!

First, a little background into networking using Azure Resource Manager...

Virtual Machines reside in a **Virtual Network (VNET)** and do not need a seperate container service to exist (like Cloud Services). When you create the VNET, you have to specify a region for the VNET. If you want to implement network connectivity for a Virtual Machine, you would add a **Network Interface Card (NIC)**. Now the Virtual Machine has private connectivity with other Virtual Machines within the VNET. Other Virtual Machines can talk to your first Virtual Machine using their private IP Addresses which are simply IP addresses internal to that VNET.

![Private Connectivity](/content/img/import_private.PNG)

If you want a Virtual Machine to communicate with the "outside world", you would add a **Public IP Address (PIP)**. This PIP would be it's own resource and it can be associated (bound) to your NIC. Once bound, the outside world can communicate with your Virtual Machine using the assigned IP Address. The best part of this relationship is that the PIP is it's own resource and can be un-bound from this Virtual Machine and possibly used with other Virtual Machines.

![Public Connectivity](/content/img/import_public.PNG)

If you want to implement a domain name, you simply configure the **domainnamelabel** setting of the PIP. This setting, once configured, will give you a FQDN within the region of the VNET. 

> For example, if your VNET was created in **East US**, and your *domainnamelabel* was **testapp**, your *FQDN* will be: **testapp.eastus.cloudapp.azure.com**.

![FQDN](/content/img/import_domain.PNG)
 
Public IP Addresses can also optionally be used with a **Load Balancer** instead of Network Interface card for scenarios where you want to distribute load between multiple Virtual Machines:

![Load Balanced VMs with FQDN](/content/img/import_loadbalanced.PNG)