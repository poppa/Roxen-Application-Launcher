#!/bin/sh
# Run this to generate all the initial makefiles, etc.

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

PKG_NAME="roxenlauncher"

if test -f "/usr/bin/gnome-autogen.sh"; then
  . gnome-autogen.sh
else
  echo "You need to install \"gnome-common\""
fi
