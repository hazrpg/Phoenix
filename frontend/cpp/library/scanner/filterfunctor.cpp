#include "filterfunctor.h"
#include "phxpaths.h"
#include "cryptohash.h"
#include "libretrodatabase.h"


using namespace Library;

FilterFunctor::FilterFunctor( const Step step )
    : mStep( step ) {
    // Copy firmware sql table into a QHash. This is so we can use GameHasher::isBios() from a QtConcurrent::mappedReduce
    // thread pool, without worrying about sync issues.
    if( mFirmwareMap.isEmpty() ) {
        static const QString firmwareStatement = QStringLiteral( "SELECT system, biosFile, sha1, md5, crc32, region FROM firmware" );

        LibretroDatabase libretroDatabase;

        QSqlQuery query = QSqlQuery( libretroDatabase );

        bool exec = query.exec( firmwareStatement );
        Q_ASSERT_X( exec, Q_FUNC_INFO, qPrintable( query.lastError().text() ) );

        if( exec ) {
            while( query.next() ) {
                QHash<QString, QString> map = {
                    { "system", query.value( 0 ).toString() },
                    { "biosFile", query.value( 1 ).toString() },
                    { "region", query.value( 5 ).toString() },
                };
                mFirmwareMap.insert( query.value( 4 ).toString(), map );
            }
        }
    }
}

bool FilterFunctor::operator()( const FileEntry &entry ) {
    QFileInfo info( entry.filePath );

    if( info.suffix() == QStringLiteral( "bin" ) && entry.scannerResult != GameScannerResult::PartOfCueFile ) {

        // Check for bios, cache if bios is found
        QString biosName;

        if( isBios( info, biosName ) ) {
            qDebug() << "is an actual bios file";
            QString cacheFile = PhxPaths::firmwareLocation() + biosName;
            qDebug() << "File To cache: " << cacheFile;

            if( !QFile::exists( cacheFile ) ) {
                QFile::copy( info.canonicalFilePath(), cacheFile );
            }
        }

        return false;
    }

    return true;
}

bool FilterFunctor::isBios( QFileInfo &info, QString &trueBiosName ) {

    return false;

    QFile file( info.canonicalFilePath() );

    // This file may fail to open if the file is in a zip file, or in a cue file.
    // We can skip cue files, but may need to open zip files and examine...
    // For now, just assume it isn't a bios file.
    if( !file.open( QIODevice::ReadOnly ) ) {
        return false;
    }

    QCryptographicHash sha1( QCryptographicHash::Sha1 );

    sha1.addData( &file );
    QString sha1Result = QString( sha1.result().toHex().toUpper() );

    QHash<QString, QString> firmwareMap = mFirmwareMap.value( sha1Result );
    bool result = !firmwareMap.isEmpty();

    if( !firmwareMap.isEmpty() ) {
        trueBiosName = firmwareMap.value( "biosFile" );
    }

    return result;
}
