# zsh-Mordio
A heavily-opinionated and colorful light scientific scripting framework. This library is geared toward simple scripts that does only one thing per script which are joined together with a Makefile or something else. Rudimentary argument data types. Basically my daily data-crunching and researching framework.

## Dependencies

- All the dependencies from zsh-Skritt.
    - Some more tools needed from the so-called "coreutils": `cut`, `wc`, `grep`
- tar (both gnu and bsd should work)
- zstd: most data types need this utility for storage
- b3sum: for checksums (You need the [official reference implementation](https://github.com/BLAKE3-team/BLAKE3))
