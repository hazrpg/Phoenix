#pragma once

#include <QObject>
#include <QVariant>

class QCoreApplication;
class QQmlEngine;
class QJSEngine;

class CommandLine : public QObject
{
    Q_OBJECT

public:
    explicit CommandLine(QObject *parent = 0);

    static bool checkCmdLineRun( const QCoreApplication &app );
    static bool setArgs( const QCoreApplication &app );

    Q_INVOKABLE static QVariant args();

    static QObject *registerSingletonCallback( QQmlEngine *engine, QJSEngine * );

private:
    static QVariantMap static_args;
};
