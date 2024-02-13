library devaloop_form_builder;

import 'package:devaloop_form_builder/input_field_file.dart';
import 'package:devaloop_form_builder/input_field_form.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:devaloop_form_builder/input_field_date_time.dart';
import 'package:devaloop_form_builder/input_field_number.dart';
import 'package:devaloop_form_builder/input_field_option.dart';
import 'package:devaloop_form_builder/input_field_text.dart';
import 'package:intl/intl.dart';

class FormBuilder extends StatefulWidget {
  const FormBuilder({
    super.key,
    this.formName,
    required this.inputFields,
    this.onInitial,
    this.onBeforeValidation,
    this.onAfterValidation,
    required this.onSubmit,
    this.submitButtonSettings,
    this.additionalButtons,
    this.isFormEditable,
    this.onValueChanged,
  });

  final String? formName;
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
  final dynamic Function(
      BuildContext context, Map<String, InputValue> inputValues) onSubmit;
  final SubmitButtonSettings? submitButtonSettings;
  final List<AdditionalButton>? additionalButtons;
  final bool? isFormEditable;
  final dynamic Function(
      BuildContext context,
      Input field,
      dynamic previousValue,
      dynamic currentValue,
      Map<String, InputValue> inputValues)? onValueChanged;

  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  final List<dynamic> _controllers = [];
  late Map<Input, String?> _errors = {};
  late Map<String, String?> _additionalErrorOnAfterValidation = {};
  final _formKey = GlobalKey<FormState>();
  late Map<String, InputValue> _inputValues;
  late List<bool> _isSubmittings;
  bool? _isEditable;

