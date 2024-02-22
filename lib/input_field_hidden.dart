library devaloop_form_builder;

import 'package:flutter/material.dart';

class InputFieldHidden extends StatefulWidget {
  final String label;
  final InputFieldHiddenController controller;

  const InputFieldHidden({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  State<InputFieldHidden> createState() => _InputFieldHiddenState();
}

class _InputFieldHiddenState extends State<InputFieldHidden> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.text = widget.controller.getData() != null
          ? widget.controller.getData()!.toString()
          : '';
    });

    return Visibility(
      visible: false,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: widget.label,
          helperMaxLines: 100,
        ),
        controller: _controller,
      ),
    );
  }
}

class InputFieldHiddenController extends ChangeNotifier {
  dynamic _data;

  void setData(dynamic data) {
    _data = data;
    notifyListeners();
  }

  dynamic getData() {
    return _data;
  }

  void clear() {
    _data = null;
    notifyListeners();
  }
}
