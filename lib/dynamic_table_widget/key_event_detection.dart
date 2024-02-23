import 'package:dynamic_table/dynamic_table_source/iterable_extension.dart';
import 'package:dynamic_table/dynamic_table_widget/logging.dart';
import 'package:dynamic_table/utils/logging.dart';
import 'package:flutter/services.dart';

enum KeyEventModificationType { SINGLE, DUAL }

class KeyEventModifyingKeys {
  // ignore: unused_element
  KeyEventModifyingKeys._(
      {required this.type,
      Set<LogicalKeyboardKey>? singleModifier,
      (Set<LogicalKeyboardKey>, Set<LogicalKeyboardKey>)? dualModifier})
      : this._singleModifier =
            Set<LogicalKeyboardKey>.unmodifiable(singleModifier ?? Set()),
        this._dualModifier = (
          Set<LogicalKeyboardKey>.unmodifiable(dualModifier?.$1 ?? Set()),
          Set<LogicalKeyboardKey>.unmodifiable(dualModifier?.$2 ?? Set())
        );

  KeyEventModifyingKeys.single(Set<LogicalKeyboardKey> modifyingKeys)
      : type = KeyEventModificationType.SINGLE,
        _singleModifier = modifyingKeys,
        _dualModifier = (Set<LogicalKeyboardKey>(), Set<LogicalKeyboardKey>());

  KeyEventModifyingKeys.dual(
      (Set<LogicalKeyboardKey>, Set<LogicalKeyboardKey>) modifyingKeys)
      : type = KeyEventModificationType.DUAL,
        _singleModifier = Set<LogicalKeyboardKey>(),
        _dualModifier = modifyingKeys;

  final KeyEventModificationType type;
  final (Set<LogicalKeyboardKey>, Set<LogicalKeyboardKey>) _dualModifier;
  final Set<LogicalKeyboardKey> _singleModifier;

  Set<LogicalKeyboardKey> get singleModifier => _singleModifier;
  (Set<LogicalKeyboardKey>, Set<LogicalKeyboardKey>) get dualModifier =>
      _dualModifier;
}

class KeySelection {
  KeySelection({
    this.isMainKeySelected = false,
    this.isCtrlAndShiftSelected = false,
    this.isCtrlAndAltSelected = false,
    this.isAltAndShiftSelected = false,
    this.isCtrlKeySelected = false,
    this.isAltKeySelected = false,
    this.isShiftKeySelected = false,
  });
  final bool isMainKeySelected;
  final bool isCtrlAndShiftSelected;
  final bool isCtrlAndAltSelected;
  final bool isAltAndShiftSelected;
  final bool isCtrlKeySelected;
  final bool isAltKeySelected;
  final bool isShiftKeySelected;

  @override
  bool operator ==(Object other) {
    if (other is! KeySelection) return false;
    return (this.isMainKeySelected == other.isMainKeySelected &&
        this.isCtrlAndShiftSelected == other.isCtrlAndShiftSelected &&
        this.isCtrlAndAltSelected == other.isCtrlAndAltSelected &&
        this.isAltAndShiftSelected == other.isAltAndShiftSelected &&
        this.isCtrlKeySelected == other.isCtrlKeySelected &&
        this.isAltKeySelected == other.isAltKeySelected &&
        this.isShiftKeySelected == other.isShiftKeySelected);
  }

  @override
  String toString() {
    String result = "";
    if (isMainKeySelected) result += "MainKeySelected\n";
    if (isCtrlAndShiftSelected) result += "isCtrlAndShiftSelected\n";
    if (isCtrlAndAltSelected) result += "CtrlAndAltSelected\n";
    if (isAltAndShiftSelected) result += "AltAndShiftSelected\n";
    if (isCtrlKeySelected) result += "CtrlKeySelected\n";
    if (isAltKeySelected) result += "AltKeySelected\n";
    if (isShiftKeySelected) result += "ShiftKeySelected\n";
    return result.isEmpty? "": result.replaceRange(result.length-1, null, "");
  }
}

final shiftKeys = List<LogicalKeyboardKey>.unmodifiable([
  LogicalKeyboardKey.shift,
  LogicalKeyboardKey.shiftLeft,
  LogicalKeyboardKey.shiftRight
]);

final ctrlKeys = List<LogicalKeyboardKey>.unmodifiable([
  LogicalKeyboardKey.control,
  LogicalKeyboardKey.controlLeft,
  LogicalKeyboardKey.controlRight
]);

final altKeys = List<LogicalKeyboardKey>.unmodifiable([
  LogicalKeyboardKey.alt,
  LogicalKeyboardKey.altLeft,
  LogicalKeyboardKey.altRight
]);

