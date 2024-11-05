import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AddCatPage extends StatefulWidget {
  const AddCatPage({Key? key}) : super(key: key);

  @override
  State<AddCatPage> createState() => _AddCatPageState();
}

class _AddCatPageState extends State<AddCatPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Cat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'name',
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: FormBuilderValidators.required(),
              ),
              FormBuilderTextField(
                name: 'breed',
                decoration: const InputDecoration(
                  labelText: 'Breed',
                ),
                validator: FormBuilderValidators.required(),
              ),
              FormBuilderTextField(
                name: 'age',
                decoration: const InputDecoration(
                  labelText: 'Age',
                ),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.required(),
              ),
              FormBuilderTextField(
                name: 'color',
                decoration: const InputDecoration(
                  labelText: 'Color',
                ),
                validator: FormBuilderValidators.required(),
              ),
              FormBuilderTextField(
                name: 'imageUrl',
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                ),
                validator: FormBuilderValidators.required(),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle form submission, e.g., send data to backend
                    _formKey.currentState!.save();
                    print(_formKey.currentState!.value);
                  }
                },
                child: const Text('Add Cat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
