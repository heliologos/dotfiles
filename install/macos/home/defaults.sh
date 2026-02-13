#!/usr/bin/env zsh 

set -Eeuo pipefail

defaults_keyboard() {
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 25

  # Change Caps to Ctrl
  # ref. https://stackoverflow.com/a/46460200
  hidutil property --set \
    '{"UserKeyMapping": [{"HIDKeyboardModifierMappingSrc": 0x700000039, "HIDKeyboardModifierMappingDst": 0x7000000e0 }] }'
}

kill_affected_applications() {
  local apps=(
    "Activity Monitor"
    "Calendar"
    "cfprefsd"
    "Dock"
    "Finder"
    "SystemUIServer"
  )
  for app in "${apps[@]}"; do
    killall "${app}" || echo "Process \`${app}\` was not running."
  done
}

main() {
  defaults_keyboard
  kill_affected_applications
}