��    *      l  ;   �      �     �     �  8   �     �     
          ,     ;     Y     o     �     �     �     �     �          5     S  #   X  #   |     �     �     �  $   �     �     �               2     H     W  -  k  $   �     �     �  "   �       =   #     a     �     �  I  �     �     �  7   �     2     E     W     g     v     �     �     �     �     �          1     Q     p     �  #   �     �     �     �     �  %        '     *     <     T     h     ~     �  �  �  $   )     N     m  "   �     �  =   �     �          '     *                              !   (         #   '                                                   	         "                       &                )          
                      $             %    Cancel Cancelling... Check this box to create new partition UUIDs on the copy Checking source... Copy From Device: Copy To Device: Copy complete. Copying partition %d of %d... Could not create FAT. Could not create file system. Could not create partition. Could not mount partition. Could not set flags. Could not unmount partition. Could not write to destination. Drives changed - cancelling... Drives changed - copy aborted Help Insufficient space. Backup aborted. Make a copy of the Raspbian SD card New Partition UUIDs No No devices available Non-MSDOS partition table on source. OK Password Required Preparing partitions... Preparing target... Reading partitions... SD Card Copier SD Card Copier Help SD Card Copier v1.0

This is an application to copy and back up SD cards. To use it, you will need a USB SD card writer.

To back up your Raspberry Pi's internal SD card, insert a blank SD card into a USB card writer and connect it to your Pi. Then start the application, choose your card writer from the “Copy To Device” drop-down box and press “Start”. The copy process will take 10-15 minutes depending on the size of your card.

The resulting card should be a bootable copy of your existing card; to restore, simply place the backup card into the onboard SD card slot, put the card to restore onto into the USB writer and repeat the copy process above.

You can also back up to a standard USB stick, and then restore from the USB stick to an SD card by setting the “Copy From Device” drop-down to the USB stick and the “Copy To Device” to a USB card writer containing the card to restore onto.

Note that you cannot copy onto the SD card from which your Pi is currently booted, which is why it does not appear in the “Copy To Device” dropdown.

Note also that the destination card doesn’t need to be the same size as the source card, but it must have enough space to hold all the data that is on it. The application will warn you if there is insufficient space on the destination.

Under Raspbian Stretch and later versions, you cannot mount two partitions with the same UUID, so you will not be able to mount a cloned SD card when booted from the disk from which it was cloned. If you need to do this, check the "New Partition UUIDs" box before copying.
 Select the device from which to copy Select the device to copy from Select the device to copy to Select the device to which to copy Start This will erase all content on the device '%s'. Are you sure? Too many partitions on source. Unable to read source. Yes Project-Id-Version: piclone 0.5
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2017-07-18 08:19+0100
Last-Translator: Simon Long <simon@raspberrypi.org>
Language-Team: English (British)
Language: en_GB
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Plural-Forms: nplurals=2; plural=(n != 1);
 Cancel Cancelling... Tick this box to create new partition UUIDs on the copy Checking source... Copy From Device: Copy To Device: Copy complete. Copying partition %d of %d... Could not create FAT. Could not create file system. Could not create partition. Could not mount partition. Could not set flags. Could not unmount partition. Could not write to destination. Drives changed - cancelling... Drives changed - copy aborted Help Insufficient space. Backup aborted. Copy SD cards and USB devices New Partition UUIDs No No devices available Non MS-DOS partition table on source. OK Password Required Preparing partitions... Preparing target... Reading partitions... SD Card Copier SD Card Copier Help SD Card Copier

This is an application to copy and back up SD cards. To use it, you will need a USB SD card writer.

To back up your Raspberry Pi's internal SD card, insert a blank SD card into a USB card writer connected to the Raspberry Pi. Then choose the internal SD card (labelled as '/dev/mmcblk0') from the “Copy From Device” drop-down box, choose your card writer from the “Copy To Device” drop-down box and press “Start”. The copy process will take 10-15 minutes depending on the size of your card.

The resulting card should be a bootable copy of your existing card; to restore, simply place the backup card into the onboard SD card slot, put the card to restore onto into the USB writer and repeat the copy process above.

You can also back up to a standard USB stick, and then restore from the USB stick to an SD card by setting the “Copy From Device” drop-down to the USB stick and the “Copy To Device” to a USB card writer containing the card to restore onto.

Note that you cannot copy onto the SD card from which your Raspberry Pi is booted, which is why it does not appear in the “Copy To Device” dropdown.

Note also that the destination card doesn’t need to be the same size as the source card, but the destination must have enough space for all the data on the source. The application will warn you if there is insufficient space on the destination.

Under some versions of the operating system, you cannot mount two partitions with the same UUID, so you will not be able to mount a cloned SD card when booted from the disk from which it was cloned. If you need to do this, tick the "New Partition UUIDs" box before copying.
 Select the device from which to copy Select the device to copy from Select the device to copy to Select the device to which to copy Start This will erase all content on the device '%s'. Are you sure? Too many partitions on source. Unable to read source. Yes 