library devaloop_form_builder;

import 'dart:io';

import 'package:devaloop_form_builder/input_field_date_time.dart';
import 'package:devaloop_form_builder/input_field_option.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:devaloop_form_builder/form_builder.dart';
import 'package:intl/intl.dart';

import 'input_field_number.dart';
import 'input_field_text.dart';

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
  final dynamic Function(
      BuildContext context,
      List<Map<String, dynamic>> previousValue,
      List<Map<String, dynamic>> currentValue)? onValueChanged;
  final InputForm input;

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
    this.onValueChanged,
    required this.input,
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
      _controller.text = '${widget.controller.getData().length} Data Filled';
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
                              var inputValue = InputValue(
                                  controller: widget.controller,
                                  inputField: widget.input);

                              final List<Map<String, dynamic>> prevValue =
                                  List.from(inputValue.getFormValues());

                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StatefulBuilder(
                                      builder: (context, setFormState) {
                                    return InputFieldFormPage(
                                      title: widget.label,
                                      inputFields: widget.inputFields,
                                      additionalButtons:
                                          widget.additionalButtons,
                                      isFormEditable: widget.isEditable,
                                      onAfterValidation:
                                          widget.onAfterValidation,
                                      onBeforeValidation:
                                          widget.onBeforeValidation,
                                      onFormValueChanged:
                                          widget.input.onFormValueChanged,
                                      setFormState: setFormState,
                                      onInitial: widget.isMultiInputForm ??
                                              false
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
                                              }
                                            },
                                    );
                                  }),
                                ),
                              );

                              if (!mounted) return;

                              if (result != null) {
                                setState(() {
                                  if (!(widget.isMultiInputForm ?? false)) {
                                    widget.controller.clear();
                                  }
                                  widget.controller.add(result);
                                  if (widget.controller.getData().isEmpty) {
                                    _controller.clear();
                                  } else {
                                    _controller.text =
                                        '${widget.controller.getData().length} Data Filled';
                                  }
                                });

                                if (widget.onValueChanged != null) {
                                  if (!mounted) return;
                                  widget.onValueChanged!.call(context,
                                      prevValue, inputValue.getFormValues());
                                }
                              }
                            }

                            navigateToInputFieldFormPage(context);
                            setState(() {
                              if (widget.controller.getData().isEmpty) {
                                _controller.clear();
                              } else {
                                _controller.text =
                                    '${widget.controller.getData().length} Data Filled';
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

                if (widget.controller.getData().isNotEmpty) {
                  List<MapEntry<List<Map<String, dynamic>>, List<Input>>> data =
                      [];
                  data.add(MapEntry(
                      widget.controller.getData(), widget.inputFields));

                  MapEntry<
                          MapEntry<bool, MapEntry<int, int>>,
                          List<
                              MapEntry<List<Map<String, dynamic>>,
                                  List<Input>>>> loopCheck =
                      MapEntry(const MapEntry(true, MapEntry(-1, 0)), data);
                  bool isSubFormValid = true;
                  while (
                      loopCheck.key.key == true && loopCheck.value.isNotEmpty) {
                    loopCheck = validateSubForm(loopCheck);
                    if (loopCheck.key.key == false) {
                      isSubFormValid = false;
                    }
                  }
                  if (isSubFormValid == false) {
                    int itemErrorPosition = -1;
                    if (loopCheck.key.value.key == -1) {
                      itemErrorPosition = loopCheck.key.value.value;
                    } else {
                      itemErrorPosition = loopCheck.key.value.key;
                    }
                    return 'Data Item at position $itemErrorPosition is invalid';
                  }
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
                    var inputValue = InputValue(
                        controller: widget.controller,
                        inputField: widget.input);

                    final List<Map<String, dynamic>> prevValue =
                        List.from(inputValue.getFormValues());

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StatefulBuilder(builder: (context, setFormState) {
                          return InputFieldFormPage(
                            title: widget.label,
                            inputFields: widget.inputFields,
                            additionalButtons: widget.additionalButtons,
                            isFormEditable: widget.isEditable,
                            onAfterValidation: widget.onAfterValidation,
                            onBeforeValidation: widget.onBeforeValidation,
                            onFormValueChanged: widget.input.onFormValueChanged,
                            setFormState: setFormState,
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
                                          inputValues[e.name]!.setDateTime(
                                              widget.controller
                                                  .getData()[index]
                                                  .entries
                                                  .where((element) =>
                                                      element.key == e.name)
                                                  .firstOrNull
                                                  ?.value);
                                        } else if (e.runtimeType ==
                                            InputNumber) {
                                          inputValues[e.name]!.setNumber(widget
                                              .controller
                                              .getData()[index]
                                              .entries
                                              .where((element) =>
                                                  element.key == e.name)
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
                          );
                        }),
                      ),
                    );

                    if (!mounted) return;

                    if (result != null) {
                      setState(() {
                        if (!(widget.isMultiInputForm ?? false)) {
                          widget.controller.clear();
                        }
                        widget.controller.add(result);
                        if (widget.controller.getData().isEmpty) {
                          _controller.clear();
                        } else {
                          _controller.text =
                              '${widget.controller.getData().length} Data Filled';
                        }
                      });

                      if (widget.onValueChanged != null) {
                        if (!mounted) return;
                        widget.onValueChanged!.call(
                            context, prevValue, inputValue.getFormValues());
                      }
                    }
                  }

                  navigateToInputFieldFormPage(context);
                  setState(() {
                    if (widget.controller.getData().isEmpty) {
                      _controller.clear();
                    } else {
                      _controller.text =
                          '${widget.controller.getData().length} Data Filled';
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
                                '${e.label}: ${data == null ? '-' : '${widget.controller.getData().length} Data Filled'}';
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
                                var inputValue = InputValue(
                                    controller: widget.controller,
                                    inputField: widget.input);

                                final List<Map<String, dynamic>> prevValue =
                                    List.from(inputValue.getFormValues());
                                setState(() {
                                  widget.controller.clearAt(index);
                                  if (widget.controller.getData().isEmpty) {
                                    _controller.clear();
                                  }
                                });

                                if (widget.onValueChanged != null) {
                                  if (!mounted) return;
                                  widget.onValueChanged!.call(context,
                                      prevValue, inputValue.getFormValues());
                                }
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
                                        var inputValue = InputValue(
                                            controller: widget.controller,
                                            inputField: widget.input);

                                        final List<Map<String, dynamic>>
                                            prevValue = List.from(
                                                inputValue.getFormValues());
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StatefulBuilder(builder:
                                                    (context, setFormState) {
                                              return InputFieldFormPage(
                                                title: widget.label,
                                                inputFields: widget.inputFields,
                                                additionalButtons:
                                                    widget.additionalButtons,
                                                isFormEditable:
                                                    widget.isEditable,
                                                onAfterValidation:
                                                    widget.onAfterValidation,
                                                onBeforeValidation:
                                                    widget.onBeforeValidation,
                                                onFormValueChanged: widget
                                                    .input.onFormValueChanged,
                                                setFormState: setFormState,
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
                                              );
                                            }),
                                          ),
                                        );

                                        if (!mounted) return;

                                        if (result != null) {
                                          setState(() {
                                            widget.controller
                                                .set(index, result);
                                            _controller.clear();
                                            if (widget.controller
                                                .getData()
                                                .isEmpty) {
                                              _controller.clear();
                                            } else {
                                              _controller.text =
                                                  '${widget.controller.getData().length} Data Filled';
                                            }
                                          });

                                          if (widget.onValueChanged != null) {
                                            if (!mounted) return;
                                            widget.onValueChanged!.call(
                                                context,
                                                prevValue,
                                                inputValue.getFormValues());
                                          }
                                        }
                                      }

                                      navigateToInputFieldFormPage(context);
                                      setState(() {
                                        _controller.clear();
                                        if (widget.controller
                                            .getData()
                                            .isEmpty) {
                                          _controller.clear();
                                        } else {
                                          _controller.text =
                                              '${widget.controller.getData().length} Data Filled';
                                        }
                                      });
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

  MapEntry<MapEntry<bool, MapEntry<int, int>>,
          List<MapEntry<List<Map<String, dynamic>>, List<Input>>>>
      validateSubForm(
          MapEntry<MapEntry<bool, MapEntry<int, int>>,
                  List<MapEntry<List<Map<String, dynamic>>, List<Input>>>>
              toBeChecks) {
    bool isValid = true;
    List<MapEntry<List<Map<String, dynamic>>, List<Input>>> nextCheck = [];

    int index = 0;
    for (var toBeCheck in toBeChecks.value) {
      index = 0;
      for (var formValue in toBeCheck.key) {
        index++;
        for (var inputFieldFormInputField in toBeCheck.value) {
          if (inputFieldFormInputField.runtimeType == InputDateTime) {
            var item = inputFieldFormInputField as InputDateTime;
            if (item.isOptional == false) {
              if (formValue[inputFieldFormInputField.name] == null) {
                isValid = false;
                break;
              }
            }
          }
          if (inputFieldFormInputField.runtimeType == InputNumber) {
            var item = inputFieldFormInputField as InputNumber;
            if (item.isOptional == false) {
              if (formValue[inputFieldFormInputField.name] == null) {
                isValid = false;
                break;
              }
            }
            if (formValue[inputFieldFormInputField.name] != null) {
              if (item.inputNumberMode == InputNumberMode.decimal) {
                try {
                  double.tryParse(formValue[inputFieldFormInputField.name]);
                } catch (ex) {
                  isValid = false;
                  break;
                }
              } else {
                try {
                  int.tryParse(formValue[inputFieldFormInputField.name]);
                } catch (ex) {
                  isValid = false;
                  break;
                }
              }
            }
          }
          if (inputFieldFormInputField.runtimeType == InputOption) {
            var item = inputFieldFormInputField as InputOption;
            if (item.isOptional == false) {
              if (formValue[inputFieldFormInputField.name] == null) {
                isValid = false;
                break;
              }
            }
          }
          if (inputFieldFormInputField.runtimeType == InputText) {
            var item = inputFieldFormInputField as InputText;
            if (item.isOptional == false) {
              if (formValue[inputFieldFormInputField.name] == null) {
                isValid = false;
                break;
              }
            }
            if (formValue[inputFieldFormInputField.name] != null) {
              if (item.inputTextMode == InputTextMode.email) {
                if (!RegExp(
                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                    .hasMatch(formValue[inputFieldFormInputField.name])) {
                  isValid = false;
                  break;
                }
              }
            }
          }
          if (inputFieldFormInputField.runtimeType == InputForm) {
            var item = inputFieldFormInputField as InputForm;
            if (item.isOptional == false) {
              if (formValue[inputFieldFormInputField.name] == null) {
                isValid = false;
                break;
              }
            }
            if (formValue[inputFieldFormInputField.name] != null) {
              nextCheck.add(MapEntry(formValue[inputFieldFormInputField.name],
                  inputFieldFormInputField.inputFields));
            }
          }
        }
        if (isValid == false) {
          break;
        }
      }
    }

    return MapEntry(
        MapEntry(
            isValid,
            MapEntry(
                toBeChecks.key.value.key == -1
                    ? index
                    : toBeChecks.key.value.key,
                index)),
        nextCheck);
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
  final dynamic Function(
          BuildContext, Input, dynamic, dynamic, Map<String, InputValue>)?
      onFormValueChanged;
  final void Function(void Function()) setFormState;

  const InputFieldFormPage({
    super.key,
    required this.title,
    required this.inputFields,
    this.onInitial,
    this.onBeforeValidation,
    this.onAfterValidation,
    this.additionalButtons,
    this.isFormEditable,
    this.onFormValueChanged,
    required this.setFormState,
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
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          bottom: 15,
        ),
        child: FormBuilder(
          inputFields: widget.inputFields,
          onValueChanged:
              (context, field, prevValue, currentValue, inputValues) {
            if (widget.onFormValueChanged != null) {
              widget.onFormValueChanged!
                  .call(context, field, prevValue, currentValue, inputValues);
              Future.delayed(
                const Duration(milliseconds: 500),
                () => widget.setFormState(() {}),
              );
            }
          },
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
