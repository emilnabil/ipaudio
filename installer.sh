#!/bin/sh
#
# Command: wget -q "--no-check-certificate"   https://raw.githubusercontent.com/emilnabil/ipaudio/main/installer.sh -O - | /bin/sh
######### Only These two lines to edit with new version ######
version=5.3
description="Add support for dm one/two"
echo ' =====================
================================
===================================== '
echo "  download and install ipaudio "
TEMPATH='/tmp'
PLUGINPATH='/usr/lib/enigma2/python/Plugins/Extensions/IPAudio'

CHECK='/tmp/check'
BINDIR='/usr/bin/'
ARMBIN='/tmp/ipaudio/bin/arm/*'
MIPSBIN='/tmp/ipaudio/bin/mips/*'
SH4BIN='/tmp/ipaudio/bin/sh4/*'
AARCH64='/tmp/ipaudio/bin/aarch64/*'
IPAUDIO='/tmp/ipaudio/usr/*'
PLAYLIST='/tmp/ipaudio/etc/ipaudio.json'
ASOUND='/tmp/ipaudio/etc/asound.conf'
uname -m >$CHECK

# remove old version
rm -r $PLUGINPATH >/dev/null 2>&1
rm -f /usr/bin/ipplayer >/dev/null 2>&1
rm -f /usr/bin/ipplayer-auto >/dev/null 2>&1
rm -f /usr/bin/ipplayer-os >/dev/null 2>&1
rm -f /usr/bin/gst1.0-ipaudio >/dev/null 2>&1

cd $TEMPATH
set -e
wget -q "https://raw.githubusercontent.com/emilnabil/ipaudio/main/
ipaudio-$version.tar.gz"

tar -xzf ipaudio-"$version".tar.gz -C /tmp
set +e
rm -f ipaudio-"$version".tar.gz
cd ..

# check depends packges
if [ -f /var/lib/dpkg/status ]; then
        STATUS='/var/lib/dpkg/status'
        OS='DreamOS'
else
        STATUS='/var/lib/opkg/status'
        OS='Opensource'
fi

if grep -q 'gstreamer1.0-plugins-base-volume' $STATUS; then
    gstVol='Installed'
fi

if grep -q 'gstreamer1.0-plugins-good-ossaudio' $STATUS; then
    gstOss='Installed'
fi

if grep -q 'gstreamer1.0-plugins-good-mpg123' $STATUS; then
    gstMp3='Installed'
fi

if grep -q 'gstreamer1.0-plugins-good-equalizer' $STATUS; then
    equalizer='Installed'
fi

if [ $gstVol = "Installed" -a $gstOss = "Installed" -a $gstMp3 = "Installed" -a $equalizer = "Installed" ]; then
     echo ""
else
        if [ $OS = "DreamOS" ]; then
                echo "=========================================================================="
                echo "Some Depends Need to Be downloaded From Feeds ...."
                echo "=========================================================================="
                echo "APT Update ..."
                echo "========================================================================"
                apt-get update
                echo " Downloading gstreamer1.0-plugins-base-volume ......"
                apt-get install gstreamer1.0-plugins-base-volume -y;
                echo "========================================================================"
                echo " Downloading gstreamer1.0-plugins-good-ossaudio ......"
                apt-get install gstreamer1.0-plugins-good-ossaudio -y;
                echo "========================================================================"
                echo " Downloading gstreamer1.0-plugins-good-mpg123 ......"
                apt-get install gstreamer1.0-plugins-good-mpg123 -y;
                echo "========================================================================"
                echo " Downloading gstreamer1.0-plugins-good-equalizer ......"
                apt-get install gstreamer1.0-plugins-good-equalizer -y;
                echo "========================================================================"
        else
                echo "=========================================================================="
                echo "Some Depends Need to Be downloaded From Feeds ...."
                echo "=========================================================================="
                echo "Opkg Update ..."
                echo "========================================================================"
                opkg update
                echo " Downloading gstreamer1.0-plugins-base-volume ......"
                opkg install gstreamer1.0-plugins-base-volume
                echo "========================================================================"
                echo " Downloading gstreamer1.0-plugins-good-ossaudio ......"
                opkg install gstreamer1.0-plugins-good-ossaudio
                echo "========================================================================"
                echo " Downloading gstreamer1.0-plugins-good-mpg123 ......"
                opkg install gstreamer1.0-plugins-good-mpg123
                echo "========================================================================"
                echo " Downloading gstreamer1.0-plugins-good-equalizer ......"
                opkg install gstreamer1.0-plugins-good-equalizer
                echo "========================================================================"
        fi
fi

if grep -q 'gstreamer1.0-plugins-base-volume' $STATUS; then
	echo ""
else
	echo "#########################################################"
	echo "#  gstreamer1.0-plugins-base-volume Not found in feed   #"
	echo "#         IPaudio has not been installed                #"
	echo "#########################################################"
        rm -r /tmp/ipaudio
        rm -f $CHECK
	exit 1
fi


if grep -qs -i 'mips' cat $CHECK; then
        echo "[ Your device is MIPS ]"
        cp -a $MIPSBIN $BINDIR
        chmod 0775 /usr/bin/gst1.0-ipaudio
elif grep -qs -i 'armv7l' cat $CHECK; then
        echo "[ Your device is armv7l ]"
        cp -a $ARMBIN $BINDIR
        chmod 0775 /usr/bin/gst1.0-ipaudio
elif grep -qs -i 'sh4' cat $CHECK; then
        echo "[ Your device is sh4 ]"
        cp -a $SH4BIN $BINDIR
        chmod 0775 /usr/bin/gst1.0-ipaudio
elif grep -qs -i 'aarch64' cat $CHECK ; then
	echo "[ Your device is aarch64 ]"
        cp -a $AARCH64 $BINDIR
        chmod 0775 /usr/bin/gst1.0-ipaudio
else
        echo "###############################"
        echo "## Your stb is not supported ##"
        echo "###############################"
        rm -r /tmp/ipaudio
        rm -f $CHECK
        exit 1
        echo ""
fi

mkdir -p $PLUGINPATH
cp -r $IPAUDIO $PLUGINPATH


if [ ! -f /etc/enigma2/ipaudio.json ]; then
        cp -a $PLAYLIST /etc/enigma2
fi

if [ ! -f /etc/asound.conf ]; then
        echo "Send asound.conf to /etc"
        cp -a $ASOUND /etc
fi

rm -r /tmp/ipaudio
rm -f $CHECK

echo ""
sync
echo "#########################################################"
echo "#          IPAudio $version INSTALLED SUCCESSFULLY           #"
echo "#                BY ZIKO - support on                   #"
echo ".   welcome to ipaudio "
echo "#           your Device will RESTART Now                #"
echo "#########################################################"
if [ $OS = 'DreamOS' ]; then 
    systemctl restart enigma2
else
    killall -9 enigma2
fi
exit 0







