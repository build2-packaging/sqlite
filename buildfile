# file      : buildfile
# copyright : not copyrighted - public domain

./: lib{sqlite3} test/ doc{README} file{manifest}
include test/

lib{sqlite3}: {h c}{sqlite3} h{sqlite3ext}

# The set of features we enable by default is inspired by Debian, Fedora, and
# the official documentation.
#
# Note that we "prefix" them to what might have been specified by the user so
# that it is possible to override the defaults by specifying them as =0 (it's
# also the reason we use cc.* instead of c.*, the former comes first).
#
# PREUPDATE_HOOK is required by SESSION
#
# -DSQLITE_ENABLE_SESSION=1 removed due to bug in 3.14.1.
#
cc.poptions =+ \
-DSQLITE_THREADSAFE=1 \
-DSQLITE_ENABLE_FTS4=1 \
-DSQLITE_ENABLE_FTS5=1 \
-DSQLITE_ENABLE_RTREE=1 \
-DSQLITE_ENABLE_JSON1=1 \
-DSQLITE_SECURE_DELETE=1 \
-DSQLITE_ENABLE_DBSTAT_VTAB=1 \
-DSQLITE_ENABLE_UNLOCK_NOTIFY=1 \
-DSQLITE_ENABLE_LOAD_EXTENSION=1 \
-DSQLITE_ENABLE_PREUPDATE_HOOK=1 \
-DSQLITE_ENABLE_COLUMN_METADATA=1 \
-DSQLITE_ENABLE_FTS3_PARENTHESIS=1

if ($c.target.class != "windows")
{
  cc.poptions =+ -DHAVE_USLEEP=1

  # SQLITE_THREADSAFE requres -lpthread
  # SQLITE_ENABLE_LOAD_EXTENSION requires -ldl
  # SQLITE_ENABLE_FTS5 requires -lm (calls log(1))
  #
  # You may be wondering why we didn't import them instead. While it would be
  # almost equivalent, there is a subtle difference: if we import them, then
  # build2 will start selecting static/shared libraries and we probably don't
  # want that here. These libraries are in a sense an extension of -lc and we
  # want them to be linked in the same way as -lc (e.g., the user will have to
  # specify -static to force static linking and so on).
  #
  c.libs += -lpthread -ldl -lm

  # @@ Currently not implemented in build2. Also is it right to link to other
  #    libraries that may have been specified by the user?
  #
  liba{sqlite3}: cc.export.libs = $c.libs
}

# Both Debian and Fedora add this so gotta be important.
#
if ($c.id != "msvc")
  c.coptions += -fno-strict-aliasing

# It would have been cleaner to handle this in a header but that will require
# modifying sqlite3.h. Note that this is also sub-optimal if we are not using
# an export stub (no dllimport).
#
lib{sqlite3}: cc.export.poptions = -I$src_root

if ($c.target.class == "windows")
{
  objs{*}: c.poptions += '-DSQLITE_API=__declspec(dllexport)'
  libs{sqlite3}: cc.export.poptions += '-DSQLITE_API=__declspec(dllimport)'
}
