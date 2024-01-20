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
                optionTotalData: Future(() => 2),
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
                optionTotalData: Future(() => Db.hobbies.length),
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
                                hiddenValue: [e.id], value: [e.name, e.detail]))
                            .where((element) => element.value[0]
                                .toLowerCase()
                                .contains(
                                    params['name']!.getString()!.toLowerCase()))
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
                    optionTotalData: Future(() => Db.hobbies.length),
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
