# Maintainer: Joan Figueras <ffigue at gmail dot com>
# Contributor: Torge Matthies <openglfreak at googlemail dot com>
# Contributor: Jan Alexander Steffens (heftig) <heftig@archlinux.org>
# Contributor: Yoshi2889 <rick.2889 at gmail dot com>
# Contributor: Tobias Powalowski <tpowa@archlinux.org>
# Contributor: Thomas Baechler <thomas@archlinux.org>

##
## The following variables can be customized at build time. Use env or export to change at your wish
##
##   Example: env _microarchitecture=98 use_numa=n use_tracers=n makepkg -sc
##
## Look inside 'choose-gcc-optimization.sh' to choose your microarchitecture
## Valid numbers between: 0 to 99
## Default is: 0 => generic
## Good option if your package is for one machine: 98 (Intel native) or 99 (AMD native)
if [ -z ${_microarchitecture+x} ]; then
  _microarchitecture=0
fi

CONFIG_ASHMEM=m 
CONFIG_ANDROID=y
CONFIG_ANDROID_BINDER_IPC=m
CONFIG_ANDROID_BINDERFS=n
CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"
CONFIG_DRM_SIMPLEDRM=y
# _compiler=clang

## Disable NUMA since most users do not have multiple processors. Breaks CUDA/NvEnc.
## Archlinux and Xanmod enable it by default.
## Set variable "use_numa" to: n to disable (possibly increase performance)
##                             y to enable  (stock default)
if [ -z ${use_numa+x} ]; then
  use_numa=y
fi

## For performance you can disable FUNCTION_TRACER/GRAPH_TRACER. Limits debugging and analyzing of the kernel.
## Stock Archlinux and Xanmod have this enabled. 
## Set variable "use_tracers" to: n to disable (possibly increase performance)
##                                y to enable  (stock default)
if [ -z ${use_tracers+x} ]; then
  use_tracers=n
fi

## Choose between GCC and CLANG config (default is GCC)
## Use the environment variable "_compiler=clang"
if [ "${_compiler}" = "clang" ]; then
  _compiler_flags="CC=clang HOSTCC=clang LLVM=1 LLVM_IAS=1"
fi

# Choose between the 4 main configs for stable branch. Default x86-64-v1 which use CONFIG_GENERIC_CPU2:
# Possible values: config_x86-64-v1 (default) / config_x86-64-v2 / config_x86-64-v3 / config_x86-64-v4
# This will be overwritten by selecting any option in microarchitecture script
# Source files: https://github.com/xanmod/linux/tree/5.17/CONFIGS/xanmod/gcc
if [ -z ${_config+x} ]; then
  _config=config_x86-64-v2
fi

# Compress modules with ZSTD (to save disk space)
if [ -z ${_compress_modules+x} ]; then
  _compress_modules=n
fi

# Compile ONLY used modules to VASTLY reduce the number of modules built
# and the build time.
#
# To keep track of which modules are needed for your specific system/hardware,
# give module_db script a try: https://aur.archlinux.org/packages/modprobed-db
# This PKGBUILD read the database kept if it exists
#
# More at this wiki page ---> https://wiki.archlinux.org/index.php/Modprobed-db
if [ -z ${_localmodcfg} ]; then
  _localmodcfg=n
fi

# Tweak kernel options prior to a build via nconfig
if [ -z ${_makenconfig} ]; then
  _makenconfig=n
fi

### IMPORTANT: Do no edit below this line unless you know what you're doing

pkgbase=linux-xanmod-bore-tty
_major=6.10
pkgver=${_major}.6
_branch=6.x
xanmod=1
_revision=
# _sf_branch=edge
_sf_branch=main
_cjk_major=6.9
pkgrel=${xanmod}
pkgdesc='Linux Xanmod.'
url="http://www.xanmod.org/"
arch=(x86_64)

