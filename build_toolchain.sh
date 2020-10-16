#!/bin/bash

export ROOTDIR=$ROOTDIR
export CONFIG_TOOLCHAIN_DIR='${ROOTDIR}/out'
[ -f ../trunk/.config ] && . ../trunk/.config

echo "================ START BUILDING TOOLCHAIN =============="

if [ ! -f configure ]; then
  ./bootstrap || exit 1
fi
if [ ! -f Makefile ]; then
  ./configure --enable-local || exit 1
fi
if [ ! -f ct-ng ]; then
  make || exit 1
fi
if [ ! -d dl ]; then
  echo "============= CREATE LOCAL TARBALLS DIR ================"
  mkdir dl
fi
if [ -d .build ]; then
  echo "============== CLEANING OLD BUILD TREE ================="
  ./ct-ng clean
  rm -rf ${CONFIG_TOOLCHAIN_DIR}
fi

(./ct-ng mipsel-linux-uclibc &&
  sed -i -e '/CT_LOG_ALL/d' .config &&
  sed -i -e '/CT_LOG_EXTRA/d' .config &&
  sed -i -e '/CT_LOG_LEVEL_MAX/d' .config &&
  sed -i -e '/CT_LOG_PROGRESS_BAR/s/y$/n/' .config &&
  echo 'CT_LOG_ERROR=y' >>.config &&
  echo 'CT_LOG_LEVEL_MAX="ERROR"' >>.config &&
  ./ct-ng build) || exit 1

echo "====================All IS DONE!========================"
