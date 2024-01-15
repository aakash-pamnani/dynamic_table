import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ChainedKeyEventResult = ({KeyEventResult keyEventResult, bool keyHandled});

class ChainHandlingKeys {
  ChainHandlingKeys(
      {required ChainedKeyEventResult keyEventResult,
      required ChainHandlingKeys chainedCallBack(
          List<LogicalKeyboardKey> logicalKeys, void callBack()?,
          {bool handleOnCondition()?})})
      : _keyEventResult = keyEventResult,
        _chainedCallBack = chainedCallBack;

  ChainedKeyEventResult _keyEventResult;
  ChainHandlingKeys Function(
      List<LogicalKeyboardKey> logicalKeys, void Function()? callBack,
      {bool Function()? handleOnCondition}) _chainedCallBack;

  KeyEventResult result() {
    return _keyEventResult.keyEventResult;
  }

  ChainHandlingKeys chain(
      List<LogicalKeyboardKey> logicalKeys, void callBack()?,
      {bool handleOnCondition()?}) {
    if (_keyEventResult.keyHandled) {
      return this;
    }
    return _chainedCallBack(logicalKeys, callBack,
        handleOnCondition: handleOnCondition);
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

  ChainedKeyEventResult _handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
      List<LogicalKeyboardKey> logicalKeys, void callBack()?,
      {bool handleOnCondition()?}) {
    // ignore: curly_braces_in_flow_control_structures
    if (handleOnCondition?.call() ?? true) if (callBack != null &&
        (logicalKeys.contains(this.logicalKey))) {
      return (keyEventResult: this._handleKeyAndCallOnlyOnKeyDown(callBack), keyHandled: true);
    }

    return (keyEventResult: KeyEventResult.ignored, keyHandled: logicalKeys.contains(this.logicalKey));
  }

  ChainHandlingKeys handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
      List<LogicalKeyboardKey> logicalKeys, void callBack()?,
      {bool handleOnCondition()?}) {
    return ChainHandlingKeys(
      keyEventResult: _handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
          logicalKeys, callBack,
          handleOnCondition: handleOnCondition),
      chainedCallBack: handleKeysIfCallBackExistAndCallOnlyOnKeyDown,
    );
  }
}
