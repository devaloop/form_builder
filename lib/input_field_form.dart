library devaloop_form_builder;

import 'dart:io';

import 'package:devaloop_form_builder/input_field_date_time.dart';
import 'package:devaloop_form_builder/input_field_option.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:devaloop_form_builder/form_builder.dart';
import 'package:intl/intl.dart';

class InputFieldForm extends StatefulWidget {
  final String label;
  final bool isRequired;
  final String? helperText;
  final InputFieldFormController controller;
  final String? Function(String? errorMessage)? onValidating;
  final bool? isEditable;
  final List<Input> inputFields;
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
  final bool? isMultiInputForm;

  const InputFieldForm({
    super.key,
    required this.label,
    required this.isRequired,
    this.helperText,
    required this.controller,
    this.onValidating,
    this.isEditable,
    required this.inputFields,
    this.onInitial,
    this.onBeforeValidation,
    this.onAfterValidation,
    this.additionalButtons,
    this.isMultiInputForm,
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
    if (widget.controller.getData().isNotEmpty) {
      _controller.text = 'Data Filled';
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
                    icon: widget.isMultiInputForm ?? false
                        ? const Icon(Icons.add)
                        : const Icon(Icons.edit),
                    onPressed: widget.isEditable ?? false
                        ? () {
                            Future<void> navigateToInputFieldFormPage(
                                BuildContext context) async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InputFieldFormPage(
                                    title: widget.label,
                                    inputFields: widget.inputFields,
                                    additionalButtons: widget.additionalButtons,
                                    isFormEditable: widget.isEditable,
                                    onAfterValidation: widget.onAfterValidation,
                                    onBeforeValidation:
                                        widget.onBeforeValidation,
                                    onInitial: widget.isMultiInputForm ?? false
                                        ? null
                                        : (context, inputValues) {
                                            for (var index = 0;
                                                index <
                                                    widget.controller
                                                        .getData()
                                                        .length;
                                                index++) {
                                              for (var e
                                                  in widget.inputFields) {
                                                if (e.runtimeType ==
                                                    InputText) {
                                                  inputValues[e.name]!
                                                      .setString(widget
                                                          .controller
                                                          .getData()[index]
                                                          .entries
                                                          .where((element) =>
                                                              element.key ==
                                                              e.name)
                                                          .firstOrNull
                                                          ?.value);
                                                } else if (e.runtimeType ==
                                                    InputDateTime) {
                                                  inputValues[e.name]!
                                                      .setDateTime(widget
                                                          .controller
                                                          .getData()[index]
                                                          .entries
                                                          .where((element) =>
                                                              element.key ==
                                                              e.name)
                                                          .firstOrNull
                                                          ?.value);
                                                } else if (e.runtimeType ==
                                                    InputNumber) {
                                                  inputValues[e.name]!
                                                      .setNumber(widget
                                                          .controller
                                                          .getData()[index]
                                                          .entries
                                                          .where((element) =>
                                                              element.key ==
                                                              e.name)
                                                          .firstOrNull
                                                          ?.value);
                                                } else if (e.runtimeType ==
                                                    InputOption) {
                                                  inputValues[e.name]!
                                                      .setListOptionValues(widget
                                                              .controller
                                                              .getData()[index]
                                                              .entries
                                                              .where((element) =>
                                                                  element.key ==
                                                                  e.name)
                                                              .firstOrNull
                                                              ?.value ??
                                                          []);
                                                } else if (e.runtimeType ==
                                                    InputForm) {
                                                  inputValues[e.name]!
                                                      .setFormValues(widget
                                                              .controller
                                                              .getData()[index]
                                                              .entries
                                                              .where((element) =>
                                                                  element.key ==
                                                                  e.name)
                                                              .firstOrNull
                                                              ?.value ??
                                                          []);
                                                } else {}
                                              }
                                            }
                                          },
                                  ),
                                ),
                              );

                              if (!mounted) return;

                              if (result != null) {
                                setState(() {
                                  if (!(widget.isMultiInputForm ?? false)) {
                                    widget.controller.clear();
                                  }
                                  widget.controller.add(result);
                                  _controller.text = 'Data Filled';
                                });
                              }
                            }

                            navigateToInputFieldFormPage(context);
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
                  Future<void> navigateToInputFieldFormPage(
                      BuildContext context) async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InputFieldFormPage(
                          title: widget.label,
                          inputFields: widget.inputFields,
                          additionalButtons: widget.additionalButtons,
                          isFormEditable: widget.isEditable,
                          onAfterValidation: widget.onAfterValidation,
                          onBeforeValidation: widget.onBeforeValidation,
                          onInitial: widget.isMultiInputForm ?? false
                              ? null
                              : (context, inputValues) {
                                  for (var index = 0;
                                      index <
                                          widget.controller.getData().length;
                                      index++) {
                                    for (var e in widget.inputFields) {
                                      if (e.runtimeType == InputText) {
                                        inputValues[e.name]!.setString(widget
                                            .controller
                                            .getData()[index]
                                            .entries
                                            .where((element) =>
                                                element.key == e.name)
                                            .firstOrNull
                                            ?.value);
                                      } else if (e.runtimeType ==
                                          InputDateTime) {
                                        inputValues[e.name]!.setDateTime(widget
                                            .controller
                                            .getData()[index]
                                            .entries
                                            .where((element) =>
                                                element.key == e.name)
                                            .firstOrNull
                                            ?.value);
                                      } else if (e.runtimeType == InputNumber) {
                                        inputValues[e.name]!.setNumber(widget
                                            .controller
                                            .getData()[index]
                                            .entries
                                            .where((element) =>
                                                element.key == e.name)
                                            .firstOrNull
                                            ?.value);
                                      } else if (e.runtimeType == InputOption) {
                                        inputValues[e.name]!
                                            .setListOptionValues(widget
                                                    .controller
                                                    .getData()[index]
                                                    .entries
                                                    .where((element) =>
                                                        element.key == e.name)
                                                    .firstOrNull
                                                    ?.value ??
                                                []);
                                      } else if (e.runtimeType == InputForm) {
                                        inputValues[e.name]!.setFormValues(
                                            widget.controller
                                                    .getData()[index]
                                                    .entries
                                                    .where((element) =>
                                                        element.key == e.name)
                                                    .firstOrNull
                                                    ?.value ??
                                                []);
                                      } else {}
                                    }
                                  }
                                },
                        ),
                      ),
                    );

                    if (!mounted) return;

                    if (result != null) {
                      setState(() {
                        if (!(widget.isMultiInputForm ?? false)) {
                          widget.controller.clear();
                        }
                        widget.controller.add(result);
                        _controller.text = 'Data Filled';
                      });
                    }
                  }

                  navigateToInputFieldFormPage(context);
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
                //double boxWidth = constraints.maxWidth;
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
                      title: Wrap(
                        children: widget.inputFields.map((e) {
                          List<Widget> listDataView = [];
                          String value = '';
                          if (e.runtimeType == InputDateTime) {
                            DateTime? data = widget.controller
                                .getData()[index]
                                .entries
                                .where((element) => element.key == e.name)
                                .firstOrNull
                                ?.value;
                            String strData = '-';
                            if (data != null) {
                              if (((e as InputDateTime).inputDateTimeMode ??
                                      InputDateTimeMode.dateTime) ==
                                  InputDateTimeMode.date) {
                                strData = DateFormat('yyyy-MM-dd').format(data);
                              }
                              if (((e).inputDateTimeMode ??
                                      InputDateTimeMode.dateTime) ==
                                  InputDateTimeMode.time) {
                                strData = DateFormat('HH:mm:ss').format(data);
                              }
                              if (((e).inputDateTimeMode ??
                                      InputDateTimeMode.dateTime) ==
                                  InputDateTimeMode.dateTime) {
                                strData = DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(data);
                              }
                            }
                            value = '${e.label}: $strData';

                            listDataView.add(Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1.0,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(7.5),
                                child: Text(value),
                              ),
                            ));
                          }
                          if (e.runtimeType == InputNumber) {
                            value =
                                '${e.label}: ${widget.controller.getData()[index].entries.where((element) => element.key == e.name).firstOrNull?.value ?? '-'} ';

                            listDataView.add(Card(
                              child: Padding(
                                padding: const EdgeInsets.all(7.5),
                                child: Text(value),
                              ),
                            ));
                          }
                          if (e.runtimeType == InputOption) {
                            List<OptionItem> data = widget.controller
                                    .getData()[index]
                                    .entries
                                    .where((element) => element.key == e.name)
                                    .firstOrNull
                                    ?.value ??
                                [];
                            value =
                                '${e.label}: ${data.isNotEmpty ? ('${data.length} Selected') : '-'}';

                            if (((e as InputOption).isMultiSelection ??
                                    false) ==
                                false) {
                              listDataView.add(Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(7.5),
                                  child: Text(
                                      '${e.label}: ${data.isEmpty ? '-' : data.map((eItem) {
                                            int indexHeader = 0;
                                            return eItem.value
                                                .map((eValue) {
                                                  String? label;
                                                  if (e.dataHeaders != null) {
                                                    try {
                                                      label = e.dataHeaders![
                                                          indexHeader];
                                                    } catch (ex) {
                                                      label = null;
                                                    }
                                                    indexHeader++;
                                                  }
                                                  return (label == null
                                                          ? ''
                                                          : ('$label: ')) +
                                                      eValue;
                                                })
                                                .toList()
                                                .join(' | ');
                                          }).toList().join(', ')} '),
                                ),
                              ));
                            } else {
                              listDataView.add(Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.grey.shade200, width: 1),
                                  borderRadius: BorderRadius.circular(15 + 7.5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(7.5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(value),
                                      ListView.separated(
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            int indexHeader = 0;
                                            return ListTile(
                                              title: Wrap(
                                                children: data[index]
                                                    .value
                                                    .map((fieldItem) {
                                                  String? label;
                                                  if (e.dataHeaders != null) {
                                                    try {
                                                      label = e.dataHeaders![
                                                          indexHeader];
                                                    } catch (ex) {
                                                      label = null;
                                                    }
                                                    indexHeader++;
                                                  }
                                                  return Text((label == null
                                                          ? ''
                                                          : ('$label: ')) +
                                                      fieldItem);
                                                }).toList(),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              const Divider(
                                                height: 1,
                                              ),
                                          itemCount: data.length)
                                    ],
                                  ),
                                ),
                              ));
                            }
                          }
                          if (e.runtimeType == InputText) {
                            value =
                                '${e.label}: ${widget.controller.getData()[index].entries.where((element) => element.key == e.name).firstOrNull?.value ?? '-'} ';

                            listDataView.add(Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1.0,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(7.5),
                                child: Text(value),
                              ),
                            ));
                          }
                          if (e.runtimeType == InputForm) {
                            List<Map<String, dynamic>>? data = widget.controller
                                .getData()[index]
                                .entries
                                .where((element) => element.key == e.name)
                                .firstOrNull
                                ?.value;
                            value =
                                '${e.label}: ${data == null ? '-' : 'Data Filled'}';
                            listDataView.add(Card(
                              color: Colors.white,
                              elevation: 0,
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1.0,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(7.5),
                                child: Text(value),
                              ),
                            ));
                          }
                          return Wrap(
                            children: listDataView,
                          );
                        }).toList(),
                      ),
                      leading: IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: widget.isEditable ?? false
                            ? () {
                                setState(() {
                                  widget.controller.clearAt(index);
                                  if (widget.controller.getData().isEmpty) {
                                    _controller.clear();
                                  }
                                });
                              }
                            : null,
                      ),
                      trailing: widget.isMultiInputForm ?? false
                          ? IconButton(
                              icon: const Icon(Icons.navigate_next),
                              onPressed: widget.isEditable ?? false
                                  ? () {
                                      Future<void> navigateToInputFieldFormPage(
                                          BuildContext context) async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                InputFieldFormPage(
                                              title: widget.label,
                                              inputFields: widget.inputFields,
                                              additionalButtons:
                                                  widget.additionalButtons,
                                              isFormEditable: widget.isEditable,
                                              onAfterValidation:
                                                  widget.onAfterValidation,
                                              onBeforeValidation:
                                                  widget.onBeforeValidation,
                                              onInitial:
                                                  (context, inputValues) {
                                                for (var e
                                                    in widget.inputFields) {
                                                  if (e.runtimeType ==
                                                      InputText) {
                                                    inputValues[e.name]!
                                                        .setString(widget
                                                            .controller
                                                            .getData()[index]
                                                            .entries
                                                            .where((element) =>
                                                                element.key ==
                                                                e.name)
                                                            .firstOrNull
                                                            ?.value);
                                                  } else if (e.runtimeType ==
                                                      InputDateTime) {
                                                    inputValues[e.name]!
                                                        .setDateTime(widget
                                                            .controller
                                                            .getData()[index]
                                                            .entries
                                                            .where((element) =>
                                                                element.key ==
                                                                e.name)
                                                            .firstOrNull
                                                            ?.value);
                                                  } else if (e.runtimeType ==
                                                      InputNumber) {
                                                    inputValues[e.name]!
                                                        .setNumber(widget
                                                            .controller
                                                            .getData()[index]
                                                            .entries
                                                            .where((element) =>
                                                                element.key ==
                                                                e.name)
                                                            .firstOrNull
                                                            ?.value);
                                                  } else if (e.runtimeType ==
                                                      InputOption) {
                                                    inputValues[e.name]!
                                                        .setListOptionValues(widget
                                                                .controller
                                                                .getData()[
                                                                    index]
                                                                .entries
                                                                .where((element) =>
                                                                    element
                                                                        .key ==
                                                                    e.name)
                                                                .firstOrNull
                                                                ?.value ??
                                                            []);
                                                  } else if (e.runtimeType ==
                                                      InputForm) {
                                                    inputValues[e.name]!
                                                        .setFormValues(widget
                                                                .controller
                                                                .getData()[
                                                                    index]
                                                                .entries
                                                                .where((element) =>
                                                                    element
                                                                        .key ==
                                                                    e.name)
                                                                .firstOrNull
                                                                ?.value ??
                                                            []);
                                                  } else {}
                                                }
                                              },
                                            ),
                                          ),
                                        );

                                        if (!mounted) return;

                                        if (result != null) {
                                          setState(() {
                                            widget.controller
                                                .set(index, result);
                                            _controller.text = 'Data Filled';
                                          });
                                        }
                                      }

                                      navigateToInputFieldFormPage(context);
                                    }
                                  : null,
                            )
                          : null,
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
  final List<Input> inputFields;
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
    required this.inputFields,
    this.onInitial,
    this.onBeforeValidation,
    this.onAfterValidation,
    this.additionalButtons,
    this.isFormEditable,
  });

  @override
  State<InputFieldFormPage> createState() => _InputFieldFormPage();
}