license=(GPL2)
makedepends=(
  bc
  cpio
  gettext
  libelf
  pahole
  perl
  python
  tar
  xz
)
if [ "${_compiler}" = "clang" ]; then
  makedepends+=(clang llvm lld)
fi
options=('!strip')
_srcname="linux-${pkgver}-xanmod${xanmod}"

source=("https://cdn.kernel.org/pub/linux/kernel/v${_branch}/linux-${_major}.tar."{xz,sign}
        "patch-${pkgver}-xanmod${xanmod}${_revision}.xz::https://sourceforge.net/projects/xanmod/files/releases/${_sf_branch}/${pkgver}-xanmod${xanmod}/patch-${pkgver}-xanmod${xanmod}.xz"
        "https://raw.githubusercontent.com/bigshans/cjktty-patches/master/v${_branch}/cjktty-${_cjk_major}.patch"
        "0001.bore.patch"
        choose-gcc-optimization.sh)

validpgpkeys=(
    'ABAF11C65A2970B130ABE3C479BE3E4300411886' # Linux Torvalds
    '647F28654894E3BD457199BE38DBBDC86092693E' # Greg Kroah-Hartman
)

# Archlinux patches
_commit="ec9e9a4219fe221dec93fa16fddbe44a34933d8d"
_patches=()
for _patch in ${_patches[@]}; do
    source+=("${_patch}::https://raw.githubusercontent.com/archlinux/svntogit-packages/${_commit}/trunk/${_patch}")
done

sha256sums=('774698422ee54c5f1e704456f37c65c06b51b4e9a8b0866f34580d86fef8e226'
            'SKIP'
            'b1a31b0ff4b4e1a42d2648c05154c3f2862d716c0a5b431c27c61c432c657471'
            '6714bf3968392e29f19e44514d490ad7ec718c3897003210fd1e499017dd429d'
            '93783b04c86fc5c10b091fdf2373edea7094c3650b0051e558d6c1fa1db88f78'
            '1ac18cad2578df4a70f9346f7c6fccbb62f042a0ee0594817fdef9f2704904ee')

export KBUILD_BUILD_HOST=${KBUILD_BUILD_HOST:-archlinux}
export KBUILD_BUILD_USER=${KBUILD_BUILD_USER:-makepkg}
export KBUILD_BUILD_TIMESTAMP=${KBUILD_BUILD_TIMESTAMP:-$(date -Ru${SOURCE_DATE_EPOCH:+d @$SOURCE_DATE_EPOCH})}

