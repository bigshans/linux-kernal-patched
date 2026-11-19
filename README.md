# Linux-Xanmod-Bore-Cjktty

## Introduction

This is my personal linux kernel repository.

## Differences from Linux-Xanmod-Caucle

- Add anbox config
- Add cjktty
- Add BORE CPU Scheduler
- Added some make parameters to fit my computer's hardware
- Tickless

## Build And Install

If you have compiled code in the past, you can use `make clean` to clean up the directory.

``` shell
make clean
```

If a source host is unreachable (SourceForge mirrors rotate and may be blocked),
fetch every source with mirror fallback and sha256 verification:

``` shell
make fetch
```

This reuses already-present files, restores from `backup/` when the network is
unreachable, and otherwise tries several mirrors. Every file is sha256-verified.
`makepkg` will then build without touching the network.

Then run it,

``` shell
makepkg -sfi
```

If your compilation is interrupted in the middle, just re-run `makepkg -sfi`; it reuses the existing source tree. Use `make purge` to drop every downloaded/extracted artifact.

``` shell
make purge
```

Of course, you can also download it from the release. Only the default configuration.

## Build-time options

All options can be overridden via environment variables, e.g.
`env _microarchitecture=98 _thp=madvise makepkg -sfi`.

| Variable | Default | Description |
| --- | --- | --- |
| `_microarchitecture` | `0` | GCC microarchitecture. `0` = config default (x86-64-v3), `98` = Intel native, `99` = AMD native |
| `_compiler` | `gcc` | Set to `clang` for LLVM / ThinLTO |
| `_config` | `config` | Xanmod config file under `CONFIGS/x86_64/` (`config_x86-64-v1/v2/v3/v4`) |
| `_thp` | `madvise` | Transparent Huge Pages default: `always` / `madvise` / `never` |
| `_compress_modules` | `y` | Compress modules with ZSTD |
| `_min_base_slice_ns` | `2000000` | BORE base slice lower bound (2 ms at HZ=1000) |
| `_localmodcfg` | `n` | `y` = build only modules listed in `~/.config/modprobed.db` |
| `_makenconfig` | `n` | `y` = run `make nconfig` before building |
| `use_numa` | `y` | `n` = disable NUMA |
| `use_tracers` | `n` | `y` = enable FTRACE / FUNCTION_TRACER / STACK_TRACER |

Examples:

``` shell
env _microarchitecture=98 makepkg -sfi
env _compiler=clang makepkg -sfi
env _thp=always makepkg -sfi
env _min_base_slice_ns=1000000 makepkg -sfi
```

## Runtime knobs

BORE can be toggled at runtime (no reboot, no rebuild):

``` shell
cat /proc/sys/kernel/sched_bore          # 1 = BORE enabled
sudo sysctl -w kernel.sched_bore=0       # fall back to the regular fair scheduler
sudo sysctl -w kernel.sched_bore=1
```

Transparent Huge Pages can also be changed at runtime:

``` shell
cat /sys/kernel/mm/transparent_hugepage/enabled
echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
```

## Notes

- The default configuration targets a general desktop: `THP=madvise`, full preemption,
  `HZ=1000`, ZSTD-compressed modules, BORE enabled (can be disabled at runtime).
- Aggressive tuning (native CPU, `always` THP, tickless full dynticks, etc.) should be
  passed via environment variables instead of changing the defaults.
- It is recommended to keep the official `linux` package installed as a fallback kernel.
- Version-specific sources (`patch-*-xanmod*.xz`, `cjktty-*.patch`, `0001-bore-*.patch`)
  are downloaded artifacts: `make purge` removes them and `make fetch` restores them.
  They are deliberately not committed, so a stale copy can never be reused across
  a version bump.
- Optional: install `ccache` and enable it in `/etc/makepkg.conf` to speed up repeated rebuilds.
