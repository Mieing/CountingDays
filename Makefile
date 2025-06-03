TARGET := iphone:clang:latest:16.0
INSTALL_TARGET_PROCESSES = CountingDays
THEOS_DEVICE_IP = 192.168.100.101
THEOS_DEVICE_PORT = 22
include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = CountingDays

CountingDays_FILES = $(wildcard *.swift)
CountingDays_FRAMEWORKS = UIKit
CountingDays_CFLAGS = -fobjc-arc
CountingDays_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/application.mk
