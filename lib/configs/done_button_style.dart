import 'package:flutter/material.dart';

/// Class used to style the done button
class DoneButtonStyle {
  /// Use an [OutlinedButton].
  DoneButtonStyle.outlinedButton({
    this.buttonColor = Colors.white,
    this.doneButtonDisabledBehavior = DoneButtonDisabledBehavior.disabled,
  })  : type = ButtonType.outlinedButton,
        icon = Icons.check;

  /// Use an [IconButton].
  DoneButtonStyle.iconButton({
    required this.icon,
    this.doneButtonDisabledBehavior = DoneButtonDisabledBehavior.disabled,
  })  : type = ButtonType.outlinedButton,
        buttonColor = Colors.black;

  /// IconData used by the done button when doneButtonStyle is
  /// [DoneButtonStyle.iconButton].
  ///
  /// Defaults to Icon.check.
  final IconData icon;

  /// The background color of the image selection completed button.
  ///
  /// This color only applies to the [DoneButtonStyle.outlinedButton].
  ///
  /// Defaults to white.
  /// This results in appBarBackgroundColor being used.
  final Color buttonColor;

  /// The type of button used on the image picker to select images and close
  /// the image picker.
  ///
  /// The alternate style [DoneButtonStyle.iconButton] uses an [IconButton] that
  /// is typically used in [AppBar] actions.
  final ButtonType type;

  /// Used to define the type of of behavior the done button has when
  /// no images have been selected that will be returned.
  ///
  /// Defaults to [DoneButtonDisabledBehavior.disabled].
  final DoneButtonDisabledBehavior doneButtonDisabledBehavior;
}

/// Enum used to define the type of of behavior the done button has when
/// no images have been selected that will be returned.
enum DoneButtonDisabledBehavior {
  /// Done button is disabled
  disabled,

  /// Done button is hidden and not shown at all.
  hidden,
}

/// Enum used to define the type of used done button by the image picker.
enum ButtonType {
  /// Use an [OutlinedButton].
  outlinedButton,

  /// Use an [IconButton].
  iconButton,
}
