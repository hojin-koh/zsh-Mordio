#!/usr/bin/env zsh
description="Test if a simple script can be run"

main() {
  debug "$description"
  info "$description"
  warn "$description"
}

source "${0:a:h}/../../skritt"
