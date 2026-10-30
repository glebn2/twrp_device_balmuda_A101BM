#
# Copyright (C) 2026 glebn2
# SPDX-License-Identifier: Apache-2.0
#

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

$(call inherit-product, vendor/twrp/config/common.mk)

$(call inherit-product, device/balmuda/A101BM/device.mk)

PRODUCT_DEVICE := A101BM
PRODUCT_NAME := twrp_A101BM
PRODUCT_BRAND := BALMUDA
# One image for A101BM and X01A: the model is fixed, the codename comes from the
# installed system (TW_OVERRIDE_SYSTEM_PROPS in BoardConfig.mk).
PRODUCT_MODEL := Phone
PRODUCT_MANUFACTURER := BALMUDA
PRODUCT_RELEASE_NAME := BALMUDA Phone

PRODUCT_GMS_CLIENTID_BASE := android-balmuda
