import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/vendor_vacation_entity.dart';

class ManageVacationDialog extends StatefulWidget {
  final DateTime selectedDate;
  final VendorVacationEntity? existingVacation;
  final String? vendorId;
  final Function(VendorVacationEntity vacation)? onSave;
  final Function(String vacationId, DateTime date)? onClear;

  const ManageVacationDialog({
    super.key,
    required this.selectedDate,
    this.existingVacation,
    this.vendorId,
    this.onSave,
    this.onClear,
  });

  @override
  State<ManageVacationDialog> createState() => _ManageVacationDialogState();
}

class _ManageVacationDialogState extends State<ManageVacationDialog> {
  static const String typeSingle = "Single Day Holiday";
  static const String typeGroup = "Group Holiday/Date Range ";
  static const String typeWorking = "Working Day (Open for booking)";

  late String _selectedType;
  late DateTime _startDate;
  late DateTime _endDate;
  late TextEditingController _reasonController;
  late bool _isMarkAsClosed;
  late bool _isExistingHoliday;

  @override
  void initState() {
    super.initState();
    final vacation = widget.existingVacation;
    if (vacation != null && vacation.isVacation) {
      _isExistingHoliday = true;
      if (vacation.startDate != null && vacation.endDate != null) {
        _selectedType = typeGroup;
        _startDate = vacation.startDate!;
        _endDate = vacation.endDate!;
      } else {
        _selectedType = typeSingle;
        _startDate =
            vacation.parsedDate ?? vacation.startDate ?? widget.selectedDate;
        _endDate = _startDate;
      }
      _reasonController = TextEditingController(text: vacation.reason);
      _isMarkAsClosed = vacation.isClosed;
    } else {
      _isExistingHoliday = false;
      _selectedType = typeSingle;
      _startDate = widget.selectedDate;
      _endDate = widget.selectedDate;
      _reasonController = TextEditingController();
      _isMarkAsClosed = true;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  bool get _isWorkingDay => _selectedType == typeWorking;
  bool get _isGroupHoliday => _selectedType == typeGroup;

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _handleSave() {
    final vacationId = widget.existingVacation?.id ?? '';
    final resolvedVendorId = widget.vendorId ??
        widget.existingVacation?.vendorId ??
        '';
    final VendorVacationEntity newVacation;

    if (_isWorkingDay) {
      final dateStr =
          "${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}";
      newVacation = VendorVacationEntity(
        id: '',
        date: dateStr,
        parsedDate: _startDate,
        startDate: _startDate,
        endDate: _startDate,
        reason: '',
        isClosed: false,
        type: 'working',
        vendorId: resolvedVendorId,
      );
      widget.onSave?.call(newVacation);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Marked as Working Day (Open for booking)"),
          backgroundColor: Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final reasonText = _reasonController.text.trim().isNotEmpty
        ? _reasonController.text.trim()
        : 'Holiday';

    if (_isGroupHoliday) {
      final List<String> dateList = [];
      DateTime cur = DateTime(_startDate.year, _startDate.month, _startDate.day);
      final stop = DateTime(_endDate.year, _endDate.month, _endDate.day);
      while (!cur.isAfter(stop)) {
        dateList.add(
            "${cur.year}-${cur.month.toString().padLeft(2, '0')}-${cur.day.toString().padLeft(2, '0')}");
        cur = DateTime(cur.year, cur.month, cur.day + 1);
      }

      newVacation = VendorVacationEntity(
        id: vacationId,
        startDate: _startDate,
        endDate: _endDate,
        reason: reasonText,
        isClosed: true,
        type: 'GROUP',
        vendorId: resolvedVendorId,
        dates: dateList,
      );
    } else {
      final dateStr =
          "${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}";
      newVacation = VendorVacationEntity(
        id: vacationId,
        date: dateStr,
        parsedDate: _startDate,
        startDate: _startDate,
        endDate: _startDate,
        reason: reasonText,
        isClosed: true,
        type: 'single',
        vendorId: resolvedVendorId,
      );
    }

    widget.onSave?.call(newVacation);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Vacation '$reasonText' saved successfully"),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleClear() {
    widget.onClear?.call(widget.existingVacation?.id ?? '', widget.selectedDate);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Holiday cleared successfully"),
        backgroundColor: Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. DIALOG HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Manage Vacation / Holiday",
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "CONFIGURE HOLIDAY SETTINGS",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 20),

                // 2. FORM BODY
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FIELD 1: VACATION TYPE
                      Text(
                        "VACATION TYPE",
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: _isWorkingDay
                              ? Colors.white
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isWorkingDay
                                ? const Color(0xFF241442)
                                : const Color(0xFFE2E8F0),
                            width: _isWorkingDay ? 1.5 : 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedType,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF1E293B),
                              size: 22,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: typeSingle,
                                child: Text(typeSingle),
                              ),
                              DropdownMenuItem(
                                value: typeGroup,
                                child: Text(typeGroup),
                              ),
                              DropdownMenuItem(
                                value: typeWorking,
                                child: Text(typeWorking),
                              ),
                            ],
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedType = val;
                                  if (val != typeWorking &&
                                      _reasonController.text.isEmpty) {
                                    _reasonController.text =
                                        widget.existingVacation?.reason ?? '';
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // FIELD 2: START DATE
                      Text(
                        "START DATE",
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickStartDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                DateFormat('MM/dd/yyyy').format(_startDate),
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Color(0xFF0F172A),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // OPTIONAL FIELD: END DATE (Group Holiday)
                      if (_isGroupHoliday) ...[
                        const SizedBox(height: 18),
                        Text(
                          "END DATE",
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickEndDate,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  DateFormat('MM/dd/yyyy').format(_endDate),
                                  style: GoogleFonts.inter(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: Color(0xFF0F172A),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // FIELD 3: REASON (Only if NOT Working Day)
                      if (!_isWorkingDay) ...[
                        const SizedBox(height: 18),
                        Text(
                          "REASON",
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _reasonController,
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            hintText: "Enter vacation reason",
                            hintStyle: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF94A3B8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // FIELD 4: Mark as Closed Checkbox
                        Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _isMarkAsClosed,
                                activeColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _isMarkAsClosed = val ?? true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isMarkAsClosed = !_isMarkAsClosed;
                                  });
                                },
                                child: Text(
                                  "Mark as Closed (No bookings allowed)",
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 16),

                // 3. DIALOG FOOTER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _isExistingHoliday
                      ? Row(
                          children: [
                            Expanded(
                              flex: 7,
                              child: _buildClearButton(),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 5,
                              child: _buildCancelButton(),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 8,
                              child: _buildSaveButton(),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Spacer(),
                            _buildCancelButton(),
                            const SizedBox(width: 8),
                            _buildSaveButton(),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildClearButton() {
    return OutlinedButton(
      onPressed: _handleClear,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFFCA5A5)),
        foregroundColor: const Color(0xFFEF4444),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "CLEAR HOLIDAY",
          maxLines: 1,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "CANCEL",
          maxLines: 1,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _handleSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF241442),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
        elevation: 0,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "SAVE VACATION",
          maxLines: 1,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
