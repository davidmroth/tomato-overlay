# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/busybox/busybox-1.23.2.ebuild,v 1.1 2015/05/24 11:35:12 blueness Exp $


EAPI="5"
inherit eutils

DESCRIPTION="Utilities for rescue and embedded systems"
HOMEPAGE="http://www.busybox.net/"
SRC_URI=""

MY_P=${PN}-${PV}
#if [[ ${PV} == "9999" ]] ; then
#	MY_P=${PN}
#	EGIT_REPO_URI="git://busybox.net/busybox.git"
#	inherit git-2
#else
#	MY_P=${PN}-${PV/_/-}
#	SRC_URI="http://www.busybox.net/downloads/${MY_P}.tar.bz2"
#	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-linux ~arm-linux ~x86-linux"
#fi

KEYWORDS="~mips"
LICENSE="GPL-2"
SLOT="0"

S=${WORKDIR}/${MY_P}

#EXTRACFLAGS="-DLINUX26 -DCONFIG_BCMWL5 -pipe -DBCMWPA2 -funit-at-a-time -Wno-pointer-sign -mtune=mips32 -mips32  -DTCONFIG_NVRAM_64K"

src_unpack() {
	#cp "${FILESDIR}"/source "${S}"
	mkdir -p "${S}" && tar -xzf "${FILESDIR}/${MY_P}.tgz" -C "${S}" || die
	cp "${FILESDIR}/config_busybox" "${S}/.config" || die

}

src_configure() {
	# check for a busybox config before making one of our own.
	# if one exist lets return and use it.

	if [ -f .config ]; then
		yes "" | emake -j1 -s oldconfig >/dev/null
	else
		die
	fi
}

src_compile() {
	unset KBUILD_OUTPUT #88088
	#export SKIP_STRIP=y

	#emake V=1 busybox EXTRA_CFLAGS="-fPIC ${EXTRACFLAGS}"
	emake busybox EXTRA_CFLAGS="-fPIC ${EXTRACFLAGS}"
}

src_install() {
	unset KBUILD_OUTPUT #88088

	TARGETDIR="${D}${ARCH_FW_ROOT}"
	mkdir -p "${TARGETDIR}"
	# bundle up the symlink files for use later
	emake DESTDIR="${TARGETDIR}" install
	cp -ra _install/* "${TARGETDIR}"
}
