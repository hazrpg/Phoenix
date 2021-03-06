#include "cmdlineargs.h"

#include <QFile>
#include <QFileInfo>
#include <QDebug>

QVariantMap parseCommandLine( QCoreApplication &app ) {
    QCommandLineParser parser;
    parser.addOptions( {
        { "libretro", "Run a game in Libretro mode. Choose a core with -c and a game with -g" },
        { { "c", "core" }, "Set the Libretro core", "core path" },
        { { "g", "game" }, "Set the Libretro game", "game path" },
    } );
    parser.addVersionOption();
    parser.addHelpOption();
    parser.setApplicationDescription( "Phoenix - A multi-system emulator" );
    parser.process( app );

    QVariantMap map;

    // Set source based on type given, quit if none is set
    if( parser.isSet( "libretro" ) ) {
        map[ "type" ] = "libretro";

        if( !parser.value( "core" ).isEmpty() ) {
            // Clean up the file path given from the user
            map[ "core" ] = QFileInfo( parser.value( "core" ) ).canonicalFilePath();
        } else {
            qWarning() << "A game must be specified";
            parser.showHelp();
        }

        if( !parser.value( "game" ).isEmpty() ) {
            // Clean up the file path given from the user
            map[ "game" ] = QFileInfo( parser.value( "game" ) ).canonicalFilePath();
        } else {
            qWarning() << "A game must be specified";
            parser.showHelp();
        }

        if( !QFileInfo::exists( parser.value( "core" ) ) ) {
            qWarning() << "Core file does not exist!";
            parser.showHelp();
        }

        if( !QFileInfo::exists( parser.value( "game" ) ) ) {
            qWarning() << "Game file does not exist!";
            parser.showHelp();
        }

        // Grab filename, use as title
        QFileInfo fileInfo( parser.value( "game" ) );
        map[ "title" ] = fileInfo.completeBaseName();
    } else if( app.arguments().length() == 1 ) {
        // Let this through
    } else {
        qWarning() << "A mode must be specified";
        parser.showHelp();
    }

    return map;
}