  @override
  void initState() {
    for (var e in widget.inputFields) {
      if (e.runtimeType == InputText) {
        _controllers.add(TextEditingController());
      } else if (e.runtimeType == InputNumber) {
        _controllers.add(TextEditingController());
      } else if (e.runtimeType == InputOption) {
        _controllers.add(InputFieldOptionController());
      } else if (e.runtimeType == InputDateTime) {
        _controllers.add(TextEditingController());
      } else if (e.runtimeType == InputForm) {
        _controllers.add(InputFieldFormController());
      } else if (e.runtimeType == InputFile) {
        _controllers.add(InputFieldFileController());
      } else {
        throw Exception('Unsupported InputFieldType ${e.runtimeType}');
      }
    }
    _inputValues = {
      for (int i = 0; i < widget.inputFields.length; i++)
        widget.inputFields[i].name: InputValue(
          controller: _controllers[i],
          inputField: widget.inputFields[i],
        )
    };

    if (widget.onInitial != null) {
      widget.onInitial!.call(context, _inputValues);
    }

    _isSubmittings = List.generate(
        (widget.additionalButtons?.length ?? 0) + 1, (index) => false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    List<FilledButton> listAdditionalButtons = [];
    for (var i = 0; i < _isSubmittings.length; i++) {
      if (i == _isSubmittings.length - 1) {
        listAdditionalButtons.add(FilledButton.icon(
          onPressed:
              _isSubmittings.where((element) => element == true).isNotEmpty
                  ? null
                  : () async {
                      setState(() {
                        _isSubmittings[i] = true;
                        _isEditable = false;
                      });
                      await onSubmit(context);
                      setState(() {
                        _isSubmittings[i] = false;
                        _isEditable = null;
                      });
                    },
          label: Text(widget.submitButtonSettings?.label ?? 'Submit'),
          icon: _isSubmittings[i] == true
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey,
                  ),
                )
              : widget.submitButtonSettings != null
                  ? widget.submitButtonSettings!.icon
                  : const Icon(Icons.arrow_upward),
        ));
      } else {
        AdditionalButton additionalButton = widget.additionalButtons![i];
        listAdditionalButtons.add(FilledButton.icon(
          onPressed:
              _isSubmittings.where((element) => element == true).isNotEmpty
                  ? null
                  : () async {
                      setState(() {
                        _isSubmittings[i] = true;
                        _isEditable = false;
                      });
                      await additionalButton.onTap.call();
                      setState(() {
                        _isSubmittings[i] = false;
                        _isEditable = null;
                      });
                    },
          label: Text(additionalButton.label),
          icon: _isSubmittings[i] == true
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey,
                  ),
                )
              : additionalButton.icon,
        ));
      }
    }

    var fieldOptionFormAndFile = widget.inputFields
        .where(
            (e) => [InputForm, InputOption, InputFile].contains(e.runtimeType))
        .toList();

    var fieldTextMultiLine = widget.inputFields.where((e) {
      if (e.runtimeType == InputText) {
        return (e as InputText).isMultilines == true ? true : false;
      } else {
        return false;
      }
    }).toList();

    var fieldTextAndDate = widget.inputFields
        .where((e) => !fieldOptionFormAndFile.contains(e))
        .where((e) => !fieldTextMultiLine.contains(e))
        .toList();

    var fieldOdd = [];

    if (fieldTextAndDate.length % 2 != 0) {
      fieldOdd.add(fieldTextAndDate.last);
      fieldTextAndDate.removeAt(fieldTextAndDate.length - 1);
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.formName != null)
            Text(
              widget.formName!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          LayoutBuilder(builder: (context, constraints) {
            double widthField = widget.inputFields.length == 1 || isPortrait
                ? constraints.maxWidth
                : (constraints.maxWidth / 2) - 7.5;
            var widgets = fieldTextAndDate
                .map(
                  (e) => SizedBox(
                    width: widthField,
                    child: getField(e),
                  ),
                )
                .toList();
            widgets.addAll(fieldOdd
                .map(
                  (e) => SizedBox(
                    width: constraints.maxWidth,
                    child: getField(e),
                  ),
                )
                .toList());
            widgets.addAll(fieldOptionFormAndFile
                .map(
                  (e) => SizedBox(
                    width: constraints.maxWidth,
                    child: getField(e),
                  ),
                )
                .toList());
            widgets.addAll(fieldTextMultiLine
                .map(
                  (e) => SizedBox(
                    width: constraints.maxWidth,
                    child: getField(e),
                  ),
                )
                .toList());
            return Wrap(
              spacing: 7.5,
              runSpacing: 7.5,
              alignment: WrapAlignment.spaceBetween,
              runAlignment: WrapAlignment.start,
              children: widgets,
            );
          }),
          const SizedBox(
            height: 7.5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  direction: Axis.horizontal,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  runAlignment: WrapAlignment.end,
                  runSpacing: 7.5,
                  spacing: 7.5,
                  children: listAdditionalButtons,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getField(Input e) {
    if (e.runtimeType == InputDateTime) {
      e = (e as InputDateTime);
      return InputFieldDateTime(
        controller: _controllers[
            widget.inputFields.indexWhere((element) => element == e)],
        label: e.label,
        helperText: e.helperText,
        isRequired: !(e.isOptional ?? false),
        inputDateTimeMode: e.inputDateTimeMode,
        onValidating: (errorMessage) {
          _errors[e] = errorMessage;

          var additionalErrorMessage = _additionalErrorOnAfterValidation.entries
              .where((element) => element.key == e.name)
              .map((e) => e.value ?? '')
              .toList()
              .join(', ');
          if (additionalErrorMessage.isEmpty && errorMessage == null) {
            return null;
          }
          if (errorMessage != null && additionalErrorMessage != '') {
            additionalErrorMessage = ', $additionalErrorMessage';
          }
          return (errorMessage ?? '') + additionalErrorMessage;
        },
        isEditable: _isEditable ?? widget.isFormEditable ?? true,
        onValueChanged: (context, previousValue, currentValue) {
          if (widget.onValueChanged != null) {
            widget.onValueChanged!
                .call(context, e, previousValue, currentValue, _inputValues);
          }
        },
        input: e,
      );
    } else if (e.runtimeType == InputNumber) {
      e = (e as InputNumber);
      return InputFieldNumber(
        controller: _controllers[
            widget.inputFields.indexWhere((element) => element == e)],
        label: e.label,
        helperText: e.helperText,
        isRequired: !(e.isOptional ?? false),
        inputFieldNumberMode: e.inputNumberMode,
        onValidating: (errorMessage) {
          _errors[e] = errorMessage;

          var additionalErrorMessage = _additionalErrorOnAfterValidation.entries
              .where((element) => element.key == e.name)
              .map((e) => e.value ?? '')
              .toList()
              .join(', ');
          if (additionalErrorMessage.isEmpty && errorMessage == null) {
            return null;
          }
          if (errorMessage != null && additionalErrorMessage != '') {
            additionalErrorMessage = ', $additionalErrorMessage';
          }
          return (errorMessage ?? '') + additionalErrorMessage;
        },
        isEditable: _isEditable ?? widget.isFormEditable ?? true,
        onValueChanged: (context, previousValue, currentValue) {
          if (widget.onValueChanged != null) {
            widget.onValueChanged!
                .call(context, e, previousValue, currentValue, _inputValues);
          }
        },
        input: e,
      );
    } else if (e.runtimeType == InputOption) {
      e = (e as InputOption);
      return InputFieldOption(
        controller: _controllers[
            widget.inputFields.indexWhere((element) => element == e)],
        label: e.label,
        helperText: e.helperText,
        isRequired: !(e.isOptional ?? false),
        optionData: e.optionData,
        dataHeaders: e.dataHeaders,
        searchFields: e.optionSearchForm?.searchFields,
        searchProcess: e.optionSearchForm?.searchProcess,
        isMultiSelection: e.isMultiSelection,
        onValidating: (errorMessage) {
          _errors[e] = errorMessage;

          var additionalErrorMessage = _additionalErrorOnAfterValidation.entries
              .where((element) => element.key == e.name)
              .map((e) => e.value ?? '')
              .toList()
              .join(', ');
          if (additionalErrorMessage.isEmpty && errorMessage == null) {
            return null;
          }
          if (errorMessage != null && additionalErrorMessage != '') {
            additionalErrorMessage = ', $additionalErrorMessage';
          }
          return (errorMessage ?? '') + additionalErrorMessage;
        },
        isEditable: _isEditable ?? widget.isFormEditable ?? true,
        onValueChanged: (context, previousValue, currentValue) {
          if (widget.onValueChanged != null) {
            widget.onValueChanged!
                .call(context, e, previousValue, currentValue, _inputValues);
          }
        },
        input: e,
      );
    } else if (e.runtimeType == InputText) {
      e = (e as InputText);
      return InputFieldText(
        controller: _controllers[
            widget.inputFields.indexWhere((element) => element == e)],
        label: e.label,
        helperText: e.helperText,
        isRequired: !(e.isOptional ?? false),
        isMultilines: e.isMultilines,
        inputTextMode: e.inputTextMode,
        onValidating: (errorMessage) {
          _errors[e] = errorMessage;

          var additionalErrorMessage = _additionalErrorOnAfterValidation.entries
              .where((element) => element.key == e.name)
              .map((e) => e.value ?? '')
              .toList()
              .join(', ');
          if (additionalErrorMessage.isEmpty && errorMessage == null) {
            return null;
          }
          if (errorMessage != null && additionalErrorMessage != '') {
            additionalErrorMessage = ', $additionalErrorMessage';
          }
          return (errorMessage ?? '') + additionalErrorMessage;
        },
        isEditable: _isEditable ?? widget.isFormEditable ?? true,
        onValueChanged: (context, previousValue, currentValue) {
          if (widget.onValueChanged != null) {
            widget.onValueChanged!
                .call(context, e, previousValue, currentValue, _inputValues);
          }
        },
        input: e,
      );
    } else if (e.runtimeType == InputForm) {
      e = (e as InputForm);
      return InputFieldForm(
        controller: _controllers[
            widget.inputFields.indexWhere((element) => element == e)],
        label: e.label,
        helperText: e.helperText,
        isRequired: !(e.isOptional ?? false),
        onValidating: (errorMessage) {
          _errors[e] = errorMessage;

          var additionalErrorMessage = _additionalErrorOnAfterValidation.entries
              .where((element) => element.key == e.name)
              .map((e) => e.value ?? '')
              .toList()
              .join(', ');
          if (additionalErrorMessage.isEmpty && errorMessage == null) {
            return null;
          }
          if (errorMessage != null && additionalErrorMessage != '') {
            additionalErrorMessage = ', $additionalErrorMessage';
          }
          return (errorMessage ?? '') + additionalErrorMessage;
        },
        isEditable: _isEditable ?? widget.isFormEditable ?? true,
        inputFields: e.inputFields,
        additionalButtons: e.additionalButtons,
        onAfterValidation: e.onAfterValidation,
        onBeforeValidation: e.onBeforeValidation,
        onInitial: e.onInitial,
        isMultiInputForm: e.isMultiInputForm,
        onValueChanged: (context, previousValue, currentValue) {
          if (widget.onValueChanged != null) {
            widget.onValueChanged!
                .call(context, e, previousValue, currentValue, _inputValues);
          }
        },
        input: e,
      );
    } else if (e.runtimeType == InputFile) {
      e = (e as InputFile);
      return InputFieldFile(
        controller: _controllers[
            widget.inputFields.indexWhere((element) => element == e)],
        label: e.label,
        helperText: e.helperText,
        isRequired: !(e.isOptional ?? false),
        onValidating: (errorMessage) {
          _errors[e] = errorMessage;

          var additionalErrorMessage = _additionalErrorOnAfterValidation.entries
              .where((element) => element.key == e.name)
              .map((e) => e.value ?? '')
              .toList()
              .join(', ');
          if (additionalErrorMessage.isEmpty && errorMessage == null) {
            return null;
          }
          if (errorMessage != null && additionalErrorMessage != '') {
            additionalErrorMessage = ', $additionalErrorMessage';
          }
          return (errorMessage ?? '') + additionalErrorMessage;
        },
        isEditable: _isEditable ?? widget.isFormEditable ?? true,
        isMultiSelection: e.isAllowMultiple ?? false,
        fileType: e.fileType ?? FileType.any,
        onDownload: e.onDownload,
        onValueChanged: (context, previousValue, currentValue) {
          if (widget.onValueChanged != null) {
            widget.onValueChanged!
                .call(context, e, previousValue, currentValue, _inputValues);
          }
        },
        input: e,
      );
    } else {
      throw Exception('Unsupported InputFieldType ${e.runtimeType}');
    }
  }

  Future<void> onSubmit(BuildContext context) async {
    if (widget.onBeforeValidation != null) {
      if (!context.mounted) return;
      await widget.onBeforeValidation!.call(context, _inputValues);
    }
    _errors = {};
    _formKey.currentState!.validate();

    int errorMessagesIndex = 0;
    Map<int, MapEntry<Input, String?>> errorMessages = {};
    _errors.entries
        .where((element) => element.value != null)
        .toList()
        .forEach((element) {
      errorMessages[errorMessagesIndex] = element;
      errorMessagesIndex++;
    });
    _additionalErrorOnAfterValidation = {};

    if (widget.onAfterValidation != null) {
      if (!context.mounted) return;
      await widget.onAfterValidation!.call(context, _inputValues,
          errorMessages.isEmpty, _additionalErrorOnAfterValidation);

      for (var element in _additionalErrorOnAfterValidation.entries) {
        if (element.value != null) {
          errorMessages[errorMessagesIndex] = MapEntry(
              widget.inputFields.where((e) => e.name == element.key).first,
              element.value);
          errorMessagesIndex++;
        }
      }
      _formKey.currentState!.validate();
    }

    if (errorMessages.isEmpty) {
      if (!context.mounted) return;
      await widget.onSubmit.call(context, _inputValues);
    } else {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                'There are ${errorMessages.length} failed input validations'),
            content: SizedBox(
              width: 340,
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) => ListTile(
                  title: Text(
                    errorMessages[index]!.key.label,
                    style: TextStyle(
                      color: Colors.red.shade900,
                    ),
                  ),
                  subtitle: Text(
                    errorMessages[index]!.value!,
                    style: TextStyle(
                      color: Colors.red.shade900,
                    ),
                  ),
                ),
                itemCount: errorMessages.length,
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }
}

abstract class Input {
  final String name;
  final String label;
  final String? helperText;
  final bool? isOptional;
  final dynamic Function(InputValue inputValue)? onValueChanged;

  const Input({
    required this.name,
    required this.label,
    this.helperText,
    this.isOptional = false,
    this.onValueChanged,
  });
}

class InputText extends Input {
  final bool? isMultilines;
  final InputTextMode? inputTextMode;

  const InputText({
    required super.name,
    required super.label,
    super.helperText,
    super.isOptional,
    this.isMultilines = false,
    this.inputTextMode = InputTextMode.freeText,
    super.onValueChanged,
  });
}

class InputDateTime extends Input {
  final InputDateTimeMode? inputDateTimeMode;

  const InputDateTime({
    required super.name,
    required super.label,
    super.helperText,
    super.isOptional,
    this.inputDateTimeMode = InputDateTimeMode.dateTime,
    super.onValueChanged,
  });
}

class InputForm extends Input {
  final List<Input> inputFields;
  final String? Function(String? errorMessage)? onValidating;
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
          BuildContext, Input, dynamic, dynamic, Map<String, InputValue>)?
      onFormValueChanged;

  const InputForm({
    required super.name,
    required super.label,
    super.helperText,
    super.isOptional,
    required this.inputFields,
    this.onValidating,
    this.additionalButtons = const [],
    this.isMultiInputForm = false,
    this.onAfterValidation,
    this.onBeforeValidation,
    this.onInitial,
    this.onFormValueChanged,
    super.onValueChanged,
  });
}

