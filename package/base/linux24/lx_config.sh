# --- ROCK-COPYRIGHT-NOTE-BEGIN ---
# 
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# Please add additional copyright information _after_ the line containing
# the ROCK-COPYRIGHT-NOTE-END tag. Otherwise it might get removed by
# the ./scripts/Create-CopyPatch script. Do not edit this copyright text!
# 
# ROCK Linux: rock-src/package/base/linux24/lx_config.sh
# ROCK Linux is Copyright (C) 1998 - 2003 Clifford Wolf
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version. A copy of the GNU General Public
# License can be found at Documentation/COPYING.
# 
# Many people helped and are helping developing ROCK Linux. Please
# have a look at http://www.rocklinux.org/ and the Documentation/TEAM
# file for details.
# 
# --- ROCK-COPYRIGHT-NOTE-END ---

treever=${pkg/linux/} ; treever=${treever/-*/}
archdir="$base/download/$repository/linux$treever"
srctar="linux-${vanilla_ver}.tar.bz2"

lx_cpu=`echo "$arch_machine" | sed -e s/x86$/i386/ \
  -e s/i.86/i386/ -e s/powerpc/ppc/ -e s/hppa/parisc/`

[ $arch = sparc -a "$ROCKCFG_SPARC_64BIT_KERNEL" = 1 ] && \
        lx_cpu=sparc64

MAKE="$MAKE ARCH=$lx_cpu CROSS_COMPILE=$archprefix KCC=$KCC"

# correct the abolute path for patchfiles supplied in the .conf file
for x in $patchfiles ; do
	if [ ! -e $x ] ; then
		var_remove patchfiles " " "$x"
		x=$archdir/$x
		var_append patchfiles " " "$x"
	fi
done

auto_config ()
{
	if [ -f $base/architecture/$arch/kernel$treever.conf.sh ] ; then
		echo "  using: architecture/$arch/kernel$treever.conf.sh"
		. $base/architecture/$arch/kernel$treever.conf.sh > .config
	elif [ -f $base/architecture/$arch/kernel$treever.conf.m4 ] ; then
		echo "  using: architecture/$arch/kernel$treever.conf.m4"
		m4 -I $base/architecture/$arch -I $base/architecture/share \
		   $base/architecture/$arch/kernel$treever.conf.m4 > .config
	elif [ -f $base/architecture/$arch/kernel$treever.conf ] ; then
		echo "  using: architecture/$arch/kernel$treever.conf"
		cp $base/architecture/$arch/kernel$treever.conf .config
	elif [ -f $base/architecture/$arch/kernel.conf.sh ] ; then
		echo "  using: architecture/$arch/kernel.conf.sh"
		. $base/architecture/$arch/kernel.conf.sh > .config
	elif [ -f $base/architecture/$arch/kernel.conf.m4 ] ; then
		echo "  using: architecture/$arch/kernel.conf.m4"
		m4 -I $base/architecture/$arch -I $base/architecture/share \
		   $base/architecture/$arch/kernel.conf.m4 > .config
	elif [ -f $base/architecture/$arch/kernel.conf ] ; then
		echo "  using: architecture/$arch/kernel.conf"
		cp $base/architecture/$arch/kernel.conf .config
	else
		echo "  using: no rock kernel config found"
		cp arch/$lx_cpu/defconfig .config
	fi

	echo "  merging (system default): 'arch/$lx_cpu/defconfig'"
	grep '^CONF.*=y' arch/$lx_cpu/defconfig | cut -f1 -d= | \
	while read tag ; do egrep -q "(^| )$tag[= ]" .config || echo "$tag=y"
	  done >> .config ; cp .config .config.1

	# all modules needs to be first so modules can be disabled by i.e.
	# the targets later
	echo "Enabling all modules ..."
	yes '' | eval $MAKE no2modconfig > /dev/null ; cp .config .config.2

	if [ -f $base/target/$target/kernel$treever.conf.sh ] ; then
		confscripts="$base/target/$target/kernel$treever.conf.sh $confscripts"
	elif [ -f $base/target/$target/kernel.conf.sh ] ; then
		confscripts="$base/target/$target/kernel.conf.sh $confscripts"
	fi

	for x in $confscripts ; do
		echo "  running: $x"
		sh $x .config
	done
	cp .config .config.3

	# merge various text/plain config files
	for x in $base/config/$config/linux.cfg \
	         $base/target/$target/kernel.conf ; do
	   if [ -f $x ] ; then
		echo "  merging: 'config/$config/linux.cfg'"
		tag="$(sed '/CONFIG_/ ! d; s,.*CONFIG_\([^ =]*\).*,\1,' \
			$x | tr '\n' '|')"
		egrep -v "\bCONFIG_($tag)\b" < .config > .config.4
		sed 's,\(CONFIG_.*\)=n,# \1 is not set,' \
			$x >> .config.4
		cp .config.4 .config
	   fi
	done

	# create a valid .config
	yes '' | eval $MAKE oldconfig > /dev/null ; cp .config .config.5

	# last disable broken crap
	sh $base/package/base/linux24/disable-broken.sh \
	$pkg_linux_brokenfiles < .config > config.6
	cp config.6 .config

	# create a valid .config (dependencies might need to be disabled)
	yes '' | eval $MAKE oldconfig > /dev/null

	# save final config
	cp .config .config_modules

	echo "Creating config without modules ...."
	sed "s,\(CONFIG_.*\)=m,# \1 is not set," .config > .config_new
	mv .config_new .config
	# create a valid .config (dependencies might need to be disabled)
	yes '' | eval $MAKE oldconfig > /dev/null
	mv .config .config_nomods

	# which .config to use?
	if [ "$ROCKCFG_PKG_LINUX_CONFIG_STYLE" = "modules" ] ; then
		cp .config_modules .config
	else
		cp .config_nomods .config
	fi
}

