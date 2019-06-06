---
title: Adding SyntaxHighlighter to a SharePoint 2013 master page
tags: [javascript, html5, sharepoint]
---

So I like to use my SharePoint blogging list because it provides a lot of convenience and allows me to simply publish my posts using Word. One thing I did miss was syntax highlighting support that came as a plugin with my previous blogging/CMS engines ([BlogEngine.NET](http://www.dotnetblogengine.net/), [DasBlog](http://dasblog.codeplex.com/), [umbraco](http://umbraco.com/), [Orchard](http://www.orchardproject.net/)). What I wanted to do was to make the smallest modification possible to my SP master page to enable syntax highlighting. 

Maybe it's because I'm old school, but I never stopped liking [SyntaxHighlighter](http://alexgorbatchev.com/SyntaxHighlighter/). I know Microsoft has come up with an even better one and CodeMirror is outstanding, but I'm stuck in my ways. So I decided to append the main CSS and JS files to the end of my head HTML element.

``` html
<script type="text/javascript" src="http://alexgorbatchev.com/pub/sh/current/scripts/shCore.js"></script>
<link href="http://alexgorbatchev.com/pub/sh/current/styles/shCore.css" rel="stylesheet" type="text/css" />
<link href="http://alexgorbatchev.com/pub/sh/current/styles/shThemeDefault.css" rel="stylesheet" type="text/css" />
```

I also decided to use the Autoloader. Just this summer alone, I have code snippets using CSS, HTML, PowerShell, JavaScript and C#. As opposed to including those JavaScript files on every page, the author of plugin has graciously crated an Autoloader js file that loads your syntax brushes on-demand. The one downside is that you have to create a pre-defined list of brush to JavaScript file pairings as opposed to letting it all by dynamically determined. You can go here (http://alexgorbatchev.com/SyntaxHighlighter/manual/api/autoloader.html) to read more about it. I accomplished this by adding another line after my main CSS and JS files: 

``` html
<script type="text/javascript" src="http://alexgorbatchev.com/pub/sh/current/scripts/shAutoloader.js"></script>
```

I then went to the bottom of the document and added the logic (within script tags of course) to create those pre-defined pairings: 

``` javascript
function path()
{
    var args = arguments,
        result = []
        ;

    for(var i = 0; i < args.length; i++)
        result.push(args[i].replace('@', 'http://alexgorbatchev.com/pub/sh/current/scripts/'));

    return result
};

function highlightSyntax() {

    SyntaxHighlighter.autoloader.apply(null, path(
        'applescript            @shBrushAppleScript.js',
        'actionscript3 as3      @shBrushAS3.js',
        'bash shell             @shBrushBash.js',
        'coldfusion cf          @shBrushColdFusion.js',
        'cpp c                  @shBrushCpp.js',
        'c# c-sharp csharp      @shBrushCSharp.js',
        'css                    @shBrushCss.js',
        'delphi pascal          @shBrushDelphi.js',
        'diff patch pas         @shBrushDiff.js',
        'erl erlang             @shBrushErlang.js',
        'groovy                 @shBrushGroovy.js',
        'java                   @shBrushJava.js',
        'jfx javafx             @shBrushJavaFX.js',
        'js jscript javascript  @shBrushJScript.js',
        'perl pl                @shBrushPerl.js',
        'php                    @shBrushPhp.js',
        'text plain             @shBrushPlain.js',
        'ps powershell         @shBrushPowerShell.js',
        'py python              @shBrushPython.js',
        'ruby rails ror rb      @shBrushRuby.js',
        'sass scss              @shBrushSass.js',
        'scala                  @shBrushScala.js',
        'sql                    @shBrushSql.js',
        'vb vbnet               @shBrushVb.js',
        'xml xhtml xslt html    @shBrushXml.js'
    ));

    SyntaxHighlighter.all();
}
_spBodyOnLoadFunctionNames.push("highlightSyntax");
```

After that, I only have to add a specific class to my pre tags in order to enable syntax highlighting: 

``` html
<pre class="brush: html"></pre>
```

Here's a link to my JSFiddle (http://jsfiddle.net/masenkablast/EmwrQ/) where you can play with a couple of examples and try out SyntaxHighlighter yourself. Once you are done customizing, you can just copy and paste the logic into your own SharePoint master page.