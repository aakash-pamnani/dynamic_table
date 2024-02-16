import 'package:dynamic_table/dynamic_table_widget/key_event_detection.dart';
import 'package:dynamic_table/dynamic_table_widget/logging.dart';
import 'package:dynamic_table/utils/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ChainEntryCallable = ChainedKeyEventResult Function(
    List<LogicalKeyboardKey> mainKeysRequested, void Function()? callBack,
    {bool Function()? handleOnCondition,
    bool? withShift,
    bool? withAlt,
    bool? withCtrl,
    bool? withCtrlAndShift,
    bool? withCtrlAndAlt,
    bool? withAltAndShift});

typedef ChainedKeyEventResult = ({
  KeyEventResult keyEventResult,
  bool keyHandled
});

class ChainHandlingKeys {
  ChainHandlingKeys(
      {ChainedKeyEventResult chainedKeyEventResult = (
        keyEventResult: KeyEventResult.ignored,
        keyHandled: false
      ),
      required ChainEntryCallable chainedCallBack})
      : _chainedKeyEventResult = chainedKeyEventResult,
        _chainedCallBack = chainedCallBack;

  ChainedKeyEventResult _chainedKeyEventResult;
  ChainEntryCallable _chainedCallBack;

  KeyEventResult result() {
    return _chainedKeyEventResult.keyEventResult;
  }

  ChainHandlingKeys chain(
      List<LogicalKeyboardKey> mainKeysRequested, void Function()? callBack,
      {bool Function()? handleOnCondition,
      bool? withShift,
      bool? withAlt,
      bool? withCtrl,
      bool? withCtrlAndShift,
      bool? withCtrlAndAlt,
      bool? withAltAndShift}) {
    if (_chainedKeyEventResult.keyHandled) {
      return this;
    }
    final chainedKeyEventResult = _chainedCallBack(mainKeysRequested, callBack,
        handleOnCondition: handleOnCondition,
        withShift: withShift,
        withAlt: withAlt,
        withCtrl: withCtrl,
        withCtrlAndShift: withCtrlAndShift,
        withCtrlAndAlt: withCtrlAndAlt,
        withAltAndShift: withAltAndShift);
    return ChainHandlingKeys(
        chainedKeyEventResult: chainedKeyEventResult,
        chainedCallBack: _chainedCallBack);
  }
}

extension KeyEventHandlers on KeyEvent {
  KeyEventResult _handleKeyAndCallOnlyOnKeyDown(void callBack()?) {
    if (this is KeyDownEvent) {
      callBack?.call();
      [LoggingWidget.loggingKeyEvent].info(() => "callback called..");
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.handled;
    }
  }

  KeyEventResult handleKeyIfCallBackExistAndCallOnlyOnKeyDown(
      LogicalKeyboardKey mainKeyRequested, void callBack()?) {
    return _handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
            [mainKeyRequested], callBack)
        .keyEventResult;
  }

  ChainedKeyEventResult _handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
      List<LogicalKeyboardKey> mainKeysRequested, void Function()? callBack,
      {bool Function()? handleOnCondition,
      bool? withShift,
      bool? withAlt,
      bool? withCtrl,
      bool? withCtrlAndShift,
      bool? withCtrlAndAlt,
      bool? withAltAndShift}) {
    final isAnyKeyPressed = anyKeyPressed(mainKeysRequested,
        withShift: withShift,
        withCtrl: withCtrl,
        withAlt: withAlt,
        withCtrlAndShift: withCtrlAndShift,
        withCtrlAndAlt: withCtrlAndAlt,
        withAltAndShift: withAltAndShift);

    // ignore: curly_braces_in_flow_control_structures
    if (handleOnCondition?.call() ?? true) if (callBack != null &&
        (isAnyKeyPressed)) {
      [LoggingWidget.loggingKeyEvent].info(() => "handling key event");
      return (
        keyEventResult: this._handleKeyAndCallOnlyOnKeyDown(callBack),
        keyHandled: isAnyKeyPressed
      );
    }

    return (
      keyEventResult: KeyEventResult.ignored,
      keyHandled: isAnyKeyPressed
    );
  }

  ChainHandlingKeys handleKeysIfCallBackExistAndCallOnlyOnKeyDown({String? debugLabel}) {
    // ignore: curly_braces_in_flow_control_structures
    if (debugLabel != null) {
      [LoggingWidget.loggingKeyEvent].info(() => "handing key event on : " + debugLabel);
    }
    return ChainHandlingKeys(
      chainedCallBack: _handleKeysIfCallBackExistAndCallOnlyOnKeyDown,
    );
  }
}
