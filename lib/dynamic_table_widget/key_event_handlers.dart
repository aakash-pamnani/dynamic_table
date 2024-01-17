import 'package:dynamic_table/dynamic_table_source/iterable_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ChainedKeyEventResult = ({KeyEventResult keyEventResult, bool keyHandled});

class ChainHandlingKeys {
  ChainHandlingKeys(
      {required ChainedKeyEventResult keyEventResult,
      required ChainHandlingKeys chainedCallBack(
          List<LogicalKeyboardKey> logicalKeys, void callBack()?,
          {bool handleOnCondition()?, bool? withShift})})
      : _keyEventResult = keyEventResult,
        _chainedCallBack = chainedCallBack;

  ChainedKeyEventResult _keyEventResult;
  ChainHandlingKeys Function(
      List<LogicalKeyboardKey> logicalKeys, void Function()? callBack,
      {bool Function()? handleOnCondition, bool? withShift}) _chainedCallBack;

  KeyEventResult result() {
    return _keyEventResult.keyEventResult;
  }

  ChainHandlingKeys chain(
      List<LogicalKeyboardKey> logicalKeys, void callBack()?,
      {bool handleOnCondition()?, bool? withShift}) {
    if (_keyEventResult.keyHandled) {
      return this;
    }
    return _chainedCallBack(logicalKeys, callBack,
        handleOnCondition: handleOnCondition, withShift: withShift);
  }
}

extension KeyEventHandlers on KeyEvent {
  KeyEventResult _handleKeyAndCallOnlyOnKeyDown(void callBack()?) {
    if (this is KeyDownEvent) {
      callBack?.call();
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.handled;
    }
  }

  KeyEventResult handleKeyIfCallBackExistAndCallOnlyOnKeyDown(
      LogicalKeyboardKey logicalKey, void callBack()?) {
    return _handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
        [logicalKey], callBack).keyEventResult;
  }

  bool _anyKeyPressed(List<LogicalKeyboardKey> logicalKeys, {bool? withShift}) {
    return logicalKeys.contains(this.logicalKey)
    && (withShift==null || HardwareKeyboard.instance.logicalKeysPressed.containsAny([LogicalKeyboardKey.shift, LogicalKeyboardKey.shiftLeft, LogicalKeyboardKey.shiftRight]));
  }

  ChainedKeyEventResult _handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
      List<LogicalKeyboardKey> logicalKeys, void callBack()?,
      {bool handleOnCondition()?, bool? withShift}) {
    final anyKeyPressed = _anyKeyPressed(logicalKeys, withShift: withShift);
    // ignore: curly_braces_in_flow_control_structures
    if (handleOnCondition?.call() ?? true) if (callBack != null &&
        (anyKeyPressed)) {
      return (keyEventResult: this._handleKeyAndCallOnlyOnKeyDown(callBack), keyHandled: anyKeyPressed);
    }

    return (keyEventResult: KeyEventResult.ignored, keyHandled: anyKeyPressed);
  }

  ChainHandlingKeys handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
      List<LogicalKeyboardKey> logicalKeys, void callBack()?,
      {bool handleOnCondition()?, bool? withShift}) {
    return ChainHandlingKeys(
      keyEventResult: _handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
          logicalKeys, callBack,
          handleOnCondition: handleOnCondition, withShift: withShift),
      chainedCallBack: handleKeysIfCallBackExistAndCallOnlyOnKeyDown,
    );
  }
}
