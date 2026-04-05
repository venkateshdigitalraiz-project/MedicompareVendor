import 'dart:async';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/surgery_model.dart';
import '../../surgery_injection.dart';
import '../bloc/surgery_bloc.dart';
import '../bloc/surgery_event.dart';
import '../bloc/surgery_state.dart';
import '../widgets/add_surgery_sheet.dart';

class SurgeryListPage extends StatefulWidget {
  const SurgeryListPage({super.key});

  @override
  State<SurgeryListPage> createState() => _SurgeryListPageState();
}

class _SurgeryListPageState extends State<SurgeryListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = context.read<SurgeryBloc>().state;
    if (state is SurgeryLoaded && !state.isLoadingMore) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final pagination = state.surgeryResponse.pagination;
        if (pagination.page < pagination.totalPages) {
          context.read<SurgeryBloc>().add(LoadSurgeriesEvent(
                page: pagination.page + 1,
                categoryId: state.selectedCategoryId,
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
    _debounce?.cancel();
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
          "Surgeries",
          style: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          _addSurgeryButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<SurgeryBloc, SurgeryState>(
        builder: (context, state) {
          if (state is SurgeryInitial ||
              (state is SurgeryLoading &&
                  !(context.read<SurgeryBloc>().state is SurgeryLoaded))) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SurgeryError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: Colors.red)));
          }

          if (state is SurgeryLoaded) {
            final surgeries = state.surgeryResponse.list;
            return Column(
              children: [
                // _buildHeader(),
                _buildFilters(state),
                Expanded(
                  child: surgeries.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async {
                            context
                                .read<SurgeryBloc>()
                                .add(LoadSurgeryCategoriesEvent());
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: state.isLoadingMore
                                ? surgeries.length + 1
                                : surgeries.length,
                            itemBuilder: (context, index) {
                              if (index >= surgeries.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.0),
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                );
                              }
                              final surgery = surgeries[index];
                              return _buildSurgeryItem(surgery);
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

  Widget _addSurgeryButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: AddSurgerySheet(
                existingIds:
                    (context.read<SurgeryBloc>().state as SurgeryLoaded)
                        .surgeryResponse
                        .list
                        .map((m) => m.details.id)
                        .toList(),
                onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Surgery added successfully'),
                        backgroundColor: Colors.green),
                  );
                  context.read<SurgeryBloc>().add(LoadSurgeryCategoriesEvent());
                },
              ),
            ),
          );
        },
        icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
        label: Text(
          "Add Surgery",
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.show_chart,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Manage Surgeries",
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E1B4B)),
                  ),
                  Text(
                    "Manage surgical procedures and vendors",
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(SurgeryLoaded state) {
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
            onChanged: (val) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                context.read<SurgeryBloc>().add(SearchSurgeriesEvent(val));
              });
            },
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Search surgeries...",
              hintStyle:
                  GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
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
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                itemHeight: null, // Allow expanding for multiple lines
                menuMaxHeight: 400,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.white,
                value: state.selectedCategoryId.isEmpty
                    ? null
                    : state.selectedCategoryId,
                hint: Text("All Categories",
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.grey[600])),
                selectedItemBuilder: (BuildContext context) {
                  return [
                    DropdownMenuItem(
                        value: '',
                        child: Text("All Categories",
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w500))),
                    ...state.categories.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name.replaceAll('|', ', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w500)))),
                  ].map((e) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: e.child!,
                    );
                  }).toList();
                },
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey[100]!))),
                      child: Text("All Categories",
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark)),
                    ),
                  ),
                  ...state.categories.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.grey[100]!))),
                        child: Text(
                          c.name.replaceAll('|', ', '),
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.black87, height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }),
                ],
                onChanged: (val) {
                  if (val != null) {
                    context
                        .read<SurgeryBloc>()
                        .add(SelectSurgeryCategoryEvent(val));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurgeryItem(SurgeryItem item) {
    final details = item.details;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: InkWell(
        onTap: () {
          context.push('/surgery-details', extra: item);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: details.files.isNotEmpty
                        ? Image.network(
                            "https://api.medicompares.com${details.files.first}",
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  const SizedBox(width: 12),
                  // Name & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details.name,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E1B4B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          details.subcategory?.name ?? "N/A",
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                  // Actions
                  Row(
                    children: [
                      // _actionIcon(Icons.visibility_outlined, Colors.blue, () {
                      //   context.push('/surgery-details', extra: item);
                      // }),
                      const SizedBox(width: 6),
                      _actionIcon(Icons.edit_outlined, Colors.indigo, () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: AddSurgerySheet(
                              editSurgery: item,
                              existingIds: (context.read<SurgeryBloc>().state
                                      as SurgeryLoaded)
                                  .surgeryResponse
                                  .list
                                  .map((m) => m.details.id)
                                  .toList(),
                              onSuccess: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Surgery updated successfully'),
                                      backgroundColor: Colors.green),
                                );
                                context
                                    .read<SurgeryBloc>()
                                    .add(LoadSurgeryCategoriesEvent());
                              },
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 6),
                      _actionIcon(Icons.delete_outline, Colors.red,
                          () => _showDeleteDialog(item)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoChip(
                      "Duration", details.duration ?? "N/A", Icons.access_time),
                  _complexityChip(details.complexity ?? "Simple"),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Text(
                      //   "₹${item.price.toInt()}",
                      //   style: GoogleFonts.inter(
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.bold,
                      //       color: AppColors.primary),
                      // ),
                      if (item.discountPrice > 0)
                        Text(
                          "₹${item.discountPrice.toInt()}",
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 48,
      height: 48,
      color: const Color(0xFFF8FAFF),
      child: const Icon(Icons.medical_services_outlined,
          color: Colors.grey, size: 20),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  Widget _infoChip(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400])),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700])),
          ],
        ),
      ],
    );
  }

  Widget _complexityChip(String complexity) {
    final bool isComplex = complexity.toLowerCase() == 'complex';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isComplex ? Colors.orange : Colors.green).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplex ? Icons.info_outline : Icons.check_circle_outline,
            size: 12,
            color: isComplex ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            complexity,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isComplex ? Colors.orange : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(SurgeryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Surgery",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete '${item.details.name}'?",
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: GoogleFonts.inter()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SurgeryInjection.provideSurgeryService().deleteSurgery(item.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Surgery deleted successfully'),
                backgroundColor: Colors.green),
          );
          context.read<SurgeryBloc>().add(LoadSurgeryCategoriesEvent());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_edu_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            "No surgeries found",
            style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[300]),
          ),
        ],
      ),
    );
  }
}
