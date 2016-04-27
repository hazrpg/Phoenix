#include "commandline.h"
#include "logging.h"

#include <QFile>
#include <QCoreApplication>

void printHeader() {
    qCDebug( phxCmdLine ) << "\n------------------------------------------------------------------\n"
                          << QCoreApplication::applicationName() << "is a mutli-system emulator"
                          << "and libretro frontend.\n"
                          <<  "-----------------------------------------------------------------";
}

void printHelpInfo() {

}

void printUsage() {
    qDebug() << "usage: phoenix [BACKEND] [OPTION...]";
    qDebug() << "    option:\n"
             << "        -h: shows full command line usage\n"
             << "        -c: emulation core used by the '--libretro' backend\n"
             << "        -g: game to play (used by '--libretro' backend\n";
    qDebug() << "    backend:\n"
             << "        --libretro: the libretro.api backend\n";
    qDebug() << "    example:\n"
             << "        \"phoenix --libretro -c '/usr/lib/libretro/snes9x_libretro.so' -g '/home/user/Desktop/game.sfc'\"";
}

QVariantMap CommandLine::static_args = QVariantMap();
QCommandLineParser CommandLine::parser;

CommandLine::CommandLine( QObject *parent )
    : QObject( parent ) {
}

void CommandLine::parseCommandLine( const QCoreApplication &app ) {
    parser.addOptions( {
        { { "c", "core" }, "Set the Libretro core", "Core path" },
        { { "g", "game" }, "Set the Libretro game", "Game path" },
        { "libretro", "Run a game in Libretro mode. Choose a core with -c and a game with -g" }
    } );
    parser.addVersionOption();
    parser.addHelpOption();
    parser.setApplicationDescription( "Phoenix - A multi-system emulator" );
    parser.process( app );
    qDebug() << "Type:" << parser.isSet( "libretro" ) << "Path:"
             << parser.value( "core" ) << "|" << parser.value( "game" );

    // Set source based on type given, quit if none is set
    if( parser.isSet( "libretro" ) ) {
        initLibretroSrc();
    } else {
        qWarning() << "A mode must be specified";
        parser.showHelp();
    }
}

void CommandLine::initLibretroSrc() {
    if( !parser.value( "core" ).isEmpty() ) {
        static_args[ "core" ] = parser.value( "core" );
    } else {
        qWarning() << "A game must be specified";
        parser.showHelp();
    }

    if( !parser.value( "game" ).isEmpty() ) {
        static_args[ "game" ] = parser.value( "game" );
    } else {
        qWarning() << "A game must be specified";
        parser.showHelp();
    }

    if( !QFile::exists( parser.value( "core" ) ) ) {
        qWarning() << "Core file does not exist!";
        parser.showHelp();
    }

    if( !QFile::exists( parser.value( "game" ) ) ) {
        qWarning() << "Game file does not exist!";
        parser.showHelp();
    }

}

QVariant CommandLine::args() {
    return static_args;
}

QObject *CommandLine::registerSingletonCallback( QQmlEngine *, QJSEngine * ) {
    return new CommandLine;
}
