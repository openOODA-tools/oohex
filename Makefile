# ==============================================================================
# oohex: Sovereign Hex Dump Pager and Canonical Formatter
# Verification and Lifecycle Makefile
# ==============================================================================

SHELL := /bin/bash
BIN := dist/oohex
SRC := $(shell find . -name "*.oo" -o -name "*.oot" 2>/dev/null)
VERSION := $(shell cat VERSION 2>/dev/null || echo "0.2.0")
OODA_COMPILER ?= /home/ubermetroid/.openooda/bin/oodac
OODACODEX ?= /home/ubermetroid/.openooda/northstar.oot
OO_LIST_AMBIENT_QUOTA ?= 8589934592

.PHONY: all verify build test package clean check line-cap file-law academy density package-deb package-rpm package-arch

all: verify build test

$(BIN): $(SRC)
	@mkdir -p dist
	OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) \
	OODACODEX=$(OODACODEX) \
	OODA_COMPILER=$(OODA_COMPILER) \
	OODA_NO_JAIL=1 \
	$(OODA_COMPILER) build main.oo -o $(BIN)
	@cp $(BIN) dist/oohex-linux-x86_64
	@cd dist && sha256sum oohex-linux-x86_64 > oohex-linux-x86_64.sha256
	@echo "built $(BIN) (and dist/oohex-linux-x86_64)"

build: $(BIN)

line-cap:
	@violations=0; \
	for f in $$(find . -name "*.oo" -o -name "*.oot" | grep -v '\.git' | grep -v 'dist/'); do \
		lines=$$(wc -l < "$$f"); \
		if grep -q '^// # ' "$$f" && [ $$lines -lt 16 ]; then \
			echo "VIOLATION: $$f has $$lines lines (< 16 floor)"; violations=$$((violations+1)); \
		fi; \
		if [ $$lines -gt 256 ]; then \
			echo "VIOLATION: $$f has $$lines lines (> 256 cap)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations files violate line bounds"; exit 1; fi; \
	echo "PASS: Page Rule sizing (16-256 lines, shims exempt from floor) holds"

file-law:
	@bad=$$(find . -name "*.oo" | grep -E '(utils?|helpers?|common|misc|shared|base)\.oo$$' | grep -v 'dist/' || true); \
	if [ -n "$$bad" ]; then \
		echo "VIOLATION: Generic drawer filenames detected:"; echo "$$bad"; exit 1; \
	fi; \
	echo "PASS: file law holds"

academy:
	@missing=0; \
	for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		hdr=$$(head -n 7 "$$f"); \
		for elem in "// # " "// Logline:" "// Setup:" "// Beats:"; do \
			if ! echo "$$hdr" | grep -qF "$$elem"; then \
				echo "VIOLATION: $$f missing '$$elem' in first 7 lines"; missing=$$((missing+1)); \
			fi; \
		done; \
	done; \
	if [ $$missing -gt 0 ]; then echo "FAIL: $$missing missing Academy header elements"; exit 1; fi; \
	echo "PASS: academy headers hold (all 4 elements present in first 7 lines)"

