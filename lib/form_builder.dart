library devaloop_form_builder;

import 'package:devaloop_form_builder/input_field_form.dart';
import 'package:flutter/material.dart';
import 'package:devaloop_form_builder/input_field_date_time.dart';
import 'package:devaloop_form_builder/input_field_number.dart';
import 'package:devaloop_form_builder/input_field_option.dart';
import 'package:devaloop_form_builder/input_field_text.dart';
import 'package:intl/intl.dart';

class FormBulder extends StatefulWidget {
  const FormBulder({
    super.key,
    required this.formName,
    required this.inputFields,
    this.onInitial,
    this.onBeforeValidation,
    this.onAfterValidation,
    required this.onSubmit,
    this.submitButtonSettings,
    this.additionalButtons,
    this.isFormEditable,
  });

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
  final dynamic Function(
      BuildContext context, Map<String, InputValue> inputValues) onSubmit;
  final SubmitButtonSettings? submitButtonSettings;
  final List<AdditionalButton>? additionalButtons;
  final bool? isFormEditable;

  @override
  State<FormBulder> createState() => _FormBulderState();
}

class _FormBulderState extends State<FormBulder> {
  final List<dynamic> _controllers = [];
  late Map<InputField, String?> _errors = {};
  late Map<String, String?> _additionalErrorOnAfterValidation = {};
  final _formKey = GlobalKey<FormState>();
  late Map<String, InputValue> _inputValues;
  late List<bool> _isSubmittings;
  bool? _isEditable;

