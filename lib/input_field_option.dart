library devaloop_form_builder;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:devaloop_form_builder/form_builder.dart';

class InputFieldOption extends StatefulWidget {
  final String label;
  final bool isRequired;
  final String? helperText;
  final Future<OptionData> optionData;
  final List<String>? dataHeaders;
  final Future<OptionData> Function(Map<String, InputValue>)? searchProcess;
  final InputFieldOptionController controller;
  final List<Input>? searchFields;
  final bool? isMultiSelection;
  final String? Function(String? errorMessage)? onValidating;
  final bool? isEditable;

  const InputFieldOption({
    super.key,
    required this.label,
    required this.isRequired,
    this.helperText,
    required this.optionData,
    this.dataHeaders,
    required this.searchProcess,
    required this.controller,
    this.searchFields,
    this.isMultiSelection,
    this.onValidating,
    this.isEditable,
  });

  @override
  State<InputFieldOption> createState() => _InputFieldOptionState();
}

class _InputFieldOptionState extends State<InputFieldOption> {
  bool _textFieldIsFocused = false;
  final TextEditingController _controller = TextEditingController();
  late bool _isMultiSelection;

  @override
  void initState() {
    _isMultiSelection = widget.isMultiSelection ?? false;
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
                    icon: _isMultiSelection
                        ? const Icon(Icons.add)
                        : const Icon(Icons.navigate_next),
                    onPressed: widget.isEditable ?? false
                        ? () {
                            Future<void>
                                navigateToInputFieldOptionSearchFormPage(
                                    BuildContext context) async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InputFiledOptionSearchFormPage(
                                    title: widget.label,
                                    optionData: widget.optionData,
                                    dataHeaders: widget.dataHeaders,
                                    searchFields: widget.searchFields,
                                    searchProcess: widget.searchProcess,
                                  ),
                                ),
                              );

                              if (!mounted) return;