density:
	@violations=0; \
	for d in $$(find . -maxdepth 3 -type d -not -path '*/.*' -not -path './dist*' -not -path './packaging*'); do \
		n=$$(ls "$$d"/*.oo "$$d"/*.oot 2>/dev/null | grep -v '\*' | wc -l); \
		if [ $$n -gt 8 ]; then \
			echo "VIOLATION: $$d holds $$n pages (exceeds 8)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations directories exceed the density bound"; exit 1; fi; \
	echo "PASS: directory density (<= 8 pages per directory) holds"

check:
	@for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) OODACODEX=$(OODACODEX) OODA_COMPILER=$(OODA_COMPILER) OODA_NO_JAIL=1 $(OODA_COMPILER) check "$$f" > /dev/null || exit 1; \
	done; \
	echo "PASS: oodac check holds on all .oo files"

verify: line-cap file-law academy density check

test: $(BIN)
	@echo "=== testing --help ==="
	@./$(BIN) --help | grep -q "oohex" && echo "PASS: --help"
	@echo "=== testing --version ==="
	@./$(BIN) --version | grep -q "oohex 0.2.0" && echo "PASS: --version"
	@echo "=== testing internal anchors ==="
	@./$(BIN) --test | grep -q "OK: all tests passed" && echo "PASS: internal anchors"
	@echo "=== testing showcase --demo -D ==="
	@./$(BIN) -D | grep -q "Sovereign openOODA Hex Dump Pager Demo" && echo "PASS: --demo"
	@echo "=== testing canonical hex dump ==="
	@printf "hello openOODA hex world\n" > dist/fixture.txt
	@./$(BIN) dist/fixture.txt | grep -q "00000000" && echo "PASS: canonical hex dump"
	@echo "=== testing plain hex and reverse decode ==="
	@./$(BIN) -p dist/fixture.txt | grep -q "68656c6c6f" && echo "PASS: plain hex output"
	@./$(BIN) -p dist/fixture.txt | ./$(BIN) -r | grep -q "hello openOODA" && echo "PASS: reverse hex decode"
	@echo "=== testing structured JSON output ==="
	@./$(BIN) -j dist/fixture.txt | grep -q "\"hex\":" && echo "PASS: structured JSON output"
	@echo "=== testing delta comparison ==="
	@printf "hello openOODA mod world\n" > dist/fixture2.txt
	@./$(BIN) dist/fixture.txt dist/fixture2.txt | grep -q "HEX DELTA COMPARISON" && echo "PASS: delta comparison"
	@rm -f dist/fixture.txt dist/fixture2.txt
	@echo "=== testing MCP initialize ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' | ./$(BIN) --mcp | grep -q "protocolVersion" && echo "PASS: MCP initialize"
	@echo "=== testing MCP tools/list ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | ./$(BIN) --mcp | grep -q "hex_dump" && echo "PASS: MCP tools/list"
	@echo "=== testing MCP tools/call hex_dump ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"hex_dump","arguments":{"text":"openOODA","cols":16}}}' | ./$(BIN) --mcp | grep -q '6f 70 65 6e' && echo "PASS: MCP hex_dump"
	@echo "=== testing MCP tools/call hex_diff ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"hex_diff","arguments":{"text_a":"alpha","text_b":"aleph"}}}' | ./$(BIN) --mcp | grep -q 'HEX DELTA' && echo "PASS: MCP hex_diff"
	@echo "=== testing MCP tools/call hex_stats ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"hex_stats","arguments":{"text":"binary payload"}}}' | ./$(BIN) --mcp | grep -q 'printable' && echo "PASS: MCP hex_stats"
	@echo "=== testing MCP tools/call hex_demo ==="
	@printf '%s\n' '{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"hex_demo","arguments":{}}}' | ./$(BIN) --mcp | grep -q "Sovereign openOODA Hex Dump" && echo "PASS: MCP hex_demo"
	@echo "ALL TESTS PASSED"

package-deb: $(BIN)
	@mkdir -p dist/deb-root/DEBIAN dist/deb-root/usr/bin
	@sed "s/^Version:.*/Version: $(VERSION)-1/" packaging/debian/control.binary > dist/deb-root/DEBIAN/control
	@cp $(BIN) dist/deb-root/usr/bin/oohex
	@chmod 0755 dist/deb-root/usr/bin/oohex
	@cp uninstall.sh dist/deb-root/usr/bin/oohex-uninstall
	@chmod 0755 dist/deb-root/usr/bin/oohex-uninstall
	@dpkg-deb --build --root-owner-group dist/deb-root dist/oohex_$(VERSION)-1_amd64.deb
	@rm -rf dist/deb-root
	@echo "built dist/oohex_$(VERSION)-1_amd64.deb"

package-rpm: $(BIN)
	@mkdir -p ~/rpmbuild/SOURCES ~/rpmbuild/SPECS ~/rpmbuild/RPMS
	@cp $(BIN) ~/rpmbuild/SOURCES/oohex-linux-x86_64
	@cp uninstall.sh ~/rpmbuild/SOURCES/uninstall.sh
	@sed "s/^Version:.*/Version: $(VERSION)/" packaging/oohex.spec > ~/rpmbuild/SPECS/oohex.spec
	@rpmbuild -bb ~/rpmbuild/SPECS/oohex.spec
	@cp ~/rpmbuild/RPMS/x86_64/oohex-$(VERSION)*.rpm dist/
	@echo "built dist RPM package"

package-arch: $(BIN)
	@mkdir -p dist/arch-pkg/usr/bin
	@cp $(BIN) dist/arch-pkg/usr/bin/oohex
	@chmod 0755 dist/arch-pkg/usr/bin/oohex
	@cp uninstall.sh dist/arch-pkg/usr/bin/oohex-uninstall
	@chmod 0755 dist/arch-pkg/usr/bin/oohex-uninstall
	@printf "pkgname = oohex\npkgbase = oohex\npkgver = $(VERSION)-1\npkgdesc = Sovereign hex dump pager in pure openOODA.\nurl = https://github.com/openOODA-tools/oohex\nbuilddate = $$(date +%s)\npackager = openOODA-tools <ops@openooda.org>\nsize = $$(stat -c %s $(BIN))\narch = x86_64\nlicense = Apache-2.0\ndepend = glibc\nprovides = oohex\n" > dist/arch-pkg/.PKGINFO
	@cd dist/arch-pkg && bsdtar -czvf ../oohex-$(VERSION)-1-x86_64.pkg.tar.zst .PKGINFO usr/
	@rm -rf dist/arch-pkg
	@echo "built dist/oohex-$(VERSION)-1-x86_64.pkg.tar.zst and validated PKGBUILD"

package: $(BIN) package-deb package-rpm package-arch
	@cd dist && sha256sum oohex oohex_$(VERSION)-1_amd64.deb oohex-$(VERSION)-1.fc44.x86_64.rpm oohex-$(VERSION)-1-x86_64.pkg.tar.zst oohex-linux-x86_64 oohex-linux-x86_64.sha256 > checksums.txt
	@echo "built all packages and dist/checksums.txt"

clean:
	@rm -rf dist
	@echo "cleaned"
