---
title: Leveraging Visual Studio 2012 for Node.js development
tags: [javascript, nodejs, visual-studio]
---

Lately I have been working through many good tutorials and books on Node.js. I have always wondered whether or not I could use Visual Studio as my development environment when developing for Node.js. I had a couple of things I wanted; First, I wanted to be able to use the syntax highlighting and formatting tools within Visual Studio. Second, I wanted to take advantage of the improved JavaScript Intellisense available in Visual Studio. Finally, I wanted to integrate the Run step in Visual Studio with the Node.js server.

I have been reading an excellent eBook, “Node Cookbook” published by Packt Publishing. The recipes are great and I have been using Notepad++ for editing my JS files. While working through this book, I realized that I wanted to accomplish all of this using Visual Studio mostly for the syntax and formatting support. I also wanted a setup that can work with many tutorials that leverage Node.js like AngularJS.

To start, I visited the [Node.js website](http://www.nodejs.org/) and downloaded the x86 version of Node.js for Windows. If you download the default package, you will most likely get the x64 version. Both versions can live side-by-side but only the x86 version is supported if you ever decided to download the Windows Azure SDK for Node.js.

This is enough to get started and build a simple web page. I created a JavaScript file called **server.js** with the below content:

``` javascript
var url = require('url'),
    path = require('path'),
    http = require('http')
        .createServer(function (request, response) {
            var dest = url.parse(request.url).pathname;
            console.log('url [' + dest + '] requested');
            response.writeHead(200, { 'Content-Type': 'text/html' });
            response.end('Hello World');
        }).listen(8080);
```

I then opened a command prompt at the directory of the JavaScript file and ran the node command with **server.js** as the first command line parameter. This started my webserver and I could navigate to **localhost:8080** to verify. It was my goal to replicate this process using Visual Studio. To start, create a new web site solution. You can save the .sln file anywhere you like:

![Visual Studio New Web Site Solution](/content/img/import_VS2012NewWebSite_thumb.jpg)

Next, add your **server.js** file into the solution so you can use the Visual Studio editor to modify the JavaScript file. This fulfills the first goal of leveraging Visual Studio’s great source code editor. You should notice that you get some basic Intellisense as you are editing your JavaScript file. Unfortunately, this Intellisense only covers core JavaScript functionality. We would like Intellisense to also cover some of the Node.js functionality. Thankfully, there are active projects to bring full .NET-style documentation to many JavaScript frameworks. You may already be familiar with the excellent vsdoc file available with Visual Studio.

I have included two links below to the two best projects I have found. The [Node.js Visual Studio Intellisense project](https://bitbucket.org/kurouninn/node.js-visualstudio-intellisense) created by kurouninn and hosted on BitBucket seems to be the most complete in my opinion. Any JavaScript file with the appropriate xml comments will allow Visual Studio to list the method signatures in it’s Intellisense drop-down list. In order to do this with Node.js, all you would need is to include the js file[s] included in any of the two mentioned vsdoc projects and add a reference to the top of your javascript file. If we were using kurouninn’s vsdoc files, we would add this reference at the beginning of our server.js file:

``` javascript     
/// <reference path="./nodelib/node.js" />
```

This would give us Intellisense like below:

![Node.js Intellisense](/content/img/import_VS2012JSIntellisense_thumb.jpg)

Now we have tackled our goal of getting Syntax Highlighting and Intellisense. The final thing I wished to do was to automate the process of hosting the app using Visual Studio. This was the easiest part by far. In either a Web Site or Web Application project, you can specify external programs as your Start Action. In order to start Node.js, I modified the Start action to run Windows `cmd.exe` with `/k node server.js & pause & exit` as the command line arguments. I also specified the Working directory to be the location of the files I would like to host. You can change Visual Studio so it won’t start it’s development server if you wish, but this is entirely optional. Your settings should be like below:

![Visual Studio Project Property Page](/content/img/import_VS2012NodeJSSettings_thumb.jpg)

With this set, all you need to do is to select **Start without Debugging** and you can test your Node.js app. Open any browser window and navigate to your website using the assigned port (In our example, 8080). At this point you have a simple workflow that is familiar to any .NET developer. You can use Visual Studio to add new directories, files and modify static content files using the editors that you are already familiar with. You’ll even get the added bonus of enhanced Intellisense for Node.js and a one-click process for firing up Node.js. You can also take it a step further and modify the arguments to also launch the browser using `start http://localhost:8080`. Of course it is much simpler to just use a command prompt and Notepad (or Notepad++), but I believe there is a value to the enhanced editors available in Visual Studio.

---

### Reference

* *Node.js* http://node.js.org
* *Node Cookbook* http://www.packtpub.com/node-to-guide-in-the-art-of-asynchronous-server-side-javascript-cookbook/book
* *Notepad++* http://notepad-plus-plus.org
* *Node.js VSDoc project* https://github.com/kinogam/node-vsdoc/blob/master/nd/vsdoc-test.js
* *Node.js VS Intellisense* https://bitbucket.org/kurouninn/node.js-visualstudio-intellisense
* *Stackoverflow article* http://stackoverflow.com/questions/9108686/develop-nodejs-with-visual-studio-2010
