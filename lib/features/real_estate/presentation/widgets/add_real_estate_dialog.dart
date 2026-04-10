import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wealth_tracker/features/real_estate/domain/entities/real_estate_entity.dart';
import 'package:wealth_tracker/features/real_estate/presentation/real_estate_signals.dart';

class AddRealEstateDialog extends StatefulWidget {
  final RealEstateEntity? existing;
  const AddRealEstateDialog({super.key, this.existing});

  @override
  State<AddRealEstateDialog> createState() => _AddRealEstateDialogState();
}

class _AddRealEstateDialogState extends State<AddRealEstateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();
  DateTime? _purchaseDate;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _nameController.text = e.projectName;
      _amountController.text = e.purchaseAmountEgp.toString();
      _rateController.text = e.annualAppreciationPercent.toString();
      _purchaseDate = e.purchaseDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Property' : 'Add Real Estate'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  hintText: 'e.g. Cairo Heights Apt 3B',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _pickDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Purchase Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _purchaseDate != null
                        ? DateFormat('yyyy-MM-dd').format(_purchaseDate!)
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Purchase Amount',
                  suffixText: 'EGP',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid';
                  if (double.parse(v) <= 0) return 'Must be > 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'Annual Appreciation Rate',
                  suffixText: '%',
                  hintText: 'e.g. 10',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_purchaseDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a purchase date')),
              );
              return;
            }
            _submit();
          },
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime(2020),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.existing != null) {
      updateRealEstateItem(widget.existing!.copyWith(
        projectName: _nameController.text.trim(),
        purchaseDate: _purchaseDate,
        purchaseAmountEgp: double.parse(_amountController.text),
        annualAppreciationPercent: double.parse(_rateController.text),
      ));
    } else {
      addRealEstateItem(
        projectName: _nameController.text.trim(),
        purchaseDate: _purchaseDate!,
        purchaseAmountEgp: double.parse(_amountController.text),
        annualAppreciationPercent: double.parse(_rateController.text),
      );
    }
    Navigator.pop(context);
  }
}
