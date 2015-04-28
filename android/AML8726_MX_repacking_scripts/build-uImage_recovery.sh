#!/bin/bash
#
# Copyright (C) 2011-2012 Pasquale Convertini    aka psquare (psquare.dev@gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# http://www.gnu.org/licenses/gpl-2.0.txt
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#
WORKDIR=NEWRECOVERY
UIMAGE=uImage_recovery
INITRAMFSDIR=initramfs_rec
#
#####-----
#
##////////////////////////////////////////////////////////////
# GO!
##////////////////////////////////////////////////////////////
#
echo ">>>>> Remove old files"
rm -rf $WORKDIR
mkdir -p $WORKDIR
echo ">>>>> Build initramfs"
cd $INITRAMFSDIR
find * | cpio -C 1 -R root:root -H newc -o > ../$WORKDIR/initramfs.new.cpio
cd ..
cp ${UIMAGE} $WORKDIR
cp mkimage $WORKDIR
cd $WORKDIR
#
##////////////////////////////////////////////////////////////
# Checking for uImage magic word
# http://linux-arm.org/git?p=u-boot-armdev.git;a=blob;f=include/image.h
##////////////////////////////////////////////////////////////
#
echo ">>>>> Checking for uImage magic word ( 27051956 ) :"
MAGICWORD=`dd if=${UIMAGE} ibs=1 count=4 | hexdump -v -e '4/1 "%02X"'`
if [ '27051956' != "$MAGICWORD" ]
	then
		echo "Not a uImage: $MAGICWORD != 27051956"
	exit 1
else
	echo "$UIMAGE acknowledged!"
fi
#
##////////////////////////////////////////////////////////////
# Remove header from uImage_recovery
##////////////////////////////////////////////////////////////
#
echo ">>>>> Remove header from $UIMAGE"
IMAGEOLDLZMA='Image.old.lzma'
dd if=${UIMAGE} bs=1 skip=64 of=${IMAGEOLDLZMA}
#
##////////////////////////////////////////////////////////////
# Extracting kernel from uImage_recovery
##////////////////////////////////////////////////////////////
#
echo ">>>>> Extracting kernel from $UIMAGE"
IMAGE='Image.old'
unlzma < ${IMAGEOLDLZMA} > ${IMAGE}
#
##////////////////////////////////////////////////////////////
#Extracting initramfs
# www.garykessler.net/library/file_sigs.html
# The end of the cpio archive is recognized with an empty file named 'TRAILER!!!' = '54 52 41 49 4C 45 52 21 21 21' (hexadecimal)
##////////////////////////////////////////////////////////////
#
echo ">>>>> Extracting initramfs from kernel"
CPIOSTART=`grep -a -b -m 1 -o '070701' ${IMAGE} | head -1 | cut -f 1 -d :`
CPIOEND=`grep -a -b -m 1 -o -P '\x54\x52\x41\x49\x4C\x45\x52\x21\x21\x21\x00\x00\x00\x00' ${IMAGE} | head -1 | cut -f 1 -d :`
CPIOEND=$((CPIOEND + 11 + 3))
CPIOSIZE=$((CPIOEND - CPIOSTART))
OLDINITRAMFSDIR='initramfs-old'
if [ "$CPIOSIZE" -le '0' ]
	then
		echo "initramfs.cpio not found"
		exit
fi
dd if=${IMAGE} bs=1 skip=$CPIOSTART count=$CPIOSIZE > initramfs.old.cpio
rm -rf $OLDINITRAMFSDIR
mkdir -p $OLDINITRAMFSDIR
cd $OLDINITRAMFSDIR
cpio -v -i --no-absolute-filenames < ../initramfs.old.cpio
cd ..
#
##////////////////////////////////////////////////////////////
# Fix initramfs size
##////////////////////////////////////////////////////////////
#
echo ">>>>> Fix initramfs size"
CPIOOLDSIZE=`ls -l initramfs.old.cpio | awk '{ print $5 }'`
CPIONEWSIZE=`ls -l initramfs.new.cpio | awk '{ print $5 }'`
if [ "$CPIONEWSIZE" -gt "$CPIOOLDSIZE" ]
	then
		echo "Sorry, initramfs.new.cpio exceeds $((CPIONEWSIZE-CPIOOLDSIZE)) bytes!"
		exit 1
else
	CPIOPADDING=$((CPIOOLDSIZE - CPIONEWSIZE))
	echo "Add $CPIOPADDING bytes to initramfs.new.cpio"
fi
cp initramfs.new.cpio initramfs.newfixed.cpio
dd if=/dev/zero bs=1 count=$CPIOPADDING >> initramfs.newfixed.cpio
echo ">>>>> Size of initramfs fixed!"
#
##////////////////////////////////////////////////////////////
# Rebuilding kernel Image
##////////////////////////////////////////////////////////////
#
echo ">>>>> Rebuilding kernel Image"
IMAGENEW='Image.new'
IMAGENEWLZMA='Image.new.lzma'
dd if=${IMAGE} bs=1 count=$CPIOSTART of=${IMAGENEW}
cat initramfs.newfixed.cpio >> ${IMAGENEW}
dd if=${IMAGE} bs=1 skip=$CPIOEND >> ${IMAGENEW}
echo ">>>>> Compressing kernel Image to LZMA"
lzma < ${IMAGENEW} > ${IMAGENEWLZMA}
#
##////////////////////////////////////////////////////////////
# Building uImage_recovery
##////////////////////////////////////////////////////////////
#
echo ">>>>> Making $UIMAGE"
mv ${UIMAGE} ${UIMAGE}-orig
./mkimage -A arm -O linux -T kernel -C lzma -a 80008000 -e 80008000 -d Image.new.lzma -n CrayonMod ${UIMAGE}
#
(cat << EOF) > amltxtscript
fatload mmc 0 82000000 uImage_recovery
bootm 82000000
EOF
#
echo ">>>>> Making aml_autoscript"
./mkimage -A arm -O linux -T script -C none -d amltxtscript -n CrayonMod aml_autoscript
#
echo ">>>>> New $UIMAGE ready! <<<<<"
echo ">>>>> ENJOY!!! :) <<<<<"
