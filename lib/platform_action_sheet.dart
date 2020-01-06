library platform_action_sheet;

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Display a platform dependent Action Sheet
class PlatformActionSheet {
  // display sheet
  displaySheet(BuildContext context, List<ActionSheetAction> actions) {
    if (Platform.isIOS) {
      _showCupertinoActionSheet(context, actions);
    } else {
      _settingModalBottomSheet(context, actions);
    }
  }
}

void _showCupertinoActionSheet(BuildContext context,
    List<ActionSheetAction> actions) {
  var indexOfCancel = actions.lastIndexWhere((action) =>
  action
      .isCancel); // Cancel action is treated differently with CupertinoActionSheets
  var actionSheet = CupertinoActionSheet(
      actions: List.from(actions.where((action) => !action.isCancel)).map((cAction) => cupertinoActionSheetActionFromAction(cAction)).toList(),
      cancelButton: indexOfCancel > 0
          ? cupertinoActionSheetActionFromAction(actions[indexOfCancel])
          : Container());
  showCupertinoModalPopup(
      context: context, builder: (BuildContext context) => actionSheet);
}

CupertinoActionSheetAction cupertinoActionSheetActionFromAction(
    ActionSheetAction action) =>
    CupertinoActionSheetAction(
      child: Text(action.text),
      onPressed: action.onPressed,
      isDefaultAction: action.defaultAction,
    );

ListTile listTileFromAction(ActionSheetAction action) {
  if (action.hasArrow) {
    return ListTile(
      title: Text(action.text),
      onTap: action.onPressed,
      trailing: Icon(Icons.keyboard_arrow_right),
    );
  } else {
    return ListTile(
      title: Text(
        action.text,
        style: TextStyle(
            fontWeight:
            action.defaultAction ? FontWeight.bold : FontWeight.normal),
      ),
      onTap: action.onPressed,
    );
  }
}

void _settingModalBottomSheet(context, List<ActionSheetAction> actions) {
  if (actions?.isNotEmpty ?? false) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                shrinkWrap: true,
                itemCount: actions.length,
                itemBuilder: (bc, index) => listTileFromAction(actions[index]),
                separatorBuilder: (bc, index) =>
                index >= (actions.length - 2)
                    ? Divider()
                    : Container()), // Display a separator only above the last option
          );
        });
  }
}

// this class describes an action for either a CupertinoActionSheet or a Bottom Sheet depending on the platform
class ActionSheetAction {
  final String text;
  final Function onPressed;
  final bool defaultAction;
  final bool isCancel;
  final bool hasArrow; // on Android indicates that further options are next

  ActionSheetAction({
    @required this.text,
    @required this.onPressed,
    this.defaultAction = false,
    this.isCancel = false,
    this.hasArrow = false,
  });
}
