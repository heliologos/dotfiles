#!/usr/bin/env zsh

set -Eeuo pipefail

ensure_sudo_session() {
  # Ask for the administrator password upfront.
  sudo -v

  # Keep-alive: update existing `sudo` time stamp until finished.
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
}

defaults_languages() {
  defaults write -g AppleLanguages -array "en" "es" "fr" "de"
  defaults write -g AppleLocale -string "en_US"
}

defaults_trackpad() {
  # Enable tap to click for this user and for the login screen.
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
  defaults write -g com.apple.mouse.tapBehavior -int 1

  # Disable press-and-hold for keys in favor of key repeat.
  defaults write -g ApplePressAndHoldEnabled -bool false

  # Enable full keyboard access for all controls.
  defaults write -g AppleKeyboardUIMode -int 3
}

defaults_keyboard() {
  # Disable auto-correct.
  defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

  # Disable smart quotes and dashes.
  defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults write -g NSAutomaticDashSubstitutionEnabled -bool false

  # Enable full keyboard access for all controls.
  defaults write -g AppleKeyboardUIMode -int 3

  # Set a fast keyboard repeat rate.
  defaults write -g KeyRepeat -int 1
  defaults write -g InitialKeyRepeat -int 10

  # Change Caps to Ctrl.
  # ref. https://stackoverflow.com/a/46460200
  hidutil property --set \
    '{"UserKeyMapping": [{"HIDKeyboardModifierMappingSrc": 0x700000039, "HIDKeyboardModifierMappingDst": 0x7000000e0 }] }'
}

defaults_monitor() {
  # Require password immediately after sleep or screen saver begins.
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0

  # Disable shadow in screenshots.
  defaults write com.apple.screencapture disable-shadow -bool true

  # Save screenshots to dedicated directory.
  defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"

  # Save screenshots in JPG format.
  defaults write com.apple.screencapture type -string "jpg"
}

defaults_dock() {
  # Permanently set the icon size of Dock items to 36 pixels.
  defaults write com.apple.dock tilesize -int 36
  defaults write com.apple.dock size-immutable -bool true

  # Change minimize/maximize window effect.
  defaults write com.apple.dock mineffect -string "scale"

  # Do not animate opening applications from the Dock.
  defaults write com.apple.dock launchanim -bool false

  # Speed up Mission Control animations.
  defaults write com.apple.dock expose-animation-duration -float 0.1

  # Remove auto-hide delays and animations.
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock autohide-time-modifier -float 0

  # Automatically hide and show the Dock.
  defaults write com.apple.dock autohide -bool true

  # Make Dock icons of hidden applications translucent.
  defaults write com.apple.dock showhidden -bool true
}

defaults_finder() {
  # Show icons for hard drives, servers, and removable media on the desktop.
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

  # Allow quitting Finder via Cmd + Q.
  defaults write com.apple.finder QuitMenuItem -bool true

  # Show the ~/Library folder.
  chflags nohidden ~/Library

  # Show the /Volumes folder.
  sudo chflags nohidden /Volumes

  # Expand file info panes by default.
  defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

  # Do not hide files or extensions.
  defaults write com.apple.finder AppleShowAllFiles YES
  defaults write -g AppleShowAllExtensions -bool true

  # Disable window animations.
  defaults write com.apple.finder DisableAllAnimations -bool true
  defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

  # Keep folders on top when sorting by name.
  defaults write com.apple.finder _FXSortFoldersFirst -bool true

  # Show status bar and path bar.
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder ShowPathbar -bool true

  # Expand save/print panels by default.
  defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
  defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true
  defaults write -g PMPrintingExpandedStateForPrint -bool true
  defaults write -g PMPrintingExpandedStateForPrint2 -bool true

  # Display full POSIX path as Finder window title.
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

  # Disable extension change warning.
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  # Enable text selection in Quick Look.
  defaults write com.apple.finder QLEnableTextSelection -bool true

  # Automatically open a new Finder window when a volume is mounted.
  defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
  defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
  defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

  # Avoid creating .DS_Store files.
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
  defaults write com.apple.desktopservices DSDontWriteLocalStores -bool true

  # Set search scope and preferred view style.
  defaults write com.apple.finder FXDefaultSearchScope SCcf
  defaults write com.apple.finder FXPreferredViewStyle Nlsv
  rm -f ~/.DS_Store

  # Set default path for new windows to $HOME.
  defaults write com.apple.finder NewWindowTarget PfHm

  # Enable spring loading for directories and remove delay.
  defaults write -g com.apple.springing.enabled -bool true
  defaults write -g com.apple.springing.delay -float 0

  # Disable warning before emptying Trash.
  defaults write com.apple.finder WarnOnEmptyTrash -bool false

  # Column size animation speed.
  defaults write -g NSBrowserColumnAnimationSpeedMultiplier -float 0.001
}

defaults_launchpad() {
  defaults write com.apple.dock springboard-columns -int 8
  defaults write com.apple.dock springboard-rows -int 8
  defaults write com.apple.dock ResetLaunchPad -bool true

  # Disable hot corner.
  defaults write com.apple.dock wvous-br-corner -int 0
}

defaults_mail() {
  # Copy email addresses as plain addresses in Mail.app.
  defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

  # Add Cmd + Enter to send an email in Mail.app.
  defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

  # Display emails in threaded mode, newest first.
  defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
  defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
  defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

  # Disable inline attachments.
  defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

  # Disable automatic spell checking.
  defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"
}

configure_touch_id_for_sudo() {
  local touch_id_config="auth       sufficient     pam_tid.so"
  local pam_sudo_file="/etc/pam.d/sudo"

  if ! grep -q "$touch_id_config" "$pam_sudo_file"; then
    echo "Adding Touch ID support to ${pam_sudo_file}..."
    sudo cp "$pam_sudo_file" "$pam_sudo_file.bak"
    echo -e "${touch_id_config}\n$(cat "$pam_sudo_file")" | sudo tee "$pam_sudo_file" > /dev/null
  else
    echo "Touch ID support is already enabled in ${pam_sudo_file}."
  fi
}

configure_iterm() {
  defaults write com.googlecode.iterm2 "PrefsCustomFolder" -string "$HOME/.config/iterm2"
  defaults write com.googlecode.iterm2 "LoadPrefsFromCustomFolder" -bool true
}

kill_affected_applications() {
  local apps=(
    "Activity Monitor"
    "Calendar"
    "cfprefsd"
    "Contacts"
    "Dock"
    "Finder"
    "Mail"
    "Messages"
    "Photos"
    "Safari"
    "SystemUIServer"
    "Transmission"
  )

  for app in "${apps[@]}"; do
    killall "$app" >/dev/null 2>&1 || true
  done
}

main() {
  ensure_sudo_session
  defaults_languages
  defaults_trackpad
  defaults_keyboard
  defaults_monitor
  defaults_dock
  defaults_finder
  defaults_launchpad
  defaults_mail
  configure_touch_id_for_sudo
  configure_iterm
  kill_affected_applications
}

main "$@"
