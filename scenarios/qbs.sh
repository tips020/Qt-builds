#!/bin/bash

#
# The BSD 3-Clause License. http://www.opensource.org/licenses/BSD-3-Clause
#
# This file is part of 'Qt-builds' project.
# Copyright (c) 2013 by Alexpux (alexpux@gmail.com)
# All rights reserved.
#
# Project: Qt-builds ( https://github.com/Alexpux/Qt-builds )
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# - Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the distribution.
# - Neither the name of the 'Qt-builds' nor the names of its contributors may
#     be used to endorse or promote products derived from this software
#     without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# **************************************************************************

P=qbs
P_V=${P}
SRC_FILE=""
URL=git://gitorious.org/qt-labs/qbs.git
DEPENDS=()

src_download() {
	func_download $P_V "git" $URL
}

src_unpack() {
	echo "--> Unpack empty"
}

src_patch() {
	echo "--> Patch empty"
}

src_configure() {
	mkdir -p $BUILD_DIR/${P_V}-${QT_VERSION}
	pushd $BUILD_DIR/${P_V}-${QT_VERSION} > /dev/null
	if ! [ -f configure.marker ]
	then
		local _rel_path=$( func_absolute_to_relative $BUILD_DIR/${P_V}-${QT_VERSION} $SRC_DIR/${P_V} ) 
		${QTDIR}/bin/qmake.exe QMAKE_CXXFLAGS="-Wno-error=unused-variable" -r $_rel_path/qbs.pro CONFIG+=release \
			> ${LOG_DIR}/${P_V}-configure.log 2>&1 || die "QMAKE failed"
		touch configure.marker
	fi
	popd > /dev/null
}

pkg_build() {
	local _make_flags=(
		${MAKE_OPTS}
		release
	)
	local _allmake="${_make_flags[@]}"
	func_make \
		${P_V}-${QT_VERSION} \
		"mingw32-make" \
		"$_allmake" \
		"building..." \
		"built"
		
	# _make_flags=(
		# ${MAKE_OPTS}
		# docs
	# )
	# _allmake="${_make_flags[@]}"
	# func_make \
		# ${P_V}-${QT_VERSION} \
		# "mingw32-make" \
		# "$_allmake" \
		# "building..." \
		# "built" \
		# "1"
}

pkg_install() {

	if ! [ -f $BUILD_DIR/${P_V}-${QT_VERSION}/install.marker ]
	then
		pushd $BUILD_DIR/${P_V}-${QT_VERSION} > /dev/null
		echo -n "--> Installing..."
		mkdir -p $QTDIR/{bin,lib,plugins,share}
		cp -rf bin/* $QTDIR/bin/ || die "Copy bin folder failed"
		cp -rf lib/* $QTDIR/lib/ || die "Copy lib folder failed"
		cp -rf plugins/* $QTDIR/plugins/ || die "Copy plugins folder failed"
		cp -rf share/* $QTDIR/share/ || die "Copy plugins folder failed"
		touch install.marker
		echo " done"
		popd > /dev/null
	fi
}
