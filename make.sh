#!/bin/bash
set -e

# Build fwupd (with FWUPD_TRACE instrumentation). Run from repo root.
# Usage:
#   ./make.sh              # install deps, configure, build
#   ./make.sh --no-deps    # skip installing dependencies
#   ./make.sh --tarball    # after build, also DESTDIR install and create fwupd-trace-install.tar

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

INSTALL_DEPS=1
CREATE_TARBALL=0
for arg in "$@"; do
  case "$arg" in
    --no-deps)   INSTALL_DEPS=0 ;;
    --tarball)   CREATE_TARBALL=1 ;;
    *) echo "Unknown option: $arg"; echo "Usage: $0 [--no-deps] [--tarball]"; exit 1 ;;
  esac
done

# --- Install build dependencies ---
if [ "$INSTALL_DEPS" -eq 1 ]; then
  echo "== Installing build dependencies =="
  if command -v dnf &>/dev/null; then
    if dnf builddep fwupd -y 2>/dev/null; then
      echo "Installed deps via: dnf builddep fwupd"
    else
      sudo dnf install -y meson ninja-build gcc gcc-c++ \
        glib2-devel libxmlb-devel libjcat-devel libcurl-devel sqlite-devel \
        libgusb-devel polkit-devel libcbor-devel \
        libarchive-devel libgcab-devel libgudev-devel \
        libxml2-devel json-glib-devel libsoup-devel \
        systemd-devel libelf-devel
    fi
  elif command -v yum &>/dev/null; then
    sudo yum install -y meson ninja-build gcc gcc-c++ \
      glib2-devel libxmlb-devel libjcat-devel libcurl-devel sqlite-devel \
      libgusb-devel polkit-devel libcbor-devel \
      libarchive-devel libgcab-devel libgudev-devel \
      libxml2-devel json-glib-devel libsoup-devel \
      systemd-devel libelf-devel
  elif command -v apt-get &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y meson ninja-build build-essential \
      libglib2.0-dev libxmlb-dev libjcat-dev libcurl4-gnutls-dev libsqlite3-dev \
      libgusb-2.0-dev libpolkit-gobject-1-dev libcbor-dev \
      libarchive-dev libgcab-dev libgudev-1.0-dev \
      libxml2-dev libjson-glib-dev libsoup2.4-dev \
      libsystemd-dev libelf-dev pkg-config
  else
    echo "No dnf/yum/apt-get found. Install build deps manually and run with --no-deps"
    exit 1
  fi
fi

# --- Configure ---
echo "== Configuring =="
rm -rf build
meson setup build \
  --prefix=/usr \
  --libdir=lib64 \
  -Dsystemd=enabled

# --- Build ---
echo "== Building =="
ninja -C build

# --- Optional: staging install + tarball (relocatable under /opt) ---
if [ "$CREATE_TARBALL" -eq 1 ]; then
  echo "== Creating relocatable install tarball =="
  rm -rf build/install-staging build/build-opt
  mkdir -p build/build-opt
  meson setup build/build-opt \
    --prefix=/opt/fwupd-trace \
    --libdir=lib64 \
    -Dsystemd=disabled
  ninja -C build/build-opt
  DESTDIR="$REPO_ROOT/build/install-staging" ninja -C build/build-opt install
  ( cd build/install-staging && tar cvf ../fwupd-trace-install.tar opt )
  echo "Done. Tarball: build/fwupd-trace-install.tar (extracts to /opt/fwupd-trace, does not touch /usr)"
fi

echo "== Build complete =="
