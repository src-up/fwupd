# Build fwupd trace tarball in a RHEL 10–matching environment.
# Run from fwupd repo root:
#   docker build -f Containerfile -t fwupd-trace-builder .
#   docker run --rm -v "$(pwd)":/fwupd fwupd-trace-builder
# Tarball ends up in ./build/fwupd-trace-install.tar
#
# UBI 10 lacks many -devel packages in its repos (libxmlb-devel, libjcat-devel, etc.),
# so the dnf install step fails. Use an image with full repos instead.
# FROM registry.access.redhat.com/ubi10/ubi
#
# CentOS Stream 10 = RHEL 10 preview, full repos.

FROM quay.io/centos/centos:stream10

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
