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

CommandLine::CommandLine(QObject *parent)
    : QObject(parent)
{

}

bool CommandLine::checkCmdLineRun(const QCoreApplication &app) {
    return app.arguments().size() > 1 ;
}

bool CommandLine::setArgs( const QCoreApplication &app) {

    auto args = app.arguments();
    QString key;
    for( int i=1; i < args.size(); ++i ) {
        const auto param = args[ i ];
        if ( param.startsWith( '-' ) ) {
            if ( !key.isEmpty() ) {
                static_args[ key ] = QStringLiteral( "" );
            }
            key = param;
        } else {
            if ( !key.isEmpty() ) {
               static_args[ key ] = param;
               key.clear();
            }
        }
    }

    if ( static_args.contains( QStringLiteral( "--libretro" ) ) ) {
        if ( args.size() != 6 ) {
            auto core = static_args[ QStringLiteral( "-c" ) ].toString();
            auto game = static_args[ QStringLiteral( "-g" ) ].toString();
            if ( core.isEmpty() ) {
                qCDebug( phxCmdLine ) << "the core needs to be set by '-c \"/path/to/libretro_core.so\"'.";
            }
            if ( game.isEmpty() ) {
                qCDebug( phxCmdLine ) << "the game needs to be set by '-g \"/path/to/game.file\"'";
            }
            printHeader();
            printUsage();
            return false;
        }
    } else  {
        qCDebug( phxCmdLine ) << QCoreApplication::applicationName()
                              << "currently only support the libretro api, set"
                              << "'--libretro' as the backend.";
        printHeader();
        printUsage();
        return false;
    }


    return true;

}

QVariant CommandLine::args()
{
    return static_args;
}

QObject *CommandLine::registerSingletonCallback(QQmlEngine *, QJSEngine *) {
    return new CommandLine;
}
