#!/vendor/bin/sh
#
# Copyright (C) 2022 Paranoid Android
#
# SPDX-License-Identifier: Apache-2.0
#

fix_applied=$(getprop persist.vendor.sensors.fix_applied)

if [ "$fix_applied" != "true" ]; then
    # Rename oem13 sensor according to MIUI 13
    sed -i '/oem13/d' /mnt/vendor/persist/sensors/sensors_list.txt
    echo "oem13_light_smd" >> /mnt/vendor/persist/sensors/sensors_list.txt
    setprop persist.vendor.sensors.fix_applied true
fi
