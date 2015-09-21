# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
ETYPE="sources"
DESCRIPTION="Asus RT-N66U Tomato Firmware"
HOMEPAGE=""
SRC_URI=""

inherit eutils

SLOT=0
LICENSE=GPL-2
KEYWORDS="~mips"

kver="2.6.22.19"
NVRAM_SIZE=0

DEPEND="sys-firmware/mipsel-linux-includes sys-firmware/tomato-configs sys-firmware/btools =sys-kernel/kernel-tomato-${kver} sys-firmware/btools sys-firmware/lmza-loader"
RDEPEND="${DEPEND} sys-apps/busybox"
RESTRICT="strip"

LOG=${ARCH_BUILD_LOGS}/build.log


src_unpack()
{ 
	mkdir -p ${S}
	# Make sure log directory exists
	mkdir -p ${ARCH_BUILD_LOGS}


}

config_helper()
{
	for x in $(echo ${@} | grep -v '#'); do 
		if ! test -z $(echo $x | tr -d '[[:space:]]'); then
			einfo "Exporting: $x"
			export $x
		fi
	done
}

initialize_build()
{
	. ${ARCH_CONFIG}/profile.conf
	. ${ARCH_CONFIG}/target.conf

	export BUILD="$(gcc -dumpmachine)"

	config_helper 'V1=1.29 V2=-gentoo MIPS32=r2 NVRAM_64K=y NAND=y ASUS_TRX="RT-AC66U" UFSD=y'
	config_helper $(cat ${ARCH_CONFIG}/config_router_software_current)


	test -z V1 && V1="--def"
	test -z VPN && VPN="VPN"

	if test "${CONFIG_LINUX26}" = "y"; then
		if test "${CONFIG_BCMWL6}" = "y"; then
			ND="K26AC"
		else
			ND="K26"
		fi
	else
		export ND="ND"
	fi

	test -z "${PPTPD}" && PPTPD="n"
	test -z "${NVRAM_SIZE}" && NVRAM_SIZE=0
	test -z "${ASUS_TRX}" && ASUS_TRX=0

	if test "${NVRAM_64K}" = "y"; then
		EXTRA_64KDESC=' -64K'
		EXTRA_64KCFLAG='-DTCONFIG_NVRAM_64K'
	else
		EXTRA_64KDESC=''
		EXTRA_64KCFLAG=''
	fi

	current_BUILD_NAME=$(grep "^TOMATO_BUILD_NAME" ${ARCH_CONFIG}/profile.conf  | cut -d"=" -f2 | sed -e "s/\"//g")
	current_BUILD_DESC=$(grep "^TOMATO_BUILD_DESC" ${ARCH_CONFIG}/profile.conf  | cut -d"=" -f2 | sed -e "s/ //g" | sed -e "s/\"//g")
	current_BUILD_USB=$(grep "^TOMATO_BUILD_USB"  ${ARCH_CONFIG}/profile.conf  | cut -d"=" -f2 | sed -e "s/ //g" | sed -e "s/\"//g")
	current_TOMATO_VER=$(grep "TOMATO_MAJOR" ${ARCH_INC}/tomato_version.h  | cut -d"\"" -f2).$(grep "TOMATO_MINOR" ${ARCH_INC}/tomato_version.h  | cut -d"\"" -f2)
	current_TOMATO_V1=${V1}
	current_TOMATO_V2=${V2}

	if test "${CONFIG_LINUX26}" = "y"; then
		mips_rev=$(test "${MIPS32}" = "r2" && echo "MIPSR2" || echo "MIPSR1")
		KERN_SIZE_OPT=n
	else
		mips_rev=
		KERN_SIZE_OPT=y
	fi

	beta=$(test "${TOMATO_EXPERIMENTAL}" -eq "1" && echo "-beta")

}