lx_config ()
{
	echo "Generic linux source patching and configuration ..."

	hook_eval prepatch
	apply_patchfiles
	hook_eval postpatch

	echo "Redefining some VERSION flags ..."
	x="-`echo $ver-rock | cut -d - -f 2-`"
	sed -e "s/^EXTRAVERSION =.*/EXTRAVERSION = $x/" Makefile > Makefile.new
	mv Makefile.new Makefile

	echo "Correcting user and permissions ..."
	chown -R root.root . * ; chmod -R u=rwX,go=rX .

	if [[ $treever = 24* ]] ; then
		echo "Create symlinks and a few headers for <$lx_cpu> ... "
		eval $MAKE include/linux/version.h symlinks
		cp $base/package/base/linux24/autoconf.h include/linux/
		touch include/linux/modversions.h
	fi

	if [ "$ROCKCFG_PKG_LINUX_CONFIG_STYLE" = none ] ; then
		echo "Using \$base/config/\$config/linux.cfg."
		echo "Since automatic generation is disabled ..."
		cp -v $base/config/$config/linux.cfg .config
	else
		echo "Automatically creating default configuration ...."
		auto_config
	fi

	echo "... configuration finished!"

	if [[ $treever != 24* ]] ; then
		echo "Create symlinks and a few headers for <$lx_cpu> ... "
		eval $MAKE include/linux/version.h include/asm
		eval $MAKE oldconfig > /dev/null
	fi

	echo "Clean up the *.orig and *~ files ... "
	rm -f .config.old `find -name '*.orig' -o -name '*~'`

	echo "Generic linux source configuration finished."
}

pkg_linux_brokenfiles="$base/architecture/$arch/kernel-disable.lst \
	$base/architecture/$arch/kernel$treever-disable.lst \
	$base/package/base/linux$treever/disable-broken.lst \
	$pkg_linux_brokenfiles"
