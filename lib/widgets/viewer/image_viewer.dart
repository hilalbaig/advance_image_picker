import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../configs/image_picker_configs.dart';
import '../../configs/translate_config.dart';
import '../../models/image_object.dart';
import '../../utils/confirm_dialog.dart';
import '../../utils/image_utils.dart';
import '../common/portrait_mode_mixin.dart';
import '../editors/editor_params.dart';
import '../editors/image_edit.dart';
import '../editors/image_filter.dart';
import '../editors/image_sticker.dart';

/// Image viewer for selected images.
class ImageViewer extends StatefulWidget {
  /// Default constructor for image viewer for selected images.
  ImageViewer(
      {final Key? key,
      this.initialIndex = 0,
      this.title,
      this.images,
      this.configs,
      this.onChanged})
      : pageController = PageController(initialPage: initialIndex),
        super(key: key);

  /// Initial index in image list.
  final int initialIndex;

  /// Page controller.
  final PageController pageController;

  /// Title shown in the image viewers AppBar.
  final String? title;

  /// List of selected images.
  final List<ImageObject>? images;

  /// Configuration
  final ImagePickerConfigs? configs;

  /// Callback called when viewed images are changed.
  final Function(dynamic)? onChanged;

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer>
    with PortraitStatefulModeMixin<ImageViewer> {
  /// Current index of image in list.
  int? _currentIndex;

  /// Selected images.
  List<ImageObject> _images = [];

  /// Configuration.
  ImagePickerConfigs _configs = ImagePickerConfigs();

  /// Text controller
  final TextEditingController _textFieldController = TextEditingController();

  /// Flag indicate processing or not
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    // Add images.
    _images = [...widget.images!];
    if (widget.configs != null) _configs = widget.configs!;

    // Setup current selected index
    _currentIndex = widget.initialIndex;
    onPageChanged(_currentIndex);
  }

  /// Build image editor controls
  List<Widget> _buildImageEditorControls(
    BuildContext context,
    Color toolbarColor,
    Color toolbarWidgetColor,
  ) {
    final Map<String, EditorParams> imageEditors = {};

    // Add preset image editors
    if (_configs.cropFeatureEnabled) {
      imageEditors[_configs.tr(IPMessage.imageCropTitle)] = EditorParams(
          title: _configs.tr(IPMessage.imageCropTitle),
          icon: Icons.crop_rotate,
          onEditorEvent: (
              {required BuildContext context,
              required File file,
              required String title,
              int maxWidth = 1080,
              int maxHeight = 1920,
              int compressQuality = 90,
              ImagePickerConfigs? configs}) async {
            final CroppedFile? result = await ImageCropper().cropImage(
                sourcePath: file.path,
                compressQuality: compressQuality,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                aspectRatioPresets: [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ],
                uiSettings: [
                  AndroidUiSettings(
                      toolbarTitle: title,
                      toolbarColor: toolbarColor,
                      toolbarWidgetColor: toolbarWidgetColor,
                      initAspectRatio: CropAspectRatioPreset.original,
                      lockAspectRatio: false),
                  IOSUiSettings(
                    minimumAspectRatio: 1,
                  )
                ]);
            return (result != null) ? File(result.path) : file;
          });
    }
    if (_configs.adjustFeatureEnabled) {
      imageEditors[_configs.tr(IPMessage.imageEditTitle)] = EditorParams(
          title: _configs.tr(IPMessage.imageEditTitle),
          icon: Icons.wb_sunny_outlined,
          onEditorEvent: (
                  {required BuildContext context,
                  required File file,
                  required String title,
                  int maxWidth = 1080,
                  int maxHeight = 1920,
                  int compressQuality = 90,
                  ImagePickerConfigs? configs}) async =>
              Navigator.of(context).push(MaterialPageRoute<File>(
                  fullscreenDialog: true,
                  builder: (context) => ImageEdit(
                      file: file,
                      title: title,
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      configs: _configs))));
    }
    if (_configs.filterFeatureEnabled) {
      imageEditors[_configs.tr(IPMessage.imageFilterTitle)] = EditorParams(
          title: _configs.tr(IPMessage.imageFilterTitle),
          icon: Icons.auto_awesome,
          onEditorEvent: (
                  {required BuildContext context,
                  required File file,
                  required String title,
                  int maxWidth = 1080,
                  int maxHeight = 1920,
                  int compressQuality = 90,
                  ImagePickerConfigs? configs}) async =>
              Navigator.of(context).push(MaterialPageRoute<File>(
                  fullscreenDialog: true,
                  builder: (context) => ImageFilter(
                      file: file,
                      title: title,
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      configs: _configs))));
    }
    if (_configs.stickerFeatureEnabled) {
      imageEditors[_configs.tr(IPMessage.imageStickerTitle)] = EditorParams(
          title: _configs.tr(IPMessage.imageStickerTitle),
          icon: Icons.insert_emoticon_rounded,
          onEditorEvent: (
                  {required BuildContext context,
                  required File file,
                  required String title,
                  int maxWidth = 1080,
                  int maxHeight = 1920,
                  int compressQuality = 90,
                  ImagePickerConfigs? configs}) async =>
              Navigator.of(context).push(MaterialPageRoute<File>(
                  fullscreenDialog: true,
                  builder: (context) => ImageSticker(
                      file: file,
                      title: title,
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      configs: _configs))));
    }

    // Add custom image editors
    imageEditors.addAll(_configs.externalImageEditors);

    // Create image editor icons
    return imageEditors.values
        .map((e) => GestureDetector(
              child: Icon(e.icon, size: 32, color: Colors.white),
              onTap: () async {
                final image = await _imagePreProcessing(
                    _images[_currentIndex!].modifiedPath);
                final File? outputFile = await e.onEditorEvent(
                    context: context,
                    file: image,
                    title: e.title,
                    maxWidth: _configs.imageConfigs.maxWidth,
                    maxHeight: _configs.imageConfigs.maxHeight,
                    configs: _configs);
                if (outputFile != null) {
                  setState(() {
                    _images[_currentIndex!].modifiedPath = outputFile.path;
                    widget.onChanged?.call(_images);
                  });
                }
              },
            ))
        .toList();
  }

