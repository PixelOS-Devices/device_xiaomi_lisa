#
# Copyright (C) 2022 PixelOS
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from lisa device
$(call inherit-product, device/xiaomi/lisa/device.mk)

# Inherit some common PixelOS stuff.
$(call inherit-product, vendor/aosp/config/common_full_phone.mk)
TARGET_GAPPS_ARCH := arm64
TARGET_SUPPORTS_QUICK_TAP := true

PRODUCT_NAME := aosp_lisa
PRODUCT_DEVICE := lisa
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := Xiaomi Mi 11 Lite 5G NE
PRODUCT_MANUFACTURER := Xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="lisa_global-user 11 RKQ1.210503.001 V12.5.14.0.RKOMIXM release-keys"

# Set BUILD_FINGERPRINT variable to be picked up by both system and vendor build.prop
BUILD_FINGERPRINT := Xiaomi/lisa_global/lisa:11/RKQ1.210503.001/V12.5.14.0.RKOMIXM:user/release-keys
