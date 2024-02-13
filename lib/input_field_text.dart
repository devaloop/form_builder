library devaloop_form_builder;

import 'package:devaloop_form_builder/form_builder.dart';
import 'package:flutter/material.dart';

class InputFieldText extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final String? helperText;
  final bool? isMultilines;
  final InputTextMode? inputTextMode;
  final String? Function(String? errorMessage)? onValidating;
  final bool? isEditable;
  final dynamic Function(
          BuildContext context, String previousValue, String currentValue)?
      onValueChanged;
  final InputText input;

  const InputFieldText({
    super.key,
    required this.controller,
    required this.label,
    required this.isRequired,
    this.helperText,
    this.isMultilines,
    this.inputTextMode,
    this.onValidating,
    this.isEditable,
    this.onValueChanged,
    required this.input,
  });

  @override
  Widget build(BuildContext context) {
    String prevValue = controller.text;
    return TextFormField(
      controller: controller,
      readOnly: !(isEditable ?? false),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      minLines: isMultilines ?? false ? 8 : null,
      maxLines: isMultilines ?? false ? 8 : null,
      keyboardType: TextInputType.multiline,
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
      decoration: InputDecoration(
        labelText: label + (isRequired ? '' : ' - Optional'),
        helperText: helperText,
        helperMaxLines: 100,
      ),
      onChanged: (value) {
        if (onValueChanged != null) {
          onValueChanged!.call(context, prevValue, value);
        }
        prevValue = value;
      },
      validator: (value) {
        validation() {
          if ((inputTextMode ?? InputTextMode.freeText) ==
              InputTextMode.freeText) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Required';
            }
          } else {
            if (isRequired) {
              if (value == null || value.isEmpty) {
                return 'Required';
              } else {
                if (!RegExp(
                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                    .hasMatch(value)) {
                  return 'Email Format Not Valid';
                }
              }
            } else {
              if (value == null || value.isEmpty) {
              } else {
                if (!RegExp(
                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                    .hasMatch(value)) {
                  return 'Email Format Not Valid';
                }
              }
            }
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

enum InputTextMode { freeText, email }
