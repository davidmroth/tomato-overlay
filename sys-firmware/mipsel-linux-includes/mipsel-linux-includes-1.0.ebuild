# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
ETYPE="sources"
DESCRIPTION="Mips shared includesr for bcm947xx boards"
HOMEPAGE=""
SRC_URI=""

inherit eutils

SLOT=0
LICENSE=GPL-2
KEYWORDS="~mips"


src_unpack()
{
	mkdir -p ${S} && tar -xzf ${FILESDIR}/mipsel-linux-includes.tgz -C ${S} || die

}

src_install()
{
	TARGETDIR="${D}${ARCH_SHARED}"
	mkdir -p "${TARGETDIR}"	
	cp -ra ${S}/* "${TARGETDIR}"	
    einfo "Install complete!"

}
