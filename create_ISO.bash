#!/bin/bash

mkdir temp
mount xcp-ng* temp
cp -a temp/. iso
chmod -R 777 iso
umount temp

cd iso
mkdir install
cd install
bunzip2 < ../install.img | cpio -idm
cd ..

sed -i 's+module2 /boot/vmlinuz console=hvc0 console=tty0+module2 /boot/vmlinuz console=hvc0 console=tty0 answerfile=file:///answerfile.xml install+g' \
./EFI/xenserver/grub.cfg
sed -i 's+module2 /boot/vmlinuz console=hvc0 console=tty0+module2 /boot/vmlinuz console=hvc0 console=tty0 answerfile=file:///answerfile.xml install+g' \
./EFI/xenserver/grub-usb.cfg

cp ../answerfile.xml ./install/

cd install
find . | cpio -o -H newc | bzip2 > ../install.img
cd ..
rm -rf install

OUTPUT=../xcp-ng_custom.iso
VERSION=8.3
xorrisofs -o $OUTPUT -v -r -J --joliet-long -V "XCP-ng $VERSION" -c boot/isolinux/boot.cat -b boot/isolinux/isolinux.bin \
          -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/efiboot.img -no-emul-boot .

isohybrid --uefi $OUTPUT
