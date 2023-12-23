library devaloop_form_builder;

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
  });

  @override
  Widget build(BuildContext context) {
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
