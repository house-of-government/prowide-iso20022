# Edriç translation

This fork is being translated from Prowide ISO 20022 into Edriç. The top-level `Mx.idric` module is the active user-facing entrypoint; the Java/JAXB tree is retained as a schema and behavior oracle while coverage moves to Edriç.

## Scope

Translate ISO 20022 message handling, not FINplus or SWIFT transport:

1. Business Application Header parsing/writing.
2. XML reading and writing without JAXB or DOM as architectural dependencies.
3. Typed MX models generated from ISO 20022 XSD/schema metadata.
4. Category coverage (`pacs`, `camt`, `pain`, and the remaining message families).
5. Exact decimal/currency representation; payment amounts must not be binary floating point.
6. MT ↔ MX translation together with the companion `prowide-core` Edriç API.

Java module boundaries are not Edriç module requirements. In particular, the 70+ JAXB-generated Gradle projects should become generated Edriç schema/model data rather than 70+ hand-maintained ports.

## Current executable slice

`Mx.Types` defines Business Application Header, exact currency amount, credit-transfer, and pacs.008 data. `Mx.Xml` writes the header and pacs.008 XML and escapes element text. `tests/MxTests.idric` fixes exact XML output, escaping, and textual decimal preservation.

Run:

```sh
make test
```

The next correctness milestone is `XML → model → XML` for the same pacs.008 fixture, followed by namespace/version dispatch and schema-derived generation of additional message types.
