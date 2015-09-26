import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import vg.phoenix.cache 1.0
import vg.phoenix.themes 1.0
import vg.phoenix.models 1.0
import "FontUtils.js" as FontUtils

Rectangle {
    id: gridItem;
    height: 10
    width: 10
    color: isCurrent ? "#88f9440c" : "#92464854";
    radius: 5;
    property bool isCurrent: false
    //    Behavior on color{ NumberAnimation{duration: 1200}}
    Behavior on scale{NumberAnimation{duration: 1200 ; easing.type: Easing.OutQuad}}

    Image {
        id: gridItemImage;
        height: parent.height;
        width: parent.width
        source: imageCacher.cachedUrl === "" ? "qrc:/missingArtwork.png" : imageCacher.cachedUrl;
        onStatusChanged: {
            if ( status === Image.Error ) {
                console.log( "Error in " + source );
                gridItemImage.source = "qrc:/missingArtwork.png";
            }
        }
        anchors {
            fill: parent;
            margins: 5
        }
    }
    Text {
        id: titleText;
        text: title;
        color: "white"
        width: parent.width + Math.round(gridItemImage.paintedWidth / 60)
        horizontalAlignment: Text.AlignHCenter;
        wrapMode: Text.WordWrap
        font.pixelSize: FontUtils.fontSizeToPixels("medium")
        anchors{
            top: parent.bottom
            topMargin: titleText.paintedHeight / 2
        }
    }


    ImageCacher {
        id: imageCacher;
        imageUrl: artworkUrl;
        identifier: sha1;
        Component.onCompleted: cache();
    }


    Rectangle{
        id: tracker
        color: "transparent"
        width: gridItem.width
        height: gridItem.height + titleText.paintedHeight * 2 // + titleText.paintedHeight )
        anchors.centerIn: parent
        MouseArea {
            anchors.fill: tracker;
            hoverEnabled: true
            onEntered:gridItem.color = "#88f9440c"
            onExited: gridItem.color =  "#92464854"
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                   onClicked: {
                       if (mouse.button == Qt.RightButton){
                            fillPreviews()
                           viewerLoader.sourceComponent = previews
                       }else{
                           parent.color = 'red';
                   }
            }
             onDoubleClicked: {
                console.log( timePlayed );
//                console.log( GameData.releaseDate );
            }
        }





    }
//    Component.onCompleted: scale= 1

//GameData{}

    function fillPreviews(){
        boxartGridBackground.title = titleText.text
        boxartGridBackground.timePlayed = timePlayed
        boxartGridBackground.system = system
        boxartGridBackground.creator = "Some Person"
        boxartGridBackground.desc = "Some Long desription about this game"
        boxartGridBackground.stars = "4"
        boxartGridBackground.dateCreated = "1999"
        boxartGridBackground.region = "USA"
        boxartGridBackground.genre = "sports"
        boxartGridBackground.filePath = filePath
    }






}
