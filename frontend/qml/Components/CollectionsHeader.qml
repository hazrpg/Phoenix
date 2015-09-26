import QtQuick 2.0
import QtQuick.Controls 1.4
Rectangle {
            color: "lightyellow";
            height: 36;

            anchors {
                left: parent.left;
                right: parent.right;
            }

            Text {
                text: qsTr( "Collections" );
                font {
                    pixelSize: PhxTheme.selectionArea.headerFontSize;
                    bold: true;
                }
                color: PhxTheme.common.baseFontColor;
                anchors {
                    verticalCenter: parent.verticalCenter;
                    left: parent.left;
                    leftMargin: 12;
                }
            }

            Button {
                anchors {
                    verticalCenter: parent.verticalCenter;
                    right: parent.right;
                    rightMargin: 24;
                }

                text: qsTr( "Add" );
                onClicked: {
                    collectionsModel.append( { "collectionID": listView.count
                                                , "collectionName": "New Collection "
                                                                    + listView.count } );
                    listView.currentIndex = listView.count - 1;
                    listView.currentItem.state = "ADDED";
                }
            }

        }

