# kaptionator
ios10  swift-3kaptionator app for custom Messages Stickers

![screenshot1](http://billdonner.com/kaptionatorpic/ka1.png)

![screenshot2](http://billdonner.com/kaptionatorpic/ka2.png)

![screenshot3](http://billdonner.com/kaptionatorpic/ka3.png)
designed by gary martin and bill donner

swift-3 code by bill donner

in the app store as Candidatez and Emogeez

## how to make a single pack app for AppStore

You can clone the single app version, add your own images, and offer thru if store. The sample target uses local resource images via CatalogLocalViewController, but you can substitute CatalogRemoteViewController if desired.

in the app store as Candidatez
in the app store as Emogeez

Steps:

Assuming you are building an app called MyPak 

- add a new target iMessage application with a bundle id of xxxx: 
- Generate mypak-stickerspackimages containing basic images
- Generate manifest.json file describing images, adding captions
- Add a group capability in Xcode for group.com.xxxx.mypak

## how to make the  kaptionator app

This target is an app that accepts sticker input from iCloud,iTunes, and photocapture. It has no builtin resources. Just build and run in xcode


## Requirements

You'll need some properly sized sticker images to utilize any of this. You can find some here: 

[http://billdonner.com/kaptionatorpic/testimages/](http://billdonner.com/kaptionatorpic/testimages/)


### Build

Xcode 8.0, iOS 10.0 SDK, tvOS 10.0 SDK 

### Runtime

iOS 10.0  

### License

Apache 2.0

Copyright (C) 2016 Bill Donner. All rights reserved.


