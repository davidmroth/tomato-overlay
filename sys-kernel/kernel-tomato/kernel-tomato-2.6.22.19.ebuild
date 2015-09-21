# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
ETYPE="sources"
DESCRIPTION="MIPS kernel v${KV_MAJOR}.${KV_MINOR} source"
SRC_URI=""
HOMEPAGE=""

inherit eutils

SLOT=0
LICENSE=GPL-2
KEYWORDS="~mips"

DEPEND="sys-firmware/mipsel-linux-includes sys-firmware/lmz-mksquash"

KERNEL_CONFIG=Asus_RT-N66U_config
KERNEL_SOURCE=kernel-source-2.6.22.19.tgz
WL_SOURCE=wl
SHARED_SOURCE=shared
LZMA_SOURCE=lzma
CTF_SOURCE=ctf
EMF_SOURCE=emf
ET_SOURCE=et


src_unpack() { 
	mkdir -p ${S} && tar -xzf "${FILESDIR}/${KERNEL_SOURCE}" -C "${S}" || die
    tar -xzf "${FILESDIR}/kernel-${WL_SOURCE}.tgz" -C "${S}" || die 
    tar -xzf "${FILESDIR}/kernel-${SHARED_SOURCE}.tgz" -C "${S}" || die 
    tar -xzf "${FILESDIR}/kernel-${LZMA_SOURCE}.tgz" -C "${S}" || die 
    tar -xzf "${FILESDIR}/kernel-${CTF_SOURCE}.tgz" -C "${S}" || die 
    tar -xzf "${FILESDIR}/kernel-${EMF_SOURCE}.tgz" -C "${S}" || die 
    tar -xzf "${FILESDIR}/kernel-${ET_SOURCE}.tgz" -C "${S}" || die 

	cp "${FILESDIR}/${KERNEL_CONFIG}" "${S}/.config" || die

}

src_compile() {
	export SHARED_SOURCE_DIRECTORY=../../../../${SHARED_SOURCE} # arch/mips/brcm-boards/bcm947xx/Makefile
	export LZMA_SOURCE_DIRECTORY=../../${LZMA_SOURCE} # fs/squashfs/Makefile

	if [ -f Makefile ] || [ -f GNUmakefile ] || [ -f makefile ]; then

		if ! grep -q "CONFIG_EMBEDDED_RAMDISK=y" ${S}/.config ; then
			einfo "Making zImage..."
			emake V=0 ARCH=mips CROSS_COMPILE=mipsel-linux-uclibc- zImage || die "emake failed"
		fi

		if grep -q "CONFIG_MODULES=y" ${S}/.config ; then
			einfo "Making Kernel modules..."
			emake modules || die "emake failed"
		fi
		
		einfo "Making Squashfs compression tool..."
	 	SRCBASE=${S} emake -C ${S}/scripts/squashfs mksquashfs-lzma CFLAGS="-I. -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -O2 -DOF=_Z_OF" 
		strip ${S}/scripts/squashfs/mksquashfs-lzma
	fi

}

modules_install() {
	emake -C ${S} modules_install INSTALL_MOD_STRIP="--strip-debug -x -R .comment -R .note -R .pdr -R .mdebug.abi32 -R .note.gnu.build-id -R .gnu.attributes -R .reginfo" DEPMOD=/bin/true INSTALL_MOD_PATH="${D}/${ARCH_FW_ROOT}"

}