prep_fw()
{
	# uClibc installation
	into "${ARCH_FW_ROOT}"
	newlib.so ${ARCH_TOOLCHAIN}/lib/ld-uClibc.so.0 ld-uClibc.so.0 
	newlib.so ${ARCH_TOOLCHAIN}/lib/libcrypt.so.0 libcrypt.so.0
	newlib.so ${ARCH_TOOLCHAIN}/lib/libpthread.so.0 libpthread.so.0 
	newlib.so ${ARCH_TOOLCHAIN}/lib/libgcc_s.so.1 libgcc_s.so.1 

	# Do I need this? Ebuild strips automatically, right?
	${ARCH_STRIP} ${D}${ARCH_FW_ROOT}/lib/libgcc_s.so.1

	newlib.so ${ARCH_TOOLCHAIN}/lib/libc.so.0 libc.so.0 
	newlib.so ${ARCH_TOOLCHAIN}/lib/libdl.so.0 libdl.so.0 
	newlib.so ${ARCH_TOOLCHAIN}/lib/libm.so.0 libm.so.0 
	newlib.so ${ARCH_TOOLCHAIN}/lib/libnsl.so.0 libnsl.so.0 

	if (test "${TCONFIG_SSH}" = "y"); then
		newlib.so ${ARCH_TOOLCHAIN}/lib/libutil.so.0 libutil.so.0 
	fi

	if (test "${TCONFIG_BBT}" = "y"); then
		newlib.so ${ARCH_TOOLCHAIN}/lib/librt-0.9.30.1.so librt.so.0
	fi

	if (test "${TCONFIG_NGINX}" = "y"); then
		newlib.so ${ARCH_TOOLCHAIN}/lib/libstdc++.so.6 libstdc++.so.6
		cd ${D}${ARCH_FW_ROOT}/lib && ln -sf libstdc++.so.6 libstdc++.so
		${ARCH_STRIP} ${D}lib/libstdc++.so.6
	fi

	if (test "${TCONFIG_OPTIMIZE_SHARED_LIBS}" = "y"); then
		newlib.so ${ARCH_TOOLCHAIN}/libresolv.so.0 
		${ARCH_STRIP} ${D}${ARCH_FW_ROOT}/lib/*.so.0
	fi

	exeinto "${ARCH_BIN}"
	doexe ${FILESDIR}/rootprep.sh 
	doexe ${FILESDIR}/libfoo.pl


	dodir "${ARCH_FW_ROOT}/www"

	test -e "${D}${ARCH_FW_ROOT}/lib/*.so*" && chmod 0555 ${D}${ARCH_FW_ROOT}/lib/*.so*
	test -e "${D}${ARCH_FW_ROOT}/usr/lib/*.so*" && chmod 0555 ${D}${ARCH_FW_ROOT}/usr/lib/*.so*

}

build_fw_image()
{
	(cd "/${ARCH_FW_ROOT}";${ARCH_BIN}/rootprep.sh ${ARCH_FW_ROOT}  &> ${LOG})

	# Fix libfoo.pl -- Missing or invalid environment variables
	if (test "${TCONFIG_OPTIMIZE_SHARED_LIBS}" = "y"); then
	  	${ARCH_BIN}/libfoo.pl &>> ${LOG}
	else
		${ARCH_BIN}/libfoo.pl --noopt  &>> ${LOG}
	fi

	if test -z ${TOMATO_BUILD}; then
		einfo "Error!!" && die
	else
		einfo
		einfo
		einfo "Building Tomato ${ND} ${current_BUILD_USB} ${current_TOMATO_VER}.${V1}${mips_rev}${beta}${V2} ${current_BUILD_DESC} ${current_BUILD_NAME} with ${TOMATO_PROFILE_NAME} Profile"
		einfo
	fi

	if test ${NVRAM_SIZE} -gt 0; then
		IMAGE_NAME="tomato-${ND}${current_BUILD_USB}$-NVRAM${NVRAM_SIZE}K-${current_TOMATO_VER}.${V1}${mips_rev}${beta}${V2}-${current_BUILD_DESC}.trx"
	else
		IMAGE_NAME="tomato-${ND}${current_BUILD_USB}$-${current_TOMATO_VER}.${V1}${mips_rev}${beta}${V2}-${current_BUILD_DESC}.trx"
	fi

	einfo "Compressing filesystem..."
    ${ARCH_BIN}/mksquashfs-lzma /${ARCH_FW_ROOT} ${PORTAGE_TMPDIR}/target.image -all-root -noappend -no-duplicates &>> ${LOG}

	einfo "Converting to TRX format..."
	if (test -f ${PORTAGE_TMPDIR}/vmlinuz); then
		${ARCH_BIN}/fpkg -i ${ARCH_BIN}/loader.gz -i ${ARCH_SHARED}/vmlinuz -a 1024 -i ${ARCH_SHARED}/target.image -t ${PORTAGE_TMPDIR}/${IMAGE_NAME} &>> ${LOG}
	else
		eerror "${PORTAGE_TMPDIR}/vmlinuz missing... Please reinstall sys-kernel/kernel-tomato!" || die
	fi
}

src_install()
{
	initialize_build
	prep_fw
	build_fw_image
    einfo "Kernel compile complete!"

}

pkg_postinst() {
	einfo 
	einfo "-----------------"
	einfo $(cat  ${PORTAGE_TMPDIR}/tomato_version) " ready"
	einfo "-----------------"
	einfo

	${ARCH_BIN}/uversion.pl --bump
	einfo "${HOMEPAGE}"

}
