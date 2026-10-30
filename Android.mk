LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),A101BM)
include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
