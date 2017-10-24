/**
 * shoutcast-sailfish. Copyright (C) 2017 Willem-Jan de Hoog
 *
 * License: MIT
 */


.pragma library

// key is from https://developer.getnightingale.com/d6/d7a/shoutcast_8js_source.html

/*
<stationlist>
    <tunein base="/sbin/tunein-station.pls" base-m3u="/sbin/tunein-station.m3u" base-xspf="/sbin/tunein-station.xspf"/>
      <station name="Dance Wave Retro!" mt="audio/mpeg" id="1057402" br="128" genre="House" lc="7672"/>
      <station name="radio6o8" mt="audio/mpeg" id="312852" br="128" genre="Middle Eastern" genre2="Country" genre3="Jazz" genre4="Middle Eastern" logo="http://i.radionomy.com/document/radios/7/7f84/7f84ecdd-74b6-4dcb-b9fa-14b1505ad69a.png" ct="Arian Band - Gole Aftab Gardoon" lc="4630"/>
      <station name="Metropolis 95.5" mt="audio/mpeg" id="1354289" br="32" genre="Sports" lc="4029"/>
      <station name="Dance Wave!" mt="audio/mpeg" id="893796" br="128" genre="House" ct="All about Dance from 2000 till today!" lc="3572"/>
      <station name="Rdi Scoop" mt="audio/mpeg" id="1633971" br="128" genre="House" lc="3402"/>
</stationlist>
*/
// http://wiki.shoutcast.com/wiki/SHOUTcast_Radio_Directory_API
// http://api.shoutcast.com/legacy/Top500?k=ia9p4XYXmOPEtXzL&limit=5

// http://api.shoutcast.com/genre/primary?k=[Your Dev ID]&f=xml
// http://api.shoutcast.com/genre/secondary?parentid=0&k=[Your Dev ID]&f=xml
// http://api.shoutcast.com/station/advancedsearch?genre_id=1&limit=10&f=xml&k=[Your Dev ID]
//   limit=X,Y Y is the number of results to return and X is the offset.

var DevKeyPart = "k=ia9p4XYXmOPEtXzL";
var LegacyBaseURL = "http://api.shoutcast.com/legacy/";

var PrimaryGenreBase = "http://api.shoutcast.com/genre/primary";
var SecondaryGenreBase = "http://api.shoutcast.com/genre/secondary";
var StationSearchBase = "http://api.shoutcast.com/station/advancedsearch";
var TuneInBase = "http://yp.shoutcast.com";

var QueryFormat = "f=json";

function getParentGenrePart(genreId) {
    return "parentid=" + genreId;
}

function getGenrePart(genreId) {
    return "genre_id=" + genreId;
}

function getStationPart(stationId) {
    return "id=" + stationId;
}

var LimitPart = "limit=200";

function getAudioType(mimeType) {
    switch(mimeType) {
    case "audio/mpeg": return "mp3";
    case "audio/aacp": return "aac";
    default: return mimeType;
    }
}

function extractURL(text) {

}
