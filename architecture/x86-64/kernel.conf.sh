# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: architecture/x86-64/kernel.conf.sh
# Copyright (C) 2004 - 2011 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

{
	cat <<- 'EOT'
		define(`INTEL', `Intel X86 PCs')dnl

		CONFIG_64BIT=y
		
		dnl CPU configuration
		dnl
	EOT

	linux_arch=MK8
	for x in "generic	GENERIC_CPU"	\
		 "nocona	MPSC"		\
	         "core2		MCORE2"		\
		 "atom		ATOM"
	do
		set $x
		[ "$1" = "$SDECFG_X8664_OPT" ] && linux_arch=$2
	done

	for x in GENERIC_CPU MK8 MPSC MCORE2 ATOM
	do
		if [ "$linux_arch" != "$x" ]
		then echo "# CONFIG_$x is not set"
		else echo "CONFIG_$x=y" ; fi
	done

	echo
	cat <<- 'EOT'
		CONFIG_NR_CPUS=32

		CONFIG_IA32_EMULATION=y

		dnl Other useful stuff
		dnl
		include(`kernel-x86.conf.m4')
		include(`kernel-common.conf.m4')
		include(`kernel-block.conf.m4')
		include(`kernel-net.conf.m4')
		include(`kernel-fs.conf.m4')

		CONFIG_RTC_DRV_CMOS=y
	EOT
} | m4 -I $base/architecture/$arch -I $base/architecture/x86 -I $base/architecture/share
