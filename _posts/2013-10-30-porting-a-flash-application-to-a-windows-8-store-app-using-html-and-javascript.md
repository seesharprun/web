---
title: Porting a Flash Application to a Windows 8 Store App Using HTML and JavaScript
tags: [javascript, win-ui, html5]
---

This blog post is from a series of articles that I authored for the Intel Developer Zone.  Please visit the original article link for more information:

<http://software.intel.com/en-us/articles/memory-game-sample-app>

---

## Downloads
[Porting a FLASH application to a Windows* 8 Store app using HTML and Javascript](http://software.intel.com/en-us/file/intel-memory-game-sample-apppdf) [PDF 704KB]

[FLASH HTML Package Release](http://software.intel.com/en-us/file/flash-html-release-v2zip) [ZIP 3.7MB]

---

# Memory Game Sample App

---

This project demonstrates how to convert an existing Adobe Flash* game in to a Windows* Store app using the tools available in WinJS, HTML5, CSS3, and traditional JavaScript*. We chose the scenario of a memory card game to show how we can create a responsive and modern application using the toolsets and skills available in HTML5.

## The Challenge: Porting a Flash application to Windows Store HTML & JavaScript

When porting a Flash application to Windows Store, developers face a unique challenge as there isn’t a one-to-one mapping or conversion between the formats. While challenging, it is possible if you approach the situation as if you were porting a Flash application to HTML5.

Windows Store allows you to use HTML5, CSS3, and JavaScript when developing applications so that you can build using the tools that you are already familiar with. Even better, you already know what browser your users will run when executing the application so you are not burdened with the challenges of creating polyfills and ensuring cross-browser support. With Windows 8, your application is running with the same core that powers Internet Explorer* (IE) 10. and the same is true with Windows 8.1 and IE 11.

Because of this high compatibility, you can take an existing web application and start from there by simply adding your existing HTML code, JavaScript files, and CSS stylesheets. You can also take advantage of more dynamic languages such as Less CSS, CoffeeScript, and TypeScript. In addition, you can leverage third-party frameworks such as jQuery*, Bootstrap, and Sammy.js (among others) just as you would on a normal web site. For example, you can easily use the latest version of jQuery since you don’t have to worry about legacy IE support.

![Login screen](/content/img/import_memory-game-figure-1.png)

![Game screen](/content/img/import_memory-game-figure-2.png)

This example application is a flash game that showcases some of the common transitions, animations, and game logic found in any simple memory card game. We will build the Windows Store app using many of the same techniques that you have used to build a web site. We will also write the application’s CSS to be responsive so that it will be usable whether it is fullscreen or snapped to the side of the screen.

## Common Porting Considerations

You want to focus on a couple of things when porting a Flash application to Windows Store. The most challenging is the animations from Flash and ActionScript. It is possible in jQuery to create animations that are very specific and use keyframes. You can also create animations using the easy to read fluent syntax in jQuery.

For example, we want to animate the progress bar whenever the user “levels up.” The simplest form of this is to animate the progress bar’s value to increase to the new value:

``` javascript
var exp = 0.35; //Increase to 35%    

$progress.animate({ 
    value: exp 
}, 250);
```

This animation simply increases the progress bar’s value to 0.35 in a quarter of a second. In our demo application, we have a minimum of **0.00** and a maximum of **1.00**.

What if the user has enough experience to go to the next level? If the user earns 80% additional experience, the user would go up a new level and have 20% remaining. If we simply animated the progress bar to **0.20**, it would animate backwards and not look right. The solution to this is to chain animations and add delays.

``` javascript
// fancy animation to go to end of experience bar,
// flash the bar and then start a new bar
$progress.animate({
    value: maxExp
}, 250, 'linear', function () {
    $progress.delay(250).fadeOut(function () {
        $progress.animate({
            value: 0
        }, 5, function () {
            $progress.fadeIn('fast', function () {
                $progress.animate({
                    value: exp
                }, 250);
            });
        });
    })
});
```

This sequence first animates the progress bar to the maximum value (**1.00**) within a quarter of a second and then uses a callback function to chain the remainder of the animations. The next animation is a delay so that the max value animation finishes before we fade the progress bar out very quickly in 5 milliseconds. After that quick animation is done, we just fade in the progress bar immediately and animate the progress bar to its remaining value over a quarter of a second again. This ends up with a really neat progress bar animation that emulates the animation used in the Flash memory game.

We always have the advantage of CSS3, so we could implement this using the new style transformations. This would make sense as a great alternative for simpler animations where we may not necessarily want to write JavaScript logic. If you want to create a very complex animation, jQuery has support for step animations and animation queuing that allow you to create animations in much the same way you would create them on the timeline in the Flash environment.

There are two smaller porting notes that are easily missed but will ease your development process when porting a Flash or web application. First, if you get an animation or a CSS trick/hack to work in your environment, you again don’t have to worry about polyfills. Since you’re in an environment that doesn’t require cross-platform support, you can feel comfortable with any solution or browser trick you come up with for IE and implement in your application. Second, you can design your Windows Store app with a 1-to-1 correlation with your HTML web site pages or Flash application screens. The Windows Store app uses HTML pages and supports navigation along with query strings. You can design the flow and navigation of your application exactly in the same way you would design the flow of a web site.

## Building a Modern UI Windows Store App

Most of the common pitfalls in Windows Store development revolve around the Modern UI design philosophy and app certification. There are some small, simple things you can do to make sure your application looks and performs like one of the applications that comes built in to Windows 8. These small features can also help your application pass the certification process very quickly.

When developing Windows Store apps, we have access to the expansive WinJS framework. This includes managed DLLs, JavaScript files, CSS style sheets, and other features. This library allows you to integrate your application into Windows 8 features and functionality. For example, you can use the WinJS library to create a **flyout** panel that slides in from the right of the screen when you select an item from the settings menu. You can also use the WinJS library to integrate with the user’s styling, tile updates, push notifications, charms (search/share/play-to), and even the settings menu. While it is not strictly necessary to use the WinJS library, it is the easiest way to integrate your application and help it feel “native” to Windows 8. As an aside, many developers try to minimize or isolate their use of the WinJS library to a single file. This will keep your application portable and allow you to turn your application in to a web site easily by pulling out the HTML/JavaScript/CSS content and removing the script reference to your WinJS files. In the demo application, all of the WinJS code and logic are isolated to the **main.js** file in the **Scripts** folder.

All Modern UI applications that request the Internet connectivity permission must have a “Privacy Policy” hyperlink in the Settings Pane. This is a requirement to pass the Windows Store certification process. This hyperlink can either go to a page in the application or to an external URL to show the user your privacy policy. Most developers implement this by creating an internal page so that their application will work fine even if the user is offline. This is easily implemented in JavaScript using WinJS. In your default.js file created when you create a new Windows Store project, you have a group of callbacks handling common application lifecycle events such as startup and suspension. During your app.onactivated callback, just set the applicationcommands array to the list of commands you would like. The simplest example is below:

``` javascript
app.onactivated = function (args) {
    // .......Some logic here.......
    // Add privacy policy to settings charm
    WinJS.Application.onsettings = function (e) {

        e.detail.applicationcommands = { "help": { title: "Privacy policy", href: "/privacy.html" } };

        WinJS.UI.SettingsFlyout.populateSettings(e);

    };
    // .......More logic there.......
};
```

This simply creates an applicationcommands array with one hyperlink titled “Privacy policy” that goes to the **privacy.html** page in your application. On the privacy.html page, you can use custom attributes to indicate to Windows Store that you wish for this page to be shown as a flyout on the right-hand side of the page. These same HTML attributes can be used on any page that you would like to render as a Flyout that appears from the right-side of the screen.

``` html
<div aria-label="Help settings flyout" data-win-options="{settingsCommandId:&#39;help&#39;,width:&#39;narrow&#39;}" data-win-control="WinJS.UI.SettingsFlyout">
    <div class="win-ui-light win-header">
        <button class="win-backbutton" type="button"></button>
        <div class="win-label">Privacy policy</div>
    </div>
    <div class="win-content">
        <div class="win-settings-section">
            <p>This application does not collect any personal information.</p>
            <a href="http://www.intel.com/">Go to Intel&#39;s website</a>
        </div>
    </div>
</div>
```

This will render your link in the Settings menu that, when clicked, shows a popup of your Privacy Policy as shown below:

![Settings menu and privacy policy flyout](/content/img/import_memory-game-figure-3.png)

When designing your application, you must also make sure to support all variations of the snapped, filled, and full modes. You can do this easily using responsive DIV elements that float when there’s enough width and stack when there is not enough width for them to line up horizontally. You can also use a framework like Twitter bootstrap to handle this for you. In the picture below, I stack the memory game elements vertically and hide any elements that are not very important for the user to see when in snapped view. This will allow users to play the game while doing something else on their computers.

![](/content/img/import_memory-game-figure-4.png)

As an aside, you don’t necessarily have to make your application or game functional in the **snapped** view. It is perfectly fine to display a message that tells users they must expand the window to continue play. You do have to ensure that you don’t cut-off elements or make the application unusable if the user attempts to use the application in a different screen size or orientation.

Another point to remember is to test your application so that you know it is usable in the **filled** view. Many users work on an application on ¾ of the screen while a reader or music player runs in **snapped** view. A common certification failure reason is because the developer forgot to test the application on the **filled** ¾ view. Make sure your application responds to at least these three layouts and then support the **portrait** views if you have time.

## Additional Modern UI Design Considerations

Always make sure to test your CSS and design so that it renders whether or not the user is using the **Dark** or **Light** Windows 8 theme. It is a common error to hard-code your application’s background-color CSS style to a dark color because you have the dark theme and light-colored text and then forget to handle the scenario where the user opts for the light theme with dark-colored text. By default, Windows 8 will infer its styling for many of the HTML elements based upon the styling that the user has chosen in their system settings.

If you accept input into your application, please be sure to use the built-in HTML `<input>` elements. This will ensure that any keyboard and accessibility functionality supported by the OS will remain intact when the user tries to input form data in your application. For example, your users may set up their machine for Speech Recognition. By using the built-in input elements, you don’t have to worry about writing custom code to support this scenario. Another common example is the virtual keyboard. Every manufacturer has a different built-in configuration on when its virtual keyboard is shown to the user. This can be further compounded when the user customizes these settings. With the advent of different form factors for Windows 8 machines, you don’t want to worry or think about when to show or hide the virtual keyboard. By using the built-in controls, you allow the OS to handle what input type is appropriate for the user at a certain time. It would be very difficult to re-implement all of this functionality if you used a custom control so it is always advisable to style or modify the built-in HTML controls when customization is needed.

It is always advisable to leverage the built-in styling provided by the built-in stylesheets. You can access your user’s background, theme, and highlight colors (among others) by simply referencing the CSS styles in these stylesheets. You can also use the built-in icons provided by the Windows Store framework for buttons. You would simply apply the CSS classes provided to an input element of type **submit**.

## Tips/Tricks for Developing Tablet Applications

When building an app for touch and Windows Store, you have a lot more considerations than just a typical web or desktop application. Thankfully, you can solve most of these issues using the same techniques you would to create a responsive web site that supports mobile users.

## Media Queries

Windows Store CSS stylesheets come with a set of built-in media queries. They reference different views and allow you to apply specific styling to a specific view without worrying about your end-users’ resolutions. You can pick these custom queries to indicate portrait or landscape orientation, and you can also use them to indicate if your application is snapped, filled, or fullscreen. This allows you to design for those scenarios without knowing each end-user’s device resolution.

``` css
@media screen and (-ms-view-state: filled), screen and (-ms-view-state: snapped) {

    body {
        overflow-y: hidden;
        overflow-x: hidden;
    }

    div.container {
        background-repeat: repeat-y;
        height: 100%;
        width: 100%;
    }
}
```

In this example, I want my application to hide the scrollbars and have the DIV element with a CSS class of **container** fill up 100% of the screen’s width and height if the application is in either **filled** or **snapped** view. The comma in the CSS media query designates an OR condition and allows you to reuse the same set of CSS definitions for multiple scenarios.

Windows 8.1 will come with even more fine-tuned support since users can dynamically size their snapped and filled views. Users can also do a 50/50 split view so you would style this in almost the same way as you would a responsive web site. Since users will be able to “resize” your application at will, I strongly suggest using a framework such as Twitter Bootstrap for this purpose. It will help lower the amount of time you spend developing, testing, and designing different resolutions. Bootstrap will have your elements stack if there is not enough width for your elements to fit on-screen. This is one of the most common ways to create responsive web sites on the Internet today.

## Touch Usability

Make sure your click objects (targets) are large enough to support large fingers on high resolution displays. A 50-by-50 pixel target is hard for users to click if they have a large tablet set at a very high resolution. Always assume you have to make targets big enough to touch on all platforms. Also consider 1920x1080 resolution Ultrabook™ devices as they have smaller screens with very high resolution displays. This will make it even more difficult for users to select small targets. Secondly, don’t group items too close together as users may accidentally touch multiple when they intend to touch one. Give your elements enough space so that users will have room around their fingers. A good example of this is the amount of spacing between digits on a landline telephone.

![Memory tiles with spacing](/content/img/import_memory-game-figure-5.png)

Make sure to design for touch and consider the differences between it and standard mouse input. In the Windows Store touch events, you rarely have a finger enter the hover state. While hover is useful when using a mouse, it isn’t something you see when users are using their hands for the touch display. Make sure you design your application to be usable even if the user doesn’t see a hover notification. It is never a good idea to put “mission critical” information on a hover tooltip or popup.

Windows Store apps use two different scrollbars for touch scrolling (swiping) and for mouse scrolling. Remember this if you need to design a scrollbar. You will have to replace two different CSS styles to support both scrollbars. Also remember this when testing or designing your application. The Windows Store runtime is smart enough to know when you switch inputs, and it will appropriately switch the scrollbars for you.

![Touch scrollbar](/content/img/import_memory-game-figure-6.png)

![Mouse scrollbar](/content/img/import_memory-game-figure-7.png)

Finally, design your application for horizontal scrolling. Horizontal scrolling is the norm in Windows Store apps and may be a bit different than the vertical scrolling we are all used to. It allows you to put a lot of elements on the screen at once and support swipe gestures without the user having to spend a long time going through a long list. This demo application does not have any large lists, but if it did, you would create a horizontal grid of elements that allow swiping to scroll through the view. You would also make sure that the list of elements shows a little bit of what’s off-screen. This is called “teasing the content” and lets users know that there is more content waiting for them if they wish to scroll.

## Unique Challenges with this Application

The Memory application is a very common Flash game that requires a lot of the same methods and tools you would use when converting Flash to HTML5 by hand. Because this application is animation intensive, it was very difficult to convert the animations into something usable within the web. Much of it was accomplished using the jQuery animation library. The library allows you to queue animations and use logic to determine when animations will occur. This allows you to create a pseudo-timeline of animations very similar to how animations are handled in Flash. As an alternative, jQuery supports step animations that function very similar to tweens. You can learn more about jQuery’s animate functionality by visiting the API page (http://api.jquery.com/animate/).

For flipping boxes, we leveraged the jQuery.flip library (http://lab.smashup.it/flip/) to flip the boxes over. The downside was that it was a third-party library and didn’t allow the use of the jQuery animation queue so that animations can be staggered. This was solved by using an iterator and modifying the animation’s length based on it’s position on the grid. This allowed all of the animations to be fired as they are reached logically in the code, and for the animations to stagger as if they were of different lengths. I just incremented the animation lengths as I iterated through the two-dimensional list so that the animations would appear queued or “in-order.”

``` javascript
$table = $('table.gameTable');
$tableRows = $table.find('tr');
$tableRows.each(function (rowIndex, tableRow) {

    $(tableRow).find('td div.square').each(function (cellIndex, tableCell) {

        var speedCalc = 250 + ((rowIndex + cellIndex) * 50);

        $(tableCell).flip({
            direction: 'lr',
            color: '#4CA786',
            speed: speedCalc
        });

    });

});
```

![jQuery* flip animation](/content/img/import_memory-game-figure-8.png)

One of the interesting challenges with this game was making the table responsive. The table was too wide for snapped view on most displays and needed to be modified using Media Queries. We needed to make sure the table was available for play even if it’s in the snapped view. To accomplish this, we simply used the media queries to resize the table elements and to horizontally center the table in snapped view. Regularly, the table is on the far right of the application. The CSS styles hid any menu items that were not selected. The table was then placed below the selected menu items so that users can see what game they are playing. This was done by removing the **float: left** CSS rules from the DIV element by setting them back to the default.

``` css
@media screen and (-ms-view-state: snapped) {

    div.column, div.area {
        float: inherit;
        width: auto;
        margin: inherit;
    }
}
```

Finally, it is sometimes easier to use a third-party tool for testing and editing the HTML of the application. Unlike ASP.Net development, Windows Store apps require you to deploy the application to your machine (or a simulator/remote machine) to debug. In ASP.Net, you could simply use the SignalR browser link to refresh your browser on changes. For this application, Adobe Edge Code CC (Preview)  was used to test out new styles and write JavaScript logic before copying it into the Windows 8 app. This tool allows you to link it to a browser and have the browser’s page update anytime you make changes. In the current preview, Edge Code CC only supports Chrome* so you do have to be aware of any small browser differences. You can also use Edge Reflow to test your responsive layouts and Edge Animate to create true CSS3 animations.

![Adobe Edge Cloud](/content/img/import_memory-game-figure-9.png)

## Future enhancements

Moving forward, there are definitely some improvements that can be made to this application. First, it could support the **filled** view a bit better and have a horizontal layout as opposed to mimicking the vertical layout from the **snapped** view. Second, there is some room for more animations and making the application more slick and responsive. Thankfully, the foundation is there to do both easily by just adding more jQuery animations and by tweaking the existing CSS styles.

## Summary

Building an HTML5 application for Windows 8 is very simple since we can re-use a lot of the same techniques and tools that we use for traditional web development. Without the worries of cross-browser support we can very quickly build nice applications using all of the features of HTML5 today.

<p><em><small>Intel, the Intel logo, and Ultrabook are trademarks of Intel Corporation in the U.S. and/or other countries.<br />
Copyright © 2013 Intel Corporation. All rights reserved.<br />
Other names and brands may be claimed as the property of others.</small></em></p>