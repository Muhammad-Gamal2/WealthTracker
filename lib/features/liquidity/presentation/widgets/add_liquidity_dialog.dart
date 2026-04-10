import 'package:flutter/material.dart';
import 'package:wealth_tracker/features/liquidity/domain/entities/liquidity_entity.dart';
import 'package:wealth_tracker/features/liquidity/presentation/liquidity_signals.dart';

class AddLiquidityDialog extends StatefulWidget {
  final LiquidityEntity? existing;
  const AddLiquidityDialog({super.key, this.existing});

  @override
  State<AddLiquidityDialog> createState() => _AddLiquidityDialogState();
}

class _AddLiquidityDialogState extends State<AddLiquidityDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _labelController.text = widget.existing!.label;
      _amountController.text = widget.existing!.amountUsd.toString();
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Liquidity' : 'Add Liquidity'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'e.g. Savings, Emergency Fund',
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (USD)',
                prefixText: '\$ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Invalid number';
                if (double.parse(v) < 0) return 'Must be ≥ 0';
                return null;
              },
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
      updateLiquidityItem(widget.existing!.copyWith(
        label: _labelController.text.trim(),
        amountUsd: double.parse(_amountController.text),
      ));
    } else {
      addLiquidityItem(
        label: _labelController.text.trim(),
        amountUsd: double.parse(_amountController.text),
      );
    }
    Navigator.pop(context);
  }
}
