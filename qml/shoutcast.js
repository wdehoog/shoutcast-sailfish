/**
 * shoutcast-sailfish. Copyright (C) 2017 Willem-Jan de Hoog
 *
 * License: MIT
 */


.pragma library

// http://wiki.shoutcast.com/wiki/SHOUTcast_Radio_Directory_API
// http://api.shoutcast.com/legacy/Top500?k=ia9p4XYXmOPEtXzL&limit=5

// http://api.shoutcast.com/genre/primary?k=[Your Dev ID]&f=xml
// http://api.shoutcast.com/genre/secondary?parentid=0&k=[Your Dev ID]&f=xml
// http://api.shoutcast.com/station/advancedsearch?genre_id=1&limit=10&f=xml&k=[Your Dev ID]
//   limit=X,Y Y is the number of results to return and X is the offset.
// http://api.shoutcast.com/legacy/stationsearch?k=[Your Dev ID]&search=ambient+beats (xml only)
// http://api.shoutcast.com/station/nowplaying?k=[Your Dev ID]&ct=rihanna&f=xml

// Access to the Shoutcast API requires a Dev Key. I requested one but never
// received an answer. I found some on the interweb but you better get one yourself
// the official way.
//   "U5F3uwzkJF6JW9Pf";
//   "dnHoPZSjLfVVdI8N";
var DevKeyPart = "k=ia9p4XYXmOPEtXzL";

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

function getAudioType(mimeType) {
    switch(mimeType) {
    case "audio/mpeg": return "mp3";
    case "audio/aacp": return "aac";
    default: return mimeType;
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
