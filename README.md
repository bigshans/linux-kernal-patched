# Linux-Xanmod-TT-Anbox-Cjktty

## Introduction

This is my personal linux-xanmod-tt kernel repository. I made a little modification to the linux-xanmod-tt package. If you want to use it, please note that this will overwrite the original package.

## About TT

https://github.com/hamadmarri/TT-CPU-Scheduler

## Problems

- [issue#14 about docker](https://github.com/hamadmarri/TT-CPU-Scheduler/issues/14)

If you really care about it, I suggest you to use xanmod or BORE scheduler.

## Differences from Linux-Xanmod-Caucle

- Add anbox config
- Add cjktty
- Added some make parameters to fit my computer's hardware

## Build And Install

If you have compiled code in the past, you can use the `./clean.sh` script to clean up the directory.

``` shell
./clean.sh
```

Then run it,

``` shell
makepkg -sfi
```

If your compilation is interrupted in the middle, you can use the following command to partially clean up the directory.

``` shell
./clean.sh -p
```

Of course, you can also download it from the release. Only the default configuration.