clean_and_tidy()
{
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/ && test -L build && rm -f build || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/ && test -L source && rm -f source || true
	
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/net && test -e diag && mv diag/* . && rm -rf diag || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/net && test -e et.4702 && mv et.4702/* . && rm -rf et.4702 || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/net && test -e et && mv et/* . && rm -rf et || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/net && test -e wl && mv wl/* . && rm -rf wl || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e cifs &&  mv cifs/* . && rm -rf cifs || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e jffs2 && mv jffs2/* . && rm -rf jffs2 || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e jffs && mv jffs/* . && rm -rf jffs || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/lib && test -e zlib_inflate && mv zlib_inflate/* . && rm -rf zlib_inflate || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/lib && test -e zlib_deflate && mv zlib_deflate/* . && rm -rf zlib_deflate || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/lib && test -e lzo && mv lzo/* . && rm -rf lzo || true
    rm -rf "${D}/${ARCH_FW_ROOT}"lib/modules/*/pcmcia;
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e ext2 && mv ext2/* . && rm -rf ext2 || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e ext3 && mv ext3/* . && rm -rf ext3 || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e jbd &&  mv jbd/* . && rm -rf jbd || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e fat && mv fat/* . && rm -rf fat || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e jfs && mv jfs/* . && rm -rf jfs || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e vfat && mv vfat/* . && rm -rf vfat || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e msdos && mv msdos/* . && rm -rf msdos || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e fuse && mv fuse/* . && rm -rf fuse || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e nfts && mv ntfs/* . && rm -rf ntfs || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e smbfs && mv smbfs/* . && rm -rf smbfs || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e reiserfs && mv reiserfs/* . && rm -rf reiserfs || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e hfs && mv hfs/* . && rm -rf hfs || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e hfsplus && mv hfsplus/* . && rm -rf hfsplus || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e lockd && mv lockd/* . && rm -rf lockd || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e nfsd && mv nfsd/* . && rm -rf nfsd || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e nfs && mv nfs/* . && rm -rf nfs || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e xfs && mv xfs/* . && rm -rf xfs || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e nls && mv nls/* . && rm -rf nls || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/fs && test -e exportfs && mv exportfs/* . && rm -rf exportfs || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/net && test -e sunrpc && mv sunrpc/* . && rm -rf sunrpc || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/net && test -e auth_gss && mv auth_gss/* . && rm -rf auth_gss || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/sound && test -e core && mv core/* . && rm -rf core || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/sound && test -e usb && mv usb/* . && rm -rf usb || true
	if (test -e "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/sound/core); then
		cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/sound/core && test -e oss && mv oss/* . && rm -rf oss || true
		cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/sound/core && test -e seq && mv seq/* . && rm -rf seq || true
	fi
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/usb && test -e hcd && mv hcd/* . && rm -rf hcd || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/usb && test -e host && mv host/* . && rm -rf host || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/usb && test -e storage && mv storage/* . && rm -rf storage || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/usb && test -e serial && mv serial/* . && rm -rf serial || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/usb && test -e core && mv core/* . && rm -rf core || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/usb && test -e class && mv class/* . && rm -rf class || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/usb && test -e misc && mv misc/* . && rm -rf misc || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/usb && test -e usbip && mv usbip/* . && rm -rf usbip || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/mmc && test -e core && mv core/* . && rm -rf core || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/mmc && test -e card && mv card/* . && rm -rf card || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/mmc && test -e host && mv host/* . && rm -rf host || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/hid && test -e usbhid && mv usbhid/* . && rm -rf usbhid || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/input && test -e joystick && mv joystick/* . && rm -rf joystick || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/input && test -e keyboard && mv keyboard/* . && rm -rf keyboard || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/input && test -e misc && mv misc/* . && rm -rf misc || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/input && test -e mouse && mv mouse/* . && rm -rf mouse || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/media/video && test -e uvc && mv uvc/* . && rm -rf uvc || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/media/video && test -e pwc && mv pwc/* . && rm -rf pwc || true
	if (test -e "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/media/video/gspca); then
		cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/media/video/gspca && test -e gl860 && mv gl860/* . && rm -rf gl860 || true
		cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/media/video/gspca && test -e m5602 && mv m5602/* . && rm -rf m5602 || true
		cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/media/video/gspca && test -e stv06xx && mv stv06xx/* . && rm -rf stv06xx || true
	fi
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/media/video && test -e gspca && mv gspca/* . && rm -rf gspca || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/net && test -e bcm57xx && mv bcm57xx/* . && rm -rf bcm57xx || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/net && test -e emf && mv emf/* . && rm -rf emf || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/net && test -e igs && mv igs/* . && rm -rf igs || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules/*/kernel/drivers/net && test -e ctf && mv ctf/* . && rm -rf ctf || true
    cd "${D}/${ARCH_FW_ROOT}"lib/modules && test -e source && rm -f */source || true

}

strip_modules()
{
    find "${D}/${ARCH_FW_ROOT}"lib/modules -name wl.*o -exec ${ARCH_STRIP} --strip-unneeded -x {} \;
    find "${D}/${ARCH_FW_ROOT}"lib/modules -name et.*o -exec ${ARCH_STRIP} --strip-unneeded -x {} \;
    find "${D}/${ARCH_FW_ROOT}"lib/modules -name bcm57*.*o -exec ${ARCH_STRIP} --strip-unneeded -x {} \;
    find "${D}/${ARCH_FW_ROOT}"lib/modules -name ctf.*o -exec ${ARCH_STRIP} --strip-unneeded -x {} \;
    find "${D}/${ARCH_FW_ROOT}"lib/modules -name emf.*o -exec ${ARCH_STRIP} --strip-unneeded -x {} \;
    find "${D}/${ARCH_FW_ROOT}"lib/modules -name igs.*o -exec ${ARCH_STRIP} --strip-unneeded -x {} \;
    find "${D}/${ARCH_FW_ROOT}"lib/modules -name jffs*.*o -exec ${ARCH_STRIP} --strip-unneeded -x {} \;
    find "${D}/${ARCH_FW_ROOT}"lib/modules -name *.*o -exec ${ARCH_STRIP} --strip-debug -x -R .mdebug.abi32 {} \;

}

src_install ()
{
    CC=mipsel-linux-cc LD=mipsel-linux-ld LINUXDIR=${S} SRCBASE=${S} emake -C ${S}/arch/mips/brcm-boards/bcm947xx/compressed srctree=${S} || die "emake failed";
    modules_install
	clean_and_tidy
	strip_modules

	exeinto "${PORTAGE_TMPDIR}"
	doexe ${S}/arch/mips/brcm-boards/bcm947xx/compressed/vmlinuz	

	exeinto "${ARCH_BIN}"
	doexe ${S}/scripts/squashfs/mksquashfs-lzma

}

pkg_postinst() {
    einfo "Kernel compile complete!"
	einfo "${HOMEPAGE}"

}
