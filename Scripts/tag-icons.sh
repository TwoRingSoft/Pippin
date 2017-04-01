#!/bin/sh

#  tag-icons.sh
#  Trgnmtry
#
#  Created by Andrew McKnight on 4/1/17.
#  Copyright © 2017 Two Ring Software. All rights reserved.

XCODE_ICON_TAGGER_SCRIPT_MODE="$1"

function invoke_tagger() {
    XCODE_ICON_TAGGER_TOOL_MODE="$1"
    OPTIONAL_CUSTOM_ICON_TAG_TEXT="$2"

    sh ${SRCROOT}/Vendor/XcodeIconTagger/tagIcons.sh            \
        $XCODE_ICON_TAGGER_TOOL_MODE                            \
        ${SRCROOT}/Trgnmtry/Assets.xcassets/AppIcon.appiconset  \
        $OPTIONAL_CUSTOM_ICON_TAG_TEXT
}

if [[ $XCODE_ICON_TAGGER_SCRIPT_MODE = "tag" ]]; then
    if [[ "$TARGET_NAME" = "Trgnmtry Touches" ]]; then
        invoke_tagger "custom" "Touches"
    else
        if [[ $CONFIGURATION = "Beta" ]]; then
            invoke_tagger "version"
        elif [[ $CONFIGURATION = "Debug" ]]; then
            invoke_tagger "commit"
        fi
    fi
else
    invoke_tagger "cleanup"
fi
