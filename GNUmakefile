.PHONY: pre-hook
pre-hook: lint fmt

.PHONY: lint
lint:
	cargo clippy

.PHONY: fmt
fmt:
	cargo fmt

.PHONY: gen
gen:
	cargo run --bin ift-cli -- rfc 6890 | pbcopy

.PHONY: test
test:
	cargo run --bin ift-cli -- eval 'GetInterfaceIP "lo0" | FilterIPv4'
	cargo run --bin ift-cli -- eval 'GetAllInterfaces | FilterForwardable'
	cargo run --bin ift-cli -- eval 'GetAllInterfaces | FilterGlobal'
