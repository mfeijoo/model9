��    '      T  5   �      `     a  8   h     �     �     �     �     �               7     S     n     �     �     �  #   �  #   �          !     $  $   9     ^     a     s     �     �     �     �  -  �  $        +     J  "   g     �  =   �     �     �       m       v  E   ~     �     �     �     �          5  "   R  "   u  #   �  #   �  %   �  '        .  @   4  !   u     �     �     �  *   �     �     �          +     G     a     p  �  �  #   @  #   d  &   �  "   �     �  <   �          6     R     	                  "   
                '                                  &                    $                         !      %                #                                  Cancel Check this box to create new partition UUIDs on the copy Checking source... Copy From Device: Copy To Device: Copy complete. Copying partition %d of %d... Could not create FAT. Could not create file system. Could not create partition. Could not mount partition. Could not set flags. Could not unmount partition. Could not write to destination. Help Insufficient space. Backup aborted. Make a copy of the Raspbian SD card New Partition UUIDs No No devices available Non-MSDOS partition table on source. OK Password Required Preparing partitions... Preparing target... Reading partitions... SD Card Copier SD Card Copier Help SD Card Copier v1.0

This is an application to copy and back up SD cards. To use it, you will need a USB SD card writer.

To back up your Raspberry Pi's internal SD card, insert a blank SD card into a USB card writer and connect it to your Pi. Then start the application, choose your card writer from the “Copy To Device” drop-down box and press “Start”. The copy process will take 10-15 minutes depending on the size of your card.

The resulting card should be a bootable copy of your existing card; to restore, simply place the backup card into the onboard SD card slot, put the card to restore onto into the USB writer and repeat the copy process above.

You can also back up to a standard USB stick, and then restore from the USB stick to an SD card by setting the “Copy From Device” drop-down to the USB stick and the “Copy To Device” to a USB card writer containing the card to restore onto.

Note that you cannot copy onto the SD card from which your Pi is currently booted, which is why it does not appear in the “Copy To Device” dropdown.

Note also that the destination card doesn’t need to be the same size as the source card, but it must have enough space to hold all the data that is on it. The application will warn you if there is insufficient space on the destination.

Under Raspbian Stretch and later versions, you cannot mount two partitions with the same UUID, so you will not be able to mount a cloned SD card when booted from the disk from which it was cloned. If you need to do this, check the "New Partition UUIDs" box before copying.
 Select the device from which to copy Select the device to copy from Select the device to copy to Select the device to which to copy Start This will erase all content on the device '%s'. Are you sure? Too many partitions on source. Unable to read source. Yes Project-Id-Version: piclone 0.5
Report-Msgid-Bugs-To: 
PO-Revision-Date: 2019-08-14 18:45+0200
Language-Team: Norwegian Bokmål
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Plural-Forms: nplurals=2; plural=(n != 1);
X-Generator: Poedit 2.2.3
Last-Translator: Imre Kristoffer Eilertsen <imreeil42@gmail.com>
Language: nb
 Avbrytt Huk av denne boksen for å opprette nye partisjons-UUID-er hos kopien Sjekker kilden … Kopier fra enhet: Kopier til enhet: Kopieringen er fullført. Kopierer partisjon %d av %d … Klarte ikke å opprette FAT. Klarte ikke å opprette filsystem. Klarte ikke å opprette partisjon. Klarte ikke å montere partisjonen. Klarte ikke å iverksette flaggene. Klarte ikke å avmontere partisjonen. Klarte ikke å lagre til destinasjonen. Hjelp Utilstrekkelig lagringsplass. Sikkerhetskopieringen ble avbrutt. Lag en kopi av Raspbian-SD-kortet Nye partisjons-UUID-er Nei Ingen enheter er tilgjengelige Kilden har en ikke-MSDOS-partisjonstabell. OK Passord påkrevd Forbereder partisjoner … Forbereder mål-enheten … Leser inn partisjoner … SD Card Copier SD Card Copier-hjelp SD Card Copier v1.0

Dette er et program for å (sikkerhets)kopiere SD-kort. For å bruke det, må du ha en SD-til-USB-adapter.

For å sikkerhetskopiere din Raspberry Pis interne SD-kort, sett inn et blankt SD-kort i en USB-kortskriver og koble den til din Pi. Start deretter programmer, velg kortskriveren din fra «Kopier til enhet»-nedfallsmenyen, og trykk på «Begynn». Kopieringsprosessen vil ta 10-15 minutter avhengig av kortets størrelse.

Det resulterende kortet burde da bli en oppstartsbar kopi av ditt eksisterende kort; for å gjenopprette fra den, bare sett inn sikkerhetskopikortet i Pi-ens SD-kortinngang, sett kortet det skal gjenopprettes til inn i USB-kortskriveren, og gjenta kopieringsprosessen ovenfor.

Du kan også sikkerhetskopiere til en vanlig USB-pinne, og deretter gjenopprette fra USB-pinnen til et SD-kort ved å velge USB-pinnen i «Kopier fra enhet»-nedfallsmenyen, og sett «Kopier til enhet» til en USB-kortskriver som har kortet det skal gjenopprettes til inni seg.

Bemerk at du ikke kan kopiere til SD-kortet som Pi-en din for øyeblikket er startet opp ifra, som er grunnen til at den ikke dukker opp i «Kopier til enhet»-nedfallsmenyen.

Bemerk også at mål-enheten ikke behøver å ha samme størrelse som kildekortet, men den må ha nok størrelse til å romme alle dataene som er på den. Programmet vil advare deg dersom det ikke er tilstrekkelig plass på mål-enheten.

I Raspbian Stretch og senere versjoner, kan du ikke montere to partisjoner med den samme UUID-en, så du vil ikke kunne montere et klonet SD-kort når det startes opp fra disken som den ble klonet ifra. Hvis du behøver å gjøre dette, huk av «Nye partisjons-UUID-er»-boksen før du kopierer.
 Velg enheten det skal kopieres ifra Velg enheten det skal kopieres ifra Velg enheten som det skal kopieres til Velg enheten det skal kopieres til Begynn Dette vil slette alt innhold på '%s'-enheten. Er du sikker? For mange partisjoner i kilden. Klarte ikke å lese kilden. Ja 