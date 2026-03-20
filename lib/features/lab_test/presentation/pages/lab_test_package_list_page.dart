import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../bloc/lab_test_package_bloc.dart';
import '../bloc/lab_test_package_event.dart';
import '../bloc/lab_test_package_state.dart';
import '../../data/models/lab_test_model.dart';
import '../../data/models/lab_test_package_model.dart';
import '../../data/data_sources/lab_test_service.dart';
import '../widgets/lab_test_package_card.dart';
import '../widgets/add_lab_test_package_sheet.dart';
import '../../lab_test_injection.dart';

class LabTestPackageListPage extends StatefulWidget {
  const LabTestPackageListPage({super.key});

  @override
  State<LabTestPackageListPage> createState() => _LabTestPackageListPageState();
}

class _LabTestPackageListPageState extends State<LabTestPackageListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final LabTestService _labTestService = LabTestInjection.provideLabTestService();

  List<LabTestDetails> _allLabTests = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<LabTestPackageBloc>().add(const LoadLabTestPackagesEvent());
    _fetchLabTestsForFilter();
  }

  Future<void> _fetchLabTestsForFilter() async {
    try {
      final tests = await _labTestService.getAllLabTestTablets();
      if (mounted) setState(() => _allLabTests = tests);
    } catch (_) {}
  }

  void _onScroll() {
    final state = context.read<LabTestPackageBloc>().state;
    if (state is LabTestPackageLoaded && !state.isLoadingMore) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final pagination = state.response.pagination;
        if (pagination.page < pagination.totalPages) {
          context.read<LabTestPackageBloc>().add(LoadLabTestPackagesEvent(
            page: pagination.page + 1,
            labTestId: state.selectedLabTestId,
            search: state.searchQuery,
            isLoadMore: true,
          ));
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Lab Test Packages",
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          _addPackageButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<LabTestPackageBloc, LabTestPackageState>(
        builder: (context, state) {
          if (state is LabTestPackageInitial || (state is LabTestPackageLoading && context.read<LabTestPackageBloc>().state is! LabTestPackageLoaded)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LabTestPackageError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }

          if (state is LabTestPackageLoaded) {
            return Column(
              children: [
                // _buildHeader(),
                _buildFilters(state),
                Expanded(
                  child: state.response.list.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<LabTestPackageBloc>().add(const LoadLabTestPackagesEvent());
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: state.isLoadingMore ? state.response.list.length + 1 : state.response.list.length,
                            itemBuilder: (context, index) {
                              if (index >= state.response.list.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.0),
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                );
                              }
                              final item = state.response.list[index];
                              return _buildPackageItem(item);
                            },
                          ),
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _addPackageButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.9),
                child: AddLabTestPackageSheet(
                  onSuccess: () {
                    context.read<LabTestPackageBloc>().add(const LoadLabTestPackagesEvent());
                  },
                ),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
        label: Text(
          "Add Package",
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     Container(
          //       padding: const EdgeInsets.all(8),
          //       decoration: BoxDecoration(
          //         color: AppColors.primary.withOpacity(0.1),
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 24),
          //     ),
          //     const SizedBox(width: 12),
          //     Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           "Lab Test Packages",
          //           style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B)),
          //         ),
          //         Text(
          //           "Manage your lab test packages and pricing",
          //           style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildFilters(LabTestPackageLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (val) => context.read<LabTestPackageBloc>().add(SearchLabTestPackagesEvent(val)),
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Search packages...",
              hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, size: 20),
              prefixIconColor: Colors.grey[400],
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Lab Test Dropdown Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                menuMaxHeight: 400,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.white,
                value: state.selectedLabTestId.isEmpty ? null : state.selectedLabTestId,
                hint: Text("All Lab Tests", style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text("All Lab Tests", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                  ..._allLabTests.map((t) => DropdownMenuItem(
                    value: t.id,
                    child: Text(t.name, style: GoogleFonts.inter(fontSize: 13, color: Colors.black87)),
                  )),
                ],
                onChanged: (val) {
                  if (val != null) context.read<LabTestPackageBloc>().add(SelectLabTestForPackageFilterEvent(val));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageItem(LabTestPackageItem item) {
    return LabTestPackageCard(
      package: item,
      onTap: () => context.push('/lab-test-package-details', extra: item),
      onEdit: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.9),
              child: AddLabTestPackageSheet(
                editItem: item,
                onSuccess: () {
                   context.read<LabTestPackageBloc>().add(const LoadLabTestPackagesEvent());
                },
              ),
            ),
          ),
        );
      },
      onDelete: () {
        _showDeleteDialog(item);
      },
    );
  }

  void _showDeleteDialog(LabTestPackageItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Package", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text("Are you sure you want to delete ${item.name}? This action cannot be undone.", style: GoogleFonts.inter(fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (c) => const Center(child: CircularProgressIndicator()),
              );
              
              try {
                final labService = LabTestInjection.provideLabTestService();
                await labService.deletePackage(item.id);
                if (mounted) {
                  Navigator.pop(context); // close loading
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Package deleted successfully'), backgroundColor: Colors.green));
                  context.read<LabTestPackageBloc>().add(const LoadLabTestPackagesEvent());
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // close loading
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
            child: Text("Delete", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text("No packages found", style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
