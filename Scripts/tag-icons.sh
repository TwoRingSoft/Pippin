#!/bin/sh

#  tag-icons.sh
#  Trgnmtry
#
#  Created by Andrew McKnight on 4/1/17.
#  Copyright © 2017 Two Ring Software. All rights reserved.

XCODE_ICON_TAGGER_SUBMODULE_LOCATION="$1"
XCODE_ICON_TAGGER_SCRIPT_MODE="$2"
XCODE_ICON_TAGGER_IMAGES_DIRECTORY="$3"

function invoke_tagger() {
    TAGGER_SUBMODULE_LOCATION="$1"
    XCODE_ICON_TAGGER_TOOL_MODE="$2"
    OPTIONAL_CUSTOM_ICON_TAG_TEXT="$3"

    sh "$TAGGER_SUBMODULE_LOCATION/tagIcons.sh" \
        "$XCODE_ICON_TAGGER_TOOL_MODE"          \
        "$XCODE_ICON_TAGGER_IMAGES_DIRECTORY"   \
        "$OPTIONAL_CUSTOM_ICON_TAG_TEXT"
}

if [[ $XCODE_ICON_TAGGER_SCRIPT_MODE = "tag" ]]; then
    if [[ "$TARGET_NAME" = "Trgnmtry Touches" ]]; then
        invoke_tagger "$XCODE_ICON_TAGGER_SUBMODULE_LOCATION" "custom" "Touches"
    else
        if [[ $CONFIGURATION = "Beta" ]]; then
            invoke_tagger "$XCODE_ICON_TAGGER_SUBMODULE_LOCATION" "version"
        elif [[ $CONFIGURATION = "Debug" ]]; then
            invoke_tagger "$XCODE_ICON_TAGGER_SUBMODULE_LOCATION" "commit"
        fi
    fi
else
    invoke_tagger "$XCODE_ICON_TAGGER_SUBMODULE_LOCATION" "cleanup"
fi
