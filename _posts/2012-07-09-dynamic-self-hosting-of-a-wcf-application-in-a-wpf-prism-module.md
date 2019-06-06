---
title: Dynamic Self-Hosting of a WCF Application in a WPF PRISM Module
tags: [visual-studio, wcf, wpf, xaml, prism]
---

Typically when developing an enterprise-class desktop application, a WCF service would be set up to separate the presentation tier from any tiers below it (i.e. Business Logic, Data Access). Self-hosting of a WCF service has always been an option, but many times we shy away from it because that would bring about tight coupling between our UI code and processing layers.

The advantage to self-hosting is a lightweight and easy n-tier application that we can install without having to build a complex installer or forcing our users to use IIS. Leveraging PRISM and Unity, we can actually build the "back-end" of our application, keep it's functionality separate from our UI code while still allowing the desktop application to self-host the WCF service. Using this model, the application will be lightweight enough that we can use ClickOnce to distribute our multi-tiered application. The modularity of PRISM lends itself very well to this purpose.

The trick lies in the Module functionality of PRISM. This won't go over the details of PRISM, but in short a Module is an entirely self-contained unit in the application that may be loaded statically, or loaded in a dynamic (optional) manner. We can build a Module that holds our Service implementation.

![PRISM Visual Studio Solution](/content/img/import_070912_1248_DynamicSelf11.png)

In this PRISM application example, we have a couple of things:

* A **ServiceModule** that will contain the service implementation, code to self-host the service and code to create a service client.
* A **ConsumptionModule** that will use the service without having a reference to the service.
* **DataContracts**, **Common** & **ServiceInterfaces** class libraries that are shared by all the modules.
* A PRISM **Shell**.

The DataContracts and Service Interfaces associated with our service can be put into a common project so that every other module will have access to these classes and can use them to interact with the WCF service. A quick sample implementation is below:

``` c#
//Required if using ServiceHost & Unity instance resolution
[ServiceBehavior(InstanceContextMode = InstanceContextMode.Single)]
public class DemoService : IDemoService
{
    public TimeInfo GetUTCTime()
    {
        Thread.Sleep(TimeSpan.FromSeconds(2d));

        return new TimeInfo
        {
            Time = DateTime.UtcNow.ToLongTimeString()
        };
    }
}

[ServiceContract]
public interface IDemoService
{
    [OperationContract]
    TimeInfo GetUTCTime();
}
```

In the Service module, in it's Initalize method, we would simply use the ServiceHost class to stand up the service:

``` c#
using System;
using System.ServiceModel;
using Microsoft.Practices.Prism.Modularity;
using Microsoft.Practices.Unity;
using ServiceInterfaces;

namespace ServiceModule
{
    public class ModuleInit : IModule
    {
        private IUnityContainer _container;
        private const string _serviceLocation = "net.pipe://localhost/PrismServicesSample/Client/DemoService/";

        public ModuleInit(IUnityContainer container)
        {
            _container = container;
        }

        #region IModule Members

        public void Initialize()
        {
            // Hosting the service
            IDemoService service = new DemoService();
            Uri address = new Uri(_serviceLocation);
            ServiceHost host = new ServiceHost(service, new Uri(_serviceLocation));
            host.Open();
            Console.Out.WriteLine(String.Format("The service is hosted ready at {0}", address.OriginalString));

            // Getting a client
            ChannelFactory factory = new ChannelFactory(
               new NetNamedPipeBinding(),
               new EndpointAddress(_serviceLocation)
            );
            IDemoService channelClient = factory.CreateChannel();
            _container.RegisterInstance(channelClient);
            Console.Out.WriteLine(String.Format("The client channel is ready at {0}", factory.Endpoint.Address.Uri.OriginalString));
        }

        #endregion
    }
}
```

In this example, I did set the \_serviceLocation to be a constant. It really doesn't matter what you set it to, as long as it's unique on the machine. I have even (at one time) randomly generated a location to host the service. The consuming modules in your WPF application will not know or care where the service is hosted because they will be consuming the service using Unity and it's interface. At this point you can also go another step further and split the code hosting the service and the code creating a client (ChannelFactory) into two separate modules. This is a bit more work and maintenance but it completely decouples your service layer. If your application was using WCF self-hosting and you decided to host your WCF service using Windows Service or IIS, you would have no problem with it since the service code is completely decoupled. You could also "hot-swap" your back-end, even though this has less real world uses.

One downside I did find was that I was not able to build a working ClickOnce deployment using the "soft" references in the ModuleCatalog. It seems that the project requires you to add a project reference to all of the modules in order to distribute them with the ClickOnce executable. Not a big deal for small static projects, but for projects that dynamically load modules, this would be something you have to consider.

[Attachment: PrismServicesSample.zip](http://1drv.ms/1luAnVY)
