## shoutcast-sailfish

A Shoutcast player for SailfishOS. It is a simple but effective one.

I use and develop it on my Oneplus One (currently 2.1.2.3).

See the [screenshots](https://github.com/wdehoog/shoutcast-sailfish/tree/master/screenshots) directory for how it looks.

A package can be found in my [OBS repository]( http://repo.merproject.org/obs/home:/wdehoog:/shoutcast-sailfish/sailfish_latest_armv7hl/). 

### Issues
  * The shoutcast api service is sometimes offline. The app can try to use information 'scraped' from the shoutcast home page but this is WIP and quit often the home page is offline as well. So this feature will probably disappear.

### Features
  * Browse by Genre
  * List Top 500
  * Search by 'Now Playing' or Keywords
  * Tune in on a Station 
  * Pause/Play

#### Usage
  * Press a Station will start playing it
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
Soddy but I do not accept any donations. I really appreciate the gesture but it is a hobby that I am able to do because others are investing their time as well.

If someone wants to show appreciation for my work by a donation then I suggest to help support openrepos.net.

### Thanks
  * Shoutcast: fantastic radio directory
  * nesnomis: harbour-allradio
  * Romain Pokrzywka: JSONListModel
  * Stefan Goessner: JSONPath
  * Gregor Santner & Sergejs Kovrovs: SwipeArea
  * igh0zt: app icon