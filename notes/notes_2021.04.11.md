# HTML5 ViewPort

*2021.04.11*

On one of my webpages, I noticed that visiting the site on mobile was a worse experience than on my desktop browser, particularly with regard to input textboxes. The problem was that on a phone the input control was much smaller than the surrounding text and buttons, which makes it difficult to see and use. This problem is caused by the fact that fixed size web pages are too large to fit in the viewport, so mobile browsers scale down the entire web page to fit the screen. This can be solved by including the following meta tag from HTML5:

```
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
```

[solution src](https://www.w3schools.com/css/css_rwd_viewport.asp)

