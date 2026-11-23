# menutx

**One terminal menu for a set of terminal diagnostics tools, installed with
one script on Debian-based systems.**

[![License: GPL-3.0-or-later](https://img.shields.io/badge/license-GPL--3.0--or--later-blue.svg)](LICENSE)
![Platform: Debian and Ubuntu](https://img.shields.io/badge/platform-Debian%20%7C%20Ubuntu-A81D33)
![Shell: Bash](https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white)

menutx creates `~/menutx`, installs the packages the tools need, downloads the
latest Linux builds of six terminal diagnostics programs from GitHub, verifies
their checksums when the project publishes them, and puts everything behind one
arrow-key menu. It also installs `hyfetch`, `mc`, `nmon` and `opencode`, and adds
a `menutx` alias to your `~/.bashrc`.

```text
  menutx 1.0.0
  Terminal diagnostics on Debian - 10 launchers

  > syswatch     CPU, memory, disks, processes and power
    netwatch     Connections, latency and packet capture
    diskwatch    Disks, filesystems, I/O and SMART health
    kernwatch    Kernel, eBPF, scheduler and interrupts
    netscan      nmap scans and attack-surface workflow
    soundwatch   Audio devices, streams and meters
    hyfetch      Neofetch with pride flags
    mc           Midnight Commander file manager
    nmon         Nigel's performance monitor
    opencode     AI coding agent in the terminal

  Up/Down move - Enter launch - r rescan - q quit
```

Everything menutx writes is in English.

> **Make the installer executable first.** A Git clone keeps the executable
> bit, but a ZIP download or a file uploaded through GitHub's web interface
> does not. Run `chmod +x install.sh` before `./install.sh`; otherwise the
> shell reports `Permission denied`. You can also start it with
> `bash install.sh`.

---

## What it does

On a freshly installed Debian (or Ubuntu, Mint, Pop!_OS, Kali, Raspberry Pi OS),
running `./install.sh` will:

1. **Install the system dependencies** with `apt`:
   `curl`, `ca-certificates`, `tar`, `gzip`, `xz-utils`, `sudo`, `mc`, `nmon`,
   `nmap`, `smartmontools`, `alsa-utils`, `libpulse0`, `iproute2` and `procps`.
   `nmap` is a hard dependency of netscan, `smartmontools` feeds diskwatch's
   SMART tab, and `libpulse0` is loaded at runtime by soundwatch's meters.
   `hyfetch` is installed from apt when the release packages it, otherwise with
   `pip --user`.
   Installing `smartmontools` may enable its `smartd` daemon; menutx only needs
   the `smartctl` client. Disable it with `sudo systemctl disable --now smartd`
   if you do not want it.
2. **Create `~/menutx`** and download the Linux release archives for:

   | Tool | What it does | Elevation | Upstream | License |
   |---|---|---|---|---|
   | **syswatch** | CPU, memory, disks, processes, GPU, power and network, with history and diagnostic cards | your user | [matthart1983/syswatch](https://github.com/matthart1983/syswatch) | MIT |
   | **netwatch** | Connections, per-hop latency, packet capture and a diagnosis engine | `sudo` | [matthart1983/netwatch](https://github.com/matthart1983/netwatch) | MIT |
   | **diskwatch** | Devices, volumes, filesystems, I/O latency, SMART health and busy files | `sudo` | [matthart1983/diskwatch](https://github.com/matthart1983/diskwatch) | MIT |
   | **kernwatch** | Kernel observability with eBPF: scheduling, memory, block I/O, syscalls, IRQs, cgroups | `sudo` | [matthart1983/kernwatch](https://github.com/matthart1983/kernwatch) | MIT |
   | **netscan** | An nmap workflow: target groups, scan profiles, live results and history | `sudo` | [matthart1983/netscan](https://github.com/matthart1983/netscan) | MIT |
   | **soundwatch** | Audio devices, streams, meters, spectrum, latency, xruns and routing | your user | [matthart1983/soundwatch](https://github.com/matthart1983/soundwatch) | MIT |
   | **hyfetch** | `neofetch` with LGBTQ+ pride flags | your user | [hykilpikonna/hyfetch](https://github.com/hykilpikonna/hyfetch) | MIT |
   | **mc** | Midnight Commander, a two-pane terminal file manager | your user | [MidnightCommander/mc](https://github.com/MidnightCommander/mc) | GPL-3.0-or-later |
   | **nmon** | Nigel's performance monitor for CPU, memory, disks and network | your user | [nmon.sourceforge.net](https://nmon.sourceforge.net) | GPL-3.0-or-later |
   | **opencode** | An AI coding agent for the terminal | your user | [anomalyco/opencode](https://github.com/anomalyco/opencode) | MIT |

3. **Write the menu and the per-tool launchers** (`menutx.sh`, `syswatch.sh`,
   and so on) into `~/menutx`, with a stable `bin/` symlink for every tool.
4. **Add the alias** `menutx` for `~/menutx/menutx.sh` to `~/.bashrc`
   (idempotently, with a backup of the file).
5. **Install opencode** with its official installer
   (`curl -fsSL https://opencode.ai/install | bash`), unless you pass
   `--no-opencode`.

The menu itself runs as your normal user. Only the launchers that need root
call `sudo` (netwatch, diskwatch, kernwatch, netscan); syswatch, soundwatch,
hyfetch, mc, nmon and opencode run as you. This keeps tool configuration in
your home instead of `/root`.

The installer does not write to `/etc` itself, replace system binaries, or
register its own services; apt packages may perform their normal setup (for
example, `smartmontools` can start `smartd`). Everything menutx adds lives
under `~/menutx`.

---

## Credits

menutx is a wrapper around other people's work. **The six `*watch` tools are
created by Matt Hartley ([@matthart1983](https://github.com/matthart1983),
[netwatchlabs.com](https://netwatchlabs.com)).**

- [syswatch](https://github.com/matthart1983/syswatch)
- [netwatch](https://github.com/matthart1983/netwatch)
- [diskwatch](https://github.com/matthart1983/diskwatch)
- [kernwatch](https://github.com/matthart1983/kernwatch)
- [netscan](https://github.com/matthart1983/netscan)
- [soundwatch](https://github.com/matthart1983/soundwatch)

All six are MIT-licensed. menutx only downloads, installs and launches them;
it is not affiliated with Matt Hartley. If you find these tools useful, star
the upstream repositories and consider supporting the author.

Other upstream projects:

- [hyfetch](https://github.com/hykilpikonna/hyfetch) by Azis (hykilpikonna), MIT
- [Midnight Commander](https://github.com/MidnightCommander/mc), GPL-3.0-or-later
- [nmon](https://nmon.sourceforge.net) by Nigel Griffiths, GPL-3.0-or-later
- [opencode](https://github.com/anomalyco/opencode), MIT

---

## Requirements

- **Debian 12 (bookworm) or 13 (trixie)**, or a derivative: Ubuntu 22.04+,
  Linux Mint 21+, Pop!_OS 22.04+, Kali, Raspberry Pi OS 64-bit.
- **x86_64 or aarch64.** armv7l/armv5te works for syswatch, diskwatch and
  netwatch; the other tools have no build for that architecture and are
  skipped automatically.
- A **normal user with a working `sudo`**. Run the installer as that user (or
  with `sudo ./install.sh`); a bare root shell is refused because the files
  must belong to your user. If `sudo -v` itself fails, the installer stops
  before changing anything. Restricted containers that set `no_new_privs` or
  mount `/` read-only cannot run the apt step; use `--no-deps` there.
- **Internet access** to Debian mirrors and GitHub releases.
- About **100 MB** of disk space, including the downloaded binaries and the
  apt packages.
- A UTF-8 terminal of at least 80x24.
- For **kernwatch**: a kernel built with BTF (`/sys/kernel/btf/vmlinux`).
  Debian's stock kernels have it; custom kernels may not.
- For **soundwatch meters**: PipeWire or PulseAudio running in your session.
  The tool still starts without a sound server and explains what is missing.

### If `sudo` is missing on a minimal Debian install

```bash
su -
apt-get update && apt-get install -y sudo
usermod -aG sudo YOUR_USER
exit
```

Log out and back in, then run the installer as your user.

---

## Installation

### Make the installer executable

GitHub's web upload and many ZIP downloads do not preserve the executable
bit. The Git clone below normally does, but run this anyway if you copied the
files from the GitHub page:

```bash
chmod +x install.sh
```

If you also want to run the menu and launchers directly from the repository
folder, make them executable too:

```bash
chmod +x menutx.sh uninstall.sh wrappers/*.sh
```

Without the executable bit, `./install.sh` fails with `Permission denied`.
`bash install.sh` works even without it.

### Clone and run

Clone the repository and run the installer:

```bash
git clone https://github.com/tehnium/menutx.git
cd menutx
chmod +x install.sh
./install.sh
```

If `git` is not installed on the fresh system:

```bash
sudo apt update && sudo apt install -y git
```

Or download the source archive without git:

```bash
curl -fsSL https://github.com/tehnium/menutx/archive/refs/heads/main.tar.gz | tar -xz
cd menutx-main
chmod +x install.sh
./install.sh
```

The installer asks for your sudo password once. If `sudo -v` fails, it stops
before changing anything; that is a sudo/permissions problem, not a
`chmod` problem. At the end:

```bash
source ~/.bashrc     # or open a new terminal
menutx
```

If you prefer not to use the alias:

```bash
~/menutx/menutx.sh
```

### Installer options

| Option | Effect |
|---|---|
| `--dir PATH` | Install into `PATH` instead of `~/menutx` |
| `--pinned` | Use the pinned versions in `install.sh`; do not query GitHub for the latest release |
| `--no-deps` | Skip the apt packages (and the hyfetch install); the six tools are still downloaded |
| `--no-opencode` | Do not install opencode or its launcher |
| `--no-alias` | Do not touch `~/.bashrc` |
| `-h`, `--help` | Show usage |

The environment variable `GITHUB_TOKEN` is optional. It raises the GitHub API
rate limit when the installer looks up the latest releases; a token with no
scopes is enough for public repositories.

### What gets created

```text
~/menutx/
├── menutx.sh                  # the menu
├── uninstall.sh
├── LICENSE
├── bin/                       # stable names the wrappers call
│   ├── syswatch -> ../syswatch/syswatch-linux-x86_64
│   ├── netwatch -> ../netwatch/netwatch-linux-x86_64
│   ├── diskwatch -> ../diskwatch/diskwatch-linux-x86_64
│   ├── kernwatch -> ../kernwatch/kernwatch-linux-x86_64
│   ├── netscan -> ../netscan/netscan-linux-x86_64-static
│   └── soundwatch -> ../soundwatch/soundwatch-linux-x86_64
├── syswatch/
├── netwatch/
├── diskwatch/
├── kernwatch/                 # binary, LICENSE, README and BPF provenance
├── netscan/
├── soundwatch/
├── syswatch.sh                # launchers, one per tool
├── netwatch.sh
├── diskwatch.sh
├── kernwatch.sh
├── netscan.sh
├── soundwatch.sh
├── hyfetch.sh
├── mc.sh
├── nmon.sh
└── opencode.sh
```

The exact binary names inside each tool folder depend on the architecture
(`x86_64`, `aarch64`, `armv5te`); the `bin/` symlinks hide that difference.

---

## Usage

Run `menutx` from any directory, or call `~/menutx/menutx.sh` directly.

| Key | Action |
|---|---|
| `Up` / `Down`, `j` / `k` | Move the selection |
| `Home` / `End`, `g` / `G` | Jump to the first or last entry |
| `Enter` | Launch the selected tool |
| `r` | Rescan the folder for new launchers |
| `q` | Quit |

When a tool exits, the menu comes back after you press Enter. A tool that
needs root asks for your sudo password in the terminal; a failed or cancelled
sudo run is reported with its exit status.

Non-interactive helpers:

```bash
~/menutx/menutx.sh --list       # print the launcher names
~/menutx/menutx.sh --version
~/menutx/menutx.sh --help
```

Every tool can also be started directly, which is handy for passing flags:

```bash
~/menutx/syswatch.sh --tab cpu
~/menutx/netwatch.sh --view dense
~/menutx/diskwatch.sh --tab smart
~/menutx/kernwatch.sh --view dense
~/menutx/netscan.sh
~/menutx/soundwatch.sh --theme btop
```

`diskwatch.sh` adds `--watch "$HOME"` unless you pass your own `--watch`, so
its Hot Files view follows your home directory rather than `/root`.

To add your own launcher, drop an executable `*.sh` file into `~/menutx` and
press `r` in the menu. The menu reproduces the pinned order (the six watch
tools) and sorts anything else alphabetically.

---

## Updating

Re-run the installer from a clone of the repository:

```bash
cd menutx
git pull
./install.sh
```

It replaces the downloaded binaries, rewrites the menu and wrappers, and keeps
the `~/.bashrc` alias idempotent. Your tool configuration in `~/.config` is
untouched.

To reproduce a known set of versions, use `./install.sh --pinned`. The pinned
fallbacks are:

| Tool | Pinned fallback |
|---|---|
| syswatch | v0.14.5 |
| netwatch | v1.0.0 |
| diskwatch | v0.7.2 |
| kernwatch | v0.5.1 |
| netscan | v0.8.1 |
| soundwatch | v0.2.0 |

Normally the installer asks GitHub for each project's **latest** release and
uses these only if the API is unavailable or the expected asset is missing.

### How the download works

1. `GET https://api.github.com/repos/OWNER/REPO/releases/latest` returns the
   tag. If that fails, the pinned tag is used.
2. The asset is chosen from the manifest for `amd64`, `arm64` or `armv5te`.
3. The archive is downloaded over HTTPS from the GitHub release page.
4. If the release publishes `SHA256SUMS`, the matching line is verified with
   `sha256sum -c`. netscan does not publish checksums today, so that step is
   skipped for it.
5. The archive is extracted into `~/menutx/<tool>/`, the binary is marked
   executable, and `~/menutx/bin/<tool>` is pointed at it.

---

## Uninstalling

```bash
~/menutx/uninstall.sh
```

The uninstaller removes `~/menutx` and the menutx block from `~/.bashrc`
(after asking for confirmation; `--yes` skips the prompt). It **does not**
remove apt packages, tool configuration under `~/.config`, `~/.opencode`, or
the `~/.bashrc.menutx.bak` and `~/.bashrc.menutx-uninstall.bak` backups.

You can also run `./uninstall.sh` from the repository clone; it then removes
the default `~/menutx` installation.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `menutx: command not found` | The alias is added to `~/.bashrc`: open a new terminal or run `source ~/.bashrc`. Check with `grep menutx ~/.bashrc`. |
| `sudo: command not found` | Minimal Debian install: see [If sudo is missing](#if-sudo-is-missing-on-a-minimal-debian-install). |
| `unsupported CPU architecture` | Prebuilt binaries exist for x86_64, aarch64 and some armv5te tools. On other CPUs, build the tools from source. |
| `could not query the latest release` | GitHub API rate limit or no network. Retry, set `GITHUB_TOKEN`, or use `--pinned`. |
| `checksum verification failed` | Retry the installer. If it persists, delete the affected `~/menutx/<tool>` folder and retry; do not bypass the check. |
| kernwatch reports missing BTF or permission errors | It needs root and a kernel with `CONFIG_DEBUG_INFO_BTF=y`. Debian's stock kernels have it. |
| soundwatch starts but the meters are empty | Make sure PipeWire or PulseAudio is running for your user and `libpulse0` is installed (`sudo apt install libpulse0 pipewire`). |
| netwatch says capture is not permitted | Launch it through `~/menutx/netwatch.sh` (it uses sudo), or grant capabilities as described in the netwatch documentation. |
| netscan cannot find nmap | `sudo apt install nmap`. The installer normally does this. |
| hyfetch is missing | `sudo apt install hyfetch`; if the release does not package it, `python3 -m pip install --user --break-system-packages hyfetch`. |
| opencode is missing | `curl -fsSL https://opencode.ai/install \| bash`, then run it from the menu again. |
| The TUI looks garbled after a crash | Run `reset`, use a UTF-8 terminal of at least 80x24, and avoid a non-interactive shell. |
| Menu exits immediately in a script | That is the non-interactive fallback; use `menutx.sh --list` for scripting. |
| `Permission denied` when running `./install.sh` | `chmod +x install.sh`, or run `bash install.sh`. ZIP downloads and files uploaded through GitHub's web interface do not keep the executable bit. |
| `sudo authentication failed` | Not a `chmod` problem. Run `sudo -v` in a normal terminal; your user must be in the `sudo` group and sudo must actually work. Containers that set `no_new_privs` or mount `/` read-only cannot run the apt step: use `--no-deps` there, or run the installer on the host. |

---

## License

menutx is free software, licensed under the
**GNU General Public License v3.0 or later** (GPL-3.0-or-later). See
[LICENSE](LICENSE).

Copyright (C) 2026 tehnium and contributors.

The tools menutx downloads are **not** covered by this license. They are
separate projects with their own licenses (all six `*watch` tools are MIT);
menutx does not redistribute them, it downloads them at install time.

menutx is an unofficial launcher and is not affiliated with Matt Hartley or
the upstream projects. The tools run with elevated privileges when they need
to; review the upstream documentation before using them on production
machines.

---

[![](https://img.shields.io/badge/powered_by-dsh-4D6BFE?style=flat-square&logo=deepseek&logoColor=white)](https://github.com/deepseek-ai/deepseek-harness)
