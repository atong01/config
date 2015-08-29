#!/bin/bash
# This script is meant to be sourced by scripts in subdirectories. It automatically
# determines the canonical paths to the directory containing the sourcing script, the
# workspace directory, the corresponding "built" peer directory for the sourcing script, etc.
#
# A script in a child directory should put the following line at the top of the script:
#
#      set -e && . `dirname $0`/../ws-env.sh
#
# (The number of ../ elements corresponds to the child directory's depth).
#
# Alternatively, a symbolic link ws-env.sh can link to this file from inside the child script's directory, and
# the child script can always use:
#
#      set -e && . `dirname $0`/ws-env.sh
#
# The following variables will be defined (all paths fully canonical):
#
# To debug this script set DEBUG_WS_SCRIPTS environment variable to get an xray
#
# WS_DIR                Workspace root directory
# GIT_PROJECT_DIR       $WS_DIR/git/<current-project-name>
# BUILT_ROOT_DIR        $WS_DIR/built
# SCRIPT_DIR            The directory containing the script that sourced this file
# SCRIPT_WORKING_DIR    The current working directory at the time this file was sourced
# SCRIPT_RELATIVE_DIR   The directory of the sourcing script relative to $WS_DIR/git/
# SCRIPT_BUILT_DIR      The directory under $WS_DIR/built that is a peer to the sourcing script's directory
# SOURCE_DIR            $WS_DIR/git/source
# SOURCE_SCRIPTS_DIR    $SOURCE_DIR/scripts

set -e

# realpath is a prerequisite so we will install
# it here if necessary
if ! which realpath > /dev/null; then
 sudo apt-get install -y realpath > /dev/null
fi

