library devaloop_form_builder;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:devaloop_form_builder/form_builder.dart';

class InputFieldForm extends StatefulWidget {
  final String label;
  final bool isRequired;
  final String? helperText;
  final Map<String, InputValue> controller;
  final String? Function(String? errorMessage)? onValidating;
  final bool? isEditable;
  final String formName;
  final List<InputField> inputFields;
  final void Function(
      BuildContext context, Map<String, InputValue> inputValues)? onInitial;
  final dynamic Function(
          BuildContext context, Map<String, InputValue> inputValues)?
      onBeforeValidation;
  final dynamic Function(
      BuildContext context,
      Map<String, InputValue> inputValues,
      bool isValid,
      Map<String, String?> errorsMessages)? onAfterValidation;
  final List<AdditionalButton>? additionalButtons;
  final bool? isFormEditable;

  const InputFieldForm({
    super.key,
    required this.label,
    required this.isRequired,
    this.helperText,
    required this.controller,
    this.onValidating,
    this.isEditable,
    required this.formName,
    required this.inputFields,
    this.onInitial,
    this.onBeforeValidation,
    this.onAfterValidation,
    this.additionalButtons,
    this.isFormEditable,
  });

  @override
  State<InputFieldForm> createState() => _InputFieldFormState();
}

class _InputFieldFormState extends State<InputFieldForm> {
  bool _textFieldIsFocused = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _textFieldIsFocused = false;
    if (widget.controller.entries.isNotEmpty) {
      _controller.text = 'Form Filled';
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
                    icon: const Icon(Icons.edit_document),
                    onPressed: widget.isEditable ?? false
                        ? () {
                            Future<void>
                                navigateToInputFieldOptionSearchFormPage(
                                    BuildContext context) async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InputFieldFormPage(
                                    title: widget.label,
                                    formName: widget.formName,
                                    inputFields: widget.inputFields,
                                    additionalButtons: widget.additionalButtons,
                                    isFormEditable: widget.isFormEditable,
                                    onAfterValidation: widget.onAfterValidation,
                                    onBeforeValidation:
                                        widget.onBeforeValidation,
                                    onInitial: widget.onInitial,
                                  ),
                                ),
                              );

                              if (!mounted) return;

                              if (result != null) {
                                setState(() {
                                  (result as Map<String, InputValue>)
                                      .forEach((key, value) {
                                    widget.controller[key] = value;
                                  });
                                  _controller.text = 'Data Filled';
                                });
                              }
                            }

                            navigateToInputFieldOptionSearchFormPage(context);
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
            onTap: () {
              if (!kIsWeb) {
                if (Platform.isAndroid || Platform.isIOS) {
                  Future<void> navigateToInputFieldOptionSearchFormPage(
                      BuildContext context) async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InputFieldFormPage(
                          title: widget.label,
                          formName: widget.formName,
                          inputFields: widget.inputFields,
                          additionalButtons: widget.additionalButtons,
                          isFormEditable: widget.isFormEditable,
                          onAfterValidation: widget.onAfterValidation,
                          onBeforeValidation: widget.onBeforeValidation,
                          onInitial: widget.onInitial,
                        ),
                      ),
                    );

                    if (!mounted) return;

                    if (result != null) {
                      setState(() {
                        (result as Map<String, InputValue>)
                            .forEach((key, value) {
                          widget.controller[key] = value;
                        });
                        _controller.text = 'Data Filled';
                      });
                    }
                  }

                  navigateToInputFieldOptionSearchFormPage(context);
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
          visible: (widget.controller.isNotEmpty ? true : false),
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
                //double boxWidth = constraints.maxWidth;
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    top: 15,
                    bottom: 15,
                  ),
                  shrinkWrap: true,
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Wrap(
                        children: widget.inputFields.map((e) {
                          String value = '';
                          if (e.inputFieldType == InputFieldType.text) {
                            value =
                                '${e.label}: ${widget.controller.entries.where((element) => element.key == e.name).first.value.getString() ?? ''} ';
                          }
                          //TODO Tipe Lain
                          return Text(value);
                        }).toList(),
                      ),
                      leading: IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: widget.isEditable ?? false
                            ? () {
                                setState(() {
                                  widget.controller.clear();
                                  _controller.clear();
                                });
                              }
                            : null,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.navigate_next),
                        onPressed: widget.isEditable ?? false
                            ? () {
                                Future<void>
                                    navigateToInputFieldOptionSearchFormPage(
                                        BuildContext context) async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InputFieldFormPage(
                                        title: widget.label,
                                        formName: widget.formName,
                                        inputFields: widget.inputFields,
                                        additionalButtons:
                                            widget.additionalButtons,
                                        isFormEditable: widget.isFormEditable,
                                        onAfterValidation:
                                            widget.onAfterValidation,
                                        onBeforeValidation:
                                            widget.onBeforeValidation,
                                        onInitial: (context, inputValues) {
                                          for (var element
                                              in widget.inputFields) {
                                            if (element.inputFieldType ==
                                                InputFieldType.text) {
                                              inputValues[element.name]!
                                                  .setString(widget
                                                      .controller[element.name]!
                                                      .getString());
                                            }
                                            //TODO Tipe Lain
                                          }
                                        },
                                      ),
                                    ),
                                  );

                                  if (!mounted) return;

                                  if (result != null) {
                                    setState(() {
                                      (result as Map<String, InputValue>)
                                          .forEach((key, value) {
                                        widget.controller[key] = value;
                                      });
                                      _controller.text = 'Data Filled';
                                    });
                                  }
                                }

                                navigateToInputFieldOptionSearchFormPage(
                                    context);
                              }
                            : null,
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

class InputFieldFormPage extends StatefulWidget {
  final String title;
  final String formName;
  final List<InputField> inputFields;
  final void Function(
      BuildContext context, Map<String, InputValue> inputValues)? onInitial;
  final dynamic Function(
          BuildContext context, Map<String, InputValue> inputValues)?
      onBeforeValidation;
  final dynamic Function(
      BuildContext context,
      Map<String, InputValue> inputValues,
      bool isValid,
      Map<String, String?> errorsMessages)? onAfterValidation;
  final List<AdditionalButton>? additionalButtons;
  final bool? isFormEditable;

  const InputFieldFormPage({
    super.key,
    required this.title,
    required this.formName,
    required this.inputFields,
    this.onInitial,
    this.onBeforeValidation,
    this.onAfterValidation,
    this.additionalButtons,
    this.isFormEditable,
  });

  @override
  State<InputFieldFormPage> createState() => _InputFieldOptionSearchFormPage();
}

class _InputFieldOptionSearchFormPage extends State<InputFieldFormPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarDividerColor: Colors.white,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          bottom: 15,
        ),
        child: FormBulder(
          formName: widget.formName,
          inputFields: widget.inputFields,
          onSubmit: (context, inputValues) {
            Map<String, InputValue> controller = {};
            for (var inputField in widget.inputFields) {
              controller[inputField.name] = inputValues[inputField.name]!;
            }

            Navigator.pop(context, controller);
          },
          additionalButtons: widget.additionalButtons,
          isFormEditable: widget.isFormEditable,
          onAfterValidation: widget.onAfterValidation,
          onBeforeValidation: widget.onBeforeValidation,
          onInitial: widget.onInitial,
          submitButtonSettings: const SubmitButtonSettings(
            label: 'Fill',
            icon: Icon(Icons.edit_document),
          ),
        ),
      ),
    );
  }
}