prepare() {
  cd linux-${_major}

  # Apply Xanmod patch
  patch -Np1 -i ../patch-${pkgver}-xanmod${xanmod}${_revision}

  msg2 "Setting version..."
  echo "-$pkgrel" > localversion.10-pkgrel
  echo "${pkgbase#linux-xanmod}" > localversion.20-pkgname

  # Archlinux patches
  local src
  for src in "${source[@]}"; do
    src="${src%%::*}"
    src="${src##*/}"
    [[ $src = *.patch ]] || continue
    msg2 "Applying patch $src..."
    patch -Np1 < "../$src"
    msg2 "$src patched"
  done

  # Applying configuration
  cp -vf CONFIGS/xanmod/gcc/${_config} .config
  # enable LTO_CLANG_THIN
  if [ "${_compiler}" = "clang" ]; then
    scripts/config --disable LTO_CLANG_FULL
    scripts/config --enable LTO_CLANG_THIN
    _LLVM=1
  fi

  # Setting features for desktop use
  msg2 "Setting features for desktop use..."
  scripts/config --set-val CONFIG_BLK_DEV_LOOP_MIN_COUNT 0 \
                 --enable SCHED_BORE

  # Change tick rate to 1000.
  scripts/config -d HZ_500
  scripts/config -e HZ_1000
  scripts/config --set-val HZ 1000

  # Enable full tickless mode
  scripts/config -d HZ_PERIODIC
  scripts/config -d NO_HZ_IDLE
  scripts/config -d CONTEXT_TRACKING_USER_FORCE
  scripts/config -e NO_HZ_FULL
  scripts/config -e NO_HZ
  scripts/config -e NO_HZ_COMMON
  scripts/config -e CONTEXT_TRACKING

  # set RCU
  scripts/config -e RT_MUTEXES
  scripts/config -e PREEMPT_RCU
  scripts/config -e RCU_EXPERT
  scripts/config -d FORCE_TASKS_RCU
  scripts/config -d FORCE_TASKS_RUDE_RCU
  scripts/config -d FORCE_TASKS_TRACE_RCU
  scripts/config --set-val RCU_FANOUT 32
  scripts/config --set-val RCU_FANOUT_LEAF 16
  scripts/config -e RCU_BOOST
  scripts/config --set-val RCU_BOOST_DELAY 500
  scripts/config -d RCU_EXP_KTHREAD
  scripts/config -e RCU_NOCB_CPU
  scripts/config -e RCU_NOCB_CPU_DEFAULT_ALL
  scripts/config -d RCU_NOCB_CPU_CB_BOOST
  scripts/config -d TASKS_TRACE_RCU_READ_MB
  scripts/config -e RCU_LAZY

  # Enable full preempt.
  scripts/config -e PREEMPT_BUILD
  scripts/config -d PREEMPT_NONE
  scripts/config -d PREEMPT_VOLUNTARY
  scripts/config -e PREEMPT
  scripts/config -e PREEMPT_COUNT
  scripts/config -e PREEMPTION
  scripts/config -e PREEMPT_DYNAMIC

  # CONFIG_STACK_VALIDATION gives better stack traces. Also is enabled in all official kernel packages by Archlinux team
  scripts/config --enable CONFIG_STACK_VALIDATION

  # Enable IKCONFIG following Arch's philosophy
  scripts/config --enable CONFIG_IKCONFIG \
                 --enable CONFIG_IKCONFIG_PROC

  scripts/config --module  CONFIG_ASHMEM
  scripts/config --enable  CONFIG_ANDROID
  scripts/config --set-str CONFIG_ANDROID_BINDER_DEVICES ""
  # Requested by Alexandre Frade to fix issues in python-gbinder
  scripts/config --enable CONFIG_ANDROID_BINDERFS
  scripts/config --enable CONFIG_ANDROID_BINDER_IPC

  # User set. See at the top of this file
  if [ "$use_tracers" = "y" ]; then
    msg2 "Enabling CONFIG_FTRACE only if we are not compiling with clang..."
    if [ "${_compiler}" = "gcc" ] || [ "${_compiler}q" = "q" ]; then
      scripts/config --enable CONFIG_FTRACE \
                     --enable CONFIG_FUNCTION_TRACER \
                     --enable CONFIG_STACK_TRACER
    fi
  fi

  if [ "$use_numa" = "n" ]; then
    msg2 "Disabling NUMA..."
    scripts/config --disable CONFIG_NUMA
  fi

  # Compress modules by default (following Arch's kernel)
  if [ "$_compress_modules" = "y" ]; then
    scripts/config --enable CONFIG_MODULE_COMPRESS_ZSTD
  fi

  ## Use Arch Wiki TOMOYO configuration: https://wiki.archlinux.org/title/TOMOYO_Linux#Installation_2
  msg2 "Replacing Debian TOMOYO configuration with upstream Arch Linux..."
  scripts/config --set-str CONFIG_SECURITY_TOMOYO_POLICY_LOADER      "/usr/bin/tomoyo-init"
  scripts/config --set-str CONFIG_SECURITY_TOMOYO_ACTIVATION_TRIGGER "/usr/lib/systemd/systemd"

  # Let's user choose microarchitecture optimization in GCC
  # Use default microarchitecture only if we have not choosen another microarchitecture
  if [ "$_microarchitecture" -ne "0" ]; then
    ../choose-gcc-optimization.sh $_microarchitecture
  fi

  # This is intended for the people that want to build this package with their own config
  # Put the file "myconfig" at the package folder (this will take preference) or "${XDG_CONFIG_HOME}/linux-xanmod/myconfig"
  # If we detect partial file with scripts/config commands, we execute as a script
  # If not, it's a full config, will be replaced
  for _myconfig in "${SRCDEST}/myconfig" "${HOME}/.config/linux-xanmod/myconfig" "${XDG_CONFIG_HOME}/linux-xanmod/myconfig" ; do
    if [ -f "${_myconfig}" ] && [ "$(wc -l <"${_myconfig}")" -gt "0" ]; then
      if grep -q 'scripts/config' "${_myconfig}"; then
        # myconfig is a partial file. Executing as a script
        msg2 "Applying myconfig..."
        bash -x "${_myconfig}"
      else
        # myconfig is a full config file. Replacing default .config
        msg2 "Using user CUSTOM config..."
        cp -f "${_myconfig}" .config
      fi
      echo
      break
    fi
  done

  ### Optionally load needed modules for the make localmodconfig
  # See https://aur.archlinux.org/packages/modprobed-db
  if [ "$_localmodcfg" = "y" ]; then
    if [ -f $HOME/.config/modprobed.db ]; then
      msg2 "Running Steven Rostedt's make localmodconfig now"
      make ${_compiler_flags} LSMOD=$HOME/.config/modprobed.db localmodconfig
    else
      msg2 "No modprobed.db data found"
      exit 1
    fi
  fi

  msg2 "make ${_compiler_flags} olddefconfig"
  make ${_compiler_flags} olddefconfig
  #diff -u CONFIGS/xanmod/gcc/${_config} .config || :

  make -s kernelrelease > version
  msg2 "Prepared %s version %s" "$pkgbase" "$(<version)"

  if [ "$_makenconfig" = "y" ]; then
    make ${_compiler_flags} nconfig
  fi

  # save configuration for later reuse
  cat .config > "${SRCDEST}/config.last"
}

