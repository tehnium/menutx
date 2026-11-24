# menutx

**One terminal menu for diagnostics, browsing, media and editing, installed
with one script on Debian-based systems.**

[![License: GPL-3.0-or-later](https://img.shields.io/badge/license-GPL--3.0--or--later-blue.svg)](LICENSE)
![Platform: Debian and Ubuntu](https://img.shields.io/badge/platform-Debian%20%7C%20Ubuntu-A81D33)
![Shell: Bash](https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white)

menutx creates `~/menutx`, installs the packages the tools need, downloads the
latest Linux builds of six terminal diagnostics programs and Browsh, verifies
their checksums when the project publishes them, and puts everything behind one
arrow-key menu. The same menu also gives you a text-based web browser, a video
player, a music player, an image viewer and a text editor. It installs
`hyfetch`, `mc`, `nmon` and `opencode`, and adds a `menutx` alias to your
`~/.bashrc`.

```text
  menutx 1.1.0
  Terminal tools on Debian - 15 launchers

  > syswatch     CPU, memory, disks, processes and power
    netwatch     Connections, latency and packet capture
    diskwatch    Disks, filesystems, I/O and SMART health
    kernwatch    Kernel, eBPF, scheduler and interrupts
    netscan      nmap scans and attack-surface workflow
    soundwatch   Audio devices, streams and meters
    browsh       Text-based web browser (Firefox)
    mpv          Video player with terminal output
    cmus         Music player and library
    chafa        Image and GIF viewer
    micro        Text and Markdown editor
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
   `nmap`, `smartmontools`, `alsa-utils`, `libpulse0`, `iproute2`, `procps`,
   `mpv`, `cmus`, `chafa`, `fzf` and `micro`.
   `nmap` is a hard dependency of netscan, `smartmontools` feeds diskwatch's
   SMART tab, `libpulse0` is loaded at runtime by soundwatch's meters, `mpv`
   plays video, `cmus` plays music, `chafa` shows images and `micro` edits
   text. `fzf` powers the file pickers in the `mpv.sh` and `chafa.sh`
   launchers.
   `hyfetch` is installed from apt when the release packages it, otherwise with
   `pip --user`.
   Installing `smartmontools` may enable its `smartd` daemon; menutx only needs
   the `smartctl` client. Disable it with `sudo systemctl disable --now smartd`
   if you do not want it.
2. **Create `~/menutx`** and set up the menu's tools (table below). The six
   diagnostics are downloaded from GitHub in this step; Browsh is installed
   from its `.deb` in step 3, and mpv, cmus, chafa and micro come from apt in
   step 1.

   | Tool | What it does | Elevation | Upstream | License |
   |---|---|---|---|---|
   | **syswatch** | CPU, memory, disks, processes, GPU, power and network, with history and diagnostic cards | your user | [matthart1983/syswatch](https://github.com/matthart1983/syswatch) | MIT |
   | **netwatch** | Connections, per-hop latency, packet capture and a diagnosis engine | `sudo` | [matthart1983/netwatch](https://github.com/matthart1983/netwatch) | MIT |
   | **diskwatch** | Devices, volumes, filesystems, I/O latency, SMART health and busy files | `sudo` | [matthart1983/diskwatch](https://github.com/matthart1983/diskwatch) | MIT |
   | **kernwatch** | Kernel observability with eBPF: scheduling, memory, block I/O, syscalls, IRQs, cgroups | `sudo` | [matthart1983/kernwatch](https://github.com/matthart1983/kernwatch) | MIT |
   | **netscan** | An nmap workflow: target groups, scan profiles, live results and history | `sudo` | [matthart1983/netscan](https://github.com/matthart1983/netscan) | MIT |
   | **soundwatch** | Audio devices, streams, meters, spectrum, latency, xruns and routing | your user | [matthart1983/soundwatch](https://github.com/matthart1983/soundwatch) | MIT |
   | **browsh** | Text-based web browser rendered by Firefox | your user | [browsh-org/browsh](https://github.com/browsh-org/browsh) | LGPL-2.1 |
   | **mpv** | Video player with terminal output (`--vo=tct`) | your user | [mpv-player/mpv](https://github.com/mpv-player/mpv) | GPL-2.0-or-later |
   | **cmus** | Music player and library for the terminal | your user | [cmus/cmus](https://github.com/cmus/cmus) | GPL-2.0 |
   | **chafa** | Image and GIF viewer for the terminal | your user | [hpjansson/chafa](https://github.com/hpjansson/chafa) | LGPL-3.0 |
   | **micro** | Text and Markdown editor | your user | [zyedidia/micro](https://github.com/zyedidia/micro) | MIT |
   | **hyfetch** | `neofetch` with LGBTQ+ pride flags | your user | [hykilpikonna/hyfetch](https://github.com/hykilpikonna/hyfetch) | MIT |
   | **mc** | Midnight Commander, a two-pane terminal file manager | your user | [MidnightCommander/mc](https://github.com/MidnightCommander/mc) | GPL-3.0-or-later |
   | **nmon** | Nigel's performance monitor for CPU, memory, disks and network | your user | [nmon.sourceforge.net](https://nmon.sourceforge.net) | GPL-3.0-or-later |
   | **opencode** | OpenCode 2, an AI coding agent for the terminal | your user | [anomalyco/opencode](https://github.com/anomalyco/opencode) | MIT |

3. **Install Browsh** from its official `.deb`. Browsh needs Firefox; if
   neither `firefox` nor `firefox-esr` is installed, apt pulls `firefox-esr`
   (about 100 MB extra). Use `--no-browsh` to skip this step.
4. **Write the menu and the per-tool launchers** (`menutx.sh`, `syswatch.sh`,
   `mpv.sh`, and so on) into `~/menutx`, with a stable `bin/` symlink for every
   downloaded tool.
5. **Add the alias** `menutx` for `~/menutx/menutx.sh` to `~/.bashrc`
   (idempotently, with a backup of the file).
6. **Install OpenCode 2** with its official v2 installer
   (`curl -fsSL https://opencode.ai/v2/install | bash`), unless you pass
   `--no-opencode`.

The menu itself runs as your normal user. Only the launchers that need root
call `sudo` (netwatch, diskwatch, kernwatch, netscan); syswatch, soundwatch,
Browsh, mpv, cmus, chafa, micro, hyfetch, mc, nmon and opencode run as you.
This keeps tool configuration in your home instead of `/root`.

The installer does not write to `/etc` itself, replace system binaries, or
register its own services; apt packages may perform their normal setup (for
example, `smartmontools` can start `smartd`). Browsh is the exception: it is
installed as a system package with apt, so the command lives in
`/usr/bin/browsh` and the menutx uninstaller leaves it in place.

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

- [Browsh](https://github.com/browsh-org/browsh) by Thomas Buckley-Houston, LGPL-2.1
- [mpv](https://github.com/mpv-player/mpv), GPL-2.0-or-later
- [cmus](https://github.com/cmus/cmus), GPL-2.0
- [chafa](https://github.com/hpjansson/chafa), LGPL-3.0
- [micro](https://github.com/zyedidia/micro), MIT
- [fzf](https://github.com/junegunn/fzf), MIT, used by the video and image pickers
- [hyfetch](https://github.com/hykilpikonna/hyfetch) by Azis (hykilpikonna), MIT
- [Midnight Commander](https://github.com/MidnightCommander/mc), GPL-3.0-or-later
- [nmon](https://nmon.sourceforge.net) by Nigel Griffiths, GPL-3.0-or-later
- [opencode](https://github.com/anomalyco/opencode), MIT
- Firefox ESR (MPL-2.0) is installed only when Browsh needs it.

---

## Requirements

- **Debian 12 (bookworm) or 13 (trixie)**, or a derivative: Ubuntu 22.04+,
  Linux Mint 21+, Pop!_OS 22.04+, Kali, Raspberry Pi OS 64-bit.
- **x86_64 or aarch64.** armv7l/armv6l also works for syswatch, diskwatch,
  netwatch and Browsh; the other tools have no build for those architectures
  and are skipped automatically.
- A **normal user with a working `sudo`**. Run the installer as that user (or
  with `sudo ./install.sh`); a bare root shell is refused because the files
  must belong to your user. If `sudo -v` itself fails, the installer stops
  before changing anything. Restricted containers that set `no_new_privs` or
  mount `/` read-only cannot run the apt step; use `--no-deps` there.
- **Internet access** to Debian mirrors and GitHub releases.
- About **500 MB** of disk space with Browsh and Firefox; about **150 MB** with
  `--no-browsh`. mpv pulls the ffmpeg libraries; Browsh pulls Firefox ESR when
  no Firefox is installed.
- A UTF-8 terminal of at least 80x24.
- For **kernwatch**: a kernel built with BTF (`/sys/kernel/btf/vmlinux`).
  Debian's stock kernels have it; custom kernels may not.
- For **soundwatch meters**, **mpv** and **cmus**: a working PipeWire,
  PulseAudio or ALSA setup. soundwatch still starts without a sound server and
  explains what is missing.
- For the best **chafa** images: a terminal with Kitty or Sixel graphics. The
  default symbols mode works everywhere.

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
| `--no-deps` | Skip the apt packages (and hyfetch, Browsh, mpv, cmus, chafa and micro); the six diagnostics are still downloaded |
| `--no-browsh` | Do not install Browsh or its Firefox dependency |
| `--no-opencode` | Do not install OpenCode 2 or its launcher |
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
├── browsh.sh
├── mpv.sh
├── cmus.sh
├── chafa.sh
├── micro.sh
├── hyfetch.sh
├── mc.sh
├── nmon.sh
└── opencode.sh
```

`browsh` itself is `/usr/bin/browsh`: it is a system package installed with
apt, not a file under `~/menutx`. The other tools live under `~/menutx`.

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

Browsing, media and editing:

```bash
~/menutx/browsh.sh https://example.com
~/menutx/mpv.sh ~/Videos/movie.mkv
~/menutx/mpv.sh --vo=kitty ~/Videos/movie.mkv   # Kitty graphics protocol
~/menutx/cmus.sh
~/menutx/chafa.sh ~/Pictures/photo.jpg
~/menutx/chafa.sh -f sixels ~/Pictures/photo.jpg
~/menutx/micro.sh ~/notes.md
```

`mpv.sh` and `chafa.sh` open an `fzf` picker when called without arguments,
searching `~/Videos` or `~/Pictures`, `~/Downloads` and the current directory.
`mpv.sh` defaults to `--vo=tct`, which works in every terminal; pass
`--vo=kitty` or `--vo=sixel` for higher-quality graphics where supported.
`chafa.sh` uses symbols by default; `-f kitty` and `-f sixels` give sharper
images. In `micro`, Ctrl-S saves and Ctrl-Q quits.

`diskwatch.sh` adds `--watch "$HOME"` unless you pass your own `--watch`, so
its Hot Files view follows your home directory rather than `/root`.

To add your own launcher, drop an executable `*.sh` file into `~/menutx` and
press `r` in the menu. The menu reproduces the pinned order (the six watch
tools, then Browsh, mpv, cmus, chafa and micro) and sorts anything else
alphabetically.

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
| Browsh | v1.8.2 (latest release with a Linux `.deb`; v1.8.3 is XPI-only) |

The six diagnostics tools normally use each project's **latest** GitHub release;
the pins are fallbacks for when the API is unavailable or an asset is missing.
Browsh is always installed from the pinned v1.8.2 `.deb`, because v1.8.3 ships
only the Firefox XPI.

### How the download works

1. `GET https://api.github.com/repos/OWNER/REPO/releases/latest` returns the
   tag. If that fails, the pinned tag is used.
2. The asset is chosen from the manifest for `amd64`, `arm64` or `armhf`
   (armv5te builds).
3. The archive is downloaded over HTTPS from the GitHub release page.
4. If the release publishes `SHA256SUMS`, the matching line is verified with
   `sha256sum -c`. netscan does not publish checksums today, so that step is
   skipped for it.
5. The archive is extracted into `~/menutx/<tool>/`, the binary is marked
   executable, and `~/menutx/bin/<tool>` is pointed at it.
6. **Browsh is different:** the installer downloads the pinned v1.8.2 `.deb`
   for the architecture, verifies it against
   `browsh_1.8.2_checksums.txt`, and installs it with `apt`, which pulls
   Firefox if no Firefox is present.

---

## Uninstalling

```bash
~/menutx/uninstall.sh
```

The uninstaller removes `~/menutx` and the menutx block from `~/.bashrc`
(after asking for confirmation; `--yes` skips the prompt). It **does not**
remove apt packages, tool configuration under `~/.config`, `~/.opencode`, or
the `~/.bashrc.menutx.bak` and `~/.bashrc.menutx-uninstall.bak` backups.

Browsh is a system package, so it stays installed. Remove it with
`sudo apt remove browsh`; remove `firefox-esr` separately only if nothing else
needs it.

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
| OpenCode 2 is missing | `curl -fsSL https://opencode.ai/v2/install \| bash`, then run it from the menu again. |
| Browsh says Firefox is missing | `sudo apt install firefox-esr`; the installer normally pulls it. |
| Browsh is slow on the first run | It starts a headless Firefox. Later runs are faster. |
| mpv shows no video | Launch it through `~/menutx/mpv.sh` (it adds `--vo=tct`), or pass `--vo=kitty` / `--vo=sixel` in a terminal that supports those protocols. |
| mpv or cmus has no sound | Check the sound server (`pactl info`, `wpctl status`) and ALSA (`aplay -l`). |
| chafa images look blocky | Use `-f kitty` or `-f sixels` in a supporting terminal; symbols mode is ANSI art by design. |
| micro: how do I save or quit? | Ctrl-S saves, Ctrl-Q quits. |
| Browsh is still installed after uninstalling menutx | Browsh is an apt package: `sudo apt remove browsh`. |
| `--no-deps` left mpv, cmus, chafa or micro missing | `sudo apt install mpv cmus chafa fzf micro`, or re-run the installer without `--no-deps`. |
| Browsh was skipped during installation | Check disk space and that `apt` works, then re-run `./install.sh`; `--no-browsh` skips it deliberately. |
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

The tools menutx downloads or installs are **not** covered by this license.
They are separate projects with their own licenses: the six `*watch` tools are
MIT, Browsh is LGPL-2.1, mpv is GPL-2.0-or-later, cmus is GPL-2.0, chafa is
LGPL-3.0 and micro is MIT. Firefox ESR, a Browsh dependency, is MPL-2.0.
menutx does not redistribute them; it downloads or installs them at install
time.

menutx is an unofficial launcher and is not affiliated with Matt Hartley or
the upstream projects. The tools run with elevated privileges when they need
to; review the upstream documentation before using them on production
machines.

---

[![](https://img.shields.io/badge/powered_by-dsh-4D6BFE?style=flat-square&logo=deepseek&logoColor=white)](https://github.com/deepseek-ai/deepseek-harness)
