## Unreleased

* More Base UI counterparts: `RaPopover` / `RaPopoverPanel` / `RaPopoverSurface`, `RaPreviewCard`, `RaCombobox`, `RaAutocomplete`, `RaSlider`, `RaNumberField`, `RaProgress`, `RaMeter`, `RaToggle`, `RaToggleGroup`, `RaToolbar` / `RaToolbarSeparator`, `RaAccordion`, `RaCheckboxGroup`, `RaFieldset`.
* New component tokens: `popover`, `combobox`, `slider`, `progress`, `numberField`, `toolbar`, `accordion`, `fieldset`; `RaControlThemeData.groupIndent`; `RaFieldThemeData.trailingPaddingRight` / `trailingGap`.
* `RaTextField` gains `trailing` (inline controls on the right) and `textAlign`. `RaIconSet.plus`. `RaLocalizations.noResults`.
* All transitions run twice as fast: `RaMotion` fast / base / slow / layout are now 50 / 75 / 125 / 150 ms (were 100 / 150 / 250 / 300). The submenu hover delay stays at 150 ms; tooltip, toast, and scrollbar delays and the spinner speed are unchanged.
* `RaColors.surfaceHover`: a light, opaque hover fill for white controls (secondary button, select, pill trigger), replacing the darker translucent `hover` there.
* `RaSegmentedControl`: the selected thumb slides between segments.
* Dialogs scale from 0.96 and fade (open and close) instead of rising from below. `RaDialogThemeData.enterOffsetFraction` is replaced by `scale`.
* Sidebar rows drop their hover fill instantly (`RaSidebarThemeData.hoverExitDuration`, also `RaPressable.hoverExitDuration` / `RaButton.hoverExitDuration`).
* Chip and row menu triggers are transparent at rest; pill and chip triggers without a leading icon get even side padding.
* New components, following Base UI and the desktop SaaS spec: `RaCheckbox`, `RaRadioGroup` / `RaRadio`, `RaSwitch`, `RaSelect`, `RaTabs`, `RaSegmentedControl`, `RaTag` / `RaCountTag`, `RaSideCard` / `RaPropertyRow`, `RaCollapsible` / `RaCollapsiblePanel`, `RaLoadingState` / `RaEmptyState` / `RaErrorState` / `RaSkeleton`, `RaDrawer` / `showRaDrawer`.
* New component tokens on `RaThemeData`: `tabs`, `segmentedControl`, `tag`, `sideCard`, `stateBlock`, `drawer`, `control`, `select`.
* `RaRovingGroup` (arrow / Home / End navigation for single-choice groups) and `RaDashedBorder`.
* `RaPressable` can expose checked / mixed / toggled semantics. `RaIconSet.minus`. `RaLocalizations` gains `loading`, `loadFailed`, `retry`, `retrying` (custom subclasses must implement them).
* Web support. Components run in the browser (JavaScript and Wasm).
* `raIsWeb` / `debugRaIsWebOverride`: detect the web, or simulate it in VM tests.
* `RaBrowserContextMenuGuard`: on the web, `RaContextMenu` disables the browser's own context menu while the pointer is over it.

## 0.1.0

* Initial release.
