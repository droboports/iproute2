CFLAGS="${CFLAGS:-} -ffunction-sections -fdata-sections"
LDFLAGS="-L${DEST}/lib -L${DEPS}/lib -Wl,--gc-sections"

### PCRE ###
_build_pcre() {
local VERSION="8.37"
local FOLDER="pcre-${VERSION}"
local FILE="${FOLDER}.tar.bz2"
local URL="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${FILE}"

_download_bz2 "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --disable-shared --enable-static --disable-cpp --enable-utf --enable-unicode-properties
make
make install
popd
}

### LIBSEPOL ###
_build_libsepol() {
local VERSION="2.4"
local FOLDER="libsepol-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://raw.githubusercontent.com/wiki/SELinuxProject/selinux/files/releases/20150202/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
make install ARCH="arm" DESTDIR="${DEPS}" PREFIX="${DEPS}"
rm -vf "${DEPS}/lib/libsepol.so"*
popd
}

### LIBSELINUX ###
# requires pcre, libsepol
_build_libselinux() {
local VERSION="2.4"
local FOLDER="libselinux-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://raw.githubusercontent.com/wiki/SELinuxProject/selinux/files/releases/20150202/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
make install ARCH="arm" DESTDIR="${DEPS}" PREFIX="${DEPS}"
rm -vf "${DEPS}/lib/libselinux.so"*
popd
}

### IPROUTE2 ###
_build_iproute2() {
local VERSION="4.1.1"
local FOLDER="iproute2-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://www.kernel.org/pub/linux/utils/net/iproute2/${FILE}"
export KERNEL_INCLUDE="${KERNEL_INCLUDE:-${HOME}/build/kernel-drobo64/kernel/include}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
#sed -e '4iset -o xtrace' -i configure
sed -e '/ARPD/d' -i Makefile
sed -e '/^TARGETS/s@arpd@@g' -i misc/Makefile
sed -e 's/arpd.8//' -i man/man8/Makefile

export PKG_CONFIG_PATH="${DEPS}/lib/pkgconfig"
make Config \
     CC="${CC}" \
     KERNEL_INCLUDE="${KERNEL_INCLUDE}"
make PREFIX="/usr" \
     CC="${CC}" \
     SHARED_LIBS=n \
     MANDIR=/man \
     KERNEL_INCLUDE="${KERNEL_INCLUDE}"
make install DESTDIR="${DEST}"
#"${STRIP}" -s -R .comment -R .note -R .note.ABI-tag "${DEST}/bin/"*
popd
}

_build_rootfs() {
# /bin/ss
  return 0
}

_build() {
  _build_sysstat
  _package
}