class _InputFieldFormPage extends State<InputFieldFormPage> {
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
          inputFields: widget.inputFields,
          onSubmit: (context, inputValues) {
            Map<String, dynamic> controller = {};
            for (var inputField in widget.inputFields) {
              if (inputField.runtimeType == InputText) {
                controller[inputField.name] =
                    inputValues[inputField.name]!.getString();
              }
              if (inputField.runtimeType == InputDateTime) {
                controller[inputField.name] =
                    inputValues[inputField.name]!.getDateTime();
              }
              if (inputField.runtimeType == InputNumber) {
                controller[inputField.name] =
                    inputValues[inputField.name]!.getNumber();
              }
              if (inputField.runtimeType == InputOption) {
                controller[inputField.name] =
                    inputValues[inputField.name]!.getListOptionValues();
              }
              if (inputField.runtimeType == InputForm) {
                controller[inputField.name] =
                    inputValues[inputField.name]!.getFormValues();
              }
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

class InputFieldFormController extends ChangeNotifier {
  List<Map<String, dynamic>> _data = [];

  void add(Map<String, dynamic> item) {
    _data.add(item);
    notifyListeners();
  }

  void set(int index, Map<String, dynamic> item) {
    _data[index] = item;
    notifyListeners();
  }

  void clearAt(int index) {
    _data.removeAt(index);
    notifyListeners();
  }

  List<Map<String, dynamic>> getData() {
    return _data;
  }

  void clear() {
    _data = [];
    notifyListeners();
  }
}
