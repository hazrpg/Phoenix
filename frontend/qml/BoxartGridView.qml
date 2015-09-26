import QtQuick 2.5
import QtQuick.Controls 1.4
import "Components"
import "Components/Utils.js" as Utils
import "Components/FontUtils.js" as FontUtils
import vg.phoenix.cache 1.0
import vg.phoenix.themes 1.0
Rectangle {
    id: boxartGridBackground;
    width: 100; height: 62;
    property string title
    property string desc
    property string timePlayed
    property string system
    property int stars
    property string creator
    property string dateCreated
    property string region
    property string genre
    property string filePath

    anchors{
        top:parent.top
        topMargin: headerArea.height + 5
    }

    Loader {
        id: viewerLoader
        width: boxartGridBackground.width
        height: boxartGridBackground.height
        sourceComponent: grid
        onSourceComponentChanged: {
            changetoPreivews.start()

        }

        NumberAnimation {
            id: changetoPreivews
            target: viewerLoader
            property: "x"
            from: parent.width * 2
            to: 0
            duration: 1200
            easing.type: Easing.OutBack
        }
    }


    Component{
        id: previews

        Rectangle{
            width: viewerLoader.width
            height: viewerLoader.height
            color: "transparent"
            Text {
                text:boxartGridBackground.title
                     + "\nTime Played " + timePlayed
                     + "\nSystem " + system
                     + "\nstars " + stars
                     + "\ncreator "  +  creator
                     + "\ndateCreated " +  dateCreated
                     + "\nregion " +  region
                     +  "\ngenre " + genre
                     +  "\npath to game " + filePath
                     + "\nw_std " + desc

                color: "white"
                font.pixelSize: FontUtils.fontSizeToPixels("x-large")
            }

            Button{
                width: parent.width / 2.5
                text: "back"
                onClicked: viewerLoader.sourceComponent = grid
                anchors.centerIn: parent
            }
        }
    }


    Component{
        id: grid
        Rectangle{
            width:boxartGridBackground.width

            height: boxartGridBackground.height
            color: "transparent"


            Flickable {
                id: scrollView;
                width:boxartGridBackground.width
                height: boxartGridBackground.height * 5
                boundsBehavior: Flickable.StopAtBounds;
                interactive: true
                contentWidth: boxartGridBackground.width
                contentHeight: boxartGridBackground.height
                Grid {
                    id: gridView;
                    columns: 4
                    columnSpacing: 4
                    rows: 20
                    Repeater{
                        id: addModel
                        property int currentIndex: -1
                        property variant currentItem;
                        model: libraryModel;
                        onCountChanged: {
                            if (currentIndex === -1 && count > 0) {
                                currentIndex = 0
                                //                            addModel.item.isCurrent = true
                            }
                            if (currentIndex >= count) {
                                currentIndex = count - 1
                            }
                        }
                        delegate: BoxArtTile{
                            isCurrent: addModel.currentIndex === addModel.item ? true : false
                            width: scrollView.width / 4.4;
                            height: scrollView.contentHeight / 4;
                        }
                    }
                    Component.onCompleted: {libraryModel.updateCount(); }
                }

            }
            Rectangle {
                id: scrollbar
                color: Utils.grey
                width: 25
                height: scrollView.contentHeight
                anchors{
                    top:  parent.top
                    right: parent.right
                }
            }
            AbstractScrollBar {
                id: glowingScrollbar
                width: 15
                anchors.fill: scrollbar
                targetFlickable: scrollView
                sliderAnchors.margins: 5
                sliderColor: Utils.darkGreyDesaturated
                radius: 5
                borderColor: Utils.darkGrey
                borderWidth: 1
            }
        }
    }

}





