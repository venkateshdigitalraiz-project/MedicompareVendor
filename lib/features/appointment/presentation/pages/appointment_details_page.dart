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

  int _selectedDeliveryTab = 0; // 0: Medicompares, 1: Own Deliveryman
  final TextEditingController _partnerSearchController =
      TextEditingController();
  String? _selectedDeliveryPartnerId;
  String _selectedReadyTime = '30 min';
  final List<String> _readyTimeOptions = [
    '15 min',
    '30 min',
    '45 min',
    '60 min',
    '90 min',
  ];

  bool _isPendingStatus(String status) {
    final s = status.trim().toLowerCase();
    return s == 'pending' || s == 'new' || s.isEmpty;
  }

  bool _isConfirmedStatus(String status) =>
      status.trim().toLowerCase() == 'confirmed';

  bool _isAssignedStatus(String status) {
    final s = status.trim().toLowerCase();
    return s == 'assigned' ||
        s == 'assigned_technician' ||
        s == 'assigned technician';
  }

  @override
  void dispose() {
    _partnerSearchController.dispose();
    super.dispose();
  }

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

          final String resolvedPatientId =
              (patientId != null && patientId.isNotEmpty)
                  ? patientId
                  : (patient?.patientId.isNotEmpty == true
                      ? patient!.patientId
                      : (item.patientId.isNotEmpty ? item.patientId : ''));

          final String reportType = item.reports.isNotEmpty &&
                  item.reports.first.reportType.isNotEmpty
              ? item.reports.first.reportType
              : (item.type.toLowerCase().contains('lab') ||
                      item.serviceTypes.toLowerCase().contains('lab')
                  ? 'labtests'
                  : (item.type.isNotEmpty
                      ? item.type.toLowerCase()
                      : 'labtests'));

          final String resolvedSelectType =
              (selectType != null && selectType.isNotEmpty)
                  ? selectType
                  : (isGroup ? 'family' : 'family');

          final String description =
              item.reports.isNotEmpty ? item.reports.first.description : '';

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
    if (s == 'assigned_technician') return 'assigned';
    if ([
      'pending',
      'confirmed',
      'assigned',
      'sample_collected',
      'sample_not_collected',
      'completed',
    ].contains(s)) {
      return s;
    }
    return s;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF2E7D32);
      case 'sample_collected':
        return const Color(0xFF1565C0);
      case 'sample_not_collected':
        return const Color(0xFFD32F2F);
      case 'confirmed':
        return const Color(0xFF0284C7);
      case 'assigned':
      case 'assigned_technician':
        return const Color(0xFF059669);
      case 'cancelled':
      case 'rejected':
      case 'failed':
        return const Color(0xFFDC2626);
      case 'pending':
      default:
        return const Color(0xFFEF6C00);
    }
  }

  // Dropdown background helper - commented out with status dropdown
  /*
  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFFE8F5E9);
      case 'sample_collected':
        return const Color(0xFFE3F2FD);
      case 'sample_not_collected':
        return const Color(0xFFFFEBEE);
      case 'confirmed':
        return const Color(0xFFE0F2FE);
      case 'assigned':
      case 'assigned_technician':
        return const Color(0xFFECFDF5);
      case 'cancelled':
      case 'rejected':
      case 'failed':
        return const Color(0xFFFEE2E2);
      case 'pending':
      default:
        return const Color(0xFFFFF3E0);
    }
  }
  */

  Widget _buildAppBarActions() {
    return BlocBuilder<AppointmentDetailsBloc, AppointmentDetailsState>(
      builder: (context, state) {
        if (state is AppointmentStatusUpdatingState) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }

        // Do not show any buttons while loading or if details are not yet loaded
        if (state is! AppointmentDetailsLoaded) {
          return const SizedBox.shrink();
        }

        final details = state.appointmentDetails;
        final orderStatus = details.orderStatus.trim().toLowerCase();
        final isPending = orderStatus == 'pending';

        // Only show Cancel and Accept buttons when the API orderStatus is strictly pending
        if (!isPending) {
          return const SizedBox.shrink();
        }

        final orderId = details.id.isNotEmpty
            ? details.id
            : (details.orderId.isNotEmpty
                ? details.orderId
                : widget.appointmentId);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCompactAppBarButton(
              label: "Cancel Order",
              color: const Color(0xFFDC2626),
              onTap: () => _showCancelOrderDialog(orderId),
            ),
            const SizedBox(width: 6),
            _buildCompactAppBarButton(
              label: "Accept Order",
              color: AppColors.primary,
              onTap: () {
                context.read<AppointmentDetailsBloc>().add(
                      UpdateAppointmentOrderStatusEvent(
                        orderId: orderId,
                        orderStatus: 'confirmed',
                      ),
                    );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompactAppBarButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          minimumSize: const Size(0, 30),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showCancelOrderDialog(String orderId) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Cancel Order",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please provide a reason for cancelling this appointment order.",
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter cancellation reason...",
                hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Close",
              style: GoogleFonts.inter(
                  color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a cancellation reason"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              context.read<AppointmentDetailsBloc>().add(
                    UpdateAppointmentOrderStatusEvent(
                      orderId: orderId,
                      orderStatus: 'cancelled',
                      rejectionReason: reason,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              "Cancel Order",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildStatusDropdown(
  //     {required String orderId, required String currentStatus}) {
  //   final activeColor = _getStatusColor(currentStatus);
  //   final activeBgColor = _getStatusBgColor(currentStatus);

  //   final items = [
  //     {'label': 'Pending', 'value': 'pending'},
  //     {'label': 'Confirmed', 'value': 'confirmed'},
  //     {'label': 'Assigned', 'value': 'assigned'},
  //     {'label': 'Sample Collected', 'value': 'sample_collected'},
  //     {'label': 'Not Collected', 'value': 'sample_not_collected'},
  //     {'label': 'Completed', 'value': 'completed'},
  //     {'label': 'Cancelled', 'value': 'cancelled'},
  //   ];

  //   final currentLabel = items.firstWhere(
  //     (e) => e['value'] == currentStatus,
  //     orElse: () => {'label': 'Pending', 'value': 'pending'},
  //   )['label']!;

  //   return PopupMenuButton<String>(
  //     tooltip: 'Change Status',
  //     padding: EdgeInsets.zero,
  //     position: PopupMenuPosition.under,
  //     color: Colors.white,
  //     elevation: 6,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     onSelected: (newStatus) {
  //       if (newStatus == 'cancelled') {
  //         _showCancelOrderDialog(orderId);
  //         return;
  //       }
  //       setState(() {
  //         _selectedStatus = newStatus;
  //       });
  //       context.read<AppointmentDetailsBloc>().add(
  //             UpdateAppointmentOrderStatusEvent(
  //               orderId: orderId,
  //               orderStatus: newStatus,
  //             ),
  //           );
  //     },
  //     // itemBuilder: (context) => items.map((item) {
  //     //   final itemColor = _getStatusColor(item['value']!);
  //     // //  final itemBg = _getStatusBgColor(item['value']!);
  //     //   final isSelected = item['value'] == currentStatus;

  //     //   return PopupMenuItem<String>(
  //     //     value: item['value'],
  //     //     height: 38,
  //     //     child: Container(
  //     //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     //       decoration: BoxDecoration(
  //     //         color: isSelected ? itemBg : Colors.transparent,
  //     //         borderRadius: BorderRadius.circular(6),
  //     //       ),
  //     //       child: Row(
  //     //         mainAxisSize: MainAxisSize.min,
  //     //         children: [
  //     //           Container(
  //     //             width: 7,
  //     //             height: 7,
  //     //             decoration: BoxDecoration(
  //     //               shape: BoxShape.circle,
  //     //               color: itemColor,
  //     //             ),
  //     //           ),
  //     //           const SizedBox(width: 8),
  //     //           Text(
  //     //             item['label']!,
  //     //             style: GoogleFonts.inter(
  //     //               fontSize: 12,
  //     //               fontWeight:
  //     //                   isSelected ? FontWeight.bold : FontWeight.w500,
  //     //               color: isSelected ? itemColor : Colors.black87,
  //     //             ),
  //     //           ),
  //     //           if (isSelected) ...[
  //     //             const SizedBox(width: 8),
  //     //             Icon(Icons.check, size: 14, color: itemColor),
  //     //           ],
  //     //         ],
  //     //       ),
  //     //     ),
  //     //   );
  //     // }).toList(),
  //     child: Container(
  //       height: 30,
  //       margin: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
  //       padding: const EdgeInsets.symmetric(horizontal: 8),
  //       decoration: BoxDecoration(
  //         color: activeBgColor,
  //         borderRadius: BorderRadius.circular(16),
  //         border: Border.all(color: activeColor.withOpacity(0.4), width: 1),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             width: 6,
  //             height: 6,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               color: activeColor,
  //             ),
  //           ),
  //           const SizedBox(width: 5),
  //           ConstrainedBox(
  //             constraints: const BoxConstraints(maxWidth: 105),
  //             child: Text(
  //               currentLabel,
  //               style: GoogleFonts.inter(
  //                 fontSize: 11,
  //                 fontWeight: FontWeight.w600,
  //                 color: activeColor,
  //               ),
  //               overflow: TextOverflow.ellipsis,
  //               maxLines: 1,
  //             ),
  //           ),
  //           const SizedBox(width: 2),
  //           Icon(Icons.keyboard_arrow_down_rounded,
  //               size: 16, color: activeColor),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
          _buildAppBarActions(),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<AppointmentDetailsBloc, AppointmentDetailsState>(
        listener: (context, state) {
          if (state is AppointmentDetailsLoaded) {
            _cachedDetails = state.appointmentDetails;
            final normalized =
                _normalizeStatus(state.appointmentDetails.orderStatus);
            _selectedStatus = normalized;
          } else if (state is AppointmentStatusUpdatedState) {
            setState(() {
              _cachedDetails = null;
              _selectedStatus = null;
            });
            context
                .read<AppointmentDetailsBloc>()
                .add(GetAppointmentDetailsEvent(widget.appointmentId));
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
          if ((state is AppointmentDetailsLoading ||
                  state is AppointmentStatusUpdatingState) &&
              _cachedDetails == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final details = state is AppointmentDetailsLoaded
              ? state.appointmentDetails
              : _cachedDetails;

          if (details != null) {
            final activeStatus =
                (_selectedStatus ?? _normalizeStatus(details.orderStatus))
                    .trim()
                    .toLowerCase();

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isPendingStatus(activeStatus)) ...[
                        // Pending status: no delivery cards displayed
                      ] else if (_isConfirmedStatus(activeStatus)) ...[
                        _buildDeliveryAssignmentSection(state, details),
                        const SizedBox(height: 24),
                      ] else if (_isAssignedStatus(activeStatus)) ...[
                        _buildAssignedDeliveryPartnerSection(
                          details.deliveries.isNotEmpty
                              ? details.deliveries.first
                              : null,
                        ),
                        const SizedBox(height: 24),
                      ],
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
        children: [
          ...(details.isGroup
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
                      ...group.items.map((item) => _buildItemRow(item,
                          details: details,
                          patient: patient,
                          patientId: patientId,
                          selectType: selectType)),
                    ],
                  );
                }).toList()
              : details.normalItems
                  .map((item) => _buildItemRow(item,
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
                  .toList()),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildItemRow(AppointmentServiceItemEntity item,
      {required AppointmentDetailsEntity details,
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
          Builder(
            builder: (context) {
              final String pType = patient?.type.trim().toLowerCase() ?? '';
              final String effectivePatientType = pType.isNotEmpty
                  ? pType
                  : (selectType?.trim().toLowerCase() ?? '');
              final matchingReports = item.reports.where((report) {
                return report.selectType.trim().toLowerCase() ==
                    effectivePatientType;
              }).toList();

              final validReports = matchingReports.where((report) {
                return report.file.trim().isNotEmpty;
              }).toList();

              if (validReports.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: validReports.asMap().entries.map((entry) {
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
                );
              } else if (_pickedFiles.containsKey(item.orderItemId)) {
                return Row(
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
                  ],
                );
              } else {
                return BlocBuilder<AppointmentDetailsBloc,
                    AppointmentDetailsState>(
                  builder: (context, state) {
                    final isUploading = state is ReportUploadingState &&
                        state.orderItemId == item.orderItemId;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isUploading ? "Uploading..." : "Upload Report",
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
                );
              }
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

    final effectiveOrdStatus =
        _selectedStatus ?? _normalizeStatus(details.orderStatus);
    String ordStatus = effectiveOrdStatus.isNotEmpty
        ? effectiveOrdStatus[0].toUpperCase() +
            effectiveOrdStatus.substring(1).replaceAll('_', ' ')
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
    Widget? trailing,
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
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            if (trailing != null) trailing,
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

  Widget _buildAssignedDeliveryPartnerSection(
      AppointmentDeliveryEntity? delivery) {
    String formattedAssignedDate = 'N/A';
    if (delivery?.deliveryAssignedAt != null) {
      formattedAssignedDate = DateFormat('MMM d, yyyy, hh:mm a')
          .format(delivery!.deliveryAssignedAt!);
    }

    final partner = delivery?.deliveryPartnerDetails;
    final partnerName =
        partner?.name.isNotEmpty == true ? partner!.name : 'Delivery Partner';
    final initialLetter =
        partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'M';
    final vehicleNumber = partner?.vehicleNumber.isNotEmpty == true
        ? partner!.vehicleNumber
        : 'N/A';
    final phone = partner?.phone.isNotEmpty == true ? partner!.phone : 'N/A';
    final email = partner?.email.isNotEmpty == true ? partner!.email : 'N/A';
    final otp = delivery?.deliveryOtp.isNotEmpty == true
        ? delivery!.deliveryOtp
        : 'N/A';

    return _buildCard(
      title: "Assigned Delivery Partner",
      icon: Icons.local_shipping_outlined,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "Our Deliveryman",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF059669),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: partner?.profileImage != null &&
                        partner!.profileImage!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          partner.profileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                            initialLetter,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        initialLetter,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partnerName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Vehicle: $vehicleNumber",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "DELIVERY OTP",
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD97706),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      otp,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 15, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          phone,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 15, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          email,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Assigned At: $formattedAssignedDate",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAssignmentSection(
      AppointmentDetailsState state, AppointmentDetailsEntity details) {
    final loadedState = state is AppointmentDetailsLoaded ? state : null;
    final partners = loadedState?.deliveryPartners ?? [];
    final ownPartner = loadedState?.ownDeliveryPartner;
    final isLoadingPartners = loadedState?.isLoadingPartners ?? false;
    final partnersError = loadedState?.partnersError;
    final isAssigning = loadedState?.isAssigningPartner ?? false;

    if (_selectedDeliveryPartnerId == null && partners.isNotEmpty) {
      _selectedDeliveryPartnerId = partners.first.id;
    }

    return _buildCard(
      title: "Delivery Assignment",
      icon: Icons.local_shipping_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Tabs: Medicompares vs Own Deliveryman
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDeliveryTab = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedDeliveryTab == 0
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: _selectedDeliveryTab == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Medicompares",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: _selectedDeliveryTab == 0
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _selectedDeliveryTab == 0
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDeliveryTab = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedDeliveryTab == 1
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: _selectedDeliveryTab == 1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Own Deliveryman",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: _selectedDeliveryTab == 1
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _selectedDeliveryTab == 1
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab content
          if (_selectedDeliveryTab == 0) ...[
            // Search Input
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _partnerSearchController,
                decoration: InputDecoration(
                  hintText: "Search Medicompares partner...",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  suffixIcon: _partnerSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 16, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _partnerSearchController.clear();
                            context.read<AppointmentDetailsBloc>().add(
                                  const GetDeliveryPartnersEvent(
                                      search: '', forceRefresh: true),
                                );
                          },
                        )
                      : null,
                ),
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF1E293B)),
                onSubmitted: (value) {
                  context.read<AppointmentDetailsBloc>().add(
                        GetDeliveryPartnersEvent(
                            search: value.trim(), forceRefresh: true),
                      );
                },
                onChanged: (value) {
                  if (value.isEmpty) {
                    context.read<AppointmentDetailsBloc>().add(
                          const GetDeliveryPartnersEvent(
                              search: '', forceRefresh: true),
                        );
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // Delivery Partner List
            if (isLoadingPartners && partners.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (partnersError != null && partners.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        partnersError,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.red.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          context.read<AppointmentDetailsBloc>().add(
                                const GetDeliveryPartnersEvent(
                                    forceRefresh: true),
                              );
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              )
            else if (partners.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Text(
                    "No active delivery partners found",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: partners.length,
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.grey.shade100, height: 1),
                itemBuilder: (context, index) {
                  final partner = partners[index];
                  final isSelected = _selectedDeliveryPartnerId == partner.id;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDeliveryPartnerId = partner.id;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.06)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.primary.withOpacity(0.4),
                                width: 1)
                            : Border.all(color: Colors.transparent, width: 1),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  partner.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (partner.phone.isNotEmpty)
                                  Text(
                                    partner.phone,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  "ID: ${partner.partnerId}",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  size: 15, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                              Text(
                                partner.rating > 0
                                    ? partner.rating.toStringAsFixed(1)
                                    : '4.5',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 16),

            // Ready In Dropdown
            Row(
              children: [
                Text(
                  "Ready in: ",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedReadyTime,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          size: 18, color: Color(0xFF64748B)),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                      items: _readyTimeOptions.map((opt) {
                        return DropdownMenuItem<String>(
                          value: opt,
                          child: Text(opt),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedReadyTime = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Assign Medicompares Partner Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isAssigning
                    ? null
                    : () {
                        if (_selectedDeliveryPartnerId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Please select a delivery partner to assign"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        final orderId = details.id.isNotEmpty
                            ? details.id
                            : (details.orderId.isNotEmpty
                                ? details.orderId
                                : widget.appointmentId);
                        context.read<AppointmentDetailsBloc>().add(
                              AssignDeliveryPartnerEvent(
                                orderId: orderId,
                                deliveryPartnerId: _selectedDeliveryPartnerId!,
                                deliveryManType: 'vendor',
                                deliveryPartner: 'self',
                                readyTime: null,
                              ),
                            );
                      },
                child: isAssigning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Assign Medicompares Partner",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ] else ...[
            // Own Deliveryman tab
            if (isLoadingPartners && ownPartner == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (ownPartner != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: ownPartner.profileImage != null &&
                              ownPartner.profileImage!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.network(
                                ownPartner.profileImage!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Text(
                                  ownPartner.name.isNotEmpty
                                      ? ownPartner.name[0].toUpperCase()
                                      : 'O',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              ownPartner.name.isNotEmpty
                                  ? ownPartner.name[0].toUpperCase()
                                  : 'O',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  ownPartner.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFA7F3D0)),
                                ),
                                child: Text(
                                  "Internal",
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          if (ownPartner.phone.isNotEmpty)
                            Text(
                              ownPartner.phone,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            "Vendor ID: ${ownPartner.partnerId}",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Ready In Dropdown
              Row(
                children: [
                  Text(
                    "Ready in: ",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedReadyTime,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            size: 18, color: Color(0xFF64748B)),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                        ),
                        items: _readyTimeOptions.map((opt) {
                          return DropdownMenuItem<String>(
                            value: opt,
                            child: Text(opt),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedReadyTime = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Assign Own Deliveryman Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isAssigning
                      ? null
                      : () {
                          final orderId = details.id.isNotEmpty
                              ? details.id
                              : (details.orderId.isNotEmpty
                                  ? details.orderId
                                  : widget.appointmentId);
                          final readyMinutes =
                              _selectedReadyTime.replaceAll(' min', '');
                          context.read<AppointmentDetailsBloc>().add(
                                AssignDeliveryPartnerEvent(
                                  orderId: orderId,
                                  deliveryPartnerId: ownPartner.id,
                                  deliveryManType: 'vendor',
                                  deliveryPartner: 'vendor',
                                  readyTime: readyMinutes,
                                ),
                              );
                        },
                  child: isAssigning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Assign Own Deliveryman",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ] else ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.person_pin_circle_outlined,
                        size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      "Own Deliveryman",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "No internal delivery personnel registered.",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

    final effectiveOrdStatus =
        _selectedStatus ?? _normalizeStatus(details.orderStatus);
    String ordStatus = effectiveOrdStatus.isNotEmpty
        ? effectiveOrdStatus[0].toUpperCase() +
            effectiveOrdStatus.substring(1).replaceAll('_', ' ')
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
          _error =
              "Failed to load PDF from server (HTTP ${response.statusCode})";
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
/*
 "selectType": "self", and  "type": "self" both matched  then consider patientDetails  {name} compare both  but UI display URl but real ti display upload file with icon. please cross check it  
 */
