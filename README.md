Form Builder : Consists of, input with text type, input with email type, input with date type, input with option type, input with more than one option type, input with number type, and input with text type with multiple lines

## Usage

```dart
import 'package:example/db.dart';
import 'package:flutter/material.dart';
import 'package:form_builder/form_builder.dart';
import 'package:form_builder/input_field_date_time.dart';
import 'package:form_builder/input_field_number.dart';
import 'package:form_builder/input_field_option.dart';
import 'package:form_builder/input_field_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Member',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: FormBulder(
            formName: 'Member',
            inputFields: [
              const InputField(
                name: 'name',
                inputFieldType: InputFieldType.text,
                label: 'Name',
              ),
              const InputField(
                name: 'email',
                inputFieldType: InputFieldType.text,
                label: 'Email',
                inputTextSettings: InputTextSettings(
                  inputTextMode: InputTextMode.email,
                ),
              ),
              const InputField(
                name: 'birthDate',
                inputFieldType: InputFieldType.dateTime,
                label: 'Birth Date',
                inputDateTimeSettings: InputDateTimeSettings(
                  inputDateTimeMode: InputDateTimeMode.date,
                ),
              ),
              InputField(
                name: 'gender',
                inputFieldType: InputFieldType.option,
                label: 'Gender',
                inputOptionSettings: InputOptionSettings(
                  optionData: Future<OptionData>(
                    () {
                      var data = [
                        const OptionItem(
                            hiddenValue: ['Male'], value: ['Male']),
                        const OptionItem(
                            hiddenValue: ['Female'], value: ['Female']),
                      ];
                      return OptionData(
                          displayedListOfOptions: data,
                          totalOption: data.length);
                    },
                  ),
                  optionTotalData: Future(() => 2),
                ),
              ),
              InputField(
                name: 'hobbies',
                inputFieldType: InputFieldType.option,
                label: 'Hobbies',
                inputOptionSettings: InputOptionSettings(
                  isMultiSelection: true,
                  optionData: Future<OptionData>(
                    () {
                      var data = Db.hobbies
                          .take(10)
                          .map((e) => OptionItem(
                              hiddenValue: [e.id], value: [e.name, e.detail]))
                          .toList();
                      return OptionData(
                        displayedListOfOptions: data,
                        totalOption: Db.hobbies.length,
                      );
                    },
                  ),
                  dataHeaders: ['Name', 'Detail'],
                  optionTotalData: Future(() => Db.hobbies.length),
                  optionSearchForm: OptionSearchForm(
                    searchFields: [
                      const InputField(
                          name: 'name',
                          inputFieldType: InputFieldType.text,
                          label: 'Name',
                          isOptional: true),
                      const InputField(
                        name: 'detail',
                        inputFieldType: InputFieldType.text,
                        label: 'Detail',
                        isOptional: false,
                      ),
                    ],
                    searchProcess: (params) {
                      return Future<OptionData>(
                        () {
                          var data = Db.hobbies
                              .map((e) => OptionItem(
                                  hiddenValue: [e.id],
                                  value: [e.name, e.detail]))
                              .where((element) => element.value[0]
                                  .toLowerCase()
                                  .contains(params['name']!
                                      .getString()!
                                      .toLowerCase()))
                              .toList();
                          return OptionData(
                            displayedListOfOptions: data,
                            totalOption: Db.hobbies.length,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const InputField(
                name: 'rate',
                inputFieldType: InputFieldType.number,
                label: 'Rate',
                isOptional: true,
                inputNumberSettings: InputNumberSettings(
                  inputNumberMode: InputNumberMode.decimal,
                ),
              ),
              const InputField(
                name: 'rateInfo',
                inputFieldType: InputFieldType.text,
                label: 'Rate Info',
                helperText: 'Must be filled when rate is filled.',
                isOptional: true,
                inputTextSettings: InputTextSettings(
                  isMultilines: true,
                ),
              ),
            ],
            onInitial: (context, inputValues) {
              inputValues['name']!.setString('Budi Saputra');
            },
            onBeforeValidation: (context, inputValues) {
              inputValues['name']!
                  .setString(inputValues['name']!.getString()?.toUpperCase());
            },
            onAfterValidation: (context, inputValues, isValid, errorMessages) {
              if (inputValues['rate']!.getNumber() != null &&
                  inputValues['rateInfo']!.getString() == null) {
                errorMessages['rateInfo'] =
                    'Must be filled because rate is filled.';
              }
            },
            onSubmit: (context, inputValues) {
              var result = inputValues['name']!.getString();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Processing Data $result')),
              );
            },
            submitButtonSettings: const SubmitButtonSettings(
              label: 'Add Member',
              icon: Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}
```
