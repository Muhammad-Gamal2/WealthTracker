import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
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
  final _purchasePriceController = TextEditingController();
  int _karat = 21;
  PriceSnapshot? _prices;

  static const _karatOptions = [24, 22, 21, 18];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _labelController.text = widget.existing!.label;
      _gramsController.text = widget.existing!.weightGrams.toString();
      _karat = widget.existing!.karat;
      if (widget.existing!.purchasePricePerGram > 0) {
        _purchasePriceController.text =
            widget.existing!.purchasePricePerGram.toString();
      }
    }
    _labelController.addListener(_onFieldChanged);
    _gramsController.addListener(_onFieldChanged);
    _purchasePriceController.addListener(_onFieldChanged);
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    final p = await sl<PriceUpdateService>().getGoldPrices();
    if (mounted) {
      setState(() {
        _prices = p;
      });
    }
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _labelController.removeListener(_onFieldChanged);
    _gramsController.removeListener(_onFieldChanged);
    _purchasePriceController.removeListener(_onFieldChanged);
    _labelController.dispose();
    _gramsController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  double? get _estimatedValue {
    if (_prices == null) return null;
    final grams = double.tryParse(_gramsController.text);
    if (grams == null || grams <= 0) return null;
    final label = _labelController.text.trim();
    if (label.isEmpty) return null;
    return grams * _prices!.priceForKarat(_karat);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final estimated = _estimatedValue;

    return Container(
      decoration: BoxDecoration(
        color: ObsidianTheme.surface2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: const Border(
          top: BorderSide(color: ObsidianTheme.gold, width: 2),
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
                        isEditing ? 'تعديل الذهب' : 'إضافة ذهب',
                        style: GoogleFonts.reemKufi(
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
                            color: ObsidianTheme.inputFill,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.close,
                              size: 18, color: ObsidianTheme.text3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Label field
                  _buildFieldLabel('LABEL · الوصف'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _labelController,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 14, color: ObsidianTheme.text1),
                    decoration:
                        _inputDecoration(hintText: 'e.g. Wedding Ring, Bullion'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  // Weight field
                  _buildFieldLabel('WEIGHT · الوزن'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _gramsController,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 14, color: ObsidianTheme.text1),
                    decoration:
                        _inputDecoration(hintText: '0.00', suffixText: 'g'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      if (double.parse(v) <= 0) return 'Must be > 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  // Karat picker
                  _buildFieldLabel('KARAT · العيار'),
                  const SizedBox(height: 6),
                  _buildKaratPicker(),
                  const SizedBox(height: 14),
                  // Purchase price field
                  _buildFieldLabel('PURCHASE PRICE · سعر الشراء'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _purchasePriceController,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 14, color: ObsidianTheme.text1),
                    decoration: _inputDecoration(
                      hintText: '0.00 (optional)',
                      suffixText: 'EGP/g',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (double.tryParse(v) == null) return 'Invalid number';
                      if (double.parse(v) < 0) return 'Must be >= 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  // Live value preview
                  if (estimated != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ObsidianTheme.goldBg,
                        borderRadius:
                            BorderRadius.circular(ObsidianTheme.radius),
                        border: Border.all(
                          color: ObsidianTheme.gold.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Estimated Value',
                            style: GoogleFonts.reemKufi(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ObsidianTheme.gold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            CurrencyFormatter.formatEgp(estimated),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: ObsidianTheme.gold,
                            ),
                          ),
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
                              side:
                                  BorderSide(color: ObsidianTheme.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    ObsidianTheme.radius),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.reemKufi(
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
                                  color: ObsidianTheme.gold
                                      .withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: FilledButton(
                              onPressed: _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: ObsidianTheme.gold,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      ObsidianTheme.radius),
                                ),
                              ),
                              child: Text(
                                isEditing ? 'حفظ' : 'إضافة ذهب',
                                style: GoogleFonts.reemKufi(
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
      style: GoogleFonts.jetBrainsMono(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: ObsidianTheme.text3,
        letterSpacing: 0.18 * 9,
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, String? suffixText}) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
      hintStyle: GoogleFonts.jetBrainsMono(fontSize: 14, color: ObsidianTheme.text3),
      suffixStyle: GoogleFonts.jetBrainsMono(fontSize: 14, color: ObsidianTheme.text3),
      filled: true,
      fillColor: ObsidianTheme.inputFill,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: ObsidianTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: ObsidianTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: ObsidianTheme.gold, width: 1.5),
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

  Widget _buildKaratPicker() {
    return Row(
      children: _karatOptions.map((k) {
        final isSelected = _karat == k;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: k != _karatOptions.last ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => setState(() {
                _karat = k;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? ObsidianTheme.goldBg
                      : ObsidianTheme.inputFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? ObsidianTheme.gold.withValues(alpha: 0.5)
                        : ObsidianTheme.border,
                  ),
                ),
                child: Text(
                  '${k}K',
                  style: GoogleFonts.reemKufi(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color:
                        isSelected ? ObsidianTheme.gold : ObsidianTheme.text3,
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
    final purchasePrice =
        double.tryParse(_purchasePriceController.text) ?? 0;
    if (widget.existing != null) {
      updateGoldItem(widget.existing!.copyWith(
        label: _labelController.text.trim(),
        weightGrams: double.parse(_gramsController.text),
        karat: _karat,
        purchasePricePerGram: purchasePrice,
      ));
    } else {
      addGoldItem(
        label: _labelController.text.trim(),
        weightGrams: double.parse(_gramsController.text),
        karat: _karat,
        purchasePricePerGram: purchasePrice,
      );
    }
    Navigator.pop(context);
  }
}

/// Show the add/edit gold bottom sheet.
void showAddGoldSheet(BuildContext context, {GoldEntity? existing}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddGoldDialog(existing: existing),
  );
}
