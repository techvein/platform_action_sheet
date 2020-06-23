library platform_action_sheet;

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Display a platform dependent Action Sheet
class PlatformActionSheet {
  /// Function to display the sheet
  void displaySheet(
      {@required BuildContext context,
      Widget title,
      Widget message,
      @required List<ActionSheetAction> actions}) {
    if (Platform.isIOS) {
      _showCupertinoActionSheet(context, title, message, actions);
    } else {
      _settingModalBottomSheet(context, title, message, actions);
    }
  }
}

void _showCupertinoActionSheet(
    BuildContext context, title, message, List<ActionSheetAction> actions) {
  final noCancelOption = -1;
  // Cancel action is treated differently with CupertinoActionSheets
  var indexOfCancel = actions.lastIndexWhere((action) => action.isCancel);
  showCupertinoModalPopup(context: context, builder: (context) {
    return indexOfCancel == noCancelOption
        ? CupertinoActionSheet(
        title: title,
        message: message,
        actions: actions
            .where((action) => !action.isCancel)
            .map<Widget>((action) => _cupertinoActionSheetActionFromAction(context, action))
            .toList())
        : CupertinoActionSheet(
        title: title,
        message: message,
        actions: actions
            .where((action) => !action.isCancel)
            .map<Widget>((action) => _cupertinoActionSheetActionFromAction(context, action))
            .toList(),
        cancelButton:
        _cupertinoActionSheetActionFromAction(context, actions[indexOfCancel]));
  });
}

CupertinoActionSheetAction _cupertinoActionSheetActionFromAction(
        BuildContext context, ActionSheetAction action) =>
    CupertinoActionSheetAction(
      child: Text(action.text),
      onPressed: () => action.onPressed(context),
      isDefaultAction: action.defaultAction,
    );

ListTile _listTileFromAction(BuildContext context, ActionSheetAction action) => action.hasArrow
    ? ListTile(
        title: Text(action.text),
        onTap: () => action.onPressed(context),
        trailing: Icon(Icons.keyboard_arrow_right),
      )
    : ListTile(
        title: Text(
          action.text,
          style: TextStyle(
              fontWeight:
                  action.defaultAction ? FontWeight.bold : FontWeight.normal),
        ),
        onTap: () => action.onPressed(context),
      );

void _settingModalBottomSheet(
    context, title, message, List<ActionSheetAction> actions) {
  if (actions.isNotEmpty) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          final _lastItem = 1, _secondLastItem = 2;
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: title,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: message,
                ),
                ListView.separated(
                    padding: const EdgeInsets.only(left: 20),
                    shrinkWrap: true,
                    itemCount: actions.length,
                    itemBuilder: (_, index) =>
                        _listTileFromAction(context, actions[index]),
                    separatorBuilder: (_, index) =>
                        (index == (actions.length - _secondLastItem) &&
                                actions[actions.length - _lastItem].isCancel)
                            ? Divider()
                            : Container()),
              ],
            ), // Separator above the last option only
          );
        });
  }
}

/// Data class for Actions in ActionSheet
class ActionSheetAction {
  /// Text to display
  final String text;

  /// The function which will be called when the action is pressed
  final void Function(BuildContext) onPressed;

  /// Is this a default action - especially for iOS
  final bool defaultAction;

  /// This is a cancel option - especially for iOS
  final bool isCancel;

  /// on Android indicates that further options are next
  final bool hasArrow;

  /// Construction of an ActionSheetAction
  ActionSheetAction({
    @required this.text,
    @required this.onPressed,
    this.defaultAction = false,
    this.isCancel = false,
    this.hasArrow = false,
  });
}