class InputNumber extends Input {
  final InputNumberMode? inputNumberMode;

  const InputNumber({
    required super.name,
    required super.label,
    super.helperText,
    super.isOptional,
    this.inputNumberMode = InputNumberMode.decimal,
    super.onValueChanged,
  });
}

class InputOption extends Input {
  final Future<OptionData> optionData;
  final Future<int> optionTotalData;
  final List<String>? dataHeaders;
  final bool? isMultiSelection;
  final OptionSearchForm? optionSearchForm;

  const InputOption({
    required super.name,
    required super.label,
    super.helperText,
    super.isOptional,
    required this.optionData,
    required this.optionTotalData,
    this.dataHeaders = const [],
    this.optionSearchForm,
    this.isMultiSelection = false,
    super.onValueChanged,
  });
}

class InputFile extends Input {
  final bool? isAllowMultiple;
  final FileType? fileType;
  final void Function(PlatformFile file)? onDownload;

  const InputFile({
    required super.name,
    required super.label,
    super.helperText,
    super.isOptional,
    this.isAllowMultiple = false,
    this.fileType = FileType.any,
    this.onDownload,
    super.onValueChanged,
  });
}

class SubmitButtonSettings {
  const SubmitButtonSettings({
    required this.label,
    required this.icon,
  });

