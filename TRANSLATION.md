# Edriç translation

This fork is being translated from Prowide ISO 20022 into Edriç. The top-level `Mx.idric` module is the active user-facing entrypoint; the Java/JAXB tree is retained as a schema and behavior oracle while coverage moves to Edriç.

## Scope

Translate ISO 20022 message handling, not FINplus or SWIFT transport:

1. Business Application Header parsing/writing.
2. XML reading and writing without JAXB or DOM as architectural dependencies.
3. Typed MX models generated from ISO 20022 schema metadata.
4. Category coverage (`pacs`, `camt`, `pain`, and the remaining message families).
5. Exact decimal/currency representation; payment amounts must not be binary floating point.
6. MT ↔ MX translation together with the companion `prowide-core` Edriç API.

Java module boundaries are not Edriç module requirements. The 70+ JAXB-generated Gradle projects are schema/completeness input, not a module structure to hand-copy. The original XSD generator inputs are not present in this repository, so checked-in generated classes are the local extraction oracle.

## Current executable slice

`Mx.Identity` models the standard four-part MX identity and converts between `pacs.008.001.08` and its ISO 20022 Document namespace. The reader detects that identity from `Document`; the current dispatcher supports pacs.008.001.08 and rejects other message identities explicitly.

`Mx.Types` defines the first Business Application Header, exact textual currency amount, account-identification choice, credit-transfer subset, and pacs.008 data. The first transaction model now follows the generated schema on the fields it exposes: `EndToEndId`, `IntrBkSttlmAmt`, `ChrgBr`, debtor, debtor agent, creditor agent, and creditor are required; `InstrId`, debtor account, and creditor account are optional; account identifiers distinguish IBAN from `Othr`.

`Mx.Xml` writes a standalone `Document`, writes `AppHdr`, and only combines them when an explicit envelope root is supplied. `Mx.Read` locates `Document` and optional `AppHdr` independently of unrelated outer wrapper elements, decodes XML entities, reads the supported pacs.008 fields, and rejects an `AppHdr/MsgDefIdr` that disagrees with the `Document` identity.

`tests/MxTests.idric` fixes document and envelope output, exact money preservation, XML text/attribute escaping, identity parse/render, bare-document reading, wrapped-header reading, optional transaction fields, IBAN versus other-account choices, wrapper-independent payload detection, unsupported-message rejection, and header/document identity consistency.

The current pacs.008 type is intentionally not yet the complete XSD: notably, the generated `FIToFICustomerCreditTransferV08` contains one-or-more credit-transfer transactions and many additional optional transaction/header components.

Run:

```sh
make test
```

## Next generated slices

1. Resolve XML namespace prefixes as well as the current default-namespace form.
2. Generalize identity dispatch to generated pacs/camt/pain/etc. message tables.
3. Represent repeated `CdtTrfTxInf` transactions and then generate the remaining required/optional fields from checked-in JAXB metadata.
4. Generate shared ISO 20022 dictionary choices/records instead of hand-porting the `model-*` modules.
5. Replace string BIC/currency/account primitives with shared validated Edriç types from the Core translation.
6. Add MT ↔ MX translation acceptance cases once both message models share those primitives.
