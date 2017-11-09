/**
 * shoutcast-sailfish. Copyright (C) 2017 Willem-Jan de Hoog
 *
 * License: MIT
 */


.pragma library

//
// see http://wiki.shoutcast.com/wiki/SHOUTcast_Radio_Directory_API
//
// Access to the Shoutcast API requires a DevID.
// This one is mine. It can only be used for my apps.
var DevKeyPart = "k=4FyiY5TYNSSPZhHG";

var LegacyBaseURL = "http://api.shoutcast.com/legacy/";

var Top500Base = "http://api.shoutcast.com/legacy/Top500"
var PrimaryGenreBase = "http://api.shoutcast.com/genre/primary";
var SecondaryGenreBase = "http://api.shoutcast.com/genre/secondary";
var StationSearchBase = "http://api.shoutcast.com/station/advancedsearch";
var TuneInBase = "http://yp.shoutcast.com";
var KeywordSearchBase = "http://api.shoutcast.com/legacy/stationsearch";
var NowPlayingSearchBase = "http://api.shoutcast.com/station/nowplaying";

var QueryFormat = "f=json";
var HasChildrenPart = "haschildren=true"

function getLimitPart(limitValue) {
    return "limit=" + limitValue;
}

function getParentGenrePart(genreId) {
    return "parentid=" + genreId;
}

function getGenrePart(genreId) {
    return "genre_id=" + genreId;
}

function getStationPart(stationId) {
    return "id=" + stationId;
}

function getPlayingPart(query) {
    return "ct=" + encodeURI(query);
}

function getSearchPart(query) {
    return "search=" + encodeURI(query);
}

function getAudioTypeFilterPart(mimeType) {
    switch(mimeType) {
    case "audio/mpeg": return "mt=audio%2Fmpeg";
    case "audio/aacp": return "mt=audio%2Faacp";
    default: return "mt=" + mimeType;
    }
}

function getAudioType(mimeType) {
    switch(mimeType) {
    case "audio/mpeg": return "mp3";
    case "audio/aacp": return "aac";
    default: return mimeType;
    }
}

function getAudioTypeExtension(mimeType) {
    switch(mimeType) {
    case "audio/aacp": return "aac";
    default:
    case "audio/mpeg": return "mp3";
    }
}

function startsWith(str, start) {
    return str.match("^"+start) !== null;
}

function extractURLFromM3U(text) {
    var lines = text.split('\n');
    for(var i = 0;i < lines.length;i++) {
        if(startsWith(lines[i], "http"))
            return lines[i];
    }
    return "";
}

function extractURLFromPLS(text) {
    var lines = text.split('\n');
    for(var i = 0;i < lines.length;i++) {
        var match = lines[i].match("File[^=]+\s*=\s*(http.*)\s*")
        if(match && match.length>=2)
            return match[1];
    }
    return "";
}

function createInfo(item) {
    var info = {}
    info.id = item.id
    info.name = item.name ? item.name : "no name"
    info.genre = item.genre ? item.genre : "no genre"
    info.ct = item.ct ? item.ct : "no track info"
    info.lc = item.lc ? item.lc : 0
    info.br = item.br ? item.br : 0
    info.mt = item.mt ? item.mt : "no mimetype"
    info.logo = item.logo ? item.logo : ""

    info.genres = []
    if(item.genre)
        info.genres.push(item.genre)
    if(item.genre2)
        info.genres.push(item.genre2)
    if(item.genre3)
        info.genres.push(item.genre3)
    if(item.genre4)
        info.genres.push(item.genre4)
    if(item.genre5)
        info.genres.push(item.genre5)

    return info
}

var primaryGenres = []

// reverse engineerd www.shoutcast.com html/js
// genres with parentid == 0 are the 'genres', the rest are the 'subgenres'
function loadGenresFromHTML(onGenresLoaded) {
    var xhr = new XMLHttpRequest
    xhr.open("GET", "http://www.shoutcast.com")
    xhr.onreadystatechange = function() {
        if(xhr.readyState === XMLHttpRequest.DONE) {
            var responseText = xhr.responseText
            var genres = []
            var subgenres = []
            var genre = {}
            var genreId = -1
            var lines = responseText.split('\n');
            var i
            for(i = 0;i < lines.length;i++) {
                // <a href="/Genre?name=Acid%20Jazz" onclick="return loadStationsByGenre('Acid Jazz', 164, 163);">Acid Jazz</a>
                var match = lines[i].match(/.*loadStationsByGenre\('([^']+)',\s(\d+),\s(\d+)/)
                if(match && match.length >= 4) {
                    if(match[3] === "0") {
                        // new genre
                        subgenres = []
                        genre = {name: match[1], genreid: match[2], subgenres: subgenres, count: -1}
                        genres.push(genre)
                    } else
                      subgenres.push({name: match[1], genreid: match[2], parentgenreid: match[3]})
                }
            }
            for(i=0;i<genres.length;i++)
                genres[i].count = genres[i].subgenres.length
            primaryGenres = genres
            onGenresLoaded(primaryGenres)
        }
    }
    xhr.send();
}

// reverse engineered www.shoutcast.com html/js
function loadStationsAnotherWay(genre, onStationsLoaded) {
    var xhr = new XMLHttpRequest
    xhr.open("POST", "http://www.shoutcast.com/Search/UpdateAdvancedSearch")
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function() {
        if(xhr.readyState === XMLHttpRequest.DONE) {
            var response = JSON.parse(xhr.responseText)
            var stations = []
            for(var i=0;i<response.length;i++) {
                stations.push({
                    id: response[i].ID,
                    name: response[i].Name,
                    genre: response[i].Genre,
                    ct: response[i].CurrentTrack,
                    mt: response[i].Format,
                    lc: response[i].Listeners,
                    br: response[i].Bitrate,
                    logo: ""
                })
            }
            var tuneinBase = {}
            tuneinBase["base"] = "/sbin/tunein-station.pls"
            tuneinBase["base-m3u"] = "/sbin/tunein-station.m3u"
            tuneinBase["base-xspf"] = "/sbin/tunein-station.xspf"
            onStationsLoaded(stations, tuneinBase)
        }
    }
    xhr.send("genre="+encodeURIComponent(genre))
}

// reverse engineered www.shoutcast.com html/js
function loadTopStationsAnotherWay(onStationsLoaded) {
    var xhr = new XMLHttpRequest
    xhr.open("POST", "http://www.shoutcast.com/Home/Top")
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function() {
        if(xhr.readyState === XMLHttpRequest.DONE) {
            var response = JSON.parse(xhr.responseText)
            var stations = []
            for(var i=0;i<response.length;i++) {
                stations.push({
                    id: response[i].ID,
                    name: response[i].Name,
                    genre: response[i].Genre,
                    ct: response[i].CurrentTrack,
                    mt: response[i].Format,
                    lc: response[i].Listeners,
                    br: response[i].Bitrate,
                    logo: ""
                })
            }
            var tuneinBase = {}
            tuneinBase["base"] = "/sbin/tunein-station.pls"
            tuneinBase["base-m3u"] = "/sbin/tunein-station.m3u"
            tuneinBase["base-xspf"] = "/sbin/tunein-station.xspf"
            onStationsLoaded(stations, tuneinBase)
        }
    }
    xhr.send()
}

// reverse engineered www.shoutcast.com html/js
function loadStationStream(stationId, onStreamFound) {
    var xhr = new XMLHttpRequest
    xhr.open("POST", "http://www.shoutcast.com//Player/GetStreamUrl")
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhr.onreadystatechange = function() {
        if(xhr.readyState === XMLHttpRequest.DONE) {
            onStreamFound(xhr.responseText)
        }
    }
    xhr.send("station="+stationId)
}
