# xTS Docker (STICK)

Image `cavli-test-docker:stick_testtools` holds:

| In image | From (in `targets/stick/`) |
|---|---|
| `/opt/workspace/cts/android-cts/` | CTS with the VSDK test cases, unzipped to `android-cts-tools/` |
| `/opt/workspace/vts/android-vts/` | VTS, unzipped to `android-vts-tools/` |
| `/etc/docker_image_version` | Version string in `targets/stick/Dockerfile` |

All commands below run from the `xTS_docker/` folder unless the step says otherwise.

---

## Release a new version

Before you start, build CTS with VSDK in the AOSP tree
`/home/alvin/workspaces/002/cavli/projects/cts/cts-aosp`. The steps for that are in
`cqs29x-iot_jabil_platform_cts/tests/vsdk/README.md`.

`targets/stick/packages/android-cts.zip` is a symlink to
`cts-aosp/out/host/linux-x86/cts/android-cts.zip`, so the new build is used
without copying it.

A release needs about 75 GB of free disk space: 13 GB to unzip, then 24 GB each
for the image and the `.tar`, then 15 GB for the `.zip`. Check with `df -h .`.

### 1. Set the version

```bash
VER=STICK-LA5.0_CTS-14-R14_VSDK-8886a665_MEDIA-1.5_VTS-R22
```

| Part | Meaning |
|---|---|
| `STICK-LA5.0` | Device and LA release |
| `CTS-14-R14` | AOSP tag `android-cts-14.0_r14` |
| `VSDK-8886a665` | Commit of `jabil-vsdk-testcases` merged into the CTS branch (`git -C ../../cts-aosp/cts log -1 --format=%h HEAD^2`) |
| `MEDIA-1.5` | CTS media package version |
| `VTS-R22` | VTS package (`android-vts-LA5.0-R22.zip`) |

### 2. Unzip the packages

```bash
cd targets/stick/packages

# CTS
rm -rf ../android-cts-tools/android-cts
unzip -q -d ../android-cts-tools android-cts.zip

# VTS: only if the VTS package changed
# rm -rf ../android-vts-tools/android-vts
# unzip -q -d ../android-vts-tools android-vts-LA5.0-R22.zip

cd -
```

Check:

```bash
cat targets/stick/android-cts-tools/android-cts/tools/version.txt   # date of the new build
ls targets/stick/android-cts-tools/android-cts/testcases | grep -E 'CLDemo|DeskTop'   # VSDK modules
```

### 3. Write the version into the Dockerfile

```bash
sed -i -E "s#^(RUN echo \")[^\"]+(\" > /etc/docker_image_version)#\1${VER}\2#" targets/stick/Dockerfile
grep docker_image_version targets/stick/Dockerfile
```

### 4. Build the image

```bash
docker-compose build --no-cache stick
```

Also build `base` first (`docker-compose build --no-cache base`), but only if
something in `base/` changed. `cmds/build.sh` always builds both images.

### 5. Check the image

```bash
IMG=cavli-test-docker:stick_testtools
docker run --rm --entrypoint cat $IMG /etc/docker_image_version             # = $VER
docker run --rm --entrypoint cat $IMG /opt/workspace/cts/android-cts/tools/version.txt
docker run --rm --entrypoint ls  $IMG /opt/workspace/cts/android-cts/testcases | grep -E 'CLDemo|DeskTop'
```

### 6. Save and pack

```bash
OUT=release/deloy/$VER
mkdir -p $OUT /home/alvin/documents/.docker-tmp
bash cmds/save.sh $OUT ./targets/stick/Dockerfile stick_testtools
cp release/load_docker.sh release/run_docker.sh $OUT/
(cd release/deloy && zip -r $VER.zip $VER)
```

Send `release/deloy/$VER.zip` to the customer. `release/deloy/` is not tracked
by git. Delete old releases there when you no longer need them.

### 7. Commit

```bash
git add targets/stick/Dockerfile
git commit -m "xTS_docker: release $VER"
```

---

## On the customer machine

```bash
unzip <VER>.zip && cd <VER>
bash load_docker.sh docker-<VER>.tar           # add --force to replace an existing image
bash run_docker.sh                             # creates or starts container cavli-test-cts and opens a shell
cat /etc/docker_image_version                  # inside the container
```

---

## Reference

### save.sh

```bash
bash cmds/save.sh <output_dir> [Dockerfile_path] [image_tag]
```

- Reads the version from `RUN echo "VERSION" > /etc/docker_image_version` in the Dockerfile.
- Writes `<output_dir>/docker-<VERSION>.tar`. An existing file is overwritten.
- Stops if the output folder, the Dockerfile, or the image does not exist.
- First writes the `.tar` to `DOCKER_SAVE_TMPDIR` (default `/home/alvin/documents/.docker-tmp`), then moves it. This avoids "no space left" errors on the output disk. To use another folder:
  `DOCKER_SAVE_TMPDIR=/mnt/other-disk bash cmds/save.sh ...`

### Run, attach, and stop (local)

```bash
docker-compose up -d stick              # cmds/run.sh
docker exec -it stick_testtools bash
docker-compose stop stick               # cmds/stop.sh
```

If `up` fails because an old container exists:

```bash
docker ps -a                            # find the container name
docker rm -f <NAME>
```

### Images and cleanup

```bash
docker images                           # list images
docker system df                        # disk usage
docker rmi <ID>                         # remove an image
docker builder prune -a                 # remove build cache
docker-compose down --volumes           # remove the compose stack and its volumes
docker system prune -af --volumes       # remove ALL unused containers, images, networks, volumes
```

### Setup

```bash
sudo apt update
sudo apt install docker-compose-plugin  # cmds/env.sh
```
