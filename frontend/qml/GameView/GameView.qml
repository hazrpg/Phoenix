import QtQuick 2.5
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import QtQuick.Window 2.0

import vg.phoenix.themes 1.0
import vg.phoenix.paths 1.0

import Phoenix.Backend 1.0
import Phoenix.Parse 1.0

// Without deleting this component after every play session, we run the risk of a memory link from the core pointer not being cleared properly.
// This issue needs to be fixed.

Rectangle {
    id: gameView;
    color: PhxTheme.common.gameViewBackgroundColor;

    // Automatically set by VideoItem, true if a game is loaded and unpaused
    property bool running: gameConsole.playbackState === GameConsole.Playing;
    property alias playbackState: gameConsole.playbackState;
    property alias gameConsole: gameConsole;
    property alias videoOutput: phxVideoOutput;
    property bool showBar: true;
    property string title: "";
    property string artworkURL: "";

    // Object that handles the running game session

    GameConsole {
        id: gameConsole;

        videoOutput: phxVideoOutput;

        vsync: false;
        volume: gameActionBar.volumeValue;

        // Use this to automatically play once loaded
        property bool autoPlay: false;
        property bool firstLaunch: true;

        Component.onCompleted: {
            // Grab the command line arg dictionary
            source = CommandLine.args();

            // Load and play if a type was set (the remaining members of the dict (src) are assumed to be there and
            // validated by the command line parser)
            if( source[ "type" ] ) {
                load();
                play();
                layoutStackView.pop();
            }
        }

        onGamepadAdded: {
            GamepadModel.addGamepad( gamepad );
            RemapModel.addGamepad( gamepad );
        }

        onGamepadRemoved: {
            GamepadModel.removeGamepad( gamepad );
            RemapModel.addGamepad( gamepad );
        }

        onSourceChanged: {
            title = source[ "title" ] ? source[ "title" ] : "";
            artworkURL = source[ "artworkURL" ];
            root.touchMode = source[ "core" ].indexOf( "desmume" ) > -1;
        }

        onPlaybackStateChanged: {
            switch( playbackState ) {
                case GameConsole.Stopped:
                    phxVideoOutput.opacity = 0.0;
                    resetCursor();
                    cursorTimer.stop();
                    showBar = true;
                    break;

                case GameConsole.Loading:
                    phxVideoOutput.opacity = 0.0;
                    resetCursor();
                    cursorTimer.stop();
                    break;

                case GameConsole.Playing:
                    root.title = title;
                    rootMouseArea.cursorShape = Qt.BlankCursor;

                    // Show the game content
                    phxVideoOutput.opacity = 1.0;

                    // Let the window be resized even smaller than the default minimum size according to the aspect ratio
                    root.minimumWidth = Math.min( root.defaultMinWidth, root.defaultMinWidth / phxVideoOutput.aspectRatio / 2 );
                    root.minimumHeight = Math.min( root.defaultMinHeight, root.defaultMinHeight / phxVideoOutput.aspectRatio / 2 );

                    break;

                case GameConsole.Paused:
                    root.title = "Paused - " + title;
                    if( firstLaunch ) {
                        firstLaunch = false;
                        if( autoPlay ) {
                            console.log( "Autoplay activated" );
                            play();
                        }
                    }

                    phxVideoOutput.opacity = 1.0;
                    resetCursor();
                    cursorTimer.stop();
                    break;

                case GameConsole.Unloading:
                    root.title = "Unloading - " + title;
                    firstLaunch = true;
                    phxVideoOutput.opacity = 0.0;
                    resetCursor();
                    cursorTimer.stop();
                    break;

                default:
                    break;
            }
        }
    }

    // A cool logo effect
    Item {
        id: gameViewBackground;
        anchors.fill: parent;
        // A logo
        // Only visible when a game is not running
        Image {
            id: phoenixLogo;
            anchors.centerIn: parent;
            width: 150;
            height: width;
            source: "phoenix.png";
            sourceSize { height: height; width: width; }
            opacity: 0.25;
            enabled: phxVideoOutput.opacity === 1.0 ? false : true;
        }

        // Glow effect for the logo
        // Only visible when a game is not running
        Glow {
            anchors.fill: phoenixLogo;
            source: phoenixLogo;
            color: "#d55b4a";
            radius: 8.0;
            samples: 16;
            enabled: phxVideoOutput.opacity === 1.0 ? false : true;
            SequentialAnimation on radius {
                loops: Animation.Infinite;
                PropertyAnimation { to: 16; duration: 2000; easing.type: Easing.InOutQuart; }
                PropertyAnimation { to: 8; duration: 2000; easing.type: Easing.InOutQuart; }
            }
        }

    }

    // VideoOutput settings
    property alias aspectMode: phxVideoOutput.aspectMode;
    property alias linearFiltering: phxVideoOutput.linearFiltering;
    property alias television: phxVideoOutput.television;
    property alias ntsc: phxVideoOutput.ntsc;
    property alias widescreen: phxVideoOutput.widescreen;

    // A blurred copy of the video that sits behind the real video as an effect
    FastBlur {
        id: blurEffect;
        anchors.fill: parent;
        source: phxVideoOutput;
        radius: 64;
    }

    // QML-based video output module
    VideoOutput {
        id: phxVideoOutput;
        anchors.centerIn: parent;

        // Scaling

        // Info for the various modes
        property real letterBoxHeight: parent.width / aspectRatio;
        property real letterBoxWidth: parent.width;
        property real pillBoxWidth: parent.height * aspectRatio;
        property real pillBoxHeight: parent.height;
        property bool pillBoxing: parent.width / parent.height / aspectRatio > 1.0;

        // Fit mode (0): Maintain aspect ratio, fit all content within window, letterboxing/pillboxing as necessary
        property real fitModeWidth: pillBoxing ? pillBoxWidth : letterBoxWidth;
        property real fitModeHeight: pillBoxing ? pillBoxHeight : letterBoxHeight;

        // Stretch mode (1): Fit to parent, ignore aspect ratio
        property real stretchModeWidth: parent.width;
        property real stretchModeHeight: parent.height;

        // Fill mode (2): Maintian aspect ratio, fill window with content, cropping the remaining stuff
        property real fillModeWidth: 0;
        property real fillModeHeight: 0;

        // Center mode (3): Show at core's native resolution
        property real centerModeWidth: 0;
        property real centerModeHeight: 0;

        property int aspectMode: 0;

        width: {
            switch( aspectMode ) {
                case 0:
                    width: fitModeWidth;
                    break;
                case 1:
                    width: stretchModeWidth;
                    break;
                case 2:
                    width: fillModeWidth;
                    break;
                case 3:
                    width: centerModeWidth;
                    break;
                default:
                    width: 0;
                    break;
            }
        }
        height: {
            switch( aspectMode ) {
                case 0:
                    height: fitModeHeight;
                    break;
                case 1:
                    height: stretchModeHeight;
                    break;
                case 2:
                    height: fillModeHeight;
                    break;
                case 3:
                    height: centerModeHeight;
                    break;
                default:
                    height: 0;
                    break;
            }
        }

        linearFiltering: false;
        television: false;
        ntsc: true;
        widescreen: false;

        // Touch control

        MouseArea {
            anchors.fill: parent;

            property real touchX: 0;
            property real touchY: 0;
            property point touch: Qt.point( 0, 0 );
            property bool touched: false;

            acceptedButtons: root.touchMode ? Qt.LeftButton | Qt.RightButton : Qt.LeftButton;
            onDoubleClicked: {
                if( root.touchMode ) {
                    mouse.accepted = false;
                } else {
                    if ( root.visibility === Window.FullScreen )
                        root.visibility = Window.Windowed;
                    else if ( root.visibility === Window.Windowed | Window.Maximized )
                        root.visibility = Window.FullScreen;
                }
            }
            onClicked: {
                if( root.touchMode ) {
                    if( mouse.button === Qt.RightButton && running ) {
                        // Toggle state
                        if( showBar ) showBar = false;
                        else showBar = true;
                    }
                }
            }
            onPressed: checkMouse( mouse );
            onReleased: forceAnEvent( mouse );
            onPositionChanged: checkMouse( mouse );

            function checkMouse( mouse ) {
                if( root.touchMode ) {
                    touch = Qt.point( ( width - mouseX ) / width, ( height - mouseY ) / height );
                    touched = pressedButtons & Qt.LeftButton;
                    // console.log( touch + " touched = " + touched + " (normal event)" );
                    //root.gamepadManager.updateTouchState( touch, touched );
                }
            }

            // Send both messages to ensure it gets registered
            // Needed as the Apple trackpad sends pressed and released messages in quick succession
            // but not instantly. Some games cannot take one-frame input. InputManager uses a special latch
            // to ensure such one-frame inputs get played out over two frames.
            function forceAnEvent( mouse ) {
                if( root.touchMode && mouse.button === Qt.LeftButton ) {
                    // console.log( touch + " touched = true (event forced)" );
                    //root.gamepadManager.updateTouchState( touch, true );
                    //root.gamepadManager.updateTouchState( touch, false );
                }
            }
        }
    }

    // In-game controls
    GameActionBar {
        id: gameActionBar;

        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 10; }
        width: 350;
        height: 45;

        visible: opacity !== 0.0;
        enabled: visible;

        // gameActionBar visible only when paused or mouse recently moved and only while not transitioning
        opacity: {
            if( root.touchMode ) {
                opacity: 0.0;
                if( gameView.showBar || gameView.playbackState === GameConsole.Paused ) opacity: 1.0;
            } else {
                if( ( gameConsole.playbackState === GameConsole.Paused || cursorTimer.running || gameActionBarMouseArea.containsMouse )
                    && ( !layoutStackView.transitioning ) ) {
                    opacity: 1.0
                } else {
                    opacity: 0.0;
                }
            }
        }
    }

    // A hint on how to hide the action bar (for touch mode)
    Text {
        id: actionBarHint;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.bottom: gameActionBar.top;
        width: contentWidth * 2;
        height: contentHeight * 2;

        opacity: gameActionBar.opacity;
        visible: root.touchMode && gameView.playbackState === GameConsole.Playing;
        enabled: visible;

        verticalAlignment: Text.AlignVCenter;
        horizontalAlignment: Text.AlignHCenter;
        text: "(Right-click to hide)";
        color: "white";
        style: Text.Outline;
        styleColor: "black";

        font {
            pixelSize: 12;
            family: PhxTheme.common.systemFontFamily;
        }
    }

    // Mouse stuff

    // Use the main mouse area to monitor the mouse for movement
    Connections {
        target: rootMouseArea;
        onPositionChanged: mouseMoved();
        onPressed: mouseMoved();
        onReleased: mouseMoved();
        onPressAndHold: mouseMoved();
    }

    // Use this mouse area (which is the same size as GameActionBar) to see if the cursor is in that region
    Connections {
        target: gameActionBarMouseArea;
        onEntered: {
            cursorTimer.stop();
            resetCursor();
        }
        onExited: {
            mouseMoved();
        }
    }

    property Timer cursorTimer: Timer {
        interval: 1000;
        running: false;
        onTriggered: {
            // Don't hide anything in touch mode
            if( !root.touchMode ) hideCursor();
        }
    }

    // This function will reset the timer when called (which is whenever the mouse is moved)
    function mouseMoved() {
        // Reset the timer, show the mouse cursor and action bar (usually when mouse is moved)
        if( gameView.running && rootMouseArea.hoverEnabled ) {
            cursorTimer.restart();
            resetCursor();
        }
    }

    function hideCursor() { rootMouseArea.cursorShape = Qt.BlankCursor; }
    function resetCursor() { rootMouseArea.cursorShape = Qt.ArrowCursor; }
}
