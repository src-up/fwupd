# Build fwupd trace tarball in a RHEL 10–matching environment.
# Run from fwupd repo root:
#   podman build -f Containerfile -t fwupd-trace-builder .
#   podman run --rm -v "$(pwd)":/fwupd fwupd-trace-builder
# Tarball ends up in ./build/fwupd-trace-install.tar
#
# CentOS Stream 10: libcbor-devel is not in BaseOS, AppStream, CRB, or EPEL 10,
# so "dnf install" fails. Switched to UBI 10 + EPEL 10 to try that repo set.
# FROM quay.io/centos/centos:stream10
#
# UBI 10 (RHEL 10 userland) + EPEL 10.

FROM registry.access.redhat.com/ubi10/ubi

# EPEL 10 + CRB (CodeReady Builder); EPEL recommends "crb enable" for many packages.
RUN dnf install -y \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm \
    && crb enable \
    && dnf clean all

RUN dnf install -y \
    meson ninja-build gcc gcc-c++ \
    glib2-devel libxmlb-devel libjcat-devel libcurl-devel sqlite-devel \
    libgusb-devel polkit-devel libcbor-devel \
    libarchive-devel libgcab1-devel libgudev-devel \
    libxml2-devel json-glib-devel libsoup3-devel \
    systemd-devel elfutils-libelf-devel \
    && dnf clean all

WORKDIR /fwupd
CMD ["./make.sh", "--no-deps", "--tarball"]
