import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.2

import Phoenix.Backend 1.0
import vg.phoenix.themes 1.0

Item {
    id: inputView;
    width: 100
    height: 62

    ExclusiveGroup {
        id: inputColumnGroup;
    }

    Item {
        anchors {
            left: parent.left;
            right: parent.right;
            top: parent.top;
            bottom: parent.bottom;
            bottomMargin: 56;
            topMargin: 84;
            leftMargin: 56;
            rightMargin: 56;
        }

        DropShadow {
            id: controllerShadow;
            anchors.fill: source;
            source: controllerImage;
            verticalOffset: 1;
            horizontalOffset: 0;
            color: "black";
            transparentBorder: true;
            radius: 8;
            samples: radius * 2;
        }

        Image {
            id: controllerImage;
            anchors {
                bottom: parent.bottom;
                bottomMargin: -100;
                right: inputScrollView.left;
                rightMargin: 24;
                left: parent.left;
                top: parent.top;
                topMargin: 100;
            }

            height: 400;

            source: "playstationController.svg";
            fillMode: Image.PreserveAspectFit;

            sourceSize { height: height; width: width; }

        }

        ScrollView {
            id: inputScrollView;
            anchors {
                right: parent.right;
                rightMargin: 12;
                top: parent.top;
                bottom: parent.bottom;
            }

            width: 250;

            ColumnLayout {
                spacing: 6;


                ComboBox {
                    id: inputDeviceComboBox;
                    anchors {
                        right: parent.right;
                    }

                    model: GamepadModel;
                    textRole: "name";

                    onCurrentIndexChanged: {
                        RemapModel.currentIndex( inputDeviceComboBox.currentIndex );
                    }

                    Component.onCompleted: {
                        RemapModel.currentIndex( inputDeviceComboBox.currentIndex );
                    }
                }

                ComboBox {
                    anchors {
                        right: parent.right;
                    }
                   // model: RemapModel;
                    //textRole: "mapping";//[ "Player 1" ];
                }

                ListView {
                    anchors {
                        right: parent.right;
                    }

                    Layout.fillWidth: true;

                    height: 500;

                    orientation: ListView.Vertical;


                    model: RemapModel;

                    delegate: Item {
                        height: 50;
                        width: 100;
                        Rectangle {
                            color: "red";
                            anchors.fill: parent;

                            Row {
                                spacing: 12;
                                anchors.centerIn: parent;
                                Text {
                                    text: buttonKey;

                                }

                                Text {
                                    text: buttonValue;
                                }
                            }

                        }
                    }
                }

//                InputMappingColumn {
//                    id: actionButtonColumn;

//                    Layout.fillWidth: true;

//                    height: 175;

//                    headerText: qsTr( "Actions" );
//                    exclusiveGroup: inputColumnGroup;
//                    checked: false;

//                    onExclusiveGroupChanged: {
//                        if ( exclusiveGroup ) {
//                            exclusiveGroup.bindCheckable( actionButtonColumn );
//                        }
//                    }


//                }

//                InputMappingColumn {
//                    id: dpadButtonColumn;
//                    Layout.fillWidth: true;
//                    height: 175;
//                    headerText: qsTr( "Digital" );
//                    exclusiveGroup: inputColumnGroup;
//                    checked: false;

//                    onExclusiveGroupChanged: {
//                        if ( exclusiveGroup ) {
//                            exclusiveGroup.bindCheckable( dpadButtonColumn );
//                        }
//                    }

//                    /*
//                    model: ListModel {
//                        ListElement { displayButton: "Up"; key: "dpup"; value: InputDeviceEvent.Up }
//                        ListElement { displayButton: "Left"; key: "dpleft"; value: InputDeviceEvent.Left }
//                        ListElement { displayButton: "Right"; key: "dpright"; value: InputDeviceEvent.Right }
//                        ListElement { displayButton: "Down"; key: "dpdown"; value: InputDeviceEvent.Down }
//                    }*/
//                }

//                InputMappingColumn {
//                    id: miscButtonColumn;

//                    Layout.fillWidth: true;

//                    height: 250;

//                    headerText: qsTr( "Misc." );
//                    exclusiveGroup: inputColumnGroup;
//                    checked: false;

//                    onExclusiveGroupChanged: {
//                        if ( exclusiveGroup ) {
//                            exclusiveGroup.bindCheckable( miscButtonColumn );
//                        }
//                    }
                    /*
                    model: ListModel {
                        ListElement { displayButton: "L3"; key: "leftstick"; value: InputDeviceEvent.L3 }
                        ListElement { displayButton: "R3"; key: "rightstick"; value: InputDeviceEvent.R2 }
                        ListElement { displayButton: "L"; key: "leftshoulder"; value: InputDeviceEvent.L }
                        ListElement { displayButton: "R"; key: "rightshoulder"; value: InputDeviceEvent.R }
                        ListElement { displayButton: "Start"; key: "start"; value: InputDeviceEvent.Start }
                        ListElement { displayButton: "Select"; key: "back"; value: InputDeviceEvent.Select }
                    }*/
                }

                /*
                InputMappingColumn {
                    id: analogColumn;
                    headerText: qsTr( "Analog" );

                    anchors {
                        right: parent.right;
                    }
                    exclusiveGroup: inputColumnGroup;
                    checked: false;

                    onExclusiveGroupChanged: {
                        if ( exclusiveGroup ) {
                            exclusiveGroup.bindCheckable( analogColumn );
                        }
                    }

                    model: ListModel {
                        ListElement { displayButton: "Up"; key: "dpup"; value: InputDeviceEvent.Up }
                        ListElement { displayButton: "Left"; key: "dpleft"; value: InputDeviceEvent.Left }
                        ListElement { displayButton: "Right"; key: "dpright"; value: InputDeviceEvent.Right }
                        ListElement { displayButton: "Down"; key: "dpdown"; value: InputDeviceEvent.Down }
                    }
                }
                */
            //}
        }

    }
}
