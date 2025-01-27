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

# Downloading resources
sudo mkdir /mediabots /floppy /virtio
sudo wget -O /mediabots/WS2019.ISO https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso

# Downloading Virtio Drivers
sudo wget -P /virtio https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
# creating .iso for Windows tools & drivers

#
#Enabling KSM
sudo echo 1 > /sys/kernel/mm/ksm/run
#Free memories
sync; sudo echo 3 > /proc/sys/vm/drop_caches
# Gathering System information
sudo /usr/bin/qemu-img create /disk.img 90G
sudo /usr/bin/qemu-system-x86_64 -net nic -net user,hostfwd=tcp::3389-:3389,hostfwd=tcp::65534-:65534 -m 8721 -enable-kvm -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,+nx -M pc -smp cores=10 -vga std -machine type=pc,accel=kvm -usb -device usb-tablet -k en-us -boot d -cdrom /mediabots/WS2019.ISO -hda /disk.img -vnc :9 &
pid2=$(echo $! | head -1)
disown -h $pid2
echo "disowned PID : "$pid2
