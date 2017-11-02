## shoutcast-sailfish

A Shoutcast player for SailfishOS. It is a simple but effective one.

I use and develop it on my Oneplus One (currently 2.1.2.3).

See the [screenshots](https://github.com/wdehoog/shoutcast-sailfish/tree/master/screenshots) directory for how it looks.

A package can be found in my [OBS repository]( http://repo.merproject.org/obs/home:/wdehoog:/shoutcast-sailfish/sailfish_latest_armv7hl/). 

### Features
  * Browse by Genre
  * List Top 500
  * Search by 'Now Playing' or Keywords
  * Tune in on a Station 
  * Pause/Play

#### Usage
  * Press a Station will start playing it
  * Swipe the player area left/right will load previous/next Station (only for pages having a Station list)
  * When configured to do so instead of playing a stream in the built in player it will call `openUri` on a MPris Player.

### Development
This project is developed with the Sailfish OS IDE (QT Creator). 

### Translations
Translation is done using Qt Quick Internationalisation. If you want to contribute a translation take shoutcast-sailfish.ts and create a version for your locale.

### Thanks
  * Shoutcast: fantastic radio directory
  * nesnomis: harbour-allradio
  * Romain Pokrzywka: JSONListModel
  * Stefan Goessner: JSONPath
  * Gregor Santner & Sergejs Kovrovs: SwipeArea
  * igh0zt: app icon