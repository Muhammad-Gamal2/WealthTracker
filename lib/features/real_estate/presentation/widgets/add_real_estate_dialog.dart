import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wealth_tracker/core/theme/obsidian_theme.dart';
import 'package:wealth_tracker/core/utils/currency_formatter.dart';
import 'package:wealth_tracker/core/widgets/gain_badge.dart';
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

  static const _accentColor = ObsidianTheme.orange;

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
    _nameController.addListener(_onFieldChanged);
    _amountController.addListener(_onFieldChanged);
    _rateController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _amountController.removeListener(_onFieldChanged);
    _rateController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _amountController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  double? get _previewCurrentValue {
    if (_purchaseDate == null) return null;
    final amount = double.tryParse(_amountController.text);
    final rate = double.tryParse(_rateController.text);
    if (amount == null || amount <= 0 || rate == null) return null;
    final yearsElapsed =
        DateTime.now().difference(_purchaseDate!).inDays / 365.25;
    return amount * pow(1 + rate / 100, yearsElapsed);
  }

  double? get _previewGainPercent {
    final current = _previewCurrentValue;
    final amount = double.tryParse(_amountController.text);
    if (current == null || amount == null || amount <= 0) return null;
    return ((current - amount) / amount) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final previewValue = _previewCurrentValue;
    final previewGain = _previewGainPercent;

    return Container(
      decoration: BoxDecoration(
        color: ObsidianTheme.surface2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: const Border(
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
                        isEditing ? 'تعديل العقار' : 'إضافة عقار',
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
                  // Project Name
                  _buildFieldLabel('PROJECT NAME · اسم المشروع'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 14, color: ObsidianTheme.text1),
                    decoration: _inputDecoration(
                      hintText: 'e.g. Cairo Heights Apt 3B',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  // Purchase Price
                  _buildFieldLabel('PURCHASE PRICE · سعر الشراء'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _amountController,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 14, color: ObsidianTheme.text1),
                    decoration: _inputDecoration(
                      hintText: '0',
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
                  const SizedBox(height: 14),
                  // Purchase Date + Annual Growth % (2-col grid)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('PURCHASE DATE · التاريخ'),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => _pickDate(context),
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                decoration: BoxDecoration(
                                  color: ObsidianTheme.inputFill,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: ObsidianTheme.border),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _purchaseDate != null
                                            ? DateFormat('yyyy-MM-dd')
                                                .format(_purchaseDate!)
                                            : 'Select',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 14,
                                          color: _purchaseDate != null
                                              ? ObsidianTheme.text1
                                              : ObsidianTheme.text3,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.calendar_today,
                                        size: 16,
                                        color: ObsidianTheme.text3),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('ANNUAL GROWTH · النمو'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _rateController,
                              style: GoogleFonts.jetBrainsMono(
                                  fontSize: 14, color: ObsidianTheme.text1),
                              decoration: _inputDecoration(
                                hintText: 'e.g. 10',
                                suffixText: '%',
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
                  // Live preview card
                  if (previewValue != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ObsidianTheme.orangeBg,
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
                                'Current Value',
                                style: GoogleFonts.reemKufi(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _accentColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.formatEgp(previewValue),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _accentColor,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (previewGain != null)
                            GainBadge(percent: previewGain),
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
                                  color: _accentColor
                                      .withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: FilledButton(
                              onPressed: () {
                                if (_purchaseDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please select a purchase date')),
                                  );
                                  return;
                                }
                                _submit();
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: _accentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      ObsidianTheme.radius),
                                ),
                              ),
                              child: Text(
                                isEditing ? 'حفظ' : 'إضافة عقار',
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

/// Show the add/edit real estate bottom sheet.
void showAddRealEstateSheet(BuildContext context,
    {RealEstateEntity? existing}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddRealEstateDialog(existing: existing),
  );
}
