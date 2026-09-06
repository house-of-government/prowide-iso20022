# Edriç translation

This fork is being translated from Prowide ISO 20022 into Edriç. The top-level `Mx.idric` module is the active user-facing entrypoint; the Java/JAXB tree is retained as a schema and behavior oracle while coverage moves to Edriç.

## Scope

Translate ISO 20022 message handling, not FINplus or SWIFT transport:

1. Business Application Header parsing/writing.
2. XML reading and writing without JAXB or DOM as architectural dependencies.
3. Typed MX models generated from ISO 20022 schema metadata.
4. Category coverage (`pacs`, `camt`, `pain`, and the remaining message families).
5. Exact decimal/currency representation; payment amounts must not be binary floating point.
6. Shared domain primitives with the companion `prowide-core` Edriç API.
7. MT ↔ MX translation only after the message-side models and shared primitives are independently stable.

Java module boundaries are not Edriç module requirements. The 70+ JAXB-generated Gradle projects are schema/completeness input, not a module structure to hand-copy. The original XSD generator inputs are not present in this repository, so checked-in generated classes are the local extraction oracle.

## Shared identifier boundary

This draft depends on the Core draft's `PaymentIdentifiers` Edriç module rather than reproducing BIC/account classes locally. The dependency is deliberately narrow: MX imports the domain values and parsers, not MT message types, FIN parsing, Java classes, or JAXB-generated structures.

MX uses the shared boundary as follows:

- `AppHdr/Fr/.../BICFI`, `AppHdr/To/.../BICFI`, `DbtrAgt/.../BICFI`, and `CdtrAgt/.../BICFI` parse to `Bic`.
- `IBAN` parses to `IbanAccount Account`; `Othr/Id` parses to `OtherAccount Account`.
- XML writing obtains exact text with `bic_text` and `account_text`.
- A 12-character FIN logical-terminal address is refused in `BICFI`; the fixture values are therefore 11-character BICs (`BANKBEBBXXX`, `BANKDEFFXXX`) rather than LT addresses.

The shared BIC check is structural, not a BIC Directory lookup. The account boundary rejects empty or multiline identifiers but deliberately does not yet claim IBAN checksum/country-length validation. No MT field is mapped to an MX field in this slice.

Public BIC structure reference: `https://www.swift.com/standards/data-standards/bic-business-identifier-code`.

## Current executable slice

`Mx.Identity` models the standard four-part MX identity and converts between `pacs.008.001.08` and its ISO 20022 Document namespace. The reader detects that identity from `Document`; the current dispatcher supports pacs.008.001.08 and rejects other message identities explicitly.

`Mx.Types` defines the first Business Application Header, exact textual currency amount, shared account-identification choice, credit-transfer subset, and pacs.008 data. The first transaction model now follows the generated schema on the fields it exposes: `EndToEndId`, `IntrBkSttlmAmt`, `ChrgBr`, debtor, debtor agent, creditor agent, and creditor are required; `InstrId`, debtor account, and creditor account are optional; account identifiers preserve IBAN versus `Othr`.

`Mx.Xml` writes a standalone `Document`, writes `AppHdr`, and only combines them when an explicit envelope root is supplied. `Mx.Read` locates `Document` and optional `AppHdr` independently of unrelated outer wrapper elements, decodes XML entities, reads the supported pacs.008 fields, validates BICFI through the shared boundary, and rejects an `AppHdr/MsgDefIdr` that disagrees with the `Document` identity.

`tests/MxTests.idric` fixes document and envelope output, exact money preservation, XML text/attribute escaping, identity parse/render, bare-document reading, wrapped-header reading, shared BIC/account behavior, invalid-BIC refusal, optional transaction fields, wrapper-independent payload detection, unsupported-message rejection, and header/document identity consistency.

The current pacs.008 type is intentionally not yet the complete XSD: notably, the generated `FIToFICustomerCreditTransferV08` contains one-or-more credit-transfer transactions and many additional optional transaction/header components.

Run:

```sh
make test
```

For the two draft PRs, CI checks out the Core `edric-translation` head, builds and installs `prowide_core_edric`, and then compiles this package against it. After the Core boundary lands on `main`, this temporary draft-branch reference should move to `main`.

## Next generated slices

1. Resolve XML namespace prefixes as well as the current default-namespace form.
2. Generalize identity dispatch to generated pacs/camt/pain/etc. message tables.
3. Represent repeated `CdtTrfTxInf` transactions and then generate the remaining required/optional fields from checked-in JAXB metadata.
4. Generate shared ISO 20022 dictionary choices/records instead of hand-porting the `model-*` modules.
5. Add full IBAN validation in the shared boundary without guessing an IBAN from untyped FIN account text.
6. Add MT ↔ MX translation acceptance cases only after both sides expose independently tested semantic values.
