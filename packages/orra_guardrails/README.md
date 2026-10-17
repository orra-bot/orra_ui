# orra_guardrails

Static checks that keep an [orra_ui](https://github.com/orra-bot/orra_ui) codebase honest. They run inside your normal `flutter test`.

- **Token layers.** Only primitives may contain color, duration, curve, or font-weight literals. The semantic layer references primitives only. Component code never hard-codes sizes and never reads brightness.
- **No raw widgets.** No Material or Cupertino imports anywhere. App code must not use unwrapped primitives such as `EditableText`, `RawMenuAnchor`, `RawTooltip`, or `showGeneralDialog`.
- **No dead tokens.** Every primitive value must be referenced somewhere.

See `example/test/guardrails_test.dart` in the repository for a complete setup.
