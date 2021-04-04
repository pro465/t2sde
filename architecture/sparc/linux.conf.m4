dnl --- T2-COPYRIGHT-NOTE-BEGIN ---
dnl This copyright note is auto-generated by scripts/Create-CopyPatch.
dnl 
dnl T2 SDE: architecture/sparc/linux.conf.m4
dnl Copyright (C) 2004 - 2021 The T2 SDE Project
dnl 
dnl More information can be found in the files COPYING and README.
dnl 
dnl This program is free software; you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; version 2 of the License. A copy of the
dnl GNU General Public License can be found in the file COPYING.
dnl --- T2-COPYRIGHT-NOTE-END ---

define(`SPARC', 'SPARC')dnl

# CONFIG_SUN4 is not set

# dnl run on old V7
# CONFIG_MATH_EMULATION=y

CONFIG_FB=y
CONFIG_FB_SBUS=y
CONFIG_FB_CGSIX=y
CONFIG_FB_BWTWO=y
CONFIG_FB_CGTHREE=y
CONFIG_FB_TCX=y
CONFIG_FB_CGFOURTEEN=y
CONFIG_FB_LEO=y

# CONFIG_FB_RIVA is not set
# CONFIG_FB_RADEON is not set

CONFIG_FONT_SUN8x16=y

include(`linux-common.conf.m4')
include(`linux-block.conf.m4')
include(`linux-net.conf.m4')
include(`linux-fs.conf.m4')

CONFIG_EXPERT=y

# CONFIG_SMP is not set
CONFIG_PREEMPT_NONE=y
# CONFIG_PCI is not set
# CONFIG_HIGH_RES_TIMERS is not set
CONFIG_LOG_BUF_SHIFT=14

# CONFIG_NAMESPACES is not set

# CONFIG_DEBUG_KERNEL is not set
# RUNTIME_TESTING_MENU is not set
# CONFIG_KALLSYMS is not set
# CONFIG_BPF is not set
# CONFIG_COMPACTION is not set
# CONFIG_KSM is not set
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_DEBUG_FS is not set

# CONFIG_WIRELESS is not set
# CONFIG_MEDIA_SUPPORT is not set
# CONFIG_VIDEO_V4L2 is not set
