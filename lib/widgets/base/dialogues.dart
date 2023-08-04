import 'package:flutter/material.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

enum ConfirmAction { cancel, accept }

Future<ConfirmAction?> asyncConfirmDialog(
  final BuildContext context,
  final String title,
  final String text,
) async {
  final textTheme = Theme.of(context).textTheme;
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false, // user must tap button to close dialog!
    builder: (final context) {
      return AlertDialog(
        backgroundColor: UiColors.yellowPapyrus,
        title: Text(
          title,
          style: textTheme.headline4,
        ),
        content: Text(
          text,
          style: textTheme.bodyText2,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, ConfirmAction.cancel);
            },
            child: Text(
              S.of(context).cancel,
              style: textTheme.headline4,
              // style: TextStyle(color: Theme.of(context).accentColor,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, ConfirmAction.accept);
            },
            child: Text(
              S.of(context).confirm,
              style: textTheme.headline4,
              // style: TextStyle(color: Theme.of(context).highlightColor,
            ),
          ),
        ],
      );
    },
  );
}

Future<int?> asyncMultipleChoiceDialog(
  final BuildContext context,
  final String title,
  final String text,
  final List<String> options,
) async {
  return showDialog<int>(
    context: context,
    barrierDismissible: false, // user must tap button to close dialog!
    builder: (final context) {
      return AlertDialog(
        backgroundColor: UiColors.yellowPapyrus,
        title: Text(
          title,
          style: Theme.of(context).textTheme.headline4,
        ),
        content: Text(
          text,
          style: Theme.of(context).textTheme.bodyText2,
        ),
        actions: options
            .map<Widget>(
              (final e) => TextButton(
                onPressed: () {
                  Navigator.of(context).pop(options.indexOf(e));
                },
                child: Text(
                  e,
                  style: Theme.of(context).textTheme.headline4,
                  // style: TextStyle(color: Theme.of(context).accentColor,
                  // ),
                ),
              ),
            )
            .toList(),
      );
    },
  );
}

Future<void> asyncInfoDialog(
  final BuildContext context,
  final String title,
  final String text,
) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button to close dialog!
    builder: (final context) {
      return AlertDialog(
        backgroundColor: UiColors.yellowPapyrus,
        title: Text(
          title,
          style: Theme.of(context).textTheme.headline4,
        ),
        content: Text(
          text,
          style: Theme.of(context).textTheme.bodyText2,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              S.of(context).ok,
              style: Theme.of(context).textTheme.headline4,
              // style: TextStyle(color: Theme.of(context).highlightColor,
            ),
          )
        ],
      );
    },
  );
}

Future<String?> asyncTextDialog(
  final BuildContext context,
  final String currentText,
  final String title,
) async {
  final TextEditingController textFieldController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (final context) {
      return AlertDialog(
        backgroundColor: UiColors.yellowPapyrus,
        title: Text(
          title,
          style: Theme.of(context).textTheme.headline4,
        ),
        // content: Text(text, style: Theme.of(context).textTheme.bodyText2,),
        content: TextField(
          controller: textFieldController,
          decoration: InputDecoration(hintText: currentText),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              S.of(context).cancel,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(textFieldController.text);
            },
            child: Text(
              S.of(context).confirm,
              style: Theme.of(context).textTheme.headline4,
            ),
          )
        ],
      );
    },
  );
}
