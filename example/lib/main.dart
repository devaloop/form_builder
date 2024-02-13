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
  late Future<int> _futureTrainingProgramOptionTotalData;
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
    _futureTrainingProgramOptionTotalData = Future(() => 0);

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
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: FormBuilder(
            formName: 'Member',
            inputFields: [
              const InputText(
                name: 'name',
                label: 'Name',
              ),
              const InputText(
                name: 'email',
                label: 'Email',
                inputTextMode: InputTextMode.email,
              ),
              const InputDateTime(
                name: 'birthDate',
                label: 'Birth Date',
                inputDateTimeMode: InputDateTimeMode.date,
              ),
              const InputDateTime(
                name: 'joinDate',
                label: 'Join Date',
                inputDateTimeMode: InputDateTimeMode.date,
              ),
              InputOption(
                name: 'trainingProgram',
                label: 'Training Program',
                optionData: _futureTrainingProgramOptionData,
              ),
              InputOption(
                name: 'gender',
                label: 'Gender',
                optionData: Future<OptionData>(
                  () {
                    var data = [
                      const OptionItem(hiddenValue: ['Male'], value: ['Male']),
                      const OptionItem(
                          hiddenValue: ['Female'], value: ['Female']),
                    ];
                    return OptionData(
                        displayedListOfOptions: data, totalOption: data.length);
                  },
                ),
              ),
              InputOption(
                name: 'hobbies',
                label: 'Hobbies',
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
                optionSearchForm: OptionSearchForm(
                  searchFields: [
                    const InputText(
                      name: 'name',
                      label: 'Name',
                    ),
                    const InputText(
                      name: 'detail',
                      label: 'Detail',
                      isOptional: true,
                    ),
                  ],
                  searchProcess: (params) {
                    return Future<OptionData>(
                      () {
                        var data = Db.hobbies
                            .map((e) => OptionItem(
                                hiddenValue: [e.id], value: [e.name, e.detail]))
                            .where((element) => element.value[0]
                                .toLowerCase()
                                .contains(
                                    params['name']!.getString()!.toLowerCase()))
                            .toList();

                        if (params['detail']!.getString() != null) {
                          data = data
                              .where((element) => element.value[0]
                                  .toLowerCase()
                                  .contains(params['detail']!
                                      .getString()!
                                      .toLowerCase()))
                              .toList();
                        }
                        return OptionData(
                          displayedListOfOptions: data,
                          totalOption: Db.hobbies.length,
                        );
                      },
                    );
                  },
                ),
              ),
              const InputNumber(
                name: 'rate',
                label: 'Rate',
                isOptional: true,
                inputNumberMode: InputNumberMode.decimal,
              ),
              const InputText(
                name: 'rateInfo',
                label: 'Rate Info',
                helperText: 'Must be filled when rate is filled.',
                isOptional: true,
                isMultilines: true,
              ),
              InputForm(
                name: 'familyMembers',
                label: 'Family Members',
                isMultiInputForm: true,
                onFormValueChanged:
                    (context, field, previousValue, currentValue, inputValues) {
                  if (field.name == 'name') {
                    if (currentValue == 'a') {
                      setState(() {
                        _genderFamilyMembers = Future<OptionData>(
                          () async {
                            await Future.delayed(const Duration(seconds: 10));
                            var data = [
                              const OptionItem(
                                  hiddenValue: ['Male'], value: ['Male']),
                              const OptionItem(
                                  hiddenValue: ['Female'], value: ['Female']),
                              const OptionItem(
                                  hiddenValue: ['Other'], value: ['Other']),
                            ];
                            return OptionData(
                                displayedListOfOptions: data,
                                totalOption: data.length);
                          },
                        );
                      });
                    }
                  }
                },
                inputFields: [
                  const InputText(
                    name: 'name',
                    label: 'Name',
                  ),
                  const InputText(
                    name: 'email',
                    label: 'Email',
                    inputTextMode: InputTextMode.email,
                    isOptional: true,
                  ),
                  const InputDateTime(
                    name: 'birthDate',
                    label: 'Birth Date',
                    inputDateTimeMode: InputDateTimeMode.date,
                  ),
                  InputOption(
                    name: 'gender',
                    label: 'Gender',
                    optionData: _genderFamilyMembers,
                  ),
                  InputOption(
                    name: 'hobbies',
                    label: 'Hobbies',
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
                    //dataHeaders: ['Name', 'Detail'],
                    optionSearchForm: OptionSearchForm(
                      searchFields: [
                        const InputText(
                            name: 'name', label: 'Name', isOptional: true),
                        const InputText(
                          name: 'detail',
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
                  const InputForm(
                    name: 'additinalInformations',
                    label: 'Additional Informations',
                    isMultiInputForm: true,
                    isOptional: false,
                    inputFields: [
                      InputText(
                        name: 'title',
                        label: 'Tittle',
                      ),
                      InputText(
                        name: 'information',
                        label: 'Informations',
                        isMultilines: true,
                      ),
                    ],
                  ),
                ],
              ),
              InputFile(
                name: 'documents',
                label: 'Documents',
                isOptional: true,
                isAllowMultiple: true,
                onDownload: (file) {
                  // ignore: avoid_print
                  print(file.name);
                },
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
                      _futureTrainingProgramOptionTotalData = Future(() => 0);
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
                        _futureTrainingProgramOptionTotalData = Future(() => 2);
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
                        _futureTrainingProgramOptionTotalData = Future(() => 2);
                      });
                    }
                  }
                }
              }
            },
            onInitial: (context, inputValues) {
              inputValues['name']!.setString('Budi Saputra');

              inputValues['familyMembers']!.setFormValues([
                {
                  'name': 'Ani',
                  'birthDate': DateTime(2000, 09, 09),
                  'additinalInformations': [
                    {
                      'title': 'Favorite Song',
                      'information': 'Happy',
                    },
                    {
                      'title': 'Favorite Food',
                    },
                    {
                      'title': 'Favorite Movie',
                    },
                  ],
                }
              ]);
            },
            onBeforeValidation: (context, inputValues) {
              inputValues['name']!
                  .setString(inputValues['name']!.getString()?.toUpperCase());
            },
            onAfterValidation: (context, inputValues, isValid, errorMessages) {
              if (inputValues['rate']!.getNumber() != null &&
                  inputValues['rateInfo']!.getString() == null) {
                errorMessages['rateInfo'] =
                    'Must be filled because rate is filled';
              }
            },
            onSubmit: (context, inputValues) {
              var result =
                  inputValues['familyMembers']!.getFormValues().first['name']!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Processing Data $result')),
              );
            },
            submitButtonSettings: const SubmitButtonSettings(
              label: 'Add Member',
              icon: Icon(Icons.add),
            ),
            additionalButtons: [
              AdditionalButton(
                onTap: () async {
                  await Future.delayed(const Duration(seconds: 2));
                },
                label: 'Cancel',
                icon: const Icon(Icons.cancel),
              ),
              AdditionalButton(
                onTap: () async {
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
