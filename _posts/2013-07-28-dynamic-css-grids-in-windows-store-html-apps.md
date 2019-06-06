---
title: Dynamic CSS Grids in Windows Store HTML Apps
tags: [win-ui, css, html5]
---

I have been working with [Bootstrap](http://getbootstrap.com/) a lot lately and realized that I really like the flexible grid system. I can easily use the 12-columns to make a 2-column or 3-column layout on my webpage that is flexible and responsive. Sure, this is simple to do with traditional CSS, but I like the abstraction and the flexibility to change my mind later and not have to modify my CSS definitions. 

>HTML should really be used for markup and hierarchical layouts. Hand-writen CSS should be isolated to just your design 

I've always felt dirty when I hand wrote CSS styling for layout because it never seemed right. This should be baked-in or automated in some way. Naturally, when working with Windows Store applications I wanted something just as flexible as Bootstrap. After spending a couple of hours (unsuccessfully) integrating Bootstrap with the Windows Store HTML/JavaScript template, I decided to roll out my own. My goal was simple, I wanted to have a fixed amount of rows and columns and to be able to use CSS classes to indicate which row or column I would like to use. I also wanted to automate this so I would not have to write the CSS manually. 

To start, I created a very simple HTML layout. I reused most of the content from the Bootstrap marketing template: 

``` html
<div class="grid">
    <div class="row1 col1 colspan3">
        <h1>Hello, world!</h1>
        <p>This is a template for a simple marketing or informational website. It includes a large callout called the hero unit and three supporting pieces of content. Use it as a starting point to create something more unique.</p>
        <p>
            <a>Learn more »</a>
        </p>
    </div>
    <div class="row2 col1">
        <h2>Heading</h2>
        <p>Donec id elit non mi porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui. </p>
        <p>
            <a href="#">View details »</a>
        </p>
    </div>
    <div class="row2 col2">
        <h2>Heading</h2>
        <p>Donec id elit non mi porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui. </p>
        <p>
            <a href="#">View details »</a>
        </p>
    </div>
    <div class="row2 col3">
        <h2>Heading</h2>
        <p>Donec sed odio dui. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Vestibulum id ligula porta felis euismod semper. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus.</p>
        <p>
            <a href="#">View details »</a>
        </p>
    </div>
</div>  
```
    
I named the CSS classes that I would like to use first to make it clear that my intention is to affect layout. I could have easily done this using an attribute such as **data-col** or **data-rowspan** but I'm going to keep it simple for this post. In the future, I will move to using custom attributes for layout. To make this happen, I created a simple 3 columns x 2 rows grid. Since Windows Store apps use the IE10/11 engine, I can count on safely using the [Grid Layout properties] (http://msdn.microsoft.com/en-us/library/windows/apps/hh453256.aspx) introduced in IE10 (-ms-grid, -ms-grid-row, -ms-grid-column). A cool side note is that these properties reflect the CSS3 grid layout properties that have been spec'd out and already have a page on W3School's website (http://www.w3schools.com/cssref/css3_pr_grid-rows.asp, http://www.w3schools.com/cssref/css3_pr_grid-columns.asp). After a couple of minutes of typing, I came up with a style sheet that seemed to do the trick: 

```css
body {
    padding-top: 50px;
    padding-bottom: 20px;
    padding-left: 15px;
    padding-right: 15px;
}

.grid {
    display: -ms-grid;
    -ms-grid-columns: (auto)[3];
    -ms-grid-rows: (auto)[2];
}

.row1 {
    -ms-grid-row: 1;
}

.row2 {
    -ms-grid-row: 2;
}

.col1 {
    -ms-grid-column: 1;
}

.col2 {
    -ms-grid-column: 2;
}

.col3 {
    -ms-grid-column: 3;
}

.rowspan2 {
    -ms-grid-row-span: 2;
}

.colspan2 {
    -ms-grid-column-span: 2;
}

.colspan3 {
    -ms-grid-column-span: 3;
}


@media screen and (max-width: 505px) {
    .grid {
        display: inherit;
    }
}
```

This style sheet will simply allow me to have a grid layout where appropriate and to have a vertical layout when the app is narrow enough. Here are some example screenshots: 

![](/content/img/import_080813_1612_DynamicCSSG1.png)

![](/content/img/import_080813_1612_DynamicCSSG2.png)

You can see that the application dynamically re-flows the content when the app is too narrow and it also lays everything out in a grid format as expected. This is great, but it would be even better if I can automate this whole process like Bootstrap does with its CSS/JS generator. This is definitely possible with LessCSS. I can write some LESS code to dynamically generate these classes based on how many rows or columns I would like. To do this, I would create a .LESS file in a browser-based LESS compiler. I haven't figured out how to do this in a Windows Store project, so I typically do this outside of Visual Studio or in a new project. I have even successfully created a second project in the Windows Store solution to hold my TypeScript and LessCSS files. I then used file linking to add these files into my Windows Store project. In Less file, I will add my base styles: 

```scss
body {
    padding-top: 50px;
    padding-bottom: 20px;
    padding-left: 15px;
    padding-right: 15px;
}

.grid {
    display: -ms-grid;
    -ms-grid-columns: auto;
    grid-columns: auto;
    -ms-grid-rows: auto;
    grid-rows: auto;
}

.loopingClass (~"col", @columnCount);
.loopingClass (~"row", @rowCount);

@media screen and (max-width: (@minWidth + 50)) {
    .grid {
        display: inherit;
    }
}
```

I will then add add some mixins so that I can generate the column/row or span classes:

```scss
.grid-marker (row, @marker) {
    -ms-grid-row: @marker;
    grid-row: @marker;
}

.grid-marker (col, @marker) {
    -ms-grid-column: @marker;
    grid-column: @marker;
}

.grid-span (row, @marker) {
    -ms-grid-row-span: @marker;
    grid-row-span: @marker;
}

.grid-span (col, @marker) {
    -ms-grid-column-span: @marker;
    grid-column-span: @marker;
}
```

After that, I will create a looping method:

``` scss
.loopingClass (@prefix, @index) when (@index > 0) {

    .@{prefix}@{index} {
    .grid-marker(@prefix, @index);
    }

    .@{prefix}span@{index}{
    .grid-span(@prefix, @index);
    }

    .loopingClass(@prefix, @index - 1);
}
```

And then call that looping method:

``` scss
.loopingClass (~"col", @columnCount);
.loopingClass (~"row", @rowCount);
```

And my generated Less file and resultant CSS will look like this:

``` scss
​@defaultCount: 3;
@columnCount: @defaultCount;
@rowCount: @defaultCount;
@minWidth: 500px;

.loopingClass (@prefix, @index) when (@index > 0) {

.@{prefix}@{index} {
    .grid-marker(@prefix, @index);
    }

.@{prefix}span@{index}{
    .grid-span(@prefix, @index);
}

    .loopingClass(@prefix, @index - 1);
}

.grid-marker (row, @marker) {
    -ms-grid-row: @marker;
    grid-row: @marker;
}

.grid-marker (col, @marker) {
    -ms-grid-column: @marker;
    grid-column: @marker;
}

.grid-span (row, @marker) {
    -ms-grid-row-span: @marker;
    grid-row-span: @marker;
}

.grid-span (col, @marker) {
    -ms-grid-column-span: @marker;
    grid-column-span: @marker;
}

// Base style
body {
    padding-top: 50px;
    padding-bottom: 20px;
    padding-left: 15px;
    padding-right: 15px;
}

// Grid style
.grid {
    display: -ms-grid;
    -ms-grid-columns: auto;
    grid-columns: auto;
    -ms-grid-rows: auto;
    grid-rows: auto;
}

// Row/Column and Span styles
.loopingClass (~"col", @columnCount);
.loopingClass (~"row", @rowCount);

// Media query to lay out grid horizontally
@media screen and (max-width: (@minWidth + 50)) {
    .grid {
        display: inherit;
    }
}
```

``` css
body {
    padding-top: 50px;
    padding-bottom: 20px;
    padding-left: 15px;
    padding-right: 15px;
}
.grid {
    display: -ms-grid;
    -ms-grid-columns: auto;
    grid-columns: auto;
    -ms-grid-rows: auto;
    grid-rows: auto;
}
.col3 {
    -ms-grid-column: 3;
    grid-column: 3;
}
.colspan3 {
    -ms-grid-column-span: 3;
    grid-column-span: 3;
}
.col2 {
    -ms-grid-column: 2;
    grid-column: 2;
}
.colspan2 {
    -ms-grid-column-span: 2;
    grid-column-span: 2;
}
.col1 {
    -ms-grid-column: 1;
    grid-column: 1;
}
.colspan1 {
    -ms-grid-column-span: 1;
    grid-column-span: 1;
}
.row3 {
    -ms-grid-row: 3;
    grid-row: 3;
}
.rowspan3 {
    -ms-grid-row-span: 3;
    grid-row-span: 3;
}
.row2 {
    -ms-grid-row: 2;
    grid-row: 2;
}
.rowspan2 {
    -ms-grid-row-span: 2;
    grid-row-span: 2;
}
.row1 {
    -ms-grid-row: 1;
    grid-row: 1;
}
.rowspan1 {
    -ms-grid-row-span: 1;
    grid-row-span: 1;
}
@media screen and (max-width: 550px) {
    .grid {
        display: inherit;
    }
}
```

If I use Visual Studio, I will also get a generated min.css file. If I apply that min.css file to Visual Studio, I will get the same styling as before (I switched to the light theme for the screenshots): 

![](/content/img/import_080813_1612_DynamicCSSG3.png)

![](/content/img/import_080813_1612_DynamicCSSG4.png)

To sum up, I was able to create a Less CSS file that allowed me to dynamically generate columns and rows based upon a **columnCount** and **rowCount** variable at the top of the file. I can then use this file to apply a dynamic grid format to my Windows Store application. 