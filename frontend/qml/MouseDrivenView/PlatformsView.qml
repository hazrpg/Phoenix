import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import vg.phoenix.models 1.0
import vg.phoenix.themes 1.0

// @disable-check M300
PhxScrollView {
    id: platformsView;

    // The default of 20 just isn't fast enough
    __wheelAreaScrollSpeed: 100;

    ListView {
        id: listView;
        spacing: 0;
        model: PlatformsModel { id: platformsModel; }
        boundsBehavior: Flickable.StopAtBounds;

        highlight: Item {
            x: listView.currentItem.x;
            y: listView.currentItem.y;
            anchors.fill: listView.currentItem;

            // Gives the highlighter that nice glow.
            DropShadow {
                source: highlighterRectangle;
                anchors.fill: source;
                horizontalOffset: 0;
                verticalOffset: 0;
                radius: 12.0;
                samples: radius * 2;
                color: "red";
            }

            Rectangle {
                id: highlighterRectangle;
                anchors {
                    top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right;
                    leftMargin: 12;
                    rightMargin: 12;
                }
                //width: listView.currentItem.marqueeText.running ? listView.currentItem.marqueeText.textWidth : listView.currentItem.width;
                color: "transparent";

                border {
                    width: 3;
                    color: PhxTheme.common.menuItemBackgroundColor;
                }

                radius: 5;

                /* Rectangle {
                    anchors { top: parent.top; bottom: parent.bottom; left: parent.left; }
                    width: 4;
                    height: parent.height;
                    color: PhxTheme.common.menuItemHighlight;
                } */
            }
        }

        header: Rectangle {
            color: "transparent";
            height: PhxTheme.common.menuTitleHeight;
            anchors { left: parent.left; right: parent.right; }

            Text {
                text: qsTr( "Systems" );
                anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: PhxTheme.common.menuItemMargin; }
                font { pixelSize: PhxTheme.selectionArea.headerFontSize; bold: true; }
                color: PhxTheme.selectionArea.highlightFontColor;
            }
        }

        delegate: Item {
            property alias marqueeText: platformText;
            height: PhxTheme.common.menuItemHeight;
            anchors { left: parent.left; right: parent.right; }

            // Image {
            //     anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: PhxTheme.common.menuItemMargin; }
            //     smooth: false;
            //     sourceSize { height: height; width: width; }
            //     source: "systems/" + listView.model.get( index ) + ".svg";
            // }

            MarqueeText {
                id: platformText;
                anchors { verticalCenter: parent.verticalCenter; left: parent.left; right: parent.right; leftMargin: PhxTheme.common.menuItemMargin; rightMargin: PhxTheme.common.menuItemMargin; }
                horizontalAlignment: Text.AlignLeft;
                // Print friendly name if one exists
                text: listView.model.get( index )[1] !== "" ? listView.model.get( index )[1] : listView.model.get( index )[0];
                fontSize: PhxTheme.common.baseFontSize + 1;
                color: index === listView.currentIndex ? PhxTheme.common.menuItemHighlight : PhxTheme.selectionArea.baseFontColor;
                spacing: 40;
                running: index === listView.currentIndex || mouseArea.containsMouse;
                pixelsPerFrame: 2.0;
                bold: index === listView.currentIndex;
            }

            MouseArea {
                id: mouseArea;
                anchors.fill: parent;
                hoverEnabled: true;
                onClicked: {
                    if ( contentArea.contentStackView.currentItem.objectName !== "PlatformsView" ) {
                        contentArea.contentStackView.push( { item: contentArea.boxartGrid, replace: true } );
                    }

                    // Always use UUID
                    listView.currentIndex = index;
                    if ( index === 0 ) { contentArea.contentLibraryModel.clearFilter( "games", "system" ); }
                    else { contentArea.contentLibraryModel.setFilter( "games", "system", listView.model.get( index )[0] ); }
                }
            }
        }
    }
}
