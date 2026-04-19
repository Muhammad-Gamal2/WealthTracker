import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/core/widgets/gain_badge.dart';
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
  final _buyPriceController = TextEditingController();
  final _currentPriceController = TextEditingController();
  String _market = 'EGX';

  static const _accentColor = ObsidianTheme.green;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _symbolController.text = e.symbol;
      _nameController.text = e.name;
      _quantityController.text = e.quantity.toString();
      _buyPriceController.text = e.purchasePrice.toString();
      _market = e.market;
    }
    _symbolController.addListener(_onFieldChanged);
    _nameController.addListener(_onFieldChanged);
    _quantityController.addListener(_onFieldChanged);
    _buyPriceController.addListener(_onFieldChanged);
    _currentPriceController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _symbolController.removeListener(_onFieldChanged);
    _nameController.removeListener(_onFieldChanged);
    _quantityController.removeListener(_onFieldChanged);
    _buyPriceController.removeListener(_onFieldChanged);
    _currentPriceController.removeListener(_onFieldChanged);
    _symbolController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _buyPriceController.dispose();
    _currentPriceController.dispose();
    super.dispose();
  }

  double? get _previewTotal {
    final qty = double.tryParse(_quantityController.text);
    final current = double.tryParse(_currentPriceController.text);
    if (qty == null || qty <= 0 || current == null || current <= 0) return null;
    return qty * current;
  }

  double? get _previewGainPercent {
    final buy = double.tryParse(_buyPriceController.text);
    final current = double.tryParse(_currentPriceController.text);
    if (buy == null || buy <= 0 || current == null || current <= 0) return null;
    return ((current - buy) / buy) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final previewTotal = _previewTotal;
    final previewGain = _previewGainPercent;
    final currencyLabel = _market == 'EGX' ? 'EGP' : 'USD';

    return Container(
      decoration: const BoxDecoration(
        color: ObsidianTheme.surface2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(color: _accentColor, width: 2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0x1FFFFFFF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title row
                  Row(
                    children: [
                      Text(
                        isEditing ? 'Edit Stock' : 'Add Stock',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ObsidianTheme.text1,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0x0DFFFFFF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.close,
                              size: 18, color: ObsidianTheme.text3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Market segmented control
                  _buildFieldLabel('MARKET'),
                  const SizedBox(height: 6),
                  _buildMarketPicker(),
                  const SizedBox(height: 14),
                  // Symbol field
                  _buildFieldLabel('SYMBOL'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _symbolController,
                    style: GoogleFonts.dmMono(
                        fontSize: 14, color: ObsidianTheme.text1),
                    decoration: _inputDecoration(
                      hintText: _market == 'EGX' ? 'e.g. COMI' : 'e.g. AAPL',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  // Company name (optional)
                  _buildFieldLabel('COMPANY NAME (OPTIONAL)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.dmMono(
                        fontSize: 14, color: ObsidianTheme.text1),
                    decoration: _inputDecoration(
                      hintText: 'e.g. Apple Inc.',
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Quantity + Buy Price (2-col grid)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('QUANTITY'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _quantityController,
                              style: GoogleFonts.dmMono(
                                  fontSize: 14, color: ObsidianTheme.text1),
                              decoration: _inputDecoration(hintText: '0'),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                if (double.tryParse(v) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('BUY PRICE'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _buyPriceController,
                              style: GoogleFonts.dmMono(
                                  fontSize: 14, color: ObsidianTheme.text1),
                              decoration: _inputDecoration(
                                hintText: '0.00',
                                suffixText: currencyLabel,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                if (double.tryParse(v) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Current Price
                  _buildFieldLabel('CURRENT PRICE'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _currentPriceController,
                    style: GoogleFonts.dmMono(
                        fontSize: 14, color: ObsidianTheme.text1),
                    decoration: _inputDecoration(
                      hintText: '0.00',
                      suffixText: currencyLabel,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 14),
                  // Live preview card
                  if (previewTotal != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ObsidianTheme.greenBg,
                        borderRadius:
                            BorderRadius.circular(ObsidianTheme.radius),
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Value',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _accentColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$currencyLabel ${CurrencyFormatter.formatNumber(previewTotal)}',
                                style: GoogleFonts.dmMono(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _accentColor,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (previewGain != null) GainBadge(percent: previewGain),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  const SizedBox(height: 6),
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              side: const BorderSide(
                                  color: ObsidianTheme.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ObsidianTheme.radius),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ObsidianTheme.text2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  ObsidianTheme.radius),
                              boxShadow: [
                                BoxShadow(
                                  color: _accentColor
                                      .withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: FilledButton(
                              onPressed: _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: _accentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      ObsidianTheme.radius),
                                ),
                              ),
                              child: Text(
                                isEditing ? 'Save' : 'Add',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: ObsidianTheme.text3,
        letterSpacing: 0.07 * 11,
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, String? suffixText}) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
      hintStyle: GoogleFonts.dmMono(fontSize: 14, color: ObsidianTheme.text3),
      suffixStyle:
          GoogleFonts.dmMono(fontSize: 14, color: ObsidianTheme.text3),
      filled: true,
      fillColor: const Color(0x0DFFFFFF),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ObsidianTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ObsidianTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _accentColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ObsidianTheme.lossRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: ObsidianTheme.lossRed, width: 1.5),
      ),
    );
  }

  Widget _buildMarketPicker() {
    const markets = ['EGX', 'US'];
    return Row(
      children: markets.map((m) {
        final isSelected = _market == m;
        final label = m == 'EGX' ? 'EGX (Egypt)' : 'US Market';
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: m != markets.last ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _market = m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? ObsidianTheme.greenBg
                      : const Color(0x0DFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? _accentColor.withValues(alpha: 0.5)
                        : ObsidianTheme.border,
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? _accentColor : ObsidianTheme.text3,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.existing != null) {
      updateStockItem(widget.existing!.copyWith(
        symbol: _symbolController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        quantity: double.parse(_quantityController.text),
        purchasePrice: double.parse(_buyPriceController.text),
        market: _market,
        currency: _market == 'EGX' ? 'EGP' : 'USD',
      ));
    } else {
      addStockItem(
        symbol: _symbolController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        quantity: double.parse(_quantityController.text),
        purchasePrice: double.parse(_buyPriceController.text),
        market: _market,
      );
    }
    Navigator.pop(context);
  }
}

/// Show the add/edit stock bottom sheet.
void showAddStockSheet(BuildContext context, {StockEntity? existing}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddStockDialog(existing: existing),
  );
}
