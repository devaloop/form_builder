library devaloop_form_builder;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InputFieldFile extends StatefulWidget {
  final String label;
  final bool isRequired;
  final String? helperText;
  final InputFieldFileController controller;
  final bool isMultiSelection;
  final String? Function(String? errorMessage)? onValidating;
  final bool? isEditable;
  final FileType fileType;
  final void Function(PlatformFile file)? onDownload;

  const InputFieldFile({
    super.key,
    required this.label,
    required this.isRequired,
    this.helperText,
    required this.controller,
    required this.isMultiSelection,
    this.onValidating,
    this.isEditable,
    required this.fileType,
    this.onDownload,
  });

  @override
  State<InputFieldFile> createState() => _InputFieldFileState();
}

class _InputFieldFileState extends State<InputFieldFile> {
  bool _textFieldIsFocused = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _textFieldIsFocused = false;
    if (widget.controller.getData().isNotEmpty) {
      _controller.text =
          '${widget.controller.getData().length} Option Selected';
    } else {
      _controller.clear();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Focus(
          child: TextFormField(
            controller: _controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLines: null,
            decoration: InputDecoration(
              labelText:
                  widget.label + (widget.isRequired ? '' : ' - Optional'),
              helperText: widget.helperText,
              helperMaxLines: 100,
              suffixIcon: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  IconButton(
                    icon: widget.isMultiSelection
                        ? const Icon(Icons.add)
                        : const Icon(Icons.navigate_next),
                    onPressed: widget.isEditable ?? false
                        ? () async {
                            final result = await FilePicker.platform.pickFiles(
                              withData: true,
                              type: widget.fileType,
                              allowMultiple: widget.isMultiSelection,
                            );

                            if (result == null) return;

                            setState(() {
                              if (widget.isMultiSelection == true) {
                                for (var file in result.files) {
                                  widget.controller.add(file);
                                }
                              } else {
                                widget.controller.add(result.files.first);
                              }

                              if (widget.controller.getData().isNotEmpty) {
                                _controller.text =
                                    '${widget.controller.getData().length} File Added';
                              } else {
                                _controller.clear();
                              }
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
            validator: (value) {
              validation() {
                if (widget.isRequired && (value == null || value.isEmpty)) {
                  return 'Required';
                }

                return null;
              }

              String? errorMessage = validation.call();
              if (widget.onValidating != null) {
                return widget.onValidating!.call(errorMessage);
              }
              return errorMessage;
            },
            readOnly: true,
            onTap: () async {
              if (!kIsWeb) {
                if (Platform.isAndroid || Platform.isIOS) {
                  final result = await FilePicker.platform.pickFiles(
                    withData: true,
                    type: widget.fileType,
                    allowMultiple: widget.isMultiSelection,
                  );

                  if (result == null) return;

                  setState(() {
                    if (widget.isMultiSelection == true) {
                      for (var file in result.files) {
                        widget.controller.add(file);
                      }
                    } else {
                      widget.controller.add(result.files.first);
                    }

                    if (widget.controller.getData().isNotEmpty) {
                      _controller.text =
                          '${widget.controller.getData().length} File Added';
                    } else {
                      _controller.clear();
                    }
                  });
                }
              }
            },
          ),
          onFocusChange: (isFocused) {
            setState(() {
              _textFieldIsFocused = isFocused;
            });
          },
        ),
        Visibility(
          visible: (widget.controller.getData().isNotEmpty ? true : false),
          child: Card(
            shape: Border(
              bottom: BorderSide(
                color: (_textFieldIsFocused
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black26),
                width: 2,
              ),
            ),
            elevation: 0,
            color: Colors.transparent,
            margin: const EdgeInsets.only(
              left: 0,
              right: 0,
              top: 1,
              bottom: 0,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    top: 15,
                    bottom: 15,
                  ),
                  shrinkWrap: true,
                  itemCount: widget.controller.getData().length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: IconButton(
                          onPressed: () {
                            setState(() {
                              widget.controller.getData().removeAt(index);

                              if (widget.controller.getData().isNotEmpty) {
                                _controller.text =
                                    '${widget.controller.getData().length} File Added';
                              } else {
                                _controller.clear();
                              }
                            });
                          },
                          icon: const Icon(Icons.remove)),
                      title: Text(widget.controller.getData()[index].name),
                      trailing: widget.onDownload == null
                          ? null
                          : IconButton(
                              onPressed: () {
                                widget.onDownload!
                                    .call(widget.controller.getData()[index]);
                              },
                              icon: const Icon(Icons.download),
                            ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class InputFieldFileController extends ChangeNotifier {
  List<PlatformFile> _data = [];

  void add(PlatformFile item) {
    _data.add(item);
    notifyListeners();
  }

  List<PlatformFile> getData() {
    return _data;
  }

  void clear() {
    _data = [];
    notifyListeners();
  }
}
