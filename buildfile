# file      : buildfile
# copyright : not copyrighted - public domain

./: {*/ -build/} doc{INSTALL README} manifest

# Don't install tests or the INSTALL file.
#
dir{test/}:      install = false
doc{INSTALL}@./: install = false
