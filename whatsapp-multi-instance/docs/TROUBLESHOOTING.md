# Troubleshooting

Start with `wam doctor`. It checks most of this automatically.

## Docker

**`permission denied while trying to connect to the docker API`**
Your user isn't in the docker group in this terminal.
```bash
sudo usermod -aG docker $USER
newgrp docker          # this terminal only; log out/in for all terminals
```

**`Unable to locate package ...` / apt aborts**
Remove any package that doesn't exist for your kernel (like `linux-modules-extra-<your kernel>`); one missing package makes apt install nothing. `./install.sh` doesn't need it.

**`docker.service does not exist`**
Docker wasn't installed because the earlier apt command failed. Run `./install.sh` again.

**Image download: `read: connection reset by peer`**
Network hiccup. `wam pull` retries until done. If it keeps failing, limit parallel downloads:
```bash
echo '{"max-concurrent-downloads": 1}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
wam pull
```
Or download once on a hotspot. The image is cached afterwards.

## Kernel / binder

**Container exits immediately, logs mention binder**
```bash
grep binder /proc/filesystems        # "nodev binder" = good (binderfs)
modinfo binder_linux                 # module available?
sudo modprobe binder_linux devices="binder,hwbinder,vndbinder"
```
If neither works, your kernel lacks binder. Install the stock Ubuntu kernel (`sudo apt install linux-generic`), reboot, and choose it under *Advanced options* in GRUB.

**Waydroid installed?**
It also uses binder. Stop it before using wam: `waydroid session stop`.

## Permissions

**`mkdir: cannot create directory ‘~/redroid/wa2’: Permission denied`**
Docker created `~/redroid` as root. Fix just the top folder (not `-R`, the instance data must stay root-owned):
```bash
sudo chown $USER:$USER ~/redroid
```

## adb / scrcpy

**`Connection refused` on adb connect**
The container is still booting, or isn't running. `wam open N` waits for boot automatically; check `wam list` and `wam logs N`.

**`device offline` / `device not found`**
```bash
adb kill-server && adb start-server
wam stop N && wam open N
```

**scrcpy: `Could not find any ADB device`**
Same cause: not booted yet. Use `wam open`, which waits.

## Installing WhatsApp

| Error | Meaning / fix |
|---|---|
| `INSTALL_PARSE_FAILED_NOT_APK` | file is a web page. See [GET-THE-APK](GET-THE-APK.md) |
| `INSTALL_FAILED_NO_MATCHING_ABIS` | you downloaded an ARM-only build. Get the **universal** one |
| `INSTALL_FAILED_MISSING_SPLIT` | partial bundle. `wam install` handles bundles; re-download the file |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | `wam shell N` then `pm uninstall com.whatsapp`, reinstall |

**I installed it but see no WhatsApp icon**
Redroid's home screen shows only default icons. Use `wam open N`, or tap the Android-robot icon in the bottom row to open the app drawer.

## WhatsApp itself

**"You have a custom ROM installed"** — informational. Tap OK.

**No SMS code** — wait for the countdown, choose *Call me*. Check the number works in a normal phone first.

**"Can't register on this device" / number restricted** — WhatsApp doesn't support emulators and can refuse them. It's outside this project's control. Try later, or use a different number.

**Logged out after a restart** — don't `docker rm` or `wam remove` an instance; use `wam stop`. Data is kept in `~/redroid/waN`.

## Performance

- Freezing laptop → run fewer instances. See `wam ram`.
- Lower the screen size for less load: `WAM_WIDTH=540 WAM_HEIGHT=960 WAM_DPI=240 wam create 6` (affects newly created instances).
- Close the scrcpy window of idle instances and `wam stop` them.
