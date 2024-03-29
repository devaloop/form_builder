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
            formName: 'Member',
            inputFields: const [
              InputText(
                name: 'name',
                label: 'Name',
              ),
              InputForm(
                name: 'detailProduct',
                label: 'Detail Product',
                inputFields: [
                  InputNumber(
                    name: 'quantity',
                    label: 'Quantity',
                  ),
                  InputText(
                    name: 'unit',
                    label: 'Unit',
                  ),
                  InputNumber(
                    name: 'purchasePrice',
                    label: 'Purchase Price',
                  ),
                  InputNumber(
                    name: 'sellingPrice',
                    label: 'Selling Price',
                  ),
                  InputNumber(
                    name: 'tax',
                    label: 'Tax',
                  ),
                ],
              ),
              InputForm(
                name: 'unitConversion',
                label: 'Unit Conversion',
                isMultiInputForm: true,
                isOptional: true,
                inputFields: [
                  InputNumber(
                    name: 'quantity',
                    label: 'Quantity',
                  ),
                  InputText(
                    name: 'unit',
                    label: 'Unit',
                  ),
                ],
              ),
              InputForm(
                name: 'priceConversion',
                label: 'Price Conversion',
                isMultiInputForm: true,
                isOptional: true,
                inputFields: [
                  InputText(
                    name: 'unit',
                    label: 'Unit',
                    isEditable: false,
                  ),
                  InputNumber(
                    name: 'purchasePricePerUnit',
                    label: 'Purchase Price Per Unit',
                  ),
                  InputNumber(
                    name: 'sellingPricePerUnit',
                    label: 'Selling Price Per Unit',
                  ),
                  InputNumber(
                    name: 'taxPerUnit',
                    label: 'Tax Per Unit',
                  ),
                ],
              ),
            ],
            onInitial: (context, inputValues) async {
              inputValues['name']!.setString('A');
              inputValues['detailProduct']!.setFormValues([
                {
                  'unit': 'Karton',
                  'quantity': 1,
                  'purchasePrice': 100000,
                  'sellingPrice': 200000,
                  'tax': 20000,
                },
              ]);
              await Future.delayed(const Duration(seconds: 15));
              List<Map<String, dynamic>> unitConversion = [];
              List<Map<String, dynamic>> priceConversion = [];
              unitConversion.add({
                'quantity': 1,
                'unit': 'Karton',
              });
              priceConversion.add({
                'unit': 'Karton',
                'purchasePricePerUnit': 100000,
                'sellingPricePerUnit': 200000,
                'taxPerUnit': 200000,
              });
              inputValues['unitConversion']!.setFormValues(unitConversion);
              inputValues['priceConversion']!.setFormValues(priceConversion);
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