  final String label;
  final Widget icon;
}

class InputValue {
  const InputValue({
    required this.controller,
    required this.inputField,
  });

  final dynamic controller;
  final Input inputField;

  void setFiles(List<PlatformFile> value) {
    if (inputField.runtimeType == InputFile) {
      (controller as InputFieldFileController).clear();
      for (var e in value) {
        (controller as InputFieldFileController).add(e);
      }
    } else {
      throw Exception(
          'Unsupported setFiles for this input type ${inputField.runtimeType}');
    }
  }

  List<PlatformFile> getFiles() {
    if (inputField.runtimeType == InputFile) {
      return (controller as InputFieldFileController).getData();
    } else {
      throw Exception(
          'Unsupported getListOptionValues for this input type ${inputField.runtimeType}');
    }
  }

  void setFormValues(List<Map<String, dynamic>> value) {
    if (inputField.runtimeType == InputForm) {
      (controller as InputFieldFormController).clear();
      for (var e in value) {
        (controller as InputFieldFormController).add(e);
      }
    } else {
      throw Exception(
          'Unsupported setFormValues for this input type ${inputField.runtimeType}');
    }
  }

  List<Map<String, dynamic>> getFormValues() {
    if (inputField.runtimeType == InputForm) {
      return (controller as InputFieldFormController).getData();
    } else {
      throw Exception(
          'Unsupported getFormValues for this input type ${inputField.runtimeType}');
    }
  }

