TEMPLATE = subdirs

# Externals
SUBDIRS += externals/quazip/quazip

DEFINES += COPY_NO_INSTALL

# Our stuff
SUBDIRS += frontend
SUBDIRS += backend


# We'll always be 64-bit
CONFIG += x86_64

# Ensure that frontend is built last
frontend.depends = backend externals/quazip/quazip

# Make portable target available at the topmost Makefile
portable.CONFIG += recursive
portable.recurse = $$SUBDIRS
portable.recurse_target = portable
QMAKE_EXTRA_TARGETS += portable
