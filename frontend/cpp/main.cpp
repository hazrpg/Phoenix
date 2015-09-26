#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "videoitem.h"
#include "inputmanager.h"
#include "librarymodel.h"
#include "libraryworker.h"
#include "imagecacher.h"
#include "platformsmodel.h"
#include "collectionsmodel.h"
#include "phxpaths.h"

#include <memory.h>

// This is used to get the stack trace behind whatever debug message you want to diagnose
// Simply change the message string below to whatever you want (partial string matching), set the breakpoint
// and uncomment the first line in main()
void phoenixDebugMessageHandler( QtMsgType type, const QMessageLogContext &context, const QString &msg ) {

    // Change this QString to reflect the message you want to get a stack trace for
    if( QString( msg ).contains( QStringLiteral( "YOUR MESSAGE HERE" ) ) ) {

        // Put a breakpoint over this line...
        int breakPointOnThisLine( 0 );

        // ...and not this one
        Q_UNUSED( breakPointOnThisLine );

    }

    QByteArray localMsg = msg.toLocal8Bit();

    switch( type ) {

        case QtDebugMsg:
            fprintf( stderr, "Debug: %s (%s:%u, %s)\n",
                     localMsg.constData(), context.file, context.line, context.function );
            break;

        case QtInfoMsg:
            fprintf( stderr, "Info: %s (%s:%u, %s)\n",
                     localMsg.constData(), context.file, context.line, context.function );
            break;

        case QtWarningMsg:
            fprintf( stderr, "Warning: %s (%s:%u, %s)\n",
                     localMsg.constData(), context.file, context.line, context.function );
            break;

        case QtCriticalMsg:
            fprintf( stderr, "Critical: %s (%s:%u, %s)\n",
                     localMsg.constData(), context.file, context.line, context.function );
            break;

        case QtFatalMsg:
            fprintf( stderr, "Fatal: %s (%s:%u, %s)\n",
                     localMsg.constData(), context.file, context.line, context.function );
            abort();
            break;

        default:
            break;

    }

}

int main( int argc, char *argv[] ) {

    // Uncomment this to enable the message handler for debugging and stack tracing
    // qInstallMessageHandler( phoenixDebugMessageHandler );

    QApplication app( argc, argv );

    // On Windows, the organization domain is used to set the registry key path... for some reason
    QApplication::setApplicationDisplayName( QStringLiteral( "Phoenix" ) );
    QApplication::setApplicationName( QStringLiteral( "Phoenix" ) );
    QApplication::setApplicationVersion( QStringLiteral( "1.0" ) );
    QApplication::setOrganizationDomain( QStringLiteral( "phoenix.vg" ) );

    Library::PhxPaths::CreateAllPaths();

    QQmlApplicationEngine engine;


    QUrl appPath(QString("%1").arg(QGuiApplication::applicationDirPath()));
    engine.rootContext()->setContextProperty("appPath", appPath);

    QUrl userPath;
    const QStringList usersLocation = QStandardPaths::standardLocations(QStandardPaths::HomeLocation);
    if (usersLocation.isEmpty())
        userPath = appPath.resolved(QUrl("/home/"));
    else
        userPath = QString("%1").arg(usersLocation.first());
    engine.rootContext()->setContextProperty("userPath", userPath);

    QUrl imagePath;
    const QStringList picturesLocation = QStandardPaths::standardLocations(QStandardPaths::PicturesLocation);
    if (picturesLocation.isEmpty())
        imagePath = appPath.resolved(QUrl("images"));
    else
        imagePath = QString("%1").arg(picturesLocation.first());
    engine.rootContext()->setContextProperty("imagePath", imagePath);

    QUrl videoPath;
    const QStringList moviesLocation = QStandardPaths::standardLocations(QStandardPaths::MoviesLocation);
    if (moviesLocation.isEmpty())
        videoPath = appPath.resolved(QUrl("./"));
    else
        videoPath = QString("%1").arg(moviesLocation.first());
    engine.rootContext()->setContextProperty("videoPath", videoPath);

    QUrl homePath;
    const QStringList homesLocation = QStandardPaths::standardLocations(QStandardPaths::HomeLocation);
    if (homesLocation.isEmpty())
        homePath = appPath.resolved(QUrl("/"));
    else
        homePath = QString("%1").arg(homesLocation.first());
    engine.rootContext()->setContextProperty("homePath", homePath);

    QUrl desktopPath;
    const QStringList desktopsLocation = QStandardPaths::standardLocations(QStandardPaths::DesktopLocation);
    if (desktopsLocation.isEmpty())
        desktopPath = appPath.resolved(QUrl("/"));
    else
        desktopPath = QString("%1").arg(desktopsLocation.first());
    engine.rootContext()->setContextProperty("desktopPath", desktopPath);

    QUrl docPath;
    const QStringList docsLocation = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation);
    if (docsLocation.isEmpty())
        docPath = appPath.resolved(QUrl("/"));
    else
        docPath = QString("%1").arg(docsLocation.first());
    engine.rootContext()->setContextProperty("docPath", docPath);


    QUrl tempPath;
    const QStringList tempsLocation = QStandardPaths::standardLocations(QStandardPaths::TempLocation);
    if (tempsLocation.isEmpty())
        tempPath = appPath.resolved(QUrl("/"));
    else
        tempPath = QString("%1").arg(tempsLocation.first());
    engine.rootContext()->setContextProperty("tempPath", tempPath);

    // Register my types!
    VideoItem::registerTypes();
    InputManager::registerTypes();

    qmlRegisterSingletonType( QUrl( "qrc:/PhxTheme.qml" ), "vg.phoenix.themes", 1, 0, "PhxTheme" );
    qmlRegisterType<Library::PlatformsModel>( "vg.phoenix.models", 1, 0, "PlatformsModel" );
    qmlRegisterType<Library::CollectionsModel>( "vg.phoenix.models", 1, 0, "CollectionsModel" );
    qmlRegisterType<Library::LibraryModel>( "vg.phoenix.models", 1, 0, "LibraryModel" );
   //qmlRegisterType<Library::MetaDataDatabase>( "vg.phoenix.models", 1, 0, "MetaDatabase" );

    qmlRegisterType<Library::ImageCacher>( "vg.phoenix.cache", 1, 0, "ImageCacher" );

    qRegisterMetaType<Library::GameData>( "GameData" );

    engine.load( QUrl( QStringLiteral( "qrc:/main.qml" ) ) );

    return app.exec();

}
