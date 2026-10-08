Name:           oohex
Version:        0.2.0
Release:        1%{?dist}
Summary:        Color-coded hexadecimal viewer with canonical ASCII sidebar and delta highlighting.
License:        ASL 2.0
URL:            https://github.com/openOODA-tools/oohex
Source0:        oohex-linux-x86_64
Source1:        uninstall.sh
BuildArch:      x86_64
Requires:       glibc

%description
oohex is a sovereign, capability-bounded HEX DUMP PAGER written
in pure openOODA, featuring zero ambient authority, semantic byte colors,
delta diffing, and an MCP stdio server.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/oohex
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/oohex-uninstall

%files
/usr/bin/oohex
/usr/bin/oohex-uninstall

%changelog
* Thu Oct 08 2026 openOODA-tools <ops@openooda.org> - 0.2.0-1
- Sovereign native openOODA hex dump pager with MCP parity
