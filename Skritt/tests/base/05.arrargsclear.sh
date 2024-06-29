#!/usr/bin/env zsh
description="Test argument parsing"

setupArgs() {
  opt opt.3 '()' "Array clear test, that specifying an empty element don't clear the array"
}

main() {
  test "$#opt___3" -eq 3
  test "${opt___3[1]}" -eq 16
  test "${opt___3[2]}" -eq ""
  test "${opt___3[3]}" -eq 18
}

source "${0:a:h}/../../skritt"
