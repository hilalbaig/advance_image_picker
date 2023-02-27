import 'package:camera/camera.dart';

/// To config the camera
class CameraConfigs {
  /// To config the camera
  CameraConfigs(
      {this.resolutionPreset = ResolutionPreset.high,
      this.cameraLensDirection,
      this.flashMode = FlashMode.auto,
      this.showFlashMode = true,
      this.showLensDirection = true});

  /// Resolution setting for camera, such as high, max, medium, low.
  ///
  /// Defaults to [ResolutionPreset.high].
  final ResolutionPreset resolutionPreset;

  /// Camera direction setting.
  ///
  /// Options:
  ///
  /// * null: use all available camera (default)
  /// * 0: only use front camera
  /// * 1: only use back camera
  final int? cameraLensDirection;

  /// Set the default flash mode.
  ///
  /// Options:
  /// * off: Do not use the flash when taking a picture.
  /// * auto: Device decide whether to flash the camera when taking a picture.
  /// * always: Always use the flash when taking a picture.
  /// * torch: In this app treated the same as using always.
  ///
  /// Defaults to [FlashMode.auto].
  final FlashMode flashMode;

  /// Show the flash mode icon button.
  ///
  /// If you want to set the FlashMode to a certain mode, typically
  /// [FlashMode.off], and also hide the button than enables users to
  /// change it, then set [showFlashMode] to false.
  ///
  /// Defaults to true.
  final bool showFlashMode;

  /// Show the lens direction toggle icon button.
  ///
  /// If you want to show only one camera, you may also want to hide the
  /// button than enables users switch camera, then set [showLensDirection]
  /// to false.
  ///
  /// If you show just one [cameraLensDirection] and [showLensDirection] is
  /// true, then the lens direction button is still shown, but disabled.
  ///
  /// Defaults to true.
  final bool showLensDirection;
}