                              if (result != null) {
                                setState(() {
                                  if (!_isMultiSelection) {
                                    widget.controller.clear();
                                  }
                                  widget.controller.add(result);
                                  if (widget.controller.getData().isEmpty) {
                                    _controller.clear();
                                  } else {
                                    _controller.text =
                                        '${widget.controller.getData().length} Option Selected';
                                  }
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
                        builder: (context) => InputFiledOptionSearchFormPage(
                          title: widget.label,
                          optionData: widget.optionData,
                          searchFields: widget.searchFields,
                          searchProcess: widget.searchProcess,
                        ),
                      ),
                    );

                    if (!mounted) return;

                    if (result != null) {
                      setState(() {
                        if (!_isMultiSelection) {
                          widget.controller.clear();
                        }
                        widget.controller.add(result);
                        if (widget.controller.getData().isEmpty) {
                          _controller.clear();
                        } else {
                          _controller.text =
                              '${widget.controller.getData().length} Option Selected';
                        }
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
            child: ListView.separated(
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
                    children: widget.controller
                        .getData()[index]
                        .value
                        .asMap()
                        .map(
                          (key, value) {
                            String header = '';
                            try {
                              header = widget.dataHeaders![key];
                            } catch (e) {
                              header = '';
                            }
                            return MapEntry(
                              key,
                              Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.grey.shade200, width: 1),
                                  borderRadius: BorderRadius.circular(15 + 7.5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(7.5),
                                  child: Text(
                                      '${header == '' ? '' : '$header: '}$value'),
                                ),
                              ),
                            );
                          },
                        )
                        .values
                        .toList(),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: widget.isEditable ?? false
                        ? () {
                            setState(() {
                              widget.controller.getData().removeAt(index);
                              if (widget.controller.getData().isEmpty) {
                                _controller.clear();
                              } else {
                                _controller.text =
                                    '${widget.controller.getData().length} Option Selected';
                              }
                            });
                          }
                        : null,
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class InputFiledOptionSearchFormPage extends StatefulWidget {
  final String title;
  final Future<OptionData> optionData;
  final List<String>? dataHeaders;
  final List<Input>? searchFields;
  final Future<OptionData> Function(Map<String, InputValue>)? searchProcess;

  const InputFiledOptionSearchFormPage({
    super.key,
    required this.title,
    this.searchFields,
    required this.optionData,
    this.dataHeaders,
    required this.searchProcess,
  });

  @override
  State<InputFiledOptionSearchFormPage> createState() =>
      _InputFieldOptionSearchFormPage();
}

class _InputFieldOptionSearchFormPage
    extends State<InputFiledOptionSearchFormPage> {
  Map<String, InputValue> searchParameters = <String, InputValue>{};
  final _formKey = GlobalKey<FormState>();

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
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarDividerColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.searchFields != null)
                FormBulder(
                  formName: 'Search',
                  inputFields: widget.searchFields!,
                  onSubmit: (context, inputValues) {
                    Future<void> navigateToInputFieldOptionResultPage(
                        BuildContext context) async {
                      var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InputFieldOptionResultPage(
                            title: widget.title,
                            searchParameters: inputValues,
                            dataHeaders: widget.dataHeaders,
                            searchProcess: widget.searchProcess,
                          ),
                        ),
                      );

                      if (!mounted) return;

                      if (result != null) {
                        Navigator.pop(
                          context,
                          result,
                        );
                      }
                    }

                    navigateToInputFieldOptionResultPage(context);
                  },
                  submitButtonSettings: const SubmitButtonSettings(
                    label: 'Search',
                    icon: Icon(Icons.search),
                  ),
                ),
              FutureBuilder(
                future: widget.optionData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    var optionData = snapshot.data as OptionData;
                    final displayedListOfOptions =
                        optionData.displayedListOfOptions;
                    final totalOption = optionData.totalOption;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                            'Show ${displayedListOfOptions.length} of $totalOption Options.'),
                        ListView.separated(
                          padding: const EdgeInsets.all(0),
                          shrinkWrap: true,
                          itemCount: displayedListOfOptions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Wrap(
                                children: displayedListOfOptions[index]
                                    .value
                                    .asMap()
                                    .map(
                                      (key, value) {
                                        String header = '';
                                        try {
                                          header = widget.dataHeaders![key];
                                        } catch (e) {
                                          header = '';
                                        }
                                        return MapEntry(
                                          key,
                                          Card(
                                            color: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Colors.grey.shade200,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      15 + 7.5),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(7.5),
                                              child: Text(
                                                  '${header == '' ? '' : '$header: '}$value'),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                    .values
                                    .toList(),
                              ),
                              onTap: () {
                                Navigator.pop(
                                    context, displayedListOfOptions[index]);
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          physics: const NeverScrollableScrollPhysics(),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OptionData {
  const OptionData({
    required this.displayedListOfOptions,
    required this.totalOption,
  });

  final List<OptionItem> displayedListOfOptions;
  final int totalOption;
}

class InputFieldOptionResultPage extends StatefulWidget {
  final String title;
  final Map<String, InputValue> searchParameters;
  final List<String>? dataHeaders;
  final Future<OptionData> Function(Map<String, InputValue>)? searchProcess;

  const InputFieldOptionResultPage({
    super.key,
    required this.title,
    required this.searchParameters,
    this.dataHeaders,
    required this.searchProcess,
  });

  @override
  State<InputFieldOptionResultPage> createState() =>
      _InputFieldOptionSearchResultPage();
}

class _InputFieldOptionSearchResultPage
    extends State<InputFieldOptionResultPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarDividerColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FutureBuilder<OptionData>(
        future: widget.searchProcess!.call(widget.searchParameters),
        builder: (context, AsyncSnapshot<OptionData> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final optionData = snapshot.data as OptionData;
            final displayedListOfOptions = optionData.displayedListOfOptions;
            final totalOption = optionData.totalOption;

            if (displayedListOfOptions.isEmpty) {
              return const Center(
                child: Text(
                  'Option not found',
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Found ${displayedListOfOptions.length} of $totalOption Options.'),
                  ListView.separated(
                    padding: const EdgeInsets.all(0),
                    shrinkWrap: true,
                    itemCount: displayedListOfOptions.length,
                    itemBuilder: (context, index) {
                      if (displayedListOfOptions[index].value.length == 1 &&
                          (widget.dataHeaders == null ||
                              widget.dataHeaders!.isEmpty)) {
                        return ListTile(
                          title:
                              Text(displayedListOfOptions[index].value.first),
                          onTap: () => Navigator.pop(
                              context, displayedListOfOptions[index]),
                        );
                      }
                      return ListTile(
                        title: Text(displayedListOfOptions[index].value.first),
                        subtitle: Wrap(
                          children: displayedListOfOptions[index]
                              .value
                              .asMap()
                              .map((key, value) {
                                String field;
                                try {
                                  field = '${widget.dataHeaders![key]}: $value';
                                } catch (e) {
                                  field = value;
                                }

                                Widget widgetField;
                                double listWidth = screenWidth - 70;
                                if (listWidth < field.width()) {
                                  widgetField = SizedBox(
                                    width: listWidth,
                                    child: Column(
                                      children: [Text(field)],
                                    ),
                                  );
                                } else {
                                  widgetField = Text(field);
                                }

                                return MapEntry(
                                  key,
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      widgetField,
                                      if (key <
                                          displayedListOfOptions[index]
                                                  .value
                                                  .length -
                                              1)
                                        Container(
                                          width: 1,
                                          height: 10,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 7.5),
                                          color: Colors.grey.shade300,
                                          child: const Text(''),
                                        ),
                                    ],
                                  ),
                                );
                              })
                              .values
                              .toList(),
                        ),
                        onTap: () => Navigator.pop(
                            context, displayedListOfOptions[index]),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class InputFieldOptionController extends ChangeNotifier {
  List<OptionItem> _data = [];

  void add(OptionItem item) {
    _data.add(item);
    notifyListeners();
  }

  List<OptionItem> getData() {
    return _data;
  }

  void clear() {
    _data = [];
    notifyListeners();
  }
}

extension StringWidth on String {
  double width() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: this),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: double.infinity,
      );
    return textPainter.size.width;
  }
}

class OptionItem {
  const OptionItem({
    required this.hiddenValue,
    required this.value,
  });

  final List<String> hiddenValue;
  final List<String> value;
}

class OptionSearchForm {
  const OptionSearchForm({
    required this.searchFields,
    required this.searchProcess,
  });

  final List<Input> searchFields;
  final Future<OptionData> Function(Map<String, InputValue>) searchProcess;
}
