#!/usr/bin/env zsh
description="Test argument parsing"

setupArgs() {
  opt opt.3 '(38)' "Array overwrite test"
}

main() {
  test "$#opt___3" -eq 1
  test "${opt___3[1]}" -eq 16
}

source "${0:a:h}/../../skritt"
