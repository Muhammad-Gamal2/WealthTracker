import 'package:flutter/material.dart';
import 'package:wealth_tracker/features/stocks/domain/entities/stock_entity.dart';
import 'package:wealth_tracker/features/stocks/presentation/stocks_signals.dart';

class AddStockDialog extends StatefulWidget {
  final StockEntity? existing;
  const AddStockDialog({super.key, this.existing});

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  String _market = 'EGX';

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _symbolController.text = e.symbol;
      _nameController.text = e.name;
      _quantityController.text = e.quantity.toString();
      _priceController.text = e.purchasePrice.toString();
      _market = e.market;
    }
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Stock' : 'Add Stock'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'EGX', label: Text('EGX (Egypt)')),
                  ButtonSegment(value: 'US', label: Text('US Market')),
                ],
                selected: {_market},
                onSelectionChanged: (s) =>
                    setState(() => _market = s.first),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _symbolController,
                decoration: InputDecoration(
                  labelText: 'Symbol',
                  hintText: _market == 'EGX' ? 'e.g. COMI' : 'e.g. AAPL',
                  suffixText: _market == 'EGX' ? ':XCAI (auto)' : null,
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  hintText: 'e.g. Apple Inc.',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                    labelText: 'Number of Shares'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Purchase Price per Share',
                  suffixText: _market == 'EGX' ? 'EGP' : 'USD',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
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
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.existing != null) {
      updateStockItem(widget.existing!.copyWith(
        symbol: _symbolController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        quantity: double.parse(_quantityController.text),
        purchasePrice: double.parse(_priceController.text),
        market: _market,
        currency: _market == 'EGX' ? 'EGP' : 'USD',
      ));
    } else {
      addStockItem(
        symbol: _symbolController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        quantity: double.parse(_quantityController.text),
        purchasePrice: double.parse(_priceController.text),
        market: _market,
      );
    }
    Navigator.pop(context);
  }
}
