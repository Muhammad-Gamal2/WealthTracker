import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wealth_tracker/core/di/service_locator.dart';
import 'package:wealth_tracker/core/services/price_update_service.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
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
  PriceSnapshot? _prices;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _labelController.text = widget.existing!.label;
      _amountController.text = widget.existing!.amountUsd.toString();
    }
    _labelController.addListener(_onFieldChanged);
    _amountController.addListener(_onFieldChanged);
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    final p = await sl<PriceUpdateService>().getExchangeRate();
    if (mounted) {
      setState(() => _prices = p);
    }
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _labelController.removeListener(_onFieldChanged);
    _amountController.removeListener(_onFieldChanged);
    _labelController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double? get _egpEquivalent {
    if (_prices == null) return null;
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 0) return null;
    final label = _labelController.text.trim();
    if (label.isEmpty) return null;
    return amount * _prices!.usdToEgpRate;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final egpPreview = _egpEquivalent;

    return Container(
      decoration: BoxDecoration(
        color: ObsidianTheme.surface2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: const Border(
          top: BorderSide(color: ObsidianTheme.cyan, width: 2),
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
                        isEditing ? 'تعديل الحساب' : 'إضافة سيولة',
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
                    decoration: _inputDecoration(
                        hintText: 'e.g. Savings, Emergency Fund'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  // Amount field
                  _buildFieldLabel('AMOUNT · المبلغ'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _amountController,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 14, color: ObsidianTheme.text1),
                    decoration:
                        _inputDecoration(hintText: '0.00', suffixText: 'USD'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      if (double.parse(v) < 0) return 'Must be >= 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  // Live EGP preview
                  if (egpPreview != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ObsidianTheme.cyanBg,
                        borderRadius:
                            BorderRadius.circular(ObsidianTheme.radius),
                        border: Border.all(
                          color: ObsidianTheme.cyan.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'EGP Equivalent',
                            style: GoogleFonts.reemKufi(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ObsidianTheme.cyan,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            CurrencyFormatter.formatEgp(egpPreview),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: ObsidianTheme.cyan,
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
                              side: BorderSide(
                                  color: ObsidianTheme.border),
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
                                  color: ObsidianTheme.cyan
                                      .withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: FilledButton(
                              onPressed: _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: ObsidianTheme.cyan,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      ObsidianTheme.radius),
                                ),
                              ),
                              child: Text(
                                isEditing ? 'حفظ' : 'إضافة',
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
      suffixStyle:
          GoogleFonts.jetBrainsMono(fontSize: 14, color: ObsidianTheme.text3),
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
        borderSide: const BorderSide(color: ObsidianTheme.cyan, width: 1.5),
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

/// Show the add/edit liquidity bottom sheet.
void showAddLiquiditySheet(BuildContext context, {LiquidityEntity? existing}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddLiquidityDialog(existing: existing),
  );
}
