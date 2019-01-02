## shoutcast-sailfish

A Shoutcast player for SailfishOS. It is a simple but effective one.

I use and develop it on my Oneplus One.

See the [screenshots](https://github.com/wdehoog/shoutcast-sailfish/tree/master/screenshots) directory for how it looks.

A package can be found in my [OBS repository]( http://repo.merproject.org/obs/home:/wdehoog:/shoutcast-sailfish/sailfish_latest_armv7hl/). 

### Issues
  * The shoutcast api service is sometimes offline. The app can try to use information 'scraped' from the shoutcast home page but this is WIP and quit often the home page is offline as well. So this feature will probably disappear.
  * On my phone buffering of audio streams is terrible. I have tried two solutions to allow to change the (gstreamer) buffer size:
    * Patch gstreamer. See https://api.merproject.org/package/show/home:wdehoog:gstreamer/gst-plugins-base
    * Patch qtmultimedia. See https://api.merproject.org/package/show/home:wdehoog/qtmultimedia

    Both solutions seem to work. Using a buffer size of 256000 makes buffering of the qml mediaplayer fast and hickups are gone.

### Features
  * Browse by Genre
  * List Top 500
  * Search by 'Now Playing' or Keywords
  * Tune in on a Station 
  * Pause/Play

#### Usage
  * Press a Station will start playing it
  * A busy indicator will spin around the play Button while buffering.
  * A white bar at the top of the player area indicates the buffering progress.
  * Swipe the player area left/right will load previous/next Station (only for pages having a Station list).
    When swiped away the player can be restored using one of the pull/push menus
  * When configured to do so instead of playing a stream in the built in player it will call `openUri` on a MPris Player.
  * Cover page buttons allow play/pause/prev/next
  * Mpris controls (for example on lock page) allow play/pause/prev/next

### Development
This project is developed with the Sailfish OS IDE (QT Creator). 

### Translations
Translation is done using Qt Quick Internationalisation. If you want to contribute a translation take shoutcast-sailfish.ts and create a version for your locale.

### Donations
Sorry but I do not accept any donations. I really appreciate the gesture but it is a hobby that I am able to do because others are investing their time as well.

If someone wants to show appreciation for my work by a donation then I suggest to help support openrepos.net.

### Thanks
  * Shoutcast: fantastic radio directory
  * nesnomis: harbour-allradio
  * Romain Pokrzywka: JSONListModel
  * Stefan Goessner: JSONPath
  * Gregor Santner & Sergejs Kovrovs: SwipeArea
  * igh0zt: app icon