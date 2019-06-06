---
title: Dude, Where’s My Content-Length?
tags: [win-ui, xaml]
---

You probably have heard me preach the gospel of Portable Class Libraries sometime within the last year. I have been doing MVVM development for a long time and PCLs give me the flexibility to put my VMs and Models/Data in a shared library so I can maximize my code re-use. I was officially converted when I was building a Windows Store application for sCoolTV. They wanted an application to run on the Windows 8 platform to play their instructional videos. 

After finishing the application, I got a request to build a Windows Phone 7.5 version of the same application. Once I was done collecting myself from the floor, I had to come up with a game plan. I was only given a week to do the original application and I had less than a week to do the port. I always develop (by default) using the Model-View-ViewModel pattern so I quickly placed my ViewModel and Model projects into a Portable Class Library. I then split my data retrieval from my transport objects and created a Data PCL for all logic involved with retrieving data.

The most difficult part of the conversion was letting go of the [WebClient](http://msdn.microsoft.com/en-us/library/system.net.webclient.aspx) class I loved so much and switching to good-old-fashioned [WebRequest](http://msdn.microsoft.com/en-us/library/system.net.webrequest.aspx). The WebRequest base class was common between Windows Store and Windows Phone. After all of this was said and done, I simply had to create some XAML views and bind them to my existing ViewModels. Everything worked great and I was a happy camper. 

Not too long after the application was submitted to the store, we all of a sudden saw bug reports that the application was failing to get data from it's source. I used WebRequest to make HTTP **POST** requests to a PHP back-end. I would make a POST request with an empty body and they would parse the querystring to find out what I exactly wanted. Turns out, they moved from an Apache box to Windows Azure. With this change, there was a small, easily mistaken issue. The old box was using the **HTTP 1.0** spec, while the new shiny Windows Server virtual machine is using the **HTTP 1.1** spec. With the new spec, HTTP 1.1 requires you to send a Content-Length (of course there are exceptions) are part of any POST call. We diagnosed the issue and found that I was not sending a Content-Length header as part of my **POST** requests. If I wasn't in such a hurry, I would've quickly realized that the response from the server stated `Content-Length header expected`. 

Since I'm always sending an empty request body, I said "this is easy! I'll set [WebRequest.ContentLength](http://msdn.microsoft.com/en-us/library/system.net.webrequest.contentlength.aspx) to 0". This is the nightmare began. It was an unimplemented property that threw the [NotImplementedException](http://msdn.microsoft.com/en-us/library/system.notimplementedexception.aspx) anytime you tried to set it. The intention was that you would inherit from WebRequest, and set the ContentLength using your new class. You could also actually send content as part of your request body and it will automagically determine the Content-Length header. Once I got the keyboard impression off of my forehead, I went and implemented my POST requests like this: 

``` c#
​private async Task GetPOSTJson(Uri url)
{
    var httpClient = WebRequest.CreateHttp(url);
    httpClient.ContentType = "application/json";
    httpClient.Method = "POST";

    try
    {
        WebResponse output = null;
        try
        {
            var streamTask = Task.Factory.FromAsync(httpClient.BeginGetRequestStream, httpClient.EndGetRequestStream, null);
            using (Stream stream = await streamTask)
            using (StreamWriter streamWriter = new StreamWriter(stream))
            {
                await streamWriter.WriteAsync(String.Empty);
            }
            output = await Task.Factory.FromAsync(httpClient.BeginGetResponse, httpClient.EndGetResponse, TaskCreationOptions.None);
        }
        catch (Exception e)
        {
            string error = e.ToString();
            Debug.WriteLine(error);
        }

        string jsonOutput = String.Empty;
        if (output != null)
        {
            using (var responseStream = output.GetResponseStream())
            using (var reader = new StreamReader(responseStream))
            {
                jsonOutput = await reader.ReadToEndAsync();
            }
        }

        return jsonOutput;
    }
    catch (WebException)
    {
        // ... Error Handling & Logging logic here ...
        return String.Empty;
    }
}
```
    
Please forgive me for my ugly code. I hope this helps someone else if they are ever stuck with the same issue. I've seen this one more time since when integrating a legacy system to a new application hosted on IIS. Good job Microsoft for following (http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.4) to the letter!