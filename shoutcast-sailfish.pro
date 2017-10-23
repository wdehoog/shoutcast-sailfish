# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = shoutcast-sailfish

CONFIG += sailfishapp_qml

DISTFILES += qml/shoutcast-sailfish.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/shoutcast-sailfish.changes.in \
    rpm/shoutcast-sailfish.changes.run.in \
    rpm/shoutcast-sailfish.spec \
    rpm/shoutcast-sailfish.yaml \
    translations/*.ts \
    shoutcast-sailfish.desktop \
    qml/shoutcast.js \
    qml/components/jsonpath.js \
    qml/components/JSONListModel.qml \
    qml/pages/SubGenrePage.qml \
    qml/pages/StationsPage.qml

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/shoutcast-sailfish-de.ts
