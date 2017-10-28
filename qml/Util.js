/**
 * shoutcast-sailfish. Copyright (C) 2017 Willem-Jan de Hoog
 *
 * License: MIT
 */


.pragma library


//
// copied from https://github.com/websanova/js-url/blob/master/url.js
//
//  url();            // http://rob:abcd1234@www.example.co.uk/path/index.html?query1=test&silly=willy&field[0]=zero&field[2]=two#test=hash&chucky=cheese
//  url('domain');    // example.co.uk
//  url('hostname');  // www.example.co.uk
//  url('sub');       // www
//  url('.0')         // undefined
//  url('.1')         // www
//  url('.2')         // example
//  url('.-1')        // uk
//  url('auth')       // rob:abcd1234
//  url('user')       // rob
//  url('pass')       // abcd1234
//  url('port');      // 80
//  url('protocol');  // http
//  url('path');      // /path/index.html
//  url('file');      // index.html
//  url('filename');  // index
//  url('fileext');   // html
//  url('1');         // path
//  url('2');         // index.html
//  url('3');         // undefined
//  url('-1');        // index.html
//  url(1);           // path
//  url(2);           // index.html
//  url(-1);          // index.html
//  url('query');     // query1=test&silly=willy
//  url('?');         // {query1: 'test', silly: 'willy', field: ['zero', undefined, 'two']}
//  url('?silly');    // willy
//  url('?poo');      // undefined
//  url('field[0]')   // zero
//  url('field')      // ['zero', undefined, 'two']
//  url('hash');      // test=hash&chucky=cheese
//  url('#');         // {test: 'hash', chucky: 'cheese'}
//  url('#chucky');   // cheese
//  url('#poo');      // undefined

function _i(arg, str) {
    var sptr = arg.charAt(0),
        split = str.split(sptr);

    if (sptr === arg) { return split; }

    arg = parseInt(arg.substring(1), 10);

    return split[arg < 0 ? split.length + arg : arg - 1];
}

function parseURL(arg, url) {
    var _l = {}, tmp, tmp2;


    if ( ! arg) { return url; }

    arg = arg.toString();

    // Ignore Hashbangs.
    if (tmp = url.match(/(.*?)\/#\!(.*)/)) {
        url = tmp[1] + tmp[2];
    }

    // Hash.
    if (tmp = url.match(/(.*?)#(.*)/)) {
        _l.hash = tmp[2];
        url = tmp[1];
    }

    // Return hash parts.
    if (_l.hash && arg.match(/^#/)) { return _f(arg, _l.hash); }

    // Query
    if (tmp = url.match(/(.*?)\?(.*)/)) {
        _l.query = tmp[2];
        url = tmp[1];
    }

    // Return query parts.
    if (_l.query && arg.match(/^\?/)) { return _f(arg, _l.query); }

    // Protocol.
    if (tmp = url.match(/(.*?)\:?\/\/(.*)/)) {
        _l.protocol = tmp[1].toLowerCase();
        url = tmp[2];
    }

    // Path.
    if (tmp = url.match(/(.*?)(\/.*)/)) {
        _l.path = tmp[2];
        url = tmp[1];
    }

    // Clean up path.
    _l.path = (_l.path || '').replace(/^([^\/])/, '/$1');

    // Return path parts.
    if (arg.match(/^[\-0-9]+$/)) { arg = arg.replace(/^([^\/])/, '/$1'); }
    if (arg.match(/^\//)) { return _i(arg, _l.path.substring(1)); }

    // File.
    tmp = _i('/-1', _l.path.substring(1));

    if (tmp && (tmp = tmp.match(/(.*?)\.(.*)/))) {
        _l.file = tmp[0];
        _l.filename = tmp[1];
        _l.fileext = tmp[2];
    }

    // Port.
    if (tmp = url.match(/(.*)\:([0-9]+)$/)) {
        _l.port = tmp[2];
        url = tmp[1];
    }

    // Auth.
    if (tmp = url.match(/(.*?)@(.*)/)) {
        _l.auth = tmp[1];
        url = tmp[2];
    }

    // User and pass.
    if (_l.auth) {
        tmp = _l.auth.match(/(.*)\:(.*)/);

        _l.user = tmp ? tmp[1] : _l.auth;
        _l.pass = tmp ? tmp[2] : undefined;
    }

    // Hostname.
    _l.hostname = url.toLowerCase();

    // Return hostname parts.
    if (arg.charAt(0) === '.') { return _i(arg, _l.hostname); }

    // Return arg.
    if (arg in _l) { return _l[arg]; }

    // Return everything.
    if (arg === '{}') { return _l; }

    // Default to undefined for no match.
    return undefined;

}

