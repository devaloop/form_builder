library devaloop_form_builder;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InputFieldDateTime extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isRequired;
  final String? helperText;
  final InputDateTimeMode? inputDateTimeMode;
  final String? Function(String? errorMessage)? onValidating;
  final bool? isEditable;

  const InputFieldDateTime({
    super.key,
    required this.controller,
    required this.label,
    required this.isRequired,
    this.helperText,
    this.inputDateTimeMode,
    this.onValidating,
    this.isEditable,
  });

  @override
  State<InputFieldDateTime> createState() => _InputFieldDateTimeState();
}

class _InputFieldDateTimeState extends State<InputFieldDateTime> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: widget.label + (widget.isRequired ? '' : ' - Optional'),
        helperText: widget.helperText,
        helperMaxLines: 100,
        suffixIcon: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (widget.controller.text != "")
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: widget.isEditable ?? true
                    ? () {
                        setState(() {
                          widget.controller.clear();
                        });
                      }
                    : null,
              ),
            IconButton(
              icon: widget.inputDateTimeMode == InputDateTimeMode.time
                  ? const Icon(Icons.schedule)
                  : const Icon(Icons.calendar_month),
              onPressed: widget.isEditable ?? true
                  ? () async {
                      if (widget.inputDateTimeMode == InputDateTimeMode.time) {
                        String? pickedTime;
                        Future<void> show() async {
                          final TimeOfDay? result = await showTimePicker(
                            initialTime: widget.controller.text != ""
                                ? TimeOfDay.fromDateTime(DateTime.parse(
                                    "0000-00-00 ${widget.controller.text}:00.000"))
                                : TimeOfDay.now(),
                            context: context,
                          );
                          if (result != null) {
                            setState(() {
                              pickedTime = result.format(context).toString();
                              String strPickedTime = pickedTime!;
                              String format = "yyyy-MM-dd HH:mm";
                              if (strPickedTime.contains("AM") ||
                                  strPickedTime.contains("PM")) {
                                format = "yyyy-MM-dd hh:mm a";
                              }
                              DateTime parsedTime = DateFormat(format).parse(
                                  "${DateFormat("yyyy-MM-dd").format(DateTime.now())} $strPickedTime");
                              String formattedTime =
                                  DateFormat('HH:mm').format(parsedTime);
                              widget.controller.text = formattedTime;
                            });
                          }
                        }

                        show();
                      } else {
                        if (widget.inputDateTimeMode ==
                            InputDateTimeMode.date) {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: (widget.controller.text != ""
                                ? DateTime.parse(widget.controller.text)
                                : DateTime.now()), //get today's date
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2101),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              widget.controller.text =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                            });
                          }
                        } else {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: (widget.controller.text != ""
                                ? DateTime.parse(widget.controller.text)
                                : DateTime.now()),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2101),
                          );

                          if (pickedDate != null) {
                            String? pickedTime;
                            Future<void> show() async {
                              final TimeOfDay? result = await showTimePicker(
                                initialTime: widget.controller.text != ""
                                    ? TimeOfDay.fromDateTime(DateTime.parse(
                                        "${widget.controller.text}:00.000"))
                                    : TimeOfDay.now(),
                                context: context,
                              );
                              if (result != null) {
                                setState(() {
                                  pickedTime =
                                      result.format(context).toString();
                                  String strPickedTime = pickedTime!;
                                  String format = "yyyy-MM-dd HH:mm";
                                  if (strPickedTime.contains("AM") ||
                                      strPickedTime.contains("PM")) {
                                    format = "yyyy-MM-dd hh:mm a";
                                  }
                                  DateTime parsedTime = DateFormat(format).parse(
                                      "${DateFormat("yyyy-MM-dd").format(DateTime.now())} $strPickedTime");
                                  String formattedTime =
                                      DateFormat('HH:mm').format(parsedTime);
                                  widget.controller.text =
                                      "${DateFormat('yyyy-MM-dd').format(pickedDate)} $formattedTime";
                                });
                              }
                            }

                            show();
                          }
                        }
                      }
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
            if (widget.inputDateTimeMode == InputDateTimeMode.time) {
              String? pickedTime;
              Future<void> show() async {
                final TimeOfDay? result = await showTimePicker(
                  initialTime: widget.controller.text != ""
                      ? TimeOfDay.fromDateTime(DateTime.parse(
                          "0000-00-00 ${widget.controller.text}:00.000"))
                      : TimeOfDay.now(),
                  context: context,
                );
                if (result != null) {
                  setState(() {
                    pickedTime = result.format(context).toString();
                    String strPickedTime = pickedTime!;
                    String format = "yyyy-MM-dd HH:mm";
                    if (strPickedTime.contains("AM") ||
                        strPickedTime.contains("PM")) {
                      format = "yyyy-MM-dd hh:mm a";
                    }
                    DateTime parsedTime = DateFormat(format).parse(
                        "${DateFormat("yyyy-MM-dd").format(DateTime.now())} $strPickedTime");
                    String formattedTime =
                        DateFormat('HH:mm').format(parsedTime);
                    widget.controller.text = formattedTime;
                  });
                }
              }

              show();
            } else {
              if (widget.inputDateTimeMode == InputDateTimeMode.date) {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: (widget.controller.text != ""
                      ? DateTime.parse(widget.controller.text)
                      : DateTime.now()), //get today's date
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  setState(() {
                    widget.controller.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              } else {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: (widget.controller.text != ""
                      ? DateTime.parse(widget.controller.text)
                      : DateTime.now()),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  String? pickedTime;
                  Future<void> show() async {
                    final TimeOfDay? result = await showTimePicker(
                      initialTime: widget.controller.text != ""
                          ? TimeOfDay.fromDateTime(DateTime.parse(
                              "${widget.controller.text}:00.000"))
                          : TimeOfDay.now(),
                      context: context,
                    );
                    if (result != null) {
                      setState(() {
                        pickedTime = result.format(context).toString();
                        String strPickedTime = pickedTime!;
                        String format = "yyyy-MM-dd HH:mm";
                        if (strPickedTime.contains("AM") ||
                            strPickedTime.contains("PM")) {
                          format = "yyyy-MM-dd hh:mm a";
                        }
                        DateTime parsedTime = DateFormat(format).parse(
                            "${DateFormat("yyyy-MM-dd").format(DateTime.now())} $strPickedTime");
                        String formattedTime =
                            DateFormat('HH:mm').format(parsedTime);
                        widget.controller.text =
                            "${DateFormat('yyyy-MM-dd').format(pickedDate)} $formattedTime";
                      });
                    }
                  }

                  show();
                }
              }
            }
          }
        }
      },
    );
  }
}

enum InputDateTimeMode { date, dateTime, time }
