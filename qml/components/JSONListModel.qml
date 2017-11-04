/* JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 * Modified by Willem-Jan de Hoog
 */

import QtQuick 2.0
import "jsonpath.js" as JSONPath

Item {
    property string source: ""
    property string json: ""
    property string query: ""
    property string orderField: ""

    // json is not saved but sometimes we need to keep something
    property string keepQuery: ""
    property var keepObject: null

    property ListModel model : ListModel { id: jsonModel }
    property alias count: jsonModel.count

    signal loaded();

    onSourceChanged: refresh()

    function refresh() {
        json = ""
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE)
                json = xhr.responseText
        }
        xhr.send();
    }

    onJsonChanged: updateJSONModel()
    onQueryChanged: updateJSONModel()

    function updateJSONModel() {
        jsonModel.clear()

        if ( json === "" )
            return

        var objectArray = parseJSONString(json, query);
        if(!objectArray) {
            loaded()
            return
        }

        if(orderField !== "") {
           objectArray.sort(function(a, b) {
               // reverse!
               return b[orderField] - a[orderField]
           })
        }
        for ( var key in objectArray ) {
            var jo = objectArray[key]
            jsonModel.append( jo )
        }

        loaded()
    }

    function parseJSONString(jsonString, jsonPathQuery) {
        var objectArray = JSON.parse(jsonString);
        if ( keepQuery !== "" )
            keepObject = JSONPath.jsonPath(objectArray, keepQuery);
        if ( jsonPathQuery !== "" )
            objectArray = JSONPath.jsonPath(objectArray, jsonPathQuery);        
        return objectArray;
    }
}
