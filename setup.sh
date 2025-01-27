#!/bin/bash
#
#Vars
mounted=0
GREEN='\033[1;32m';GREEN_D='\033[0;32m';RED='\033[0;31m';YELLOW='\033[0;33m';BLUE='\033[0;34m';NC='\033[0m'
# Virtualization checking..
virtu=$(egrep -i '^flags.*(vmx|svm)' /proc/cpuinfo | wc -l)
dist=$(hostnamectl | egrep "Operating System" | cut -f2 -d":" | cut -f2 -d " ")
printf "Y\n" | apt-get install sudo -y

# Downloading Portable QEMU-KVM
echo "Downloading QEMU"
sudo apt-get update
sudo apt-get install -y qemu-kvm
sudo apt-get install -y ufw

# Downloading resources
sudo mkdir /mediabots /floppy /virtio
sudo wget -O /mediabots/WS2019.ISO https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso

#
#Enabling KSM
sudo echo 1 > /sys/kernel/mm/ksm/run
#Free memories
sync; sudo echo 3 > /proc/sys/vm/drop_caches
# Gathering System information
mkdir /NewDrive
fallocate -l 75G NewStorage
mkfs.ext4 NewStorage
mount NewStorage /NewDrive
ufw allow 22
ufw allow 3389
ufw allow 65534
sudo /usr/bin/qemu-system-x86_64 -net nic -net user,hostfwd=tcp::3389-:3389,hostfwd=tcp::65534-:65534 -m 8200 -enable-kvm -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,+nx -M pc -smp cores=36 -vga std -machine type=pc,accel=kvm -usb -device usb-tablet -k en-us -boot d -cdrom /mediabots/WS2019.ISO -hda /dev/loop0 -vnc :9 &
pid2=$(echo $! | head -1)
disown -h $pid2
echo "disowned PID : "$pid2
