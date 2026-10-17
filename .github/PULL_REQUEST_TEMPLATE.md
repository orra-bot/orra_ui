<!--
Thanks for contributing! Please read CONTRIBUTING.md first.
New components should be discussed in an issue before a PR is opened.
English or 中文 are both fine.
-->

## Summary

<!-- What does this change and why? -->

Closes #

## Type of change

- [ ] Bug fix
- [ ] New feature / component
- [ ] Token or theming change
- [ ] Window shell / platform integration
- [ ] Docs, tests, or tooling only
- [ ] Breaking change (public API or default token values change)

## Affected packages

- [ ] `orra_ui`
- [ ] `orra_desktop_shell`
- [ ] `orra_guardrails`
- [ ] `example` (gallery)

## How to verify

<!--
Which gallery page or test shows the change? For visual changes,
add before/after screenshots in light and dark mode.
-->

## Checklist

- [ ] `dart format --set-exit-if-changed .` and `flutter analyze` pass at the repository root
- [ ] Tests pass in every package I touched (`flutter test`, or `dart test` for `orra_guardrails`)
- [ ] Web-affected changes also pass `flutter test --platform chrome`
- [ ] New behavior is covered by tests that assert geometry or state, not screenshots
- [ ] No literals outside the primitive layer; guardrails tests still pass
- [ ] `CHANGELOG.md` of each affected package has an entry under **Unreleased**
- [ ] `README.md` and `README.zh-CN.md` are both updated if the public API or behavior changed
