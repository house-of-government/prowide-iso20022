IDRIC ?= idris2
IDRIC_SOURCES := $(wildcard Mx/*.idric tests/*.idric) Mx.idric

.PHONY: all test check-vocabulary clean

all: check-vocabulary
	$(IDRIC) --build prowide-iso20022.ipkg

check-vocabulary:
	@if grep -nE '(^|[^[:alnum:]_])Nat([^[:alnum:]_]|$$)' $(IDRIC_SOURCES); then \
		echo 'error: active Edriç source must use ℕ for natural numbers' >&2; \
		exit 1; \
	fi
	@if grep -nE '(^|[^[:alnum:]_])(Double|Float64)([^[:alnum:]_]|$$)' $(IDRIC_SOURCES); then \
		echo 'error: ISO 20022 amounts must not use binary floating point' >&2; \
		exit 1; \
	fi

test: all
	$(IDRIC) -p prowide_identifiers_edric tests/MxTests.idric -o prowide-iso20022-edric-tests
	./build/exec/prowide-iso20022-edric-tests

clean:
	rm -rf build
