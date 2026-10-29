# wam — Run Multiple WhatsApp Instances on Linux (Android in Docker)

Run **several WhatsApp accounts side by side on one Linux PC**. Each account lives in its own lightweight Android container (powered by [Redroid](https://github.com/remote-android/redroid-doc)) with its own phone number, login and storage. You register each one like on a normal phone (SMS or call code).

```bash
wam create 1-5                          # make 5 Android instances (uses no RAM yet)
wam install ~/Downloads/WhatsApp.apkm   # install WhatsApp in all of them
wam open 1                              # start instance 1 and open WhatsApp
wam stop                                # stop everything (logins are kept)
```

Tested on Ubuntu 24.04 (x86_64).

> **Please read [Limitations & responsible use](#limitations--responsible-use) first.** WhatsApp can detect emulators and may restrict numbers. This project can't guarantee otherwise.

---

## Requirements

| Need | Details |
|---|---|
| OS | Ubuntu / Debian x86_64 (other distros work if you install the packages yourself) |
| Kernel | must support **binder** (stock Ubuntu kernels do) |
| RAM | **~1.5–2 GB per running instance.** 12 GB → comfortable max **5** at once |
| Disk | ~1 GB for the image + ~1 GB per instance |
| Phone numbers | one real number **per instance**, able to receive an SMS or call |

Instances you aren't using are *stopped* and use **zero RAM**, so you can create 10 and run only a few at a time.

## Quick start

```bash
git clone https://github.com/YOUR_USERNAME/whatsapp-multi-instance.git
cd whatsapp-multi-instance
./install.sh            # installs docker, adb, scrcpy + the wam command
```

**Log out and back in** (or run `newgrp docker`), then:

```bash
wam doctor              # checks everything; fix any [FAIL] line
wam pull                # downloads the Android image (~850 MB, auto-retries)
wam create 1-3          # create three instances
```

Download the WhatsApp installer — see **[docs/GET-THE-APK.md](docs/GET-THE-APK.md)** (about 2 minutes) — then:

```bash
wam install ~/Downloads/com.whatsapp_XXXX.apkm 1 2 3
wam open 1
```

In the window: accept the terms, tap **OK** on the "custom ROM" notice, choose country, enter **that instance's number**, enter the code. Repeat for each instance, using a different number each time.

## Commands

| Command | What it does |
|---|---|
| `wam doctor` | checks docker, adb, scrcpy, binder, RAM, image |
| `wam pull` | downloads the Android image, retrying if the connection drops |
| `wam create <n…\|a-b\|all>` | creates instances (stopped) |
| `wam install <file> [n…\|all]` | installs WhatsApp (`.apk`, `.apkm`, `.xapk`) |
| `wam open <n…>` | starts instance, opens its window, launches WhatsApp |
| `wam start <n…\|all>` | starts without a window |
| `wam stop [n…\|all]` | stops instances; **no argument stops everything**. Data kept |
| `wam list` | shows instances, state and adb port |
| `wam ram` | live memory/CPU per running instance |
| `wam logs <n>` / `wam shell <n>` | debugging helpers |
| `wam remove <n>` | permanently deletes an instance **and its WhatsApp login** (asks first) |

Instance `N` = container `waN`, adb port `5554+N` (instance 1 → 5555), data in `~/redroid/waN`.

### Examples

```bash
wam open 1 2 3        # three windows
wam open 4            # one more
wam stop 2            # close just #2
wam stop              # close all (nothing is lost)
```

Closing a window only hides the screen. The instance keeps running and using RAM until you `wam stop` it.

## Safety limits

`wam` protects your PC from freezing:

- refuses to start an instance if **less than 2500 MB RAM** is free
- refuses to run more than **5 at once**

Change them in `~/.config/wam.conf` or with env vars:

```bash
WAM_MAX_RUNNING=6
WAM_MIN_FREE_MB=2000
WAM_COUNT=10                 # what "wam create all" makes
WAM_DIR="$HOME/redroid"      # where data lives
WAM_WIDTH=720 WAM_HEIGHT=1280 WAM_DPI=320
WAM_FORCE=1 wam open 6       # ignore the limits once
```

ADB ports are bound to `127.0.0.1` only, so nobody on your network can reach your Android instances.

## How it works

Each instance is a Docker container running the Redroid Android 13 image, started with `--privileged` so it can use the host kernel's binder driver. `wam` creates the containers, installs the APK bundle with `adb install-multiple`, waits for `sys.boot_completed`, shows the screen with `scrcpy`, and launches `com.whatsapp`.

## Troubleshooting

Full list: **[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)**. Most common:

| Problem | Fix |
|---|---|
| `permission denied ... docker.sock` | `sudo usermod -aG docker $USER`, then log out/in or `newgrp docker` |
| Image download "connection reset" | `wam pull` retries automatically |
| `INSTALL_PARSE_FAILED_NOT_APK` | the file is a web page, not an APK. See GET-THE-APK |
| "You have a custom ROM installed" | just a notice, tap **OK** |
| WhatsApp icon missing on home screen | it's in the app drawer, or run `wam open N` |
| Can't create instance 2+: permission denied on `~/redroid` | `sudo chown $USER:$USER ~/redroid` |

## Limitations & responsible use

- **Emulator detection.** WhatsApp doesn't officially support emulators. Registration may fail, codes may not arrive, or a number may be restricted later. No setting here can promise otherwise.
- **One number, one device.** Registering a number here logs it out of your real phone.
- **Real numbers only.** Virtual and temporary numbers are frequently blocked.
- **Space out registrations.** Registering many new accounts from one IP in a short time looks suspicious.
- **No spam, no bulk messaging, no automation.** This tool exists for people who legitimately need several accounts (work/personal, multiple businesses, testing). Misuse violates WhatsApp's Terms and gets numbers banned.
- No Google Play Services are included. WhatsApp works without them for basic use.
- This project is not affiliated with Meta, WhatsApp, or Redroid. WhatsApp is a trademark of its owners. You must download the app yourself; no WhatsApp files are distributed here.

## Backup

Instance data is plain folders in `~/redroid/waN` (owned by root). Back up with `sudo tar czf wa1.tgz -C ~/redroid wa1` with the instance stopped.

## Contributing

Issues and PRs welcome. Run `bash -n bin/wam` before submitting.

## License

MIT, see [LICENSE](LICENSE).
