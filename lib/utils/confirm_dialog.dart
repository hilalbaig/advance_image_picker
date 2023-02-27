import 'package:flutter/material.dart';

import '../advance_image_picker.dart';

/// A custom dialog to show a confirmation message with optional boolean return
/// that will be returned if the [onConfirm] and [onDeny] are null.
///
Future<bool?> showConfirmDialog({
  required BuildContext context,
  required IPMessage title,
  required IPMessage content,
  required ImagePickerConfigs configs,
  bool Function()? onConfirm,
  bool Function()? onDeny,
}) {
  final dialogButtonStyle = TextButton.styleFrom(
    foregroundColor: Colors.black87,
    minimumSize: const Size(88, 36),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(configs.tr(title)),
      content: Text(configs.tr(content)),
      actions: <Widget>[
        TextButton(
          style: dialogButtonStyle,
          onPressed: onDeny ?? () => Navigator.of(context).pop(false),
          child: Text(configs.tr(IPMessage.no)),
        ),
        TextButton(
          style: dialogButtonStyle,
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
          child: Text(configs.tr(IPMessage.yes)),
        ),
      ],
    ),
  );
}
