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
    # The default prefix is a folder called "Phoenix" at the root of the build folder
    win32 {
        #SOURCE_PATH = $$system( cygpath -u \"$$PWD\" )
        #TARGET_PATH = $$system( cygpath -u \"$$OUT_PWD\" )

        SOURCE_PATH = $$PWD
        TARGET_PATH = $$OUT_PWD

        isEmpty( PREFIX ) { PREFIX = $$clean_path($$OUT_PWD/../dist) }
        #else { PREFIX = $$PREFIX }

        #message( $$PREFIX )


        #isEmpty( PREFIX ) { PREFIX = $$system( cygpath -u \"$$OUT_PWD\..\dist\" ) }
        #else { PREFIX = $$system( cygpath -u \"$$PREFIX\" ) }
        #PREFIX_WIN = $$system( cygpath -w \"$$PREFIX\" )
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
    TARGETDEPS += ../externals/quazip/quazip/libquazip.a

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
#    metadb.depends += "$$PWD/metadata/openvgdb.sqlite" \
#                      "$$PWD/metadata/libretro.sqlite"

    # For the default target (...and anything that depends on it)
#    metadb.target += $$TARGET_PATH/metadata/openvgdb.sqlite
#    metadb.target += $$TARGET_PATH/metadata/libretro.sqlite
#    metadb.commands += $(COPY_FILE) \"$$SOURCE_PATH/metadata/openvgdb.sqlite\" \"$$TARGET_PATH/Metadata/openvgdb.sqlite\"
#    metadb.commands += $(COPY_FILE) \"$$SOURCE_PATH/metadata/libretro.sqlite\" \"$$TARGET_PATH/Metadata/libretro.sqlite\"
#    POST_TARGETDEPS += metadb

    # Make qmake aware that this target exists




#equals(_PRO_FILE_PWD_, $$OUT_PWD) {

# [!! COPY FILES COMMANDS !!]
_________________________________________________________________________________________________________________________________

    copy_metadata_db.target +=   $$TARGET_PATH/metadata/openvgdb.sqlite
    copy_metadata_db.depends +=  $$PWD/metadata/openvgdb.sqlite
    copy_metadata_db.commands += $(MKDIR) $$TARGET_PATH/metadata; $(COPY_FILE) \"$$SOURCE_PATH/metadata/openvgdb.sqlite\" \"$$TARGET_PATH/metadata/openvgdb.sqlite\"

    copy_libretro_db.target +=   $$TARGET_PATH/metadata/libretro.sqlite
    copy_libretro_db.depends +=  $$PWD/metadata/libretro.sqlite
    copy_libretro_db.commands += $(COPY_FILE) \"$$SOURCE_PATH/metadata/libretro.sqlite\" \"$$TARGET_PATH/metadata/libretro.sqlite\"

    QMAKE_EXTRA_TARGETS += copy_metadata_db copy_libretro_db

    PRE_TARGETDEPS += $$copy_metadata_db.target
    PRE_TARGETDEPS += $$copy_libretro_db.target
__________________________________________________________________________________________________________________________________

# [!! MAKE INSTALL COMMANDS !!] ##################################################################################################
    metadb.files += "$$PWD/metadata/openvgdb.sqlite" \
                    "$$PWD/metadata/libretro.sqlite"
    metadb.path = "$$PREFIX/metadata"
    unix: metadb.path = "$$PREFIX/share/phoenix/metadata"
    INSTALLS += metadb
__________________________________________________________________________________________________________________________________

CONFIG(debug, debug|release) {
    backend_file=backendd.dll
}

CONFIG(release, debug|release) {
    backend_file=backend.dll
}

    plugin_dir = $$TARGET_PATH/plugins/Phoenix/Backend

    copy_backend.target += $$plugin_dir/$$backend_file
    copy_backend.depends += $$clean_path($${TARGET_PATH}/../backend/$$backend_file)
    copy_backend.commands += $(MKDIR) $$plugin_dir; $(COPY_FILE) \"$$copy_backend.depends\" \"$$copy_backend.target\"

    copy_qmldir.target += $$plugin_dir/qmldir
    copy_qmldir.depends += $$clean_path($${TARGET_PATH}/../backend/qmldir)
    copy_qmldir.commands += $(COPY_FILE) \"$$copy_qmldir.depends\" \"$$copy_qmldir.target\"

   QMAKE_EXTRA_TARGETS += copy_backend copy_qmldir
   PRE_TARGETDEPS += $$copy_backend.target $$copy_qmldir.target


#
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