  void setString(String? value) {
    if (inputField.runtimeType == InputText) {
      (controller as TextEditingController).text = value ?? '';
    } else {
      throw Exception(
          'Unsupported setString for this input type ${inputField.runtimeType}');
    }
  }

  String? getString() {
    if (inputField.runtimeType == InputText) {
      if ((controller as TextEditingController).text.isEmpty) {
        return null;
      }

      return (controller as TextEditingController).text;
    } else {
      throw Exception(
          'Unsupported getString for this input type ${inputField.runtimeType}');
    }
  }

  void setDateTime(DateTime? value) {
    if (inputField.runtimeType == InputDateTime) {
      if (value == null) {
        (controller as TextEditingController).text = '';
      } else {
        if ((inputField as InputDateTime).inputDateTimeMode ==
            InputDateTimeMode.date) {
          (controller as TextEditingController).text =
              DateFormat('yyyy-MM-dd').format(value);
        } else if ((inputField as InputDateTime).inputDateTimeMode ==
            InputDateTimeMode.time) {
          (controller as TextEditingController).text =
              DateFormat('hh:mm').format(value);
        } else {
          (controller as TextEditingController).text =
              DateFormat('yyyy-MM-dd hh:mm:ss').format(value);
        }
      }
    } else {
      throw Exception(
          'Unsupported setDateTime for this input type ${inputField.runtimeType}');
    }
  }