KeySelection _getKeysInvolved(KeySelection keysRequested) {
  final involveCtrlAndShift = keysRequested.isCtrlAndShiftSelected;
  final involveCtrlAndAlt =
      keysRequested.isCtrlAndAltSelected && !involveCtrlAndShift;
  final involveAltAndShift = keysRequested.isAltAndShiftSelected &&
      !involveCtrlAndAlt &&
      !involveCtrlAndShift;
  final anyDualModifierInvolved =
      involveCtrlAndAlt || involveCtrlAndShift || involveAltAndShift;
  final involveCtrlKey =
      keysRequested.isCtrlKeySelected && !anyDualModifierInvolved;
  final involveShiftKey = keysRequested.isShiftKeySelected &&
      !anyDualModifierInvolved &&
      !involveCtrlKey;
  final involveAltKey = keysRequested.isAltKeySelected &&
      !anyDualModifierInvolved &&
      !involveShiftKey &&
      !involveCtrlKey;
  return KeySelection(
      isMainKeySelected: keysRequested.isMainKeySelected,
      isCtrlAndShiftSelected: involveCtrlAndShift,
      isCtrlAndAltSelected: involveCtrlAndAlt,
      isAltAndShiftSelected: involveAltAndShift,
      isCtrlKeySelected: involveCtrlKey,
      isAltKeySelected: involveAltKey,
      isShiftKeySelected: involveShiftKey);
}

KeySelection _getKeysPressed(
    List<LogicalKeyboardKey> mainKeysRequested, KeySelection keysInvolved) {
  final isMainKeyPressed = (keysInvolved.isMainKeySelected &&
      _anyHardwareKeyPressed(
          mainKeysRequested)); //logicalKeys.contains(this.logicalKey));
  final isShiftKeyPressed =
      (keysInvolved.isShiftKeySelected && _anyHardwareKeyPressed(shiftKeys));
  final isCtrlKeyPressed =
      (keysInvolved.isCtrlKeySelected && _anyHardwareKeyPressed(ctrlKeys));
  final isAltKeyPressed =
      (keysInvolved.isAltKeySelected && _anyHardwareKeyPressed(altKeys));
  final isCtrlAndAltPressed = (keysInvolved.isCtrlAndAltSelected &&
      _anyHardwareKeyPressed(ctrlKeys) &&
      _anyHardwareKeyPressed(altKeys));
  final isCtrlAndShiftPressed = (keysInvolved.isCtrlAndShiftSelected &&
      _anyHardwareKeyPressed(ctrlKeys) &&
      _anyHardwareKeyPressed(shiftKeys));
  final isAltAndShiftPressed = (keysInvolved.isAltAndShiftSelected &&
      _anyHardwareKeyPressed(altKeys) &&
      _anyHardwareKeyPressed(shiftKeys));
  return KeySelection(
      isMainKeySelected: isMainKeyPressed,
      isCtrlAndShiftSelected: isCtrlAndShiftPressed,
      isCtrlAndAltSelected: isCtrlAndAltPressed,
      isAltAndShiftSelected: isAltAndShiftPressed,
      isCtrlKeySelected: isCtrlKeyPressed,
      isAltKeySelected: isAltKeyPressed,
      isShiftKeySelected: isShiftKeyPressed);
}

bool _anyHardwareKeyPressed(List<LogicalKeyboardKey> hardwareLogicalKeys) {
  return HardwareKeyboard.instance.logicalKeysPressed
      .containsAny(hardwareLogicalKeys);
}

bool anyKeyPressed(List<LogicalKeyboardKey> mainKeysRequested,
    {bool? withShift,
    bool? withCtrl,
    bool? withAlt,
    bool? withCtrlAndShift,
    bool? withCtrlAndAlt,
    bool? withAltAndShift}) {
  final keysRequested = KeySelection(
    isMainKeySelected: mainKeysRequested.isNotEmpty,
    isCtrlAndShiftSelected: withCtrlAndShift ?? false,
    isCtrlAndAltSelected: withCtrlAndAlt ?? false,
    isAltAndShiftSelected: withAltAndShift ?? false,
    isCtrlKeySelected: withCtrl ?? false,
    isAltKeySelected: withAlt ?? false,
    isShiftKeySelected: withShift ?? false,
  );

  final keysInvolved = _getKeysInvolved(keysRequested);

  final keysPressed = _getKeysPressed(mainKeysRequested, keysInvolved);

  [LoggingWidget.loggingKeyEvent].info(() => "Request::");
  [LoggingWidget.loggingKeyEvent].info(() => mainKeysRequested.map((e) => e.keyLabel).toString());
  [LoggingWidget.loggingKeyEvent].info(() => keysRequested.toString());
  [LoggingWidget.loggingKeyEvent].info(() => "Pressed::");
  [LoggingWidget.loggingKeyEvent].info(() => keysPressed.toString());
  [LoggingWidget.loggingKeyEvent].info(() => "Equals::" + (keysPressed == keysRequested).toString());
  [LoggingWidget.loggingKeyEvent].info(() => "");
  return keysPressed == keysRequested;
}
