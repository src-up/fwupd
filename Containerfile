# Build fwupd trace tarball in a RHEL 10–matching environment.
# Run from fwupd repo root:
#   docker build -f Containerfile -t fwupd-trace-builder .
#   docker run --rm -v "$(pwd)":/fwupd fwupd-trace-builder
# Tarball ends up in ./build/fwupd-trace-install.tar
#
# If UBI misses packages, use: FROM rockylinux:10 (or your RHEL 10 image).

FROM registry.access.redhat.com/ubi10/ubi

RUN dnf install -y \
    meson ninja-build gcc gcc-c++ \
    glib2-devel libxmlb-devel libjcat-devel libcurl-devel sqlite-devel \
    libgusb-devel polkit-devel libcbor-devel \
    libarchive-devel libgcab-devel libgudev-devel \
    libxml2-devel json-glib-devel libsoup-devel \
    systemd-devel libelf-devel \
    && dnf clean all

WORKDIR /fwupd
CMD ["./make.sh", "--no-deps", "--tarball"]
