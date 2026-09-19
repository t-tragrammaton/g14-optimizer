# G14 CachyOS Optimizer

A bash script that tunes a CachyOS install for the ASUS ROG Zephyrus G14 (Ryzen + Nvidia hybrid graphics) — power profiles, GPU switching, battery charge limiting, and memory tuning, in one pass instead of hunting down each setting separately.

## What it does

### Power & Thermals
| Setting | Action |
|---|---|
| Power profile | Sets via `power-profiles-daemon` / `asusctl profile` (Balanced or Performance) |
| Battery charge limit | Caps charging at a set percentage (default 80%) to extend battery lifespan |
| IRQ balancing | Installs and enables `irqbalance` for better multi-core interrupt distribution |

### GPU
| Setting | Action |
|---|---|
| Graphics mode | Sets `supergfxctl` to Hybrid (both iGPU and dGPU available, required for `prime-run` offload) |
| Kernel modeset | Verifies `nvidia-drm.modeset=1` is present in the bootloader cmdline (required for clean suspend/resume on Nvidia Optimus) |

### Memory
| Setting | Action |
|---|---|
| Swappiness | Lowers `vm.swappiness` to 10 so the system prefers RAM over swap/zram until actually under pressure |
| zram | Checks for CachyOS's built-in zram-generator config before creating a new one — avoids the "device or resource busy" conflict that occurs when two zram configs target the same device |

## Why

Built after a long troubleshooting session covering an Nvidia driver/DKMS mismatch, GPU memory fragmentation causing repeated `NV_ERR_NO_MEMORY` failures, and Steam/Proton games crashing under memory pressure. The swappiness and zram tuning specifically target that fragmentation pattern; the GPU/power settings consolidate fixes that would otherwise need to be reapplied by hand after every clean install.

## How to run it

**1. Clone the repo**

`git clone https://github.com/t-tragrammaton/g14-cachyos-optimizer.git`

`cd g14-cachyos-optimizer`

**2. Review before running** — it's a `sudo` script; read it first

`less g14-optimize.sh`

**3. Run it**

`chmod +x g14-optimize.sh`

`sudo ./g14-optimize.sh`

**4. Reboot** to apply zram and sysctl changes cleanly

## Notes

- Written for CachyOS specifically; assumes `asusctl`, `supergfxctl`, and `power-profiles-daemon` are available in the repos.
- Checks for an existing CachyOS zram config before creating one, since CachyOS often ships zram-generator preconfigured — a duplicate config can conflict with the live device.
- `asusctl` command syntax has changed across versions; if a command fails, run `asusctl <subcommand> --help` to confirm current flags for your installed version.

## Status

- [x] Power profile and battery limit configuration
- [x] GPU mode verification (Hybrid)
- [x] Nvidia modeset kernel parameter check
- [x] Swappiness tuning
- [x] zram conflict detection
- [ ] Fan curve presets
- [ ] Automatic Limine/GRUB cmdline patching (currently detection-only)
