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

`Mx.Types` defines the first Business Application Header, exact textual currency amount, credit-transfer, and pacs.008 data. `Mx.Xml` writes a standalone `Document`, writes `AppHdr`, and only combines them when an explicit envelope root is supplied. `Mx.Read` locates `Document` and optional `AppHdr` independently of outer wrapper elements, checks the pacs.008.001.08 document namespace, decodes XML entities, and reads the supported pacs.008 fields into typed data. `tests/MxTests.idric` fixes document and envelope output, exact money preservation, XML escaping, bare-document reading, wrapped-header reading, and wrapper-independent payload detection.

The current pacs.008 record is intentionally a first supported subset, not yet a claim of complete XSD validity for every required/optional pacs.008.001.08 component.

Run:

```sh
make test
```

The next correctness milestone is namespace/version dispatch plus schema-derived generation of required/optional fields and additional message types. After that, replace string BIC/account/currency values with shared validated Edriç types and add MT ↔ MX translation against the companion `prowide-core` API.
