ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
RFC_6890_TXT := $(ROOT_DIR)/ift-gen/src/rfc6890_entries.txt
RFC_6890_ENTRIES_RS := $(ROOT_DIR)/src/rfc/rfc6890_entries.rs

.PHONY: pre-hook
pre-hook: lint fmt fix

.PHONY: lint
lint:
	cargo clippy

.PHONY: fix
fix:
	cargo fix --edition-idioms --broken-code

.PHONY: fmt
fmt:
	cargo +nightly fmt --all

.PHONY: download
download:
	curl -s https://tools.ietf.org/rfc/rfc6890.txt > $(RFC_6890_TXT)

.PHONY: gen-rfc-6890
gen-rfc-6890:
# first create a dummy file
	echo "use crate::rfc::WithRfc6890;" > $(RFC_6890_ENTRIES_RS)
	echo "pub fn entries() -> WithRfc6890 { WithRfc6890 { entries: vec![] }}" >> $(RFC_6890_ENTRIES_RS)

# then write the real one to a tmp loc
	echo "use crate::rfc::WithRfc6890;" > $(RFC_6890_ENTRIES_RS).tmp
	echo "use crate::rfc::Rfc6890Entry;" >> $(RFC_6890_ENTRIES_RS).tmp
	echo "pub fn entries() -> WithRfc6890 { WithRfc6890 { entries: vec![" >> $(RFC_6890_ENTRIES_RS).tmp
	cargo run -p ift-gen -- rfc 6890 >> $(RFC_6890_ENTRIES_RS).tmp
	echo "]}}" >> $(RFC_6890_ENTRIES_RS).tmp

# then move it into the correct loc
	mv $(RFC_6890_ENTRIES_RS).tmp $(RFC_6890_ENTRIES_RS)

.PHONY: gen
gen: download gen-rfc-6890 fmt

.PHONY: update
update:
	cargo readme > README.md

.PHONY: test
test:
	cargo test

.PHONY: dev-tools
dev-tools:
	rustup install nightly
	rustup component add rustfmt --toolchain nightly
	rustup component add clippy
	cargo install cargo-release
	cargo install cargo-readme

.PHONY: clean
clean:
	cargo clean

