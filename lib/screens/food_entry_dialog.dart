import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import 'dart:math';

class FoodEntryDialog extends StatefulWidget {
  final FoodEntry? existing;
  const FoodEntryDialog({super.key, this.existing});

  @override
  State<FoodEntryDialog> createState() => _FoodEntryDialogState();
}

class _FoodEntryDialogState extends State<FoodEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _caloriesController = TextEditingController(
      text: widget.existing?.calories?.toString() ?? '',
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final entry = FoodEntry(
      id: widget.existing?.id ?? Random().nextInt(999999).toString(),
      name: _nameController.text.trim(),
      calories: int.tryParse(_caloriesController.text.trim()) ?? 0,
      time: '', // kept empty just so the model structure matches
    );
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? "Add Food" : "Edit Food"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Food Name'),
              validator: (v) =>
              v == null || v.isEmpty ? 'Please enter a food name' : null,
            ),
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
              validator: (v) =>
              v == null || v.isEmpty ? 'Enter calories' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
