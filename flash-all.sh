#!/bin/sh

# Copyright 2012 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -x
fastboot flash partition gpt.bin
fastboot flash bootloader bootloader.img
fastboot reboot-bootloader
sleep 9
fastboot --set-active=a
fastboot flash modem_a NON-HLOS.bin
fastboot flash fsg_a fsg.mbn
fastboot erase modemst1
fastboot erase modemst2 
fastboot flash bluetooth_a BTFM.bin
fastboot flash dsp_a dspso.bin
fastboot flash logo_a logo.bin
fastboot flash boot_a boot.img
fastboot flash system_a system.img_sparsechunk.0
fastboot flash system_a system.img_sparsechunk.1
fastboot flash system_a system.img_sparsechunk.2
fastboot flash system_a system.img_sparsechunk.3
fastboot flash system_a system.img_sparsechunk.4
fastboot flash system_a system.img_sparsechunk.5
fastboot flash system_a system.img_sparsechunk.6
fastboot flash system_a system.img_sparsechunk.7
fastboot flash system_b system_other.img
fastboot flash oem_a oem.img
fastboot erase carrier
fastboot erase userdata
fastboot erase ddr
set +x
fastboot reboot