  @override
  void initState() {
    for (var e in widget.inputFields) {
      if (e.inputFieldType == InputFieldType.dateTime) {
        _controllers.add(TextEditingController());
      } else if (e.inputFieldType == InputFieldType.number) {
        _controllers.add(TextEditingController());
      } else if (e.inputFieldType == InputFieldType.option) {
        _controllers.add(InputFieldOptionController());
      } else if (e.inputFieldType == InputFieldType.text) {
        _controllers.add(TextEditingController());
      } else if (e.inputFieldType == InputFieldType.form) {
        _controllers.add(InputFieldFormController());
      } else {
        throw Exception('Unsupported InputFieldType ');
      }
    }
    _inputValues = {
      for (int i = 0; i < widget.inputFields.length; i++)
        widget.inputFields[i].name: InputValue(
          controller: _controllers[i],
          inputFieldType: widget.inputFields[i].inputFieldType,
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
              : widget.submitButtonSettings!.icon,
        ));
      } else {
        AdditionalButton additionalButton = widget.additionalButtons![i];
        listAdditionalButtons.add(FilledButton.icon(
          onPressed:
              _isSubmittings.where((element) => element == true).isNotEmpty
                  ? null
                  : () async {
                      setState(() {
                        _isSubmittings[0] = true;
                        _isEditable = false;
                      });
                      await additionalButton.onTap.call();
                      setState(() {
                        _isSubmittings[0] = false;
                        _isEditable = null;
                      });
                    },
          label: Text(additionalButton.label),
          icon: _isSubmittings[0] == true
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

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.formName,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          isPortrait
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.inputFields.map((e) => getField(e)).toList(),
                )
              : Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.inputFields
                            .take((widget.inputFields.length / 2).round())
                            .map((e) => getField(e))
                            .toList(),
                      ),
                    ),
                    const SizedBox(
                      width: 7.5,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.inputFields
                            .skip((widget.inputFields.length / 2).round())
                            .map((e) => getField(e))
                            .toList(),
                      ),
                    ),
                  ],
                ),
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

  Widget getField(InputField e) {
    if (e.inputFieldType == InputFieldType.dateTime) {
      return InputFieldDateTime(
        controller: _controllers[
            widget.inputFields.indexWhere((element) => element == e)],
        label: e.label,
        helperText: e.helperText,
        isRequired: !(e.isOptional ?? false),
        inputDateTimeMode: e.inputDateTimeSettings?.inputDateTimeMode,
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
          if (additionalErrorMessage.isNotEmpty) {
            additionalErrorMessage = ', $additionalErrorMessage';
          }
          return (errorMessage ?? '') + additionalErrorMessage;
        },
        isEditable: _isEditable ?? widget.isFormEditable ?? true,
      );
    } else if (e.inputFieldType == InputFieldType.number) {
      return InputFieldNumber(
        controller: _controllers[
            widget.inputFields.indexWhere((element) => element == e)],
        label: e.label,
        helperText: e.helperText,
        isRequired: !(e.isOptional ?? false),
        inputFieldNumberMode: e.inputNumberSettings?.inputNumberMode,
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
          if (additionalErrorMessage.isNotEmpty) {
            additionalErrorMessage = ', $additionalErrorMessage';
          }
          return (errorMessage ?? '') + additionalErrorMessage;
        },
        isEditable: _isEditable ?? widget.isFormEditable ?? true,
      );
    } else if (e.inputFieldType == InputFieldType.option) {
      if (e.inputOptionSettings != null) {
        return InputFieldOption(
          controller: _controllers[
              widget.inputFields.indexWhere((element) => element == e)],
          label: e.label,
          helperText: e.helperText,
          isRequired: !(e.isOptional ?? false),
          optionData: e.inputOptionSettings!.optionData,
          dataHeaders: e.inputOptionSettings!.dataHeaders,
          searchFields: e.inputOptionSettings?.optionSearchForm?.searchFields,
          searchProcess: e.inputOptionSettings?.optionSearchForm?.searchProcess,
          isMultiSelection: e.inputOptionSettings!.isMultiSelection,
          onValidating: (errorMessage) {
            _errors[e] = errorMessage;

            var additionalErrorMessage = _additionalErrorOnAfterValidation
                .entries
                .where((element) => element.key == e.name)
                .map((e) => e.value ?? '')
                .toList()
                .join(', ');
            if (additionalErrorMessage.isEmpty && errorMessage == null) {
              return null;
            }
            if (additionalErrorMessage.isNotEmpty) {
              additionalErrorMessage = ', $additionalErrorMessage';
            }
            return (errorMessage ?? '') + additionalErrorMessage;
          },
          isEditable: _isEditable ?? widget.isFormEditable ?? true,
        );
      } else {
        throw Exception(
            'optionSettings must be provided for InputFieldType.option');
      }
    } else if (e.inputFieldType == InputFieldType.text) {
      return InputFieldText(
        controller: _controllers[
            widget.inputFields.indexWhere((element) => element == e)],
        label: e.label,
        helperText: e.helperText,
        isRequired: !(e.isOptional ?? false),
        isMultilines: e.inputTextSettings?.isMultilines,
        inputTextMode: e.inputTextSettings?.inputTextMode,
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
          if (additionalErrorMessage.isNotEmpty) {
            additionalErrorMessage = ', $additionalErrorMessage';
          }
          return (errorMessage ?? '') + additionalErrorMessage;
        },
        isEditable: _isEditable ?? widget.isFormEditable ?? true,
      );
    } else if (e.inputFieldType == InputFieldType.form) {
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
          if (additionalErrorMessage.isNotEmpty) {
            additionalErrorMessage = ', $additionalErrorMessage';
          }
          return (errorMessage ?? '') + additionalErrorMessage;
        },
        isEditable: _isEditable ?? widget.isFormEditable ?? true,
        formName: e.label,
        inputFields: e.inputFormSettings!.inputFields,
        additionalButtons: e.inputFormSettings!.additionalButtons,
        onAfterValidation: e.inputFormSettings!.onAfterValidation,
        onBeforeValidation: e.inputFormSettings!.onBeforeValidation,
        onInitial: e.inputFormSettings!.onInitial,
        isMultiInputForm: true,
      );
    } else {
      throw Exception('Unsupported InputFieldType ');
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
    Map<int, MapEntry<InputField, String?>> errorMessages = {};
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

class InputField {
  const InputField({
    required this.name,
    required this.inputFieldType,
    required this.label,
    this.helperText,
    this.isOptional,
    this.inputOptionSettings,
    this.inputTextSettings,
    this.inputDateTimeSettings,
    this.inputNumberSettings,
    this.inputFormSettings,
  });

  final String name;
  final InputFieldType inputFieldType;
  final String label;
  final String? helperText;
  final bool? isOptional;
  final InputOptionSettings? inputOptionSettings;
  final InputTextSettings? inputTextSettings;
  final InputDateTimeSettings? inputDateTimeSettings;
  final InputNumberSettings? inputNumberSettings;
  final InputFormSettings? inputFormSettings;
}

class InputFormSettings {
  final String? Function(String? errorMessage)? onValidating;
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

  const InputFormSettings({
    this.onValidating,
    required this.formName,
    required this.inputFields,
    this.onInitial,
    this.onBeforeValidation,
    this.onAfterValidation,
    this.additionalButtons,
  });
}

class InputNumberSettings {
  const InputNumberSettings({
    this.inputNumberMode,
  });

  final InputNumberMode? inputNumberMode;
}

class InputDateTimeSettings {
  const InputDateTimeSettings({
    this.inputDateTimeMode,
  });

  final InputDateTimeMode? inputDateTimeMode;
}

class InputTextSettings {
  const InputTextSettings({
    this.isMultilines,
    this.inputTextMode,
  });

  final bool? isMultilines;
  final InputTextMode? inputTextMode;
}

class InputOptionSettings {
  const InputOptionSettings({
    required this.optionData,
    required this.optionTotalData,
    this.dataHeaders,
    this.isMultiSelection,
    this.optionSearchForm,
  });

  final Future<OptionData> optionData;
  final Future<int> optionTotalData;
  final List<String>? dataHeaders;
  final bool? isMultiSelection;
  final OptionSearchForm? optionSearchForm;
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
    required this.inputFieldType,
  });

  final dynamic controller;
  final InputFieldType inputFieldType;

  void setFormValues(List<Map<String, dynamic>> value) {
    if (inputFieldType == InputFieldType.form) {
      (controller as InputFieldFormController).clear();
      for (var e in value) {
        (controller as InputFieldFormController).add(e);
      }
    } else {
      throw Exception(
          'Unsupported setListOptionValues for this input type $inputFieldType');
    }
  }

  List<Map<String, dynamic>> getFormValues() {
    if (inputFieldType == InputFieldType.form) {
      return (controller as InputFieldFormController).getData();
    } else {
      throw Exception(
          'Unsupported getListOptionValues for this input type $inputFieldType');
    }
  }

  void setString(String? value) {
    if (inputFieldType == InputFieldType.text) {
      (controller as TextEditingController).text = value ?? '';
    } else {
      throw Exception(
          'Unsupported setString for this input type $inputFieldType');
    }
  }

  String? getString() {
    if (inputFieldType == InputFieldType.text) {
      if ((controller as TextEditingController).text.isEmpty) {
        return null;
      }

      return (controller as TextEditingController).text;
    } else {
      throw Exception(
          'Unsupported getString for this input type $inputFieldType');
    }
  }

  void setDateTime(DateTime? value) {
    if (inputFieldType == InputFieldType.dateTime) {
      if (value == null) {
        (controller as TextEditingController).text = '';
      } else {
        //TODO need parameter to specified date, time or dateTime
        try {
          (controller as TextEditingController).text =
              DateFormat('yyyy-MM-dd hh:mm:ss').format(value);
        } catch (e) {
          try {
            (controller as TextEditingController).text =
                DateFormat('yyyy-MM-dd').format(value);
          } catch (e) {
            (controller as TextEditingController).text =
                DateFormat('hh:mm').format(value);
          }
        }
      }
    } else {
      throw Exception(
          'Unsupported setDateTime for this input type $inputFieldType');
    }
  }

  DateTime? getDateTime() {
    if (inputFieldType == InputFieldType.dateTime) {
      if ((controller as TextEditingController).text.isEmpty) {
        return null;
      }
      try {
        return DateFormat('yyyy-MM-dd hh:mm:ss')
            .parse((controller as TextEditingController).text);
      } catch (e) {
        try {
          return DateFormat('yyyy-MM-dd')
              .parse((controller as TextEditingController).text);
        } catch (e) {
          return DateFormat('hh:mm')
              .parse((controller as TextEditingController).text);
        }
      }
    } else {
      throw Exception(
          'Unsupported getDateTime for this input type $inputFieldType');
    }
  }

  void setListOptionValues(List<OptionItem> value) {
    if (inputFieldType == InputFieldType.option) {
      (controller as InputFieldOptionController).clear();
      for (var e in value) {
        (controller as InputFieldOptionController).add(e);
      }
    } else {
      throw Exception(
          'Unsupported setListOptionValues for this input type $inputFieldType');
    }
  }

  List<OptionItem> getListOptionValues() {
    if (inputFieldType == InputFieldType.option) {
      return (controller as InputFieldOptionController).getData();
    } else {
      throw Exception(
          'Unsupported getListOptionValues for this input type $inputFieldType');
    }
  }

  void setNumber(double? value) {
    if (inputFieldType == InputFieldType.number) {
      (controller as TextEditingController).text =
          value == null ? '' : value.toString();
    } else {
      throw Exception(
          'Unsupported getString for this input type $inputFieldType');
    }
  }

  double? getNumber() {
    if (inputFieldType == InputFieldType.number) {
      if ((controller as TextEditingController).text.isEmpty) {
        return null;
      }
      return double.parse((controller as TextEditingController).text);
    } else {
      throw Exception(
          'Unsupported setString for this input type $inputFieldType');
    }
  }
}

enum InputFieldType { dateTime, number, option, text, form }

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
