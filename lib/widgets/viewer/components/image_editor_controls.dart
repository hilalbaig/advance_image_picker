// part of "../image_viewer.dart";

// /// Build image editor controls
// List<Widget> _buildImageEditorControls(
//   BuildContext context,
//   ImagePickerConfigs configs,
//   Color toolbarColor,
//   Color toolbarWidgetColor,
// ) {
//   /// Pre-processing function.
//   Future<File> _imagePreProcessing(String? path) async {
//     if (configs.imagePreProcessingBeforeEditingEnabled) {
//       return ImageUtils.compressResizeImage(
//         path!,
//         maxWidth: configs.imageConfigs.maxWidth,
//         maxHeight: configs.imageConfigs.maxHeight,
//         quality: configs.imageConfigs.compressQuality,
//       );
//     }
//     return File(path!);
//   }

//   final Map<String, EditorParams> imageEditors = {};

//   // Add preset image editors
//   if (configs.cropFeatureEnabled) {
//     imageEditors[configs.translations.textImageCropTitle] = EditorParams(
//         title: configs.translations.textImageCropTitle,
//         icon: Icons.crop_rotate,
//         onEditorEvent: (
//                 {required BuildContext context,
//                 required File file,
//                 required String title,
//                 int maxWidth = 1080,
//                 int maxHeight = 1920,
//                 int compressQuality = 90,
//                 ImagePickerConfigs? configs}) async =>
//             ImageCropper().cropImage(
//               sourcePath: file.path,
//               compressQuality: compressQuality,
//               maxWidth: maxWidth,
//               maxHeight: maxHeight,
//               aspectRatioPresets: [
//                 CropAspectRatioPreset.square,
//                 CropAspectRatioPreset.ratio3x2,
//                 CropAspectRatioPreset.original,
//                 CropAspectRatioPreset.ratio4x3,
//                 CropAspectRatioPreset.ratio16x9
//               ],
//               uiSettings: [
//                 IOSUiSettings(minimumAspectRatio: 1),
//                 AndroidUiSettings(
//                     toolbarTitle: title,
//                     toolbarColor: toolbarColor,
//                     toolbarWidgetColor: toolbarWidgetColor,
//                     initAspectRatio: CropAspectRatioPreset.original,
//                     lockAspectRatio: false)
//               ],
//             ).then((value) => File(value!.path)));
//   }
//   if (configs.adjustFeatureEnabled) {
//     imageEditors[configs.translations.textImageEditTitle] = EditorParams(
//         title: configs.translations.textImageEditTitle,
//         icon: Icons.wb_sunny_outlined,
//         onEditorEvent: (
//                 {required BuildContext context,
//                 required File file,
//                 required String title,
//                 int maxWidth = 1080,
//                 int maxHeight = 1920,
//                 int compressQuality = 90,
//                 ImagePickerConfigs? configs}) async =>
//             Navigator.of(context).push(MaterialPageRoute<File>(
//                 fullscreenDialog: true,
//                 builder: (context) => ImageEdit(
//                     file: file,
//                     title: title,
//                     maxWidth: maxWidth,
//                     maxHeight: maxHeight,
//                     configs: configs))));
//   }
//   if (configs.filterFeatureEnabled) {
//     imageEditors[configs.translations.textImageFilterTitle] = EditorParams(
//         title: configs.translations.textImageFilterTitle,
//         icon: Icons.auto_awesome,
//         onEditorEvent: (
//                 {required BuildContext context,
//                 required File file,
//                 required String title,
//                 int maxWidth = 1080,
//                 int maxHeight = 1920,
//                 int compressQuality = 90,
//                 ImagePickerConfigs? configs}) async =>
//             Navigator.of(context).push(MaterialPageRoute<File>(
//                 fullscreenDialog: true,
//                 builder: (context) => ImageFilter(
//                     file: file,
//                     title: title,
//                     maxWidth: maxWidth,
//                     maxHeight: maxHeight,
//                     configs: configs))));
//   }
//   if (configs.stickerFeatureEnabled) {
//     imageEditors[configs.translations.textImageStickerTitle] = EditorParams(
//         title: configs.translations.textImageStickerTitle,
//         icon: Icons.insert_emoticon_rounded,
//         onEditorEvent: (
//                 {required BuildContext context,
//                 required File file,
//                 required String title,
//                 int maxWidth = 1080,
//                 int maxHeight = 1920,
//                 int compressQuality = 90,
//                 ImagePickerConfigs? configs}) async =>
//             Navigator.of(context).push(MaterialPageRoute<File>(
//                 fullscreenDialog: true,
//                 builder: (context) => ImageSticker(
//                     file: file,
//                     title: title,
//                     maxWidth: maxWidth,
//                     maxHeight: maxHeight,
//                     configs: configs))));
//   }

//   // Add custom image editors
//   imageEditors.addAll(configs.externalImageEditors);

//   // Create image editor icons
//   return imageEditors.values
//       .map((e) => GestureDetector(
//             child: Icon(e.icon, size: 32, color: Colors.white),
//             onTap: () async {
//               final image = await _imagePreProcessing(
//                   _images[_currentIndex!].modifiedPath);
//               final File? outputFile = await e.onEditorEvent(
//                   context: context,
//                   file: image,
//                   title: e.title,
//                   maxWidth: configs.imageConfigs.maxWidth,
//                   maxHeight: configs.imageConfigs.maxHeight,
//                   configs: configs);
//               if (outputFile != null) {
//                 setState(() {
//                   _images[_currentIndex!].modifiedPath = outputFile.path;
//                   widget.onChanged?.call(_images);
//                 });
//               }
//             },
//           ))
//       .toList();
// }
