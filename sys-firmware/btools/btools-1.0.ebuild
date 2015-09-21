# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
ETYPE="sources"
DESCRIPTION="Btools"
HOMEPAGE=""
SRC_URI=""

inherit eutils

SLOT=0
LICENSE=GPL-2
KEYWORDS="~mips"

TARGETDIR="${D}${ARCH_BIN}"


src_unpack()
{
	
	mkdir -p ${S} && cp ${FILESDIR}/Makefile ${FILESDIR}/fpkg.c ${S} || die
}

src_compile()
{
	emake -C ${S} || die
}

src_install()
{
	export STRIP="strip" #Don't use mips strip binary

	dodir ${ARCH_BIN}
	exeinto ${ARCH_BIN}
	doexe ${S}/fpkg
	tar -xzf ${FILESDIR}/btools.tar.gz -C ${TARGETDIR} || die
    einfo "Install complete!"

}
