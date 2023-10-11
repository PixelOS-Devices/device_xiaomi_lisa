#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=lisa
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        system_ext/lib64/libwfdnative.so)
            "${PATCHELF}" --remove-needed "android.hidl.base@1.0.so" "${2}"
            ;;
        vendor/bin/hw/dolbycodec2)
            patchelf --replace-needed libavservices_minijail_vendor.so libavservices_minijail.so "${2}"
            patchelf --replace-needed libcodec2_hidl@1.0.so libcodec2_hidl@1.0.stock.so "${2}"
            patchelf --add-needed "libshim.so" "${2}"
            ;;
        vendor/etc/camera/pure*_parameter.xml)
            sed -i 's/=\([0-9]\+\)>/="\1">/g' "${2}"
            ;;
        vendor/etc/media_lahaina/video_system_specs.json \
        |vendor/etc/media_shima_v1/video_system_specs.json \
        |vendor/etc/media_yupik_v1/video_system_specs.json)
            sed -i "/max_retry_alloc_output_timeout/ s/10000/0/" "${2}"
            ;;
        vendor/lib64/hw/camera.xiaomi.so)
            # Before
            # 21 00 80 52     mov        w1,#0x1
            # 29 07 00 94     bl         <EXTERNAL>::android::hardware::configureRpcThr
            # After
            # 21 00 80 52     mov        w1,#0x1
            # 1f 20 03 d5     nop
            sed -i "s/\x21\x00\x80\x52\x29\x07\x00\x94/\x21\x00\x80\x52\x1f\x20\x03\xd5/g" "${2}"
            ;;
        vendor/lib64/hw/camera.qcom.so)
            sed -i "s/\x73\x74\x5F\x6C\x69\x63\x65\x6E\x73\x65\x2E\x6C\x69\x63/\x63\x61\x6D\x65\x72\x61\x5F\x63\x6E\x66\x2E\x74\x78\x74/g" "${2}"
            ;;
        vendor/lib/libcodec2_hidl@1.0.stock.so)
            patchelf --set-soname libcodec2_hidl@1.0.stock.so "${2}"
            patchelf --replace-needed libcodec2_vndk.so libcodec2_vndk.stock.so "${2}"
            ;;
        vendor/lib/libcodec2_vndk.stock.so)
            patchelf --set-soname libcodec2_vndk.stock.so "${2}"
            ;;
        system_ext/lib/libwfdnative.so | system_ext/lib64/libwfdnative.so )
            "${PATCHELF}" --remove-needed "android.hidl.base@1.0.so" "${2}"
            ;;
        vendor/lib64/libwa_sat.so)
            sed -i 's/\/system\/lib64\([^\/]\)/\/vendor\/lib64\1/g' "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
