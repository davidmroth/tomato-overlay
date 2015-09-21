# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
ETYPE="sources"
DESCRIPTION="LZMA compressed kernel decompressor for bcm947xx boards"
HOMEPAGE=""
SRC_URI=""

inherit eutils

SLOT=0
LICENSE=GPL-2
KEYWORDS="~mips"

DEPEND="sys-firmware/lmza"
RDEPEND="${DEPEND}"

src_unpack()
{
	mkdir -p ${S} && tar -xzf ${FILESDIR}/lmza-loader.tgz -C ${S} || die

}

src_compile()
{
	SRCBASE=${ARCH_SHARED} CC=mipsel-linux-gcc LD=mipsel-linux-ld emake -C ${S}
}

src_install()
{
    TARGETDIR="${D}${ARCH_BIN}"
    mkdir -p "${TARGETDIR}" 
    cp -ra ${S}/loader.gz "${TARGETDIR}"    
    einfo "Install complete!"

}
