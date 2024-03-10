import 'package:example/db.dart';
import 'package:flutter/material.dart';
import 'package:devaloop_form_builder/form_builder.dart';
import 'package:devaloop_form_builder/input_field_date_time.dart';
import 'package:devaloop_form_builder/input_field_number.dart';
import 'package:devaloop_form_builder/input_field_option.dart';
import 'package:devaloop_form_builder/input_field_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<OptionData> _futureTrainingProgramOptionData;
  late Future<OptionData> _genderFamilyMembers;

  @override
  void initState() {
    super.initState();
    _futureTrainingProgramOptionData = Future<OptionData>(
      () {
        List<OptionItem> data = [];
        return OptionData(
            displayedListOfOptions: data, totalOption: data.length);
      },
    );

    _genderFamilyMembers = Future<OptionData>(
      () async {
        var data = [
          const OptionItem(hiddenValue: ['Male'], value: ['Male']),
          const OptionItem(hiddenValue: ['Female'], value: ['Female']),
        ];
        return OptionData(
            displayedListOfOptions: data, totalOption: data.length);
      },
    );
  }

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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: FormBuilder(
            resetToInitialAfterSubmit: true,
            formName: 'Member',
            inputFields: const [
              InputHidden(
                name: 'id',
                label: 'ID',
              ),
              InputText(
                name: 'name',
                label: 'Name',
              ),
            ],
            onValueChanged:
                (context, field, previousValue, currentValue, inputValues) {
              if (field.name == 'joinDate') {
                DateTime? joinDate = inputValues['joinDate']!.getDateTime();
                if (previousValue != currentValue) {
                  inputValues['trainingProgram']!.setListOptionValues([]);
                  if (joinDate == null) {
                    setState(() {
                      _futureTrainingProgramOptionData = Future<OptionData>(
                        () => const OptionData(
                            displayedListOfOptions: [], totalOption: 0),
                      );
                    });
                  } else {
                    if (joinDate.isAfter(DateTime(2024))) {
                      setState(() {
                        _futureTrainingProgramOptionData = Future<OptionData>(
                          () {
                            List<OptionItem> data = [
                              const OptionItem(
                                hiddenValue: ['Flutter'],
                                value: ['Flutter'],
                              ),
                              const OptionItem(
                                hiddenValue: ['.NET MAUI'],
                                value: ['.NET MAUI'],
                              ),
                            ];
                            return OptionData(
                                displayedListOfOptions: data,
                                totalOption: data.length);
                          },
                        );
                      });
                    } else {
                      setState(() {
                        _futureTrainingProgramOptionData = Future<OptionData>(
                          () {
                            List<OptionItem> data = [
                              const OptionItem(
                                hiddenValue: ['HTML'],
                                value: ['HTML'],
                              ),
                              const OptionItem(
                                hiddenValue: ['ASP Classic'],
                                value: ['ASP Classic'],
                              ),
                            ];
                            return OptionData(
                                displayedListOfOptions: data,
                                totalOption: data.length);
                          },
                        );
                      });
                    }
                  }
                }
              }
            },
            onInitial: (context, inputValues) {
              inputValues['id']!.setHiddenValue(1001);
              inputValues['name']!.setString('Budi Saputra');
            },
            onBeforeValidation: (context, inputValues) {
              inputValues['name']!
                  .setString(inputValues['name']!.getString()?.toUpperCase());
            },
            onAfterValidation:
                (context, inputValues, isValid, errorMessages) {},
            onSubmit: (context, inputValues) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data')),
              );
            },
            submitButtonSettings: const SubmitButtonSettings(
              label: 'Add Member',
              icon: Icon(Icons.add),
            ),
            additionalButtons: [
              AdditionalButton(
                onTap: (context, inputValues) async {
                  await Future.delayed(const Duration(seconds: 2));
                  inputValues['name']!.setString(null);
                },
                label: 'Reset',
                icon: const Icon(Icons.undo),
              ),
              AdditionalButton(
                onTap: (context, inputValues) async {
                  await Future.delayed(const Duration(seconds: 2));
                },
                label: 'Cancel',
                icon: const Icon(Icons.cancel),
              ),
              AdditionalButton(
                onTap: (context, inputValues) async {
                  await Future.delayed(const Duration(seconds: 2));
                },
                label: 'Back',
                icon: const Icon(Icons.arrow_back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
