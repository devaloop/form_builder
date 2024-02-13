library devaloop_form_builder;

import 'package:devaloop_form_builder/form_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputFieldNumber extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final String? helperText;
  final InputNumberMode? inputFieldNumberMode;
  final String? Function(String? errorMessage)? onValidating;
  final bool? isEditable;
  final dynamic Function(
          BuildContext context, double? previousValue, double? currentValue)?
      onValueChanged;
  final InputNumber input;

  const InputFieldNumber({
    super.key,
    required this.controller,
    required this.label,
    required this.isRequired,
    this.helperText,
    this.inputFieldNumberMode,
    this.onValidating,
    this.isEditable,
    this.onValueChanged,
    required this.input,
  });

  @override
  Widget build(BuildContext context) {
    var integerFormatter = [
      FilteringTextInputFormatter.allow(RegExp(r"[0-9-]")),
      TextInputFormatter.withFunction(
        (oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.isNotEmpty) int.parse(text);
            return newValue;
          } catch (e) {
            final text = newValue.text;
            if (text == "-") {
              return newValue;
            }
          }
          return oldValue;
        },
      ),
    ];
    var decimalFormatter = [
      FilteringTextInputFormatter.allow(RegExp(r"[0-9.-]")),
      TextInputFormatter.withFunction(
        (oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.isNotEmpty) double.parse(text);
            return newValue;
          } catch (e) {
            final text = newValue.text;
            if (text == "-") {
              return newValue;
            }
          }
          return oldValue;
        },
      ),
    ];

    double? prevValue =
        controller.text == '' ? null : double.parse(controller.text);

    return TextFormField(
      controller: controller,
      readOnly: !(isEditable ?? true),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      inputFormatters: (inputFieldNumberMode ?? InputNumberMode.integer) ==
              InputNumberMode.integer
          ? integerFormatter
          : decimalFormatter,
      textInputAction: TextInputAction.next,
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
      decoration: InputDecoration(
        labelText: label + (isRequired ? '' : ' - Optional'),
        helperText: helperText,
        helperMaxLines: 100,
        suffixIcon: const Icon(Icons.numbers),
      ),
      onChanged: (value) {
        double? currentValue = value == '' ? null : double.parse(value);
        if (onValueChanged != null) {
          onValueChanged!.call(context, prevValue, currentValue);
        }
        prevValue = currentValue;
      },
      validator: (value) {
        validation() {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Required';
          }
          return null;
        }

        String? errorMessage = validation.call();
        if (onValidating != null) {
          return onValidating!.call(errorMessage);
        }
        return errorMessage;
      },
    );
  }
}

enum InputNumberMode { integer, decimal }
