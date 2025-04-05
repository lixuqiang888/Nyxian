## Implementing WebDevelopment into a iOS Coding app

This part is relatively matured and ironed out thanks to also the experience of [Mattycbtw](https://x.com/mattycbtw). This part explains exactly how to implement WebDevelopment.

## Preview Webcontent on iOS

To preview webcontent in our iOS coding app you need a `WKWebView` which is basically a fully featured View that can load webcontents such as from a html file or javascript file.

> Using `WKWebView` without anything else is not recommended as it lacks the functionality to open sub directories or files because of the sandbox restrictions, especially from the app data container.

## Hosting a mini WebServer and expose app data container content

Because `WKWebView` doesnt support sub file loading we can use swift packages such as [Swifter](https://github.com/httpswift/swifter) to host the app data container or where ever you wanna store projects to.