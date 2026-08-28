import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../domain/entities/appointment_details_entity.dart';
import '../bloc/appointment_details_bloc.dart';
import '../bloc/appointment_details_event.dart';
import '../bloc/appointment_details_state.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailsPage({
    super.key,
    required this.appointmentId,
  });

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  final Map<String, PlatformFile> _pickedFiles = {};
  AppointmentDetailsEntity? _cachedDetails;

  Future<void> _pickPdf({
    required AppointmentServiceItemEntity item,
    required AppointmentPatientDetailsEntity? patient,
    String? patientId,
    String? selectType,
    required String orderId,
    required bool isGroup,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.single;
        if (platformFile.path != null) {
          final extension = platformFile.path!.split('.').last.toLowerCase();
          if (extension != 'pdf') {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a valid PDF file'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          final file = File(platformFile.path!);

          final String resolvedOrderId = orderId.isNotEmpty
              ? orderId
              : (item.id.isNotEmpty
                  ? item.id
                  : (item.orderItemId.isNotEmpty
                      ? item.orderItemId
                      : widget.appointmentId));

          final String resolvedPatientId = (patientId != null && patientId.isNotEmpty)
              ? patientId
              : (patient?.patientId.isNotEmpty == true
                  ? patient!.patientId
                  : (item.patientId.isNotEmpty
                      ? item.patientId
                      : ''));

          final String reportType = item.reports.isNotEmpty &&
                  item.reports.first.reportType.isNotEmpty
              ? item.reports.first.reportType
              : (item.type.toLowerCase().contains('lab') ||
                      item.serviceTypes.toLowerCase().contains('lab')
                  ? 'labtests'
                  : (item.type.isNotEmpty ? item.type.toLowerCase() : 'labtests'));

          final String resolvedSelectType =
              (selectType != null && selectType.isNotEmpty)
                  ? selectType
                  : (isGroup ? 'family' : 'family');

          final String description = item.reports.isNotEmpty
              ? item.reports.first.description
              : '';

          if (resolvedOrderId.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Unable to upload report: missing item or order reference'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }

          setState(() {
            _pickedFiles[item.orderItemId] = platformFile;
          });

          if (mounted) {
            context.read<AppointmentDetailsBloc>().add(
                  UploadReportEvent(
                    orderId: resolvedOrderId,
                    orderItemId: item.orderItemId,
                    reportType: reportType,
                    patientId: resolvedPatientId,
                    selectType: resolvedSelectType,
                    description: description,
                    file: file,
                  ),
                );
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick PDF')),
        );
      }
    }
  }

  Future<void> _viewPdf(String itemId) async {
    final file = _pickedFiles[itemId];
    if (file != null && (file.path != null || file.bytes != null)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(
            path: file.path,
            bytes: file.bytes,
            title: file.name,
          ),
        ),
      );
    }
  }

  String _resolveFileUrl(String fileUrl) {
    if (fileUrl.trim().isEmpty) return '';
    final trimmed = fileUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return 'https://api.medicompares.com$trimmed';
    }
    return 'https://api.medicompares.com/$trimmed';
  }

  Future<void> _viewReportFile(String fileUrl, String title) async {
    final resolvedUrl = _resolveFileUrl(fileUrl);
    if (resolvedUrl.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(
            url: resolvedUrl,
            title: title,
          ),
        ),
      );
    }
  }

  void _removePdf(String itemId) {
    setState(() {
      _pickedFiles.remove(itemId);
    });
  }

  @override
  void initState() {
    super.initState();
    context
        .read<AppointmentDetailsBloc>()
        .add(GetAppointmentDetailsEvent(widget.appointmentId));
  }

  String? _selectedStatus;

  String _normalizeStatus(String status) {
    final s = status.trim().toLowerCase().replaceAll(' ', '_');
    if (s == 'not_collected') return 'sample_not_collected';
    if (['pending', 'sample_collected', 'sample_not_collected', 'completed']
        .contains(s)) {
      return s;
    }
    return 'pending';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF2E7D32);
      case 'sample_collected':
        return const Color(0xFF1565C0);
      case 'sample_not_collected':
        return const Color(0xFFD32F2F);
      case 'pending':
      default:
        return const Color(0xFFEF6C00);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFFE8F5E9);
      case 'sample_collected':
        return const Color(0xFFE3F2FD);
      case 'sample_not_collected':
        return const Color(0xFFFFEBEE);
      case 'pending':
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  Widget _buildStatusDropdown() {
    return BlocBuilder<AppointmentDetailsBloc, AppointmentDetailsState>(
      builder: (context, state) {
        String currentStatus = _selectedStatus ??
            (state is AppointmentDetailsLoaded
                ? _normalizeStatus(state.appointmentDetails.orderStatus)
                : 'pending');

        final activeColor = _getStatusColor(currentStatus);
        final activeBgColor = _getStatusBgColor(currentStatus);

        final items = [
          {'label': 'Pending', 'value': 'pending'},
          {'label': 'Sample Collected', 'value': 'sample_collected'},
          {'label': 'Not Collected', 'value': 'sample_not_collected'},
          {'label': 'Completed', 'value': 'completed'},
        ];

        final currentLabel = items.firstWhere(
          (e) => e['value'] == currentStatus,
          orElse: () => {'label': 'Pending', 'value': 'pending'},
        )['label']!;

        return PopupMenuButton<String>(
          tooltip: 'Change Status',
          padding: EdgeInsets.zero,
          position: PopupMenuPosition.under,
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (newStatus) {
            setState(() {
              _selectedStatus = newStatus;
            });
            final orderId = state is AppointmentDetailsLoaded
                ? (state.appointmentDetails.id.isNotEmpty
                    ? state.appointmentDetails.id
                    : (state.appointmentDetails.orderId.isNotEmpty
                        ? state.appointmentDetails.orderId
                        : widget.appointmentId))
                : widget.appointmentId;
            context.read<AppointmentDetailsBloc>().add(
                  UpdateAppointmentOrderStatusEvent(
                    orderId: orderId,
                    orderStatus: newStatus,
                  ),
                );
          },
          itemBuilder: (context) => items.map((item) {
            final itemColor = _getStatusColor(item['value']!);
            final itemBg = _getStatusBgColor(item['value']!);
            final isSelected = item['value'] == currentStatus;

            return PopupMenuItem<String>(
              value: item['value'],
              height: 38,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? itemBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: itemColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['label']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? itemColor : Colors.black87,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check, size: 14, color: itemColor),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
          child: Container(
            height: 30,
            margin: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: activeBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: activeColor.withOpacity(0.4), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeColor,
                  ),
                ),
                const SizedBox(width: 5),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 105),
                  child: Text(
                    currentLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: activeColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: activeColor),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 36,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Appointment Details",
              style: GoogleFonts.inter(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "ID: ${widget.appointmentId.length > 12 ? '${widget.appointmentId.substring(0, 12)}...' : widget.appointmentId}",
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          _buildStatusDropdown(),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<AppointmentDetailsBloc, AppointmentDetailsState>(
        listener: (context, state) {
          if (state is AppointmentDetailsLoaded) {
            _cachedDetails = state.appointmentDetails;
            _selectedStatus = _normalizeStatus(state.appointmentDetails.orderStatus);
          } else if (state is AppointmentStatusUpdatedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AppointmentStatusUpdateErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ReportUploadSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ReportUploadErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AppointmentDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is AppointmentDetailsLoading && _cachedDetails == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final details = state is AppointmentDetailsLoaded
              ? state.appointmentDetails
              : _cachedDetails;

          if (details != null) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppointmentInformationSection(details, isWide),
                      const SizedBox(height: 24),
                      // _buildCustomerInformationSection(details),
                      // const SizedBox(height: 24),
                      _buildAppointmentItemsSection(details),
                      const SizedBox(height: 24),
                      _buildBillingSummarySection(details),
                      const SizedBox(height: 24),
                      _buildCustomerAddressSection(details),
                      const SizedBox(height: 24),
                      _buildOrderTimelineSection(details),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAppointmentItemsSection(AppointmentDetailsEntity details) {
    int totalPatients = details.isGroup ? details.groupDetails.length : 1;
    return _buildCard(
      title: "Patients & Services ($totalPatients patients)",
      icon: Icons.medical_services_outlined,
      child: Column(
        children: details.isGroup
            ? details.groupDetails.map((group) {
                final patient = group.patientDetails;
                final patientId = patient?.patientId.isNotEmpty == true
                    ? patient!.patientId
                    : group.patientId;
                final selectType = group.selectType.isNotEmpty
                    ? group.selectType
                    : (details.personType.isNotEmpty
                        ? details.personType
                        : 'family');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (patient != null) ...[
                      Text(
                        "Patient: ${patient.name}",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                    ],
                    ...group.items.map((item) => _buildItemRow(
                        item,
                        details: details,
                        patient: patient,
                        patientId: patientId,
                        selectType: selectType)),
                  ],
                );
              }).toList()
            : details.normalItems
                .map((item) =>
                    _buildItemRow(item,
                        details: details,
                        patientId: details.groupDetails.isNotEmpty
                            ? details.groupDetails.first.patientId
                            : details.patientId,
                        selectType: details.groupDetails.isNotEmpty &&
                                details.groupDetails.first.selectType.isNotEmpty
                            ? details.groupDetails.first.selectType
                            : (details.personType.isNotEmpty
                                ? details.personType
                                : 'family')))
                .toList(),
      ),
    );
  }

  Widget _buildItemRow(
      AppointmentServiceItemEntity item, {
      required AppointmentDetailsEntity details,
      AppointmentPatientDetailsEntity? patient,
      String? patientId,
      String? selectType}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item.productImages.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.productImages.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                        ),
                      )
                    : const Icon(Icons.image_outlined, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName.isNotEmpty
                          ? item.productName
                          : "Appointment Service",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Type: ${item.type}",
                          style: GoogleFonts.inter(
                              color: Colors.grey, fontSize: 12),
                        ),
                        if (item.serviceTypes.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            "Service: ${item.serviceTypes}",
                            style: GoogleFonts.inter(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                    if (patient != null &&
                        (patient.age.isNotEmpty ||
                            patient.gender.isNotEmpty)) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (patient.age.isNotEmpty) ...[
                            Text(
                              "Age: ${patient.age}",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            if (patient.gender.isNotEmpty)
                              const SizedBox(width: 8),
                          ],
                          if (patient.gender.isNotEmpty)
                            Text(
                              "Gender: ${patient.gender}",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 12),
          _buildSummaryRow("Qty", "${item.quantity}"),
          _buildSummaryRow("Price", "₹${item.totalPrice.toStringAsFixed(2)}"),
          _buildSummaryRow(
            "Admin Commission",
            "₹${item.adminCommission.toStringAsFixed(2)}",
            labelColor: Colors.black,
            valueColor: Colors.black,
          ),
          _buildSummaryRow("Status", item.status),
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 8),
          if (item.reports.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: item.reports.asMap().entries.map((entry) {
                final int index = entry.key;
                final report = entry.value;
                final String fileName = report.file.isNotEmpty
                    ? (report.file.split('/').last.split('\\').last)
                    : "Report ${index + 1}";
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: InkWell(
                    onTap: () => _viewReportFile(report.file, fileName),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.picture_as_pdf,
                            color: Colors.red.shade400, size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            fileName,
                            style: GoogleFonts.inter(
                              color: Colors.blue.shade700,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
          else if (_pickedFiles.containsKey(item.orderItemId))
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: InkWell(
                    onTap: () => _viewPdf(item.orderItemId),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.picture_as_pdf,
                            color: Colors.red.shade400, size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _pickedFiles[item.orderItemId]!.name,
                            style: GoogleFonts.inter(
                              color: Colors.blue.shade700,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removePdf(item.orderItemId),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            )
          else
            BlocBuilder<AppointmentDetailsBloc, AppointmentDetailsState>(
              builder: (context, state) {
                final isUploading = state is ReportUploadingState &&
                    state.orderItemId == item.orderItemId;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isUploading ? "Uploading..." : "Upload",
                      style: GoogleFonts.inter(
                          color: Colors.grey.shade700, fontSize: 14),
                    ),
                    if (isUploading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      InkWell(
                        onTap: () => _pickPdf(
                          item: item,
                          patient: patient,
                          patientId: patientId,
                          selectType: selectType,
                          orderId: item.id.isNotEmpty
                              ? item.id
                              : (item.orderItemId.isNotEmpty
                                  ? item.orderItemId
                                  : (details.id.isNotEmpty
                                      ? details.id
                                      : widget.appointmentId)),
                          isGroup: details.isGroup,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.attach_file,
                              size: 20, color: Colors.blue.shade700),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentInformationSection(
      AppointmentDetailsEntity details, bool isWide) {
    int totalPatients = details.isGroup ? details.groupDetails.length : 1;
    String groupOrderText = details.isGroup
        ? "Yes - $totalPatients patient(s) in this group"
        : "No";

    String formattedSelectedDate = 'N/A';
    if (details.selectedDate != null) {
      formattedSelectedDate =
          DateFormat('MMM dd, yyyy').format(details.selectedDate!);
    }

    String formattedOrderDate = 'N/A';
    if (details.createdAt != null) {
      formattedOrderDate =
          DateFormat('MMM dd, yyyy, hh:mm a').format(details.createdAt!);
    }

    final column1 = [
      _buildInfoBlock("Order ID", details.orderId),
      _buildInfoBlock("Order Date", formattedOrderDate),
      _buildInfoBlock("Selected Date", formattedSelectedDate),
      _buildInfoBlock("Time Slot", details.selectedTimeSlot),
    ];

    final column2 = [
      _buildInfoBlock(
          "Payment Method",
          details.paymentMethod.isNotEmpty
              ? details.paymentMethod[0].toUpperCase() +
                  details.paymentMethod.substring(1)
              : 'Online'),
      _buildInfoBlock("Referred Doctor", details.referredDoctor),
      _buildInfoBlock("Group Order", groupOrderText),
    ];

    return _buildCard(
      title: "Appointment Information",
      icon: Icons.inventory_2_outlined,
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: column1,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: column2,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...column1,
                ...column2,
              ],
            ),
    );
  }

  Widget _buildInfoBlock(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF94A3B8), // slate 400
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B), // slate 800
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingSummarySection(AppointmentDetailsEntity details) {
    String payStatus = details.paymentStatus.isNotEmpty
        ? details.paymentStatus[0].toUpperCase() +
            details.paymentStatus.substring(1)
        : 'Pending';

    String ordStatus = details.orderStatus.isNotEmpty
        ? details.orderStatus[0].toUpperCase() +
            details.orderStatus.substring(1)
        : 'Pending';

    final String? createdType =
        details.couponDetails?.createdType?.toLowerCase();

    double couponAmount = 0.0;
    if (createdType == 'vendor') {
      couponAmount = details.billingSummary.couponAmount;
    }

    final double grandTotal = details.billingSummary.subtotal +
        details.billingSummary.sampleCollection -
        details.billingSummary.adminCommission -
        couponAmount;

    return _buildCard(
      title: "Billing Summary",
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _buildSummaryRow("Payment Status", payStatus,
              valueColor: _getStatusColor(payStatus)),
          _buildSummaryRow("Order Status", ordStatus,
              valueColor: _getStatusColor(ordStatus)),
          const Divider(height: 24),
          _buildSummaryRow("Subtotal (Inclusive all Taxes)",
              details.billingSummary.subtotal.toRupeeFormat(decimalDigits: 2)),
          if (details.billingSummary.sampleCollection > 0)
            _buildSummaryRow(
                "Sample Collection",
                details.billingSummary.sampleCollection
                    .toRupeeFormat(decimalDigits: 2)),
          if (details.billingSummary.tax > 0)
            _buildSummaryRow("Tax",
                details.billingSummary.tax.toRupeeFormat(decimalDigits: 2)),
          if (details.billingSummary.deliveryCharges > 0)
            _buildSummaryRow(
                "Delivery Charges",
                details.billingSummary.deliveryCharges
                    .toRupeeFormat(decimalDigits: 2)),
          if (couponAmount > 0)
            _buildSummaryRow("Coupon Discount",
                "-${couponAmount.toRupeeFormat(decimalDigits: 2)}",
                valueColor: Colors.green),
          _buildSummaryRow("Admin Commission",
              "-${details.billingSummary.adminCommission.toRupeeFormat(decimalDigits: 2)}",
              valueColor: Colors.red, labelColor: Colors.red),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Grand Total",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(grandTotal.toRupeeFormat(decimalDigits: 2),
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {Color? valueColor, Color? labelColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: labelColor ?? Colors.grey.shade700, fontSize: 14)),
          Text(
            value,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: valueColor ?? Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildCustomerAddressSection(AppointmentDetailsEntity details) {
    final address = details.shippingAddress ?? details.billingAddress;

    bool isEmptyAddress = true;
    if (address != null) {
      if (address.houseNo.isNotEmpty ||
          address.area.isNotEmpty ||
          address.landmark.isNotEmpty ||
          address.locationAddress.isNotEmpty ||
          address.pincode.isNotEmpty ||
          address.addressType.isNotEmpty) {
        isEmptyAddress = false;
      }
    }

    return _buildCard(
      title: "Customer Address",
      icon: Icons.location_on_outlined,
      child: isEmptyAddress
          ? Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("N/A",
                      style: GoogleFonts.inter(
                          fontSize: 14, color: const Color(0xFF475569))),
                  const SizedBox(height: 6),
                  Text("Type : N/A",
                      style: GoogleFonts.inter(
                          fontSize: 14, color: const Color(0xFF475569))),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (address!.houseNo.isNotEmpty) ...[
                  Text(address.houseNo,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: const Color(0xFF1E293B))),
                  const SizedBox(height: 6),
                ],
                if (address.area.isNotEmpty) ...[
                  Text(address.area,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xFF475569))),
                  const SizedBox(height: 6),
                ],
                if (address.landmark.isNotEmpty) ...[
                  Text("Landmark: ${address.landmark}",
                      style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xFF475569))),
                  const SizedBox(height: 6),
                ],
                if (address.locationAddress.isNotEmpty) ...[
                  Text(address.locationAddress,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xFF475569))),
                  const SizedBox(height: 6),
                ],
                if (address.pincode.isNotEmpty) ...[
                  Text("Pincode: ${address.pincode}",
                      style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xFF475569))),
                  const SizedBox(height: 6),
                ],
                if (address.addressType.isNotEmpty) ...[
                  Text(
                      "Type: ${address.addressType[0].toUpperCase()}${address.addressType.substring(1)}",
                      style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xFF475569))),
                ],
              ],
            ),
    );
  }

  Widget _buildOrderTimelineSection(AppointmentDetailsEntity details) {
    String formattedDate = 'N/A';
    if (details.createdAt != null) {
      formattedDate =
          DateFormat('MMM dd, yyyy, hh:mm a').format(details.createdAt!);
    }

    String payStatus = details.paymentStatus.isNotEmpty
        ? details.paymentStatus[0].toUpperCase() +
            details.paymentStatus.substring(1)
        : 'Pending';

    String ordStatus = details.orderStatus.isNotEmpty
        ? details.orderStatus[0].toUpperCase() +
            details.orderStatus.substring(1)
        : 'Pending';

    return _buildCard(
      title: "Order Timeline",
      icon: Icons.access_time,
      child: Column(
        children: [
          _buildTimelineStep(
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            bgColor: Colors.green.withOpacity(0.1),
            title: "Order Created",
            subtitle: formattedDate,
            showLine: true,
          ),
          _buildTimelineStep(
            icon: Icons.credit_card,
            iconColor: Colors.blue,
            bgColor: Colors.blue.withOpacity(0.1),
            title: "Payment $payStatus",
            subtitle: payStatus,
            showLine: true,
          ),
          _buildTimelineStep(
            icon: Icons.schedule,
            iconColor: Colors.orange,
            bgColor: Colors.orange.withOpacity(0.1),
            title: "Current Status",
            subtitle: ordStatus,
            showLine: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required bool showLine,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 24,
                color: Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              if (showLine) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class PdfViewerPage extends StatefulWidget {
  final String? path;
  final Uint8List? bytes;
  final String? url;
  final String title;

  const PdfViewerPage({
    super.key,
    this.path,
    this.bytes,
    this.url,
    required this.title,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdfData();
  }

  Future<void> _loadPdfData() async {
    try {
      if (widget.bytes != null && widget.bytes!.isNotEmpty) {
        _pdfBytes = widget.bytes;
      } else if (widget.path != null && widget.path!.isNotEmpty) {
        final file = File(widget.path!);
        if (await file.exists()) {
          _pdfBytes = await file.readAsBytes();
        } else {
          _error = "File does not exist: ${widget.path}";
        }
      } else if (widget.url != null && widget.url!.isNotEmpty) {
        final response = await http.get(Uri.parse(widget.url!));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          _pdfBytes = response.bodyBytes;
        } else {
          _error = "Failed to load PDF from server (HTTP ${response.statusCode})";
        }
      } else {
        _error = "No PDF data provided";
      }
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Failed to load PDF:\n$_error",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : PdfPreview(
                  build: (format) => _pdfBytes!,
                  allowPrinting: false,
                  allowSharing: false,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  useActions: false,
                  padding: EdgeInsets.zero,
                  previewPageMargin: EdgeInsets.zero,
                  scrollViewDecoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  pdfPreviewPageDecoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                ),
    );
  }
}
