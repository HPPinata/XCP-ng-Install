#!/bin/bash

mkdir temp
mount xcp-ng* temp
cp -a temp/. iso
chmod -R 644 iso
umount temp

cd iso
mkdir install
cd install
bunzip2 < ../install.img | cpio -idm
cd ..

cp ../answerfile.xml ./install/

cd install
find . | cpio -o -H newc | bzip2 > ../install.img
cd ..
rm -rf install

echo 'MTOOLS_LOWER_CASE=1' > ~/.mtoolsrc

cd boot
mkdir temp
mcopy -si efiboot.img :: ./temp
cd ..

sed -i 's+/boot/vmlinuz console=hvc0 console=tty0+/boot/vmlinuz console=hvc0 console=tty0 answerfile=file:///answerfile.xml install+g' \
./boot/isolinux/isolinux.cfg \
./EFI/xenserver/grub.cfg \
./EFI/xenserver/grub-usb.cfg \
./boot/temp/efi/xenserver/grub.cfg

cd boot
mdeltree -i efiboot.img ::
mcopy -i efiboot.img -s ./temp/efi ::
rm -rf temp
cd ..

rm -rf ~/.mtoolsrc

OUTPUT=../xcp-ng_custom.iso
VERSION=8.3
xorrisofs -o $OUTPUT -v -r -J --joliet-long -V "XCP-ng $VERSION" -c boot/isolinux/boot.cat -b boot/isolinux/isolinux.bin \
          -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/efiboot.img -no-emul-boot .

isohybrid --uefi $OUTPUT
