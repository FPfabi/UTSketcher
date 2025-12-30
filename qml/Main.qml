/*
 * Copyright (C) 2025  Fabian Huck
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * sketcher is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0
import io.thp.pyotherside 1.4
import Ubuntu.Web 0.2  //Morph.Web 0.2
import Ubuntu.Content 1.3
import Lomiri.Content 0.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
//import QtQuick.Controls 2.7


MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'sketcher.fabianhuck'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    property string import_path
    property string export_path
    property string emoji_path

    property string appPath: StandardPaths.writableLocation(StandardPaths.AppDataLocation)

    property var activeTransfer
    property var activeExport: null

	property var url
    property var export_url
	property var handler: ContentHandler.Source
	property var contentType: ContentType.Pictures

    signal cancel()
    signal imported(string fileUrl)

    property var infomsg

    property var navbuttonwidth: units.gu(7)

    property bool emoji_loaded: false



    //runs javascript code in webview and collects result in callback function
    function export_svg(){
        var save_dir = StandardPaths.writableLocation(StandardPaths.CacheLocation).toString().replace("file://","");
        
        webview.runJavaScript("canvas.toSVG();", function(result) { 
            py.call('my_app.save_svg_to_file', [save_dir, result], function(svgfullpath) {
                console.log('my_app.save_svg_to_file returned ' + svgfullpath);
                PopupUtils.open(exportDialog, root, { 'path': svgfullpath });
            })
        })
    }


    function import_picture(){
        root.activeTransfer = peer.request();
    }

    //Is called after peer has loaded the image
    function processItems(items) {
        var strurl = "";
        for (var i = 0; i < items.length; i++) {
            strurl += i + ") " + items[i].url + "\n";
            /* You may want to use items[i].move() to put the content somewhere permanent. */
            let importdir = Qt.resolvedUrl("../www/imported");
            console.log("Importdir: " + importdir);
            let cleanedpath = (items[i].url).toString().replace("file://", "");
            let fname = getfilename(cleanedpath);
            console.log("Filename: " + fname);
            let cleaneddir = importdir.toString().replace("file://", "");
            let old_url = items[i].url;
            //let success = items[i].copy(root.import_path);
            //let success = items[i].copy(root.app_path);
            let success = items[i].copy(root.import_path.replace("file://", ""));

            if(success==true){
                let imported_path = root.import_path.replace("file://", "") + "/" + fname;
                console.log("Copy successfull!")
                
                //lblmsg.text = fname + " was copied to " + importdir;
                let cmd = "importImage('" + imported_path + "');";
                console.log("Running webview js:" + cmd);
                webview.runJavaScript(cmd, function(result) { console.log(result); });
                //lblmsg.text = py_getfilename(old_url);
            }else{
                showJSalert("Failed to copy picture");
            }

            

        }
        
    }


    function showJSalert(msgtext){
        let fctcall = "showMessage('" + msgtext + "');";
        webview.runJavaScript(fctcall, function(result) { console.log(result); });
    }

    function openFile(fileUrl) {
        var request = new XMLHttpRequest();
        request.open("GET", fileUrl, false);
        request.send(null);
        return request.responseText;
    }

    function showSavedImages(){
        infolabel.showText("Showing saved images");
        btnleft.width = navbuttonwidth;
        fadeout_start_timer.start();
        webview.runJavaScript("qml_load_last_image();", function(result) { 
            //console.log(result); 
        });
    }

    function load_previous_image(){
        webview.runJavaScript("qml_load_previous_image();", function(result) { 
            //console.log(result); 
        });
    }
    function load_next_image(){
        webview.runJavaScript("qml_load_next_image();", function(result) { 
            //console.log(result); 
        });
    }

    function webview_add_saved_images(file_list){
        webview.runJavaScript("clear_saved_images();", function(result) { console.log(result); });

        for (let i = 0; i < file_list.length; i++) {
            let fpath = file_list[i];
            let fctcall = "add_saved_image('" + fpath + "');";
            webview.runJavaScript(fctcall, function(result) { console.log(result); });
        }

    }

    function get_new_image_name(){
        const d = new Date();
        let text = d.toString();
        return "image_" + text + ".svg"
    }

    function saveCanvas(){
        var imgName = get_new_image_name();
        let savedir = Qt.resolvedUrl("../www/saved");
        let fullsavepath = savedir + "/" + imgName;
        //webview.runJavaScript("canvas.toSVG();", function(result) { saveFile(fullsavepath, result); });
        webview.runJavaScript("qml_image_save();", function(result) { console.log(result); });
    }

    //Save and open code from here: https://stackoverflow.com/questions/17882518/reading-and-writing-files-in-qml-qt
    function saveFile(fileUrl, text) {
        var request = new XMLHttpRequest();
        request.open("PUT", fileUrl, false);
        request.send(text);
        let status = request.status;
        showJSalert(status);
    }

    function getfilename(filepath){
        var filename = filepath.replace(/^.*[\\/]/, '');
        return filename;
    }

    function py_getfilename(filepath){
        var retval = "";
        py.call('my_app.getfilename', [filepath], function(returnValue) {
            console.log('my_app.getfilename returned ' + returnValue);
            retval = returnValue;
        })
        return retval;
    }

    function send_emoji_json_to_webview(json_content){
        //console.log("send_emoji_json_to_webview: json content: " + JSON.stringify(json_content));
        var json_cmd = "import_json_emoji(" + JSON.stringify(json_content) + ");";
        webview.runJavaScript(json_cmd, function(result) { console.log(result); });
    }

    function createTimer() {
        return Qt.createQmlObject("import QtQuick 2.0; Timer {}", root);
    }
    function run_with_delay(delayTime, cb) {
        timer = createTimer();
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }

    
    /* The ContentPeer sets the kinds of content that can be imported.  For some reason,
               handler must be set to Source to indicate that the app is importing.  This seems
               backwards to me. */
    ContentPeer {
        id: peer
        contentType: ContentType.Pictures
        handler: ContentHandler.Source
        selectionType: ContentTransfer.Single
    }

    /* This is a GUI element that blocks the rest of the UI when a transfer is ongoing. */
    ContentTransferHint {
        anchors.fill: root
        activeTransfer: root.activeTransfer
    }

    /* Watch root.activeTransfer to find out when content is ready for our use. */
    Connections {
        target: root.activeTransfer
        onStateChanged: {
            if (root.activeTransfer.state === ContentTransfer.Charged)
                root.processItems(root.activeTransfer.items);
        }
    }

    Component {
        id: exportDialog
        ExportDialog {}
    }

    

    Item {
        Timer {
            id: fadeout_start_timer
            interval: 2000; 
            running: false; 
            repeat: false;
            onTriggered: PropertyAnimation { 
                target: btnleft; 
                property: "width"; 
                to: 0 }
        }        
    }
    

    Page {
        anchors.fill: parent
        header: PageHeader {
            id: header
            title: i18n.tr('Sketcher')

            ActionBar {
                anchors {
                    top: parent.top
                    right: parent.right
                    topMargin: units.gu(1)
                    rightMargin: units.gu(1)
                }
                numberOfSlots: 3
                actions: [
                    Action {
                        iconName: "document-save"
                        text: i18n.tr("Save")
                        onTriggered: saveCanvas();
                    },
                    Action {
                        iconName: "document-open"
                        text: i18n.tr("Open")
                        onTriggered: showSavedImages();
                    },
                    Action {
                        iconName: "delete"
                        text: i18n.tr("Delete")
                        onTriggered: showJSalert("Delete function is empty");
                    },
                    Action {
                        iconName: "stock_image"
                        text: i18n.tr("Export image")
                        onTriggered: export_svg();
                    },
                    Action {
                        iconName: "import"
                        text: i18n.tr("Import")
                        onTriggered: import_picture();
                    }
                    
                ]
            }


        }

        WebView {
            id: webview
            url: Qt.resolvedUrl("../www/index.html")
            //url: "http://ubuntu.com"
            anchors.fill: parent
            Component.onCompleted: {
                console.log("++++++++");
                console.log("++++++++");
                console.log(Qt.resolvedUrl("../www/index.html"));
                console.log("++++++++");
                console.log("++++++++");
                //webview.runJavaScript("qml_load_last_image();", function(result) { console.log(result); });
            }

        }

        Button {
            id: btnleft
            width: units.gu(7)
            height: units.gu(10)
            color: "lightblue" // Set your desired background color
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                fadeout_start_timer.restart();
                load_previous_image();
            }

            Icon {
                id: "scroll_left"
                name: "go-previous"
                width: parent.width
                height: units.gu(7)
                anchors.centerIn: parent                
            }
        }

        Button{
            id: btnright
            width: btnleft.width
            height: units.gu(10)
            color: "lightblue" // Set your desired background color
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                fadeout_start_timer.restart();
                load_next_image();
            }

            Icon {
                id: "scroll_right"
                name: "go-next"
                width: parent.width
                height: units.gu(7)
                anchors.centerIn: parent                
            }
        }

        RoundedLabel{
            id: infolabel
            anchors.top: header.bottom
            anchors.horizontalCenter: parent.horizontalCenter  // Center it horizontally
            anchors.topMargin: 20  // Add padding of 20 pixels from the top
        }
        
    }

    Python {
        id: py

        Component.onCompleted: {
            console.log("App Path: " + root.appPath);

            root.emoji_path = root.appPath + "/" + "emoji";
            root.emoji_path = root.emoji_path.replace("file://","");

                        

            addImportPath(Qt.resolvedUrl('../src/'));

            importModule('my_app', function() {
                console.log('my_app module imported');
                py.call('my_app.getfilename', [Qt.resolvedUrl("../www/index.html")], function(returnValue) {
                    console.log("Return from getfile: " + returnValue);
                })
                py.call('my_app.make_dir', [root.appPath, "imported"], function(returnValue) {
                    console.log("my_app.make_dir returned: " + returnValue);
                    root.import_path = root.appPath + "/" + "imported";
                    console.log("root.import_path: " + root.import_path);
                })
                py.call('my_app.make_dir', [root.appPath, "exported"], function(returnValue) {
                    console.log("my_app.make_dir returned: " + returnValue);
                    root.export_path = root.appPath + "/" + "exported";
                    console.log("root.export_path: " + root.export_path);
                })
            });
        }

        onError: {
            console.log('python error: ' + traceback);
        }

        
    }

    Component.onCompleted: {
        navbuttonwidth = btnleft.width;
        fadeout_start_timer.start();
    }


}