  /// Pre-processing function.
  Future<File> _imagePreProcessing(String? path) async {
    if (_configs.imagePreProcessingBeforeEditingEnabled) {
      return ImageUtils.compressResizeImage(path!,
          maxWidth: _configs.imageConfigs.maxWidth,
          maxHeight: _configs.imageConfigs.maxHeight,
          quality: _configs.imageConfigs.compressQuality);
    }
    return File(path!);
  }

  /// On changed event
  void onPageChanged(int? index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final hasImages = _images.isNotEmpty;

    // Use theme based AppBar colors if config values are not defined.
    // The logic is based on same approach that is used in AppBar SDK source.
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppBarTheme appBarTheme = AppBarTheme.of(context);
    final Color _appBarBackgroundColor = _configs.appBarBackgroundColor ??
        appBarTheme.backgroundColor ??
        (colorScheme.brightness == Brightness.dark
            ? colorScheme.surface
            : colorScheme.primary);
    final Color _appBarTextColor = _configs.appBarTextColor ??
        appBarTheme.foregroundColor ??
        (colorScheme.brightness == Brightness.dark
            ? colorScheme.onSurface
            : colorScheme.onPrimary);

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            title: Text("${widget.title} (${_currentIndex! + 1} "
                "/ ${_images.length})"),
            backgroundColor: _appBarBackgroundColor,
            foregroundColor: _appBarTextColor,
            actions: [
              GestureDetector(
                onTap: hasImages
                    ? () async {
                        await showConfirmDialog(
                            context: context,
                            title: IPMessage.confirm,
                            content: IPMessage.confirmDelete,
                            configs: _configs,
                            onConfirm: () {
                              Navigator.of(context).pop();
                              setState(() {
                                final deleteIndex = _currentIndex!;
                                if (_images.length > 1) {
                                  _currentIndex = max(_currentIndex! - 1, 0);
                                } else {
                                  _currentIndex = -1;
                                }
                                _images.removeAt(deleteIndex);
                                widget.onChanged?.call(_images);
                              });
                              return true;
                            });
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.delete,
                      size: 32,
                      color:
                          hasImages ? _configs.appBarTextColor : Colors.grey),
                ),
              ),
            ]),
        body: SafeArea(
          child: hasImages
              ? Column(children: [
                  _buildPhotoViewGallery(context),
                  _buildReorderableSelectedImageList(context),
                  _buildEditorControls(
                    context,
                    _appBarBackgroundColor,
                    _appBarTextColor,
                  ),
                ])
              : Center(
                  child: Text(_configs.tr(IPMessage.noImages),
                      style: const TextStyle(color: Colors.grey))),
        ));
  }

  /// Image viewer as gallery for selected image.
  Widget _buildPhotoViewGallery(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: _images.length,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildCurrentImageInfoView(context),
          ),
          if (_configs.ocrExtractFunc != null)
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildOCRTextView(context)),
        ],
      ),
    );
  }

  /// Build an image viewer.
  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final item = _images[index];
    return PhotoViewGalleryPageOptions(
        imageProvider: FileImage(File(item.modifiedPath)),
        initialScale: PhotoViewComputedScale.contained,
        minScale: PhotoViewComputedScale.contained * 0.5,
        maxScale: PhotoViewComputedScale.covered * 1.1);
  }

  /// Reorder selected image list.
  bool? _reorderSelectedImageList(int oldIndex, int newIndex) {
    if (oldIndex < 0 || newIndex < 0) return false;
    int _newIndex = newIndex;
    setState(() {
      if (_newIndex > oldIndex) {
        _newIndex -= 1;
      }
      final items = _images.removeAt(oldIndex);
      _images.insert(_newIndex, items);
      widget.onChanged?.call(_images);
      return;
    });
    return null;
  }

  /// Build reorderable selected image list.
  Widget _buildReorderableSelectedImageList(BuildContext context) {
    Widget makeThumbnail(String? path) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(File(path!),
              fit: BoxFit.cover,
              width: _configs.thumbWidth.toDouble(),
              height: _configs.thumbHeight.toDouble()));
    }

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        height: (_configs.thumbHeight + 8).toDouble(),
        child: Theme(
          data: ThemeData(
              canvasColor: Colors.transparent, shadowColor: Colors.red),
          child: ReorderableListView(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              onReorder: _reorderSelectedImageList,
              children: <Widget>[
                for (var i = 0; i < _images.length; i++)
                  Container(
                      key: ValueKey(i.toString()),
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        border: Border.all(
                            color: (i == _currentIndex)
                                ? Colors.blue
                                : Colors.white,
                            width: 3),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            _currentIndex = i;
                          });

                          if (widget.pageController.hasClients) {
                            await widget.pageController.animateToPage(
                                _currentIndex!,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                          }
                        },
                        child: makeThumbnail(_images[i].modifiedPath),
                      ))
              ]),
        ));
  }

  /// Image viewer for current image.
  Widget _buildCurrentImageInfoView(BuildContext context) {
    final image = _images[_currentIndex!];

    Future<ImageObject>? _getImageInfos(ImageObject image) async {
      // Get image resolution
      final retImg = await ImageUtils.getImageInfo(image);

      // Get detected objects
      if (_configs.labelDetectFunc != null &&
          (retImg.recognitions?.isEmpty ?? true)) {
        final _objects =
            await _configs.labelDetectFunc!.call(retImg.modifiedPath);
        if (_objects.isNotEmpty) retImg.recognitions = _objects;
      }

      // Get OCR from image
      if (_configs.ocrExtractFunc != null &&
          (retImg.ocrText?.isEmpty ?? true)) {
        final text = await _configs.ocrExtractFunc!.call(retImg.modifiedPath);
        if (text.isNotEmpty) retImg.ocrText = text;
      }
      return retImg;
    }

    return FutureBuilder<ImageObject>(
        future: _getImageInfos(image),
        builder: (BuildContext context, AsyncSnapshot<ImageObject> snapshot) {
          if (snapshot.hasData) {
            final image = snapshot.data!;
            return Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(4),
                  color: Colors.black.withOpacity(0.5),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display image resolution
                        Text("${image.modifiedWidth}x${image.modifiedHeight}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        // Display detected labels
                        if (image.recognitions != null &&
                            image.recognitions!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Wrap(
                                children: image.recognitions!.map((e) {
                              final isSelected = e.label == image.label;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (image.label != e.label) {
                                      image.label = e.label;
                                    } else {
                                      image.label = "";
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 4),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 4),
                                  child: Text(
                                      "${e.label}:${e.confidence?.toStringAsFixed(2) ?? ""}",
                                      style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey)),
                                ),
                              );
                            }).toList()),
                          ),
                      ]),
                ),
              ],
            );
          } else {
            return const CupertinoActivityIndicator();
          }
        });
  }

  /// Build widget for displaying OCR information
  Widget _buildOCRTextView(BuildContext context) {
    final image = _images[_currentIndex ?? 0];
    return Stack(
      fit: StackFit.passthrough,
      children: [
        if (image.ocrText?.isNotEmpty ?? false)
          GestureDetector(
            onTap: () async {
              _textFieldController.text = image.ocrText ?? "";
              await showDialog<void>(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          Container(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 3,
                              margin:
                                  const EdgeInsets.only(top: 40, bottom: 50),
                              padding: const EdgeInsets.all(12),
                              child: TextField(
                                maxLines: null,
                                controller: _textFieldController,
                              )),
                          Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                child: Row(children: [
                                  Text(_configs.tr(IPMessage.editText),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  const Spacer(),
                                  GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          _textFieldController.text =
                                              image.ocrOriginalText ?? "";
                                        });
                                      },
                                      child: const Icon(
                                          Icons.wifi_protected_setup,
                                          size: 32,
                                          color: Colors.blue))
                                ]),
                              )),
                          Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black87,
                                        backgroundColor: Colors.grey.shade200,
                                        padding: EdgeInsets.zero,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                        ),
                                      ),
                                      child: Text(_configs.tr(IPMessage.clear),
                                          style: const TextStyle(
                                              color: Colors.red)),
                                      onPressed: () {
                                        setState(() {
                                          _textFieldController.text = "";
                                        });
                                      },
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue,
                                        backgroundColor: Colors.blue,
                                        padding: EdgeInsets.zero,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30)),
                                        ),
                                      ),
                                      child: Text(_configs.tr(IPMessage.save),
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      onPressed: () {
                                        setState(() {
                                          image.ocrText =
                                              _textFieldController.text;
                                          Navigator.pop(context);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ))
                        ],
                      ),
                    );
                  });
            },
            child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minHeight: 100),
                child: Text(
                  image.ocrText ?? "",
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 10,
                )),
          )
        else
          const SizedBox(height: 100, width: double.infinity),
        Positioned(
          bottom: 10,
          left: 10,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              backgroundColor: Colors.blue,
              padding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                Text(_configs.tr(IPMessage.ocr),
                    style: const TextStyle(color: Colors.white)),
                if (_isProcessing)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: CupertinoActivityIndicator(),
                  )
              ]),
            ),
            onPressed: () async {
              if (image.ocrOriginalText?.isEmpty ?? true) {
                setState(() {
                  _isProcessing = true;
                });

                final text = await _configs.ocrExtractFunc!
                    .call(image.modifiedPath, isCloudService: true);
                setState(() {
                  _isProcessing = false;

                  if (text.isNotEmpty) {
                    image.ocrText = text;
                    image.ocrOriginalText = text;
                  }
                });
              } else {
                setState(() {
                  image.ocrText = image.ocrOriginalText;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  /// Build editor controls.
  Widget _buildEditorControls(
      BuildContext context, Color toolbarColor, Color toolbarWidgetColor) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        ..._buildImageEditorControls(context, toolbarColor, toolbarWidgetColor),
        _buildEditorResetButton(context),
      ]),
    );
  }

  /// Build reset button for image editor.
  Widget _buildEditorResetButton(BuildContext context) {
    final imageChanged = _images[_currentIndex!].modifiedPath !=
        _images[_currentIndex!].originalPath;
    return GestureDetector(
      onTap: imageChanged
          ? () async {
              await showConfirmDialog(
                  context: context,
                  title: IPMessage.confirm,
                  content: IPMessage.confirmResetChanges,
                  configs: _configs,
                  onConfirm: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _images[_currentIndex!].modifiedPath =
                          _images[_currentIndex!].originalPath;
                      widget.onChanged?.call(_images);
                    });
                    return true;
                  });
            }
          : null,
      child: Icon(Icons.replay,
          size: 32, color: imageChanged ? Colors.white : Colors.grey),
    );
  }
}