build() {
  cd linux-${_major}
  make ${_compiler_flags} all -j 16
  make -C tools/bpf/bpftool vmlinux.h feature-clang-bpf-co-re=1
}

_package() {
  pkgdesc="The Linux kernel and modules with Xanmod patches"
  depends=(coreutils kmod initramfs)
  optdepends=('crda: to set the correct wireless channels of your country'
              'linux-firmware: firmware images needed for some devices')
  provides=(VIRTUALBOX-GUEST-MODULES
            WIREGUARD-MODULE
            KSMBD-MODULE
            NTFS3-MODULE)
  replaces=(
    virtualbox-guest-modules-arch
    wireguard-arch
  )

  cd linux-${_major}
  local modulesdir="$pkgdir/usr/lib/modules/$(<version)"

  msg2 "Installing boot image..."
  # systemd expects to find the kernel here to allow hibernation
  # https://github.com/systemd/systemd/commit/edda44605f06a41fb86b7ab8128dcf99161d2344
  install -Dm644 "$(make -s image_name)" "$modulesdir/vmlinuz"

  # Used by mkinitcpio to name the kernel
  echo "$pkgbase" | install -Dm644 /dev/stdin "$modulesdir/pkgbase"

  msg2 "Installing modules..."
  ZSTD_CLEVEL=19 make INSTALL_MOD_PATH="$pkgdir/usr" INSTALL_MOD_STRIP=1 \
    DEPMOD=/doesnt/exist modules_install  # Suppress depmod

  rm "$modulesdir"/build
}

