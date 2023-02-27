import 'image_picker_configs.dart';

/// Used to config all the translation messages of this package
/// UI labels translated configs that requires a function with
/// one argument `message` of type `IPMessage(Enum)`.
class TranslationConfigs {
  /// Used to config all the translation messages of this package
  TranslationConfigs();

  /// UI labels translated function with 2 parameters
  /// `label` and `defaultTranslation`
  ///
  /// Declare a `key` for what label
  /// needs to be translated in your localization file,
  /// such as select_images_title. All keys and their default translations
  /// are accessible through `IPMessage.label_name`
  ///
  /// Sample usage:
  ///
  /// If using Intl, define a function like this:
  ///
  /// `configs.translations.translateFunc = (label, defaultTranslation)
  ///  => Intl.message(defaultTranslation, name: label);`
  ///
  /// If using GetX, function like this:
  ///
  /// `configs.translations.translateFunc = (label, defaultTranslation)
  /// =>label.tr;`
  ///
  /// or you can just return the default translation like this:
  ///
  /// `configs.translations.translateFunc = (_, defaultTranslation)
  /// => defaultTranslation;` (the default)
  String Function(String label, String defaultTranslation) translateFunc =
      (_, defaultTranslation) => defaultTranslation;

  /// Translate string by translateFunc.
  String _getTranslatedString(IPMessage value) {
    return translateFunc.call(value.name, value.defaultTranslation);
  }
}

/// A enum containing all the messages used in this package
enum IPMessage {
  /// In en, this message translates to: 'Selected images count'
  selectImagesTitle("Selected images count"),

  /// In en, this message translates to:
  /// 'You need allow photo gallery permission.'
  requestGalleryPermission("You need allow photo gallery permission."),

  /// In en, this message translates to: 'You need allow camera permission.'
  requestCameraPermission("You need allow camera permission."),

  /// In en, this message translates to: 'Request Permission'
  requestPermission("Request Permission"),

  /// In en, this message translates to: 'OCR'
  ocr("OCR"),

  /// In en, this message translates to: 'saturation'
  imageEditSaturation("Saturation"),

  /// In en, this message translates to: 'brightness'
  imageEditBrightness("Brightness"),

  /// In en, this message translates to: 'Contrast'
  imageEditContrast("Contrast"),

  /// In en, this message translates to: 'auto'
  exposureAutoTitle("auto"),

  /// In en, this message translates to: 'Locked'
  exposureLockedTitle("Locked"),

  /// In en, this message translates to: 'Exposure'
  exposureTitle("Exposure"),

  /// In en, this message translates to:
  /// "You can click on sticker icons to
  /// scale it or double click to remove it from image"
  imageStickerGuide(
      "You can click on sticker icons to scale it or double click to "
      "remove it from image"),

  /// In en, this message translates to: 'Select'
  selectButtonTitle("Select"),

  /// In en, this message translates to: 'Image add text'
  imageAddTextTitle("Image add text"),

  /// In en, this message translates to: 'Image sticker'
  imageStickerTitle("Image sticker"),

  /// In en, this message translates to: 'Image edit'
  imageEditTitle("Image edit"),

  /// In en, this message translates to: 'Image filter'
  imageFilterTitle("Image filter"),

  /// In en, this message translates to: 'Image crop'
  imageCropTitle("Image crop"),

  /// In en, this message translates to: 'No images ...'
  noImages("No images ..."),

  /// In en, this message translates to: 'Edit text'
  editText("Edit text"),

  /// In en, this message translates to: 'Clear'
  clear("Clear"),

  /// In en, this message translates to: 'Save'
  save("Save"),

  /// In en, this message translates to: 'No'
  no("No"),

  /// In en, this message translates to: 'Yes'
  yes("Yes"),

  /// In en, this message translates to:
  /// 'Do you want to clear all changes for this image?'
  confirmResetChanges("Do you want to clear all changes for this image?"),

  /// In en, this message translates to: 'Do you want to delete this image?'
  confirmDelete("Do you want to delete this image?"),

  /// In en, this message translates to: 'Confirm'
  confirm("Confirm"),

  /// In en, this message translates to:
  /// 'Do you want to exit without selecting images?'
  exitWithoutSelecting("Do you want to exit without selecting images?"),

  /// In en, this message translates to: 'Preview'
  previewTitle("Preview"),

  /// In en, this message translates to: 'Album'
  albumTitle("Album"),

  /// In en, this message translates to: 'Camera'
  cameraTitle("Camera"),

  /// In en, this message translates to:
  /// 'You can drag images for sorting list...'
  selectImagesGuide("You can drag images for sorting list...");

  /// The default message of the string
  final String defaultTranslation;

  /// A enum containing all the messages used in this package
  // ignore: sort_constructors_first
  const IPMessage(this.defaultTranslation);
}

///
extension TranslationExtensions on ImagePickerConfigs {
  /// A function to get the translation of a specific key/message from the
  /// [translations] property
  String tr(IPMessage message) {
    return translations._getTranslatedString(message);
  }
}
