import 'package:flutter/material.dart';
import 'package:wealth_tracker/features/gold/domain/entities/gold_entity.dart';
import 'package:wealth_tracker/features/gold/presentation/gold_signals.dart';

class AddGoldDialog extends StatefulWidget {
  final GoldEntity? existing;
  const AddGoldDialog({super.key, this.existing});

  @override
  State<AddGoldDialog> createState() => _AddGoldDialogState();
}

class _AddGoldDialogState extends State<AddGoldDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _gramsController = TextEditingController();
  int _karat = 21;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _labelController.text = widget.existing!.label;
      _gramsController.text = widget.existing!.weightGrams.toString();
      _karat = widget.existing!.karat;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Gold Item' : 'Add Gold'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'e.g. Wedding Ring, Bullion',
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _gramsController,
              decoration: const InputDecoration(
                labelText: 'Weight (grams)',
                suffixText: 'g',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Invalid number';
                if (double.parse(v) <= 0) return 'Must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _karat,
              decoration: const InputDecoration(labelText: 'Karat'),
              items: [24, 22, 21, 18]
                  .map((k) => DropdownMenuItem(
                        value: k,
                        child: Text('${k}K'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _karat = v!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.existing != null) {
      updateGoldItem(widget.existing!.copyWith(
        label: _labelController.text.trim(),
        weightGrams: double.parse(_gramsController.text),
        karat: _karat,
      ));
    } else {
      addGoldItem(
        label: _labelController.text.trim(),
        weightGrams: double.parse(_gramsController.text),
        karat: _karat,
      );
    }
    Navigator.pop(context);
  }
}
