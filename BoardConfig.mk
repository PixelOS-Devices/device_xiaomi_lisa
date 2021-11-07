#
# Copyright (C) 2022 PixelOS
#
# SPDX-License-Identifier: Apache-2.0
#


DEVICE_PATH := device/xiaomi/lisa

# Inherit from sm8350-common
include device/xiaomi/sm8350-common/BoardConfigCommon.mk

# Board
TARGET_BOOTLOADER_BOARD_NAME := lisa

# Include proprietary files
include vendor/xiaomi/lisa/BoardConfigVendor.mk