_package-headers() {
  pkgdesc="Headers and scripts for building modules for the $pkgdesc kernel"
  depends=(pahole)

  cd linux-${_major}
  local builddir="$pkgdir/usr/lib/modules/$(<version)/build"

  msg2 "Installing build files..."
  install -Dt "$builddir" -m644 .config Makefile Module.symvers System.map \
    localversion.* version vmlinux tools/bpf/bpftool/vmlinux.h
  install -Dt "$builddir/kernel" -m644 kernel/Makefile
  install -Dt "$builddir/arch/x86" -m644 arch/x86/Makefile
  cp -t "$builddir" -a scripts

  # add objtool for external module building and enabled VALIDATION_STACK option
  install -Dt "$builddir/tools/objtool" tools/objtool/objtool

  # required when DEBUG_INFO_BTF_MODULES is enabled
  install -Dt "$builddir/tools/bpf/resolve_btfids" tools/bpf/resolve_btfids/resolve_btfids

  msg2 "Installing headers..."
  cp -t "$builddir" -a include
  cp -t "$builddir/arch/x86" -a arch/x86/include
  install -Dt "$builddir/arch/x86/kernel" -m644 arch/x86/kernel/asm-offsets.s

  install -Dt "$builddir/drivers/md" -m644 drivers/md/*.h
  install -Dt "$builddir/net/mac80211" -m644 net/mac80211/*.h

  # http://bugs.archlinux.org/task/13146
  install -Dt "$builddir/drivers/media/i2c" -m644 drivers/media/i2c/msp3400-driver.h

  # http://bugs.archlinux.org/task/20402
  install -Dt "$builddir/drivers/media/usb/dvb-usb" -m644 drivers/media/usb/dvb-usb/*.h
  install -Dt "$builddir/drivers/media/dvb-frontends" -m644 drivers/media/dvb-frontends/*.h
  install -Dt "$builddir/drivers/media/tuners" -m644 drivers/media/tuners/*.h

  # https://bugs.archlinux.org/task/71392
  install -Dt "$builddir/drivers/iio/common/hid-sensors" -m644 drivers/iio/common/hid-sensors/*.h

  msg2 "Installing KConfig files..."
  find . -name 'Kconfig*' -exec install -Dm644 {} "$builddir/{}" \;

  msg2 "Removing unneeded architectures..."
  local arch
  for arch in "$builddir"/arch/*/; do
    [[ $arch = */x86/ ]] && continue
    echo "Removing $(basename "$arch")"
    rm -r "$arch"
  done

  msg2 "Removing documentation..."
  rm -r "$builddir/Documentation"

  msg2 "Removing broken symlinks..."
  find -L "$builddir" -type l -printf 'Removing %P\n' -delete

  msg2 "Removing loose objects..."
  find "$builddir" -type f -name '*.o' -printf 'Removing %P\n' -delete

  msg2 "Stripping build tools..."
  local file
  while read -rd '' file; do
    case "$(file -Sib "$file")" in
      application/x-sharedlib\;*)      # Libraries (.so)
        strip -v $STRIP_SHARED "$file" ;;
      application/x-archive\;*)        # Libraries (.a)
        strip -v $STRIP_STATIC "$file" ;;
      application/x-executable\;*)     # Binaries
        strip -v $STRIP_BINARIES "$file" ;;
      application/x-pie-executable\;*) # Relocatable binaries
        strip -v $STRIP_SHARED "$file" ;;
    esac
  done < <(find "$builddir" -type f -perm -u+x ! -name vmlinux -print0)

  msg2 "Stripping vmlinux..."
  strip -v $STRIP_STATIC "$builddir/vmlinux"
  msg2 "Adding symlink..."
  mkdir -p "$pkgdir/usr/src"
  ln -sr "$builddir" "$pkgdir/usr/src/$pkgbase"
}

pkgname=("${pkgbase}" "${pkgbase}-headers")
for _p in "${pkgname[@]}"; do
  eval "package_$_p() {
    $(declare -f "_package${_p#$pkgbase}")
    _package${_p#$pkgbase}
  }"
done

# vim:set ts=8 sts=2 sw=2 et:

