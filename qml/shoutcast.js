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
    case "audio/mpeg": return "mt=audio/mpeg";
    case "audio/aacp": return "mt=audio/aacp";
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

function createInfo(model) {
    var info = {}
    info.id = model.id
    info.name = model.name ? model.name : "no name"
    info.genre = model.genre ? model.genre : "no genre"
    info.ct = model.ct ? model.ct : "no track info"
    info.lc = model.lc ? model.lc : 0
    info.br = model.br ? model.br : 0
    info.mt = model.mt ? model.mt : "no mimetype"
    info.logo = model.logo ? model.logo : ""

    info.genres = []
    if(model.genre)
        info.genres.push(model.genre)
    if(model.genre2)
        info.genres.push(model.genre2)
    if(model.genre3)
        info.genres.push(model.genre3)
    if(model.genre4)
        info.genres.push(model.genre4)
    if(model.genre5)
        info.genres.push(model.genre5)

    return info
}