# Adds a variable, optionally sets its value, exports it if necessary, and dumps it if debugging
# $1 = global variable name
# $2 = value to set. If omitted, value is left unchanged
wsAddVar() {
  if (( $# > 1 )); then
    eval $1="'$2'"
  fi
  if [[ -n "${EXPORT_WS_ENV}" ]]; then
    export $1
  fi
  if [[ -n "$DEBUG_WS_SCRIPTS" ]]; then
    echo "$(basename $0): $1=${!1}" >&2
  fi
}

# Adds directory to one of the system pathes IF it is not on the path already
# $1 = variable name (e.g., "PATH")
# $2 = directory to add, already expanded
wsPathAddUnique() {
  eval oldpath="'$1'"
  if [[ "$oldpath" == "" ]]; then
    eval $1="'$2'"
  elif [[ ":$oldpath:" != *":$2:"* ]]; then
    eval $1="'$2:$1'"
  fi
}

if [ -n "$DEBUG_WS_SCRIPTS" ]; then
 set -x
fi

if [[ -z "${BASH_SOURCE[1]}" ]]; then
   EXPORT_WS_ENV=1
fi

wsAddVar SCRIPT_WORKING_DIR "$(realpath .)"
WS_ENV_SCRIPT_FULL_PATH="$(realpath "${BASH_SOURCE[0]}")"
wsAddVar GIT_PROJECT_DIR "$(dirname "$WS_ENV_SCRIPT_FULL_PATH")"
wsAddVar WS_DIR "$(realpath "$GIT_PROJECT_DIR/../..")"
wsAddVar SOURCE_DIR "$WS_DIR/git/source"

if [ -r "$SOURCE_DIR/ws-default-vars.sh" ]; then
  # echo sourcing "$SOURCE_DIR/ws-default-vars.sh"
  . "$SOURCE_DIR/ws-default-vars.sh"
fi

if [ -r "$WS_DIR/ws-vars.sh" ]; then
  # echo sourcing "$WS_DIR/ws-vars.sh"
  . "$WS_DIR/ws-vars.sh"
fi

if [ "$WS_VARIANT" == "" ]; then
  WS_VARIANT="$SIO_DEFAULT_VARIANT"
fi
wsAddVar WS_VARIANT

GIT_DIR="$WS_DIR/git"
GIT_DIR_SLASH="$GIT_DIR/"
wsAddVar BUILT_ROOT_DIR "$WS_DIR/var/$WS_VARIANT/built"
wsAddVar RUNTIME_ROOT_DIR "$WS_DIR/var/$WS_VARIANT/runtime"
wsAddVar CACHE_ROOT_DIR "$WS_DIR/cache"
wsAddVar SOURCE_SCRIPTS_DIR "$SOURCE_DIR/scripts"

# Tools and tools sources are checked into git -> path is relative to GIT_DIR
wsAddVar TOOLS_ROOT_DIR "$GIT_DIR/build-tools"

wsAddVar WS_GOOGLESOURCE_ROOT_DIR "$WS_DIR/googlesource"

wsAddVar GIT_PROJECT_BIN_DIR "$GIT_PROJECT_DIR/bin"
if [ -d "$GIT_PROJECT_BIN_DIR" ]; then
  if [[ ":$PATH:" != *":$GIT_PROJECT_BIN_DIR:"* ]]; then
    PATH="$GIT_PROJECT_BIN_DIR:$PATH"
  fi
fi

wsAddVar WS_DEPOT_TOOLS_DIR "$SOURCE_DIR/externals/googlesource/depot_tools"
if [[ ":$PATH:" != *":$WS_DEPOT_TOOLS_DIR:"* ]]; then
  PATH="$WS_DEPOT_TOOLS_DIR:$PATH"
fi

wsAddVar WS_INSTALL_DIR "$WS_DIR/var/$WS_VARIANT/install"
if [[ ":$PATH:" != *":$WS_INSTALL_DIR/bin:"* ]]; then
  PATH="$WS_INSTALL_DIR/bin:$PATH"
fi

if [[ ":$LD_LIBRARY_PATH:" != *":$WS_INSTALL_DIR/lib/gstreamer-1.0:"* ]]; then
  LD_LIBRARY_PATH=$WS_INSTALL_DIR/lib/gstreamer-1.0${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
fi

if [[ ":$LD_LIBRARY_PATH:" != *":$WS_INSTALL_DIR/lib:"* ]]; then
  LD_LIBRARY_PATH=$WS_INSTALL_DIR/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
fi

if [[ ":$DYLD_LIBRARY_PATH:" != *":$WS_INSTALL_DIR/lib/gstreamer-1.0:"* ]]; then
  DYLD_LIBRARY_PATH=$WS_INSTALL_DIR/lib/gstreamer-1.0${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}
fi

if [[ ":$DYLD_LIBRARY_PATH:" != *":$WS_INSTALL_DIR/lib:"* ]]; then
  DYLD_LIBRARY_PATH=$WS_INSTALL_DIR/lib${DYLD_LIBRARY_PATH:+:$DYLD_LIBRARY_PATH}
fi

#Reset GStreamer variables from .bashrc if they were set - we do *NOT* want them set in our environment
unset GST_PLUGIN_PATH
unset GST_REGISTRY
unset GST_PLUGIN_SYSTEM_PATH

# Add workspace installed plugin dir to gstreamer plugin path
if [[ ":$GST_PLUGIN_SYSTEM_PATH:" != *":$WS_INSTALL_DIR/lib.gstreamer-1.0:"* ]]; then
  GST_PLUGIN_SYSTEM_PATH=$WS_INSTALL_DIR/lib/gstreamer-1.0${GST_PLUGIN_SYSTEM_PATH:+:$GST_PLUGIN_SYSTEM_PATH}
fi

if [[ ":$GI_TYPELIB_PATH:" != *":$WS_INSTALL_DIR/share/gir-1.0:"* ]]; then
  GI_TYPELIB_PATH=$WS_INSTALL_DIR/share/gir-1.0${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}
fi

# For pkg-config packages we define intrinsically - point to ws/git/source/pkgconfig
#wsPathAddUnique PKG_CONFIG_PATH $WS_INSTALL_DIR/lib/pkgconfig
if [[ ":$PKG_CONFIG_PATH:" != *":$SOURCE_DIR/pkgconfig:"* ]]; then
    PKG_CONFIG_PATH="$SOURCE_DIR/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
fi

# For pkg-config packages we built - point to install/lib/pkgconfig
#wsPathAddUnique PKG_CONFIG_PATH $WS_INSTALL_DIR/lib/pkgconfig
if [[ ":$PKG_CONFIG_PATH:" != *":$WS_INSTALL_DIR/lib/pkgconfig:"* ]]; then
    PKG_CONFIG_PATH="$WS_INSTALL_DIR/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
fi

if [[ " $CPPFLAGS " != *" -I$WS_INSTALL_DIR/include "* ]]; then
    CPPFLAGS="-I$WS_INSTALL_DIR/include${CPPFLAGS:+ $CPPFLAGS}"
fi

wsAddVar LD_LIBRARY_PATH
wsAddVar DYLD_LIBRARY_PATH
wsAddVar GI_TYPELIB_PATH
wsAddVar PKG_CONFIG_PATH
wsAddVar GST_PLUGIN_SYSTEM_PATH

export GST_PLUGIN_SYSTEM_PATH
export LD_LIBRARY_PATH
export DYLD_LIBRARY_PATH
export GI_TYPELIB_PATH
export PKG_CONFIG_PATH
export CPPFLAGS
export WSBASH=1

# In full debug environment enable useful loader tracing
# if MAX_DEBUG ; then
#     wsAddVar LD_DEBUG 1

if [ -n "{$EXPORT_WS_ENV}" ]; then
  export 'SIO_HUB_EXTERNAL_NIC'
  export 'SIO_HUB_STACK_NIC'
  export 'SIO_HUB_STACK_SUBNET_PREFIX'
  export 'SIO_HUB_AP_NIC'
  export 'SIO_HUB_AP_SUBNET_PREFIX'
  export 'SIO_HUB_QEMU_NIC'
  export 'SIO_HUB_QEMU_SUBNET_PREFIX'
  export 'SIO_HUB_AP_PASSPHRASE'
  export 'SIO_AWS_PROFILE'
  export 'SIO_DEFAULT_VARIANT'
fi


if [[ -z "${BASH_SOURCE[1]}" ]]; then
  echo "$(basename "$0"): Not sourced from script, using current working dir as script dir." >&2
  SCRIPT_DIR="$SCRIPT_WORKING_DIR"
else
  SCRIPT_FULL_PATH="$(realpath "${BASH_SOURCE[1]}")"
  SCRIPT_DIR="$(dirname "$SCRIPT_FULL_PATH")"
fi

wsAddVar SCRIPT_DIR

wsAddVar SCRIPT_RELATIVE_DIR "${SCRIPT_DIR#$GIT_DIR_SLASH}"
wsAddVar SCRIPT_BUILT_DIR "$BUILT_ROOT_DIR/$SCRIPT_RELATIVE_DIR"
wsAddVar SCRIPT_RUNTIME_DIR "$RUNTIME_ROOT_DIR/$SCRIPT_RELATIVE_DIR"
wsAddVar SCRIPT_CACHE_DIR "$CACHE_ROOT_DIR/$SCRIPT_RELATIVE_DIR"

# Well-known fake MAC address for QEMU "build"
wsAddVar QEMU_MACADDR "52:54:00:12:34:03"
wsAddVar QEMU_PACKED_MACADDR "`echo $QEMU_MACADDR | sed 's/://g' | tr '[A-Z]' '[a-z]'`"

wsAddVar RASPBIAN_BASE_IMG_NAME "raspbian-base"
wsAddVar RASPBIAN_SURROUNDIO_IMG_NAME "raspbian-surroundio"
wsAddVar RASPBIAN_APISERVER_IMG_NAME "raspbian-apiserver"
RASPBIAN_BUILT_DIR="$WS_DIR/built/source/rpi/rpi-img"
wsAddVar RASPBIAN_BASE_PIMG "$RASPBIAN_BUILT_DIR/$RASPBIAN_BASE_IMG_NAME/"
wsAddVar RASPBIAN_SURROUNDIO_PIMG "$RASPBIAN_BUILT_DIR/$RASPBIAN_SURROUNDIO_IMG_NAME/"
wsAddVar RASPBIAN_APISERVER_PIMG "$RASPBIAN_BUILT_DIR/$RASPBIAN_APISERVER_IMG_NAME/"
wsAddVar RASPBIAN_APISERVER_IMG "$RASPBIAN_BUILT_DIR/$RASPBIAN_APISERVER_IMG_NAME.img"

#
# OS specific variables
#
lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}
# Detect platform we run on and set PLATFORM variable (consistent to our scripts).
# Nb: we assume LINUX == Debian and derivatives. If anybody wants to handle RH and Solaris ...
MACHINE=$(uname -m)
OSREV=$(uname -o)
PLATFORM=$(uname -i)
KERNEL=$(uname -s)

OSTYPE=`lowercase \`uname\``

case "$OSTYPE" in
  darwin*)  RUN_PLATFORM="MAC" ;;
  linux*)   RUN_PLATFORM="LINUX" ;;
  win32*)   RUN_PLATFORM="WIN" ;;
  cygwin*)  RUN_PLATFORM="WIN" ;;
  bsd*)     RUN_PLATFORM="BSD" ;;
  *)        RUN_PLATFORM="" ;;
esac

#set platform specific variables
    if [[ "$RUN_PLATFORM" == "MAC" ]]; then
    PACKAGEMGR="port"
elif [[ "$RUN_PLATFORM" == "LINUX" ]];  then
    PACKAGEMGR="apt-get"
fi

wsAddVar RUN_PLATFORM
wsAddVar PACKAGEMGR

# Export platform variable always
export RUN_PLATFORM

wsAddVar RPI_TOOLS_DIR "$WS_DIR/git/rpi-tools"
wsAddVar RPI_CCPREFIX "$RPI_TOOLS_DIR/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-"
wsAddVar RPI_ARCH "arm"



