# Changelog for morpheus-med/saml2 fork

Our fork adds support for AD FS and other additions for Arterys IDP integration.

## List of changes
### [PR: Rebase all relevant Arterys changes up to Oct 2023 with the latest saml2 upstream v4.0.2](https://github.com/morpheus-med/saml2/pull/7)
- Attach saml namespace definition before stringifying the document and losing this information https://github.com/morpheus-med/saml2/commit/af47d22b62415b780964ea069e8bb259cc45615a
- Adds assert.user.name_id_format to the output https://github.com/morpheus-med/saml2/commit/06374e5b0f3758336ee626c3b9a05165933419f7, https://github.com/morpheus-med/saml2/commit/09f4521b128ca3e97fa8c57415c46a9c4422aacc
- Add phone numbers to assertion map https://github.com/morpheus-med/saml2/commit/ccf92380cd208012a8f2df9d86590267e74b8f6b
- VWR-458 Fixes to support 3rd party IDPs
https://github.com/morpheus-med/saml2/pull/3 
- VWR-458 Fix query parameter
https://github.com/morpheus-med/saml2/pull/4 
- VWR-458 NameID Fixes
https://github.com/morpheus-med/saml2/pull/5 

### [PR: Update xml-crypto to v5, fix AD FS cert validation](https://github.com/morpheus-med/saml2/pull/8)

#### Problem
xml-crypto versions earlier than 5.0 throws an error on valid signed xml produced by an AD FS server (fails test 'accepts signed AD FS 2019 xml'):
```
Error: error:068000A8:asn1 encoding routines::wrong tag
      at Verify.verify (node:internal/crypto/sig:230:24)
      at RSASHA256.verifySignature (node_modules/xml-crypto/lib/signed-xml.js:116:24)
      at SignedXml.validateSignatureValue (node_modules/xml-crypto/lib/signed-xml.js:442:20)
```

#### Changes
1. Update xml-crypto to latest 5.0 release
1. `xml-crypto` no longer exports `xpath`, so we add it as a dependency and its call signature changes from `xpath(doc, xpath)` to `xpath.select(xpath, doc)`

Also addresses the following xml-crypto 5.0 breaking changes https://github.com/node-saml/xml-crypto/blob/master/CHANGELOG.md
- [documentation] [breaking-change] Expand the options, move idmode into options, fix types #323
- [documentation] [breaking-change] Remove default for transformation algorithm #410
- [breaking-change] Remove default for signature algorithm #408
- [breaking-change] Remove default for digest algorithm #406
- [breaking-change] Remove default canonicalization algorithm #405
- [breaking-change] Rename signingCert -> publicCert and signingKey -> privateKey #315
- [semver-major] [breaking-change] Add support for in ; remove KeyInfoProvider #301
- 5.0.0 [chore] Improve and simplify validation logic #373, https://github.com/node-saml/xml-crypto/pull/373 Now throws instead of just returning null on Error: invalid signature: the signature value ${this.signatureValue} is incorrect
   
With:
1. Replace `new SignedXML null, options` with `new SignedXML options`
1. Add default digestAlgorithm, signatureAlgorithm, and transformationAlgorithm, canonicalizationAlgorithm
1. `sig.keyInfoProvider = getKey: -> format_pem(certificate, 'CERTIFICATE')` becomes `sig.publicCert = format_pem(certificate, 'CERTIFICATE')`
1. Wrap sig.checkSignatureValue in try/catch

