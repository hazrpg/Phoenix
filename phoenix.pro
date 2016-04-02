TEMPLATE = subdirs
DEFINES += COPY_NO_INSTALL

# We'll always be 64-bit
CONFIG += x86_64

# Externals
SUBDIRS += externals/quazip/quazip

# Our stuff
SUBDIRS += frontend
SUBDIRS += backend

# Ensure that frontend is built last
frontend.depends = backend externals/quazip/quazip

# Make portable target available at the topmost Makefile
portable.CONFIG += recursive
portable.recurse = $$SUBDIRS
portable.recurse_target = portable
QMAKE_EXTRA_TARGETS += portable