  DateTime? getDateTime() {
    if (inputField.runtimeType == InputDateTime) {
      if ((controller as TextEditingController).text.isEmpty) {
        return null;
      } else {
        if ((inputField as InputDateTime).inputDateTimeMode ==
            InputDateTimeMode.date) {
          return DateFormat('yyyy-MM-dd')
              .parse((controller as TextEditingController).text);
        } else if ((inputField as InputDateTime).inputDateTimeMode ==
            InputDateTimeMode.time) {
          return DateFormat('hh:mm')
              .parse((controller as TextEditingController).text);
        } else {
          return DateFormat('yyyy-MM-dd hh:mm:ss')
              .parse((controller as TextEditingController).text);
        }
      }
    } else {
      throw Exception(
          'Unsupported getDateTime for this input type ${inputField.runtimeType}');
    }
  }

  void setListOptionValues(List<OptionItem> value) {
    if (inputField.runtimeType == InputOption) {
      (controller as InputFieldOptionController).clear();
      for (var e in value) {
        (controller as InputFieldOptionController).add(e);
      }
    } else {
      throw Exception(
          'Unsupported setListOptionValues for this input type ${inputField.runtimeType}');
    }
  }

  List<OptionItem> getListOptionValues() {
    if (inputField.runtimeType == InputOption) {
      return (controller as InputFieldOptionController).getData();
    } else {
      throw Exception(
          'Unsupported getListOptionValues for this input type ${inputField.runtimeType}');
    }
  }

  void setNumber(double? value) {
    if (inputField.runtimeType == InputNumber) {
      (controller as TextEditingController).text =
          value == null ? '' : value.toString();
    } else {
      throw Exception(
          'Unsupported getString for this input type ${inputField.runtimeType}');
    }
  }

  double? getNumber() {
    if (inputField.runtimeType == InputNumber) {
      if ((controller as TextEditingController).text.isEmpty) {
        return null;
      }
      return double.parse((controller as TextEditingController).text);
    } else {
      throw Exception(
          'Unsupported setString for this input type ${inputField.runtimeType}');
    }
  }
}

class AdditionalButton {
  final String label;
  final Widget icon;
  final Function() onTap;

  AdditionalButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}
