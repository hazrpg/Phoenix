# Targets

##
## Phoenix executable (default target)
##

    TARGET = Phoenix

    # App icon, metadata
    win32: RC_FILE = phoenix.rc

    macx {
        ICON = phoenix.icns
    }

##
## Common
##

    # Get the source and target's path
    # On Windows, the DOS qmake paths must be converted to Unix paths as the GNU coreutils we'll be using expect that
    # The default prefix is a folder called "dist" at the root of the build folder
    win32 {
        SOURCE_PATH = $$system( cygpath -u \"$$PWD\" )
        TARGET_PATH = $$system( cygpath -u \"$$OUT_PWD\" )

        isEmpty( PREFIX ) { PREFIX = $$system( cygpath -u \"$$OUT_PWD\..\dist\" ) }
        else { PREFIX = $$system( cygpath -u \"$$PREFIX\" ) }
        PREFIX_WIN = $$system( cygpath -w \"$$PREFIX\" )
    }

    !win32 {
        SOURCE_PATH = $$PWD
        TARGET_PATH = $$OUT_PWD

        isEmpty( PREFIX ) { PREFIX = $$OUT_PWD/../dist }

        # On OS X, write directly to within the .app folder as that's where the executable lives
        macx: TARGET_APP = "$$sprintf( "%1/%2.app", $$OUT_PWD, $$TARGET )"
        macx: TARGET_PATH = "$$TARGET_APP/Contents/MacOS"
        macx: PREFIX_PATH = "$$sprintf( "%1/%2.app", $$PREFIX, $$TARGET )/Contents/MacOS"
    }

    # Force the Phoenix binary to be relinked if the backend code has changed
    win32: TARGETDEPS += ../backend/libphoenix-backend.dll ../externals/quazip/quazip/libquazip.a
    macx: TARGETDEPS += ../backend/libphoenix-backend.dylib ../externals/quazip/quazip/libquazip.a
    unix: !macx: TARGETDEPS += ../backend/libphoenix-backend.so ../externals/quazip/quazip/libquazip.a

    # Make sure it gets installed
    target.path = "$$PREFIX"
    unix: !macx: target.path = "$$PREFIX/bin"
    INSTALLS += target

##
## Make sure that the portable file gets made in the build folder
##

    PORTABLE_FILENAME = PHOENIX-PORTABLE

    # For the default target (...and anything that depends on it)
    QMAKE_POST_LINK += touch \"$$TARGET_PATH/$$PORTABLE_FILENAME\"

    # Delete it from the prefix if doing a make install
    portablefile.path = "$$PREFIX"
    portablefile.extra = rm -f \"$$PREFIX/$$PORTABLE_FILENAME\"

    # Make qmake aware that this target exists
    QMAKE_EXTRA_TARGETS += portablefile

##
## Portable distribution: Copy just the files needed for a portable build to the given prefix so it can be archived
## and distributed
##

    portable.depends = first portablefile

    # Make qmake aware that this target exists
    QMAKE_EXTRA_TARGETS += portable

    # On OS X, just copy the whole .app folder to the prefix
    macx {
        portable.commands += mkdir -p \"$$PREFIX/\" &&\
                             cp -p -R -f \"$$TARGET_APP\" \"$$PREFIX\"
    }

    # Everywhere else, copy the structure verbatim into the prefix
    !macx {
        # Phoenix executable and the file that sets it to portable mode
        portable.commands += mkdir -p \"$$PREFIX/\" &&\
                             cp -p -f \"$$TARGET_PATH/$$TARGET\" \"$$PREFIX/$$TARGET\" &&\
                             cp -p -f \"$$TARGET_PATH/$$PORTABLE_FILENAME\" \"$$PREFIX/$$PORTABLE_FILENAME\" &&\

        # Metadata databases
        portable.commands += mkdir -p \"$$PREFIX/Metadata/\" &&\
                             cp -p -f \"$$TARGET_PATH/metadata/openvgdb.sqlite\" \"$$PREFIX/Metadata/openvgdb.sqlite\" &&\
                             cp -p -f \"$$TARGET_PATH/metadata/libretro.sqlite\" \"$$PREFIX/Metadata/libretro.sqlite\"
    }

##
## Metadata database targets
##

    # Ideally these files should come from the build folder, however, qmake will not generate rules for them if they don't
    # already exist
    metadb.depends += "$$PWD/metadata/openvgdb.sqlite" \
                      "$$PWD/metadata/libretro.sqlite"

    # For the default target (...and anything that depends on it)
    metadb.commands += mkdir -p \"$$TARGET_PATH/Metadata/\" &&\
                       cp -p -f \"$$SOURCE_PATH/metadata/openvgdb.sqlite\" \"$$TARGET_PATH/Metadata/openvgdb.sqlite\" &&\
                       cp -p -f \"$$SOURCE_PATH/metadata/libretro.sqlite\" \"$$TARGET_PATH/Metadata/libretro.sqlite\"
    POST_TARGETDEPS += metadb

    # For make install
    metadb.files += "$$PWD/metadata/openvgdb.sqlite" \
                    "$$PWD/metadata/libretro.sqlite"
    metadb.path = "$$PREFIX/Metadata"
    unix: metadb.path = "$$PREFIX/share/phoenix/Metadata"
    INSTALLS += metadb

    # Make qmake aware that this target exists
    QMAKE_EXTRA_TARGETS += metadb

##
## Linux icon
##

    unix: !macx {
        # Ideally these files should come from the build folder, however, qmake will not generate rules for them if they don't
        # already exist
        linuxicon.depends += "$$PWD/phoenix.png"

        # For make install
        linuxicon.files += "$$PWD/phoenix.png"

        linuxicon.path = "$$PREFIX/share/pixmaps"
        INSTALLS += linuxicon

        # Make qmake aware that this target exists
        QMAKE_EXTRA_TARGETS += linuxicon
    }

##
## Linux .desktop entry
##

    unix: !macx {
        # Ideally these files should come from the build folder, however, qmake will not generate rules for them if they don't
        # already exist
        linuxdesktopentry.depends += "$$PWD/phoenix.desktop"

        # For make install
        linuxdesktopentry.files += "$$PWD/phoenix.desktop"

        linuxdesktopentry.path = "$$PREFIX/share/applications"
        INSTALLS += linuxdesktopentry

        # Make qmake aware that this target exists
        QMAKE_EXTRA_TARGETS += linuxdesktopentry
    }

##
## Copy the backend plugin file and its qmldir file into the build folder
##

    # Backend plugin filename
    win32: backendpluginname = phoenix-backend.dll
    macx: backendpluginname = libphoenix-backend.dylib
    unix: !macx: backendpluginname = libphoenix-backend.so

    # Ideally these files should come from the build folder, however, qmake will not generate rules for them if they don't
    # already exist
    backendplugin.depends += "$$OUT_PWD/../backend/$$backendpluginname"

    # For the default target (...and anything that depends on it)
    backendplugin.commands += mkdir -p \"$$TARGET_PATH/Plugins/vg/phoenix/backend\" &&\
                       cp -p -f \"$$OUT_PWD/../backend/$$backendpluginname\" \"$$TARGET_PATH/Plugins/vg/phoenix/backend/$$backendpluginname\" &&\
                       cp -p -f \"$$SOURCE_PATH/../backend/qmldir\" \"$$TARGET_PATH/Plugins/vg/phoenix/backend/qmldir\"
    PRE_TARGETDEPS += backendplugin

    # For make install
    backendplugin.files += "$$OUT_PWD/../backend/$$backendpluginname" \
                           "$$SOURCE_PATH/../backend/qmldir"
    backendplugin.path = "$$PREFIX/Plugins/vg/phoenix/backend"
    unix: backendplugin.path = "$$PREFIX/lib/phoenix/Plugins/vg/phoenix/backend"
    INSTALLS += backendplugin

    # Make qmake aware that this target exists
    QMAKE_EXTRA_TARGETS += backendplugin

##
## On OS X, ignore all of the above when it comes to make install and just copy the whole .app folder verbatim
##

    macx {
        macxinstall.path = "$$PREFIX/"
        macxinstall.extra = mkdir -p \"$$PREFIX\" &&\
                            cp -p -R \"$$TARGET_APP\" \"$$PREFIX\" &&\
                            rm -f \"$$PREFIX_PATH/$$PORTABLE_FILENAME\"

        # Note the lack of +
        INSTALLS = macxinstall
    }

##
## Debugging info
##

    # win32 {
    #     !build_pass: message( PWD: $$PWD )
    #     !build_pass: message( OUT_PWD: $$OUT_PWD )
    # }
    # !build_pass: message( SOURCE_PATH: $$SOURCE_PATH )
    # !build_pass: message( TARGET_PATH: $$TARGET_PATH )
    # !build_pass: message( TARGET: $$TARGET )
    # win32 {
    #     !build_pass: message( PREFIX: $$PREFIX )
    #     !build_pass: message( PREFIX_WIN: $$PREFIX_WIN )
    # }
