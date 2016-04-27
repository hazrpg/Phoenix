#pragma once

#include <QObject>
#include <QVariant>
#include <QCommandLineOption>
#include <QCommandLineParser>

class QCoreApplication;
class QQmlEngine;
class QJSEngine;

class CommandLine : public QObject {
        Q_OBJECT

    public:
        explicit CommandLine( QObject *parent = 0 );

        static void parseCommandLine( const QCoreApplication &app );

        static void initLibretroSrc();

        Q_INVOKABLE static QVariant args();

        static QObject *registerSingletonCallback( QQmlEngine *engine, QJSEngine * );

    private:
        static QCommandLineParser parser;
        static QVariantMap static_args;
};
