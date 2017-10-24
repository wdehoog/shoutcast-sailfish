/*
  Copyright (C) 2017 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

import "pages"
import "cover"

ApplicationWindow {
    id: app

    initialPage: Component { FirstPage { } }
    allowedOrientations: defaultAllowedOrientations

    cover: CoverPage {
        id: cover
    }

    PlayerPage {
        id: playerPage
    }

    function getPlayerPage() {
        return playerPage
    }

    function pause() {
        playerPage.pause()
    }
}

