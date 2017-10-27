## shoutcast-sailfish

A Shoutcast player for SailfishOS. It is a very simple but effective one.

I use and develop it on my Oneplus One (currently 2.1.2.3).

A package can be found in my [OBS repository]( http://repo.merproject.org/obs/home:/wdehoog:/shoutcast-sailfish/sailfish_latest_armv7hl/). 

### Features
  * Browse by Genre
  * List Top 500
  * Search by 'Now Playing' or Keywords
  * Tune in on a Station 
  * Pause/Play

### Issues
  * Accessing the Shoutcast API requires a Dev Key. I requested one but got no reply. Searching the internet shows this happens all the time. So using this app requires a Dev Key and you will have to get or find one and add it to qml/shoutcast.js.

### Development
This project is developed with the Sailfish OS IDE (QT Creator). 

### Translations
Translation is done using Qt Quick Internationalisation. If you want to contribute a translation take shoutcast-sailfish.ts and create a version for your locale.

### Thanks
  * Shoutcast: fantastic radio directory
  * nesnomis: harbour-allradio
  * Romain Pokrzywka: JSONListModel
  * Stefan Goessner: JSONPath
  * igh0zt: app icon