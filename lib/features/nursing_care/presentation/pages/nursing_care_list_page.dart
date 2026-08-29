import 'dart:async';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/nursing_care/nursing_care_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../bloc/nursing_care_bloc.dart';
import '../bloc/nursing_care_event.dart';
import '../bloc/nursing_care_state.dart';
import '../../data/models/nursing_care_model.dart';
import '../widgets/nursing_care_card.dart';
import '../widgets/add_nursing_care_sheet.dart';
import 'package:MediCompare/core/utils/permission_handler.dart';

class NursingCareListPage extends StatefulWidget {
  const NursingCareListPage({super.key});

  @override
  State<NursingCareListPage> createState() => _NursingCareListPageState();
}

class _NursingCareListPageState extends State<NursingCareListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<NursingCareBloc>().add(const LoadNursingCareCategoriesEvent());
  }

  void _onScroll() {
    final state = context.read<NursingCareBloc>().state;
    if (state is NursingCareLoaded && !state.isLoadingMore) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final pagination = state.response.pagination;
        if (pagination.page < pagination.totalPages) {
          context.read<NursingCareBloc>().add(LoadNursingCareListEvent(
                page: pagination.page + 1,
                isLoadMore: true,
              ));
        }
      }
    }
  }

  void _showAddEditSheet({NursingCareItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
          child: AddNursingCareSheet(
            editItem: item,
            existingIds:
                (context.read<NursingCareBloc>().state as NursingCareLoaded)
                    .response
                    .list
                    .map((m) => m.details.id)
                    .toList(),
            onSuccess: () {
              context
                  .read<NursingCareBloc>()
                  .add(const LoadNursingCareCategoriesEvent());
            },
          ),
        ),
      ),
    );
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Clinic & Rehabs",
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            // Text("Manage nursing care services and vendors", style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
            child: ElevatedButton.icon(
              onPressed: () => _showAddEditSheet(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add Service",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NursingCareBloc, NursingCareState>(
        builder: (context, state) {
          if (state is NursingCareInitial || state is NursingCareLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NursingCareError) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () => context
                        .read<NursingCareBloc>()
                        .add(const LoadNursingCareCategoriesEvent()),
                    child: const Text("Retry"))
              ],
            ));
          }
          if (state is NursingCareLoaded) {
            return Column(
              children: [
                _buildFilters(state),
                Expanded(
                  child: state.response.list.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async => context
                              .read<NursingCareBloc>()
                              .add(const LoadNursingCareCategoriesEvent()),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: state.isLoadingMore
                                ? state.response.list.length + 1
                                : state.response.list.length,
                            itemBuilder: (context, index) {
                              if (index >= state.response.list.length) {
                                return const Center(
                                    child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)));
                              }
                              final item = state.response.list[index];
                              return NursingCareCard(
                                item: item,
                                onTap: () => context.push('/nursing-details',
                                    extra: item),
                                onEdit: () => _showAddEditSheet(item: item),
                                onDelete: () => _showDeleteDialog(item),
                              );
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

  Widget _buildFilters(NursingCareLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                context
                    .read<NursingCareBloc>()
                    .add(SearchNursingCareEvent(val));
              });
            },
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Search services...",
              hintStyle:
                  GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 12),
          //   decoration: BoxDecoration(
          //       color: const Color(0xFFF8FAFF),
          //       borderRadius: BorderRadius.circular(12)),
          //   child: DropdownButtonHideUnderline(
          //     child: DropdownButton<String>(
          //       isExpanded: true,
          //       dropdownColor: Colors.white,
          //       value: state.selectedCategoryId.isEmpty
          //           ? null
          //           : state.selectedCategoryId,
          //       hint: Text("All Categories",
          //           style: GoogleFonts.inter(
          //               fontSize: 13, color: Colors.grey[600])),
          //       items: [
          //         DropdownMenuItem(
          //             value: '',
          //             child: Text("All Categories",
          //                 style: GoogleFonts.inter(
          //                     fontSize: 13, color: Colors.black87))),
          //         ...state.categories.map((c) => DropdownMenuItem(
          //             value: c.id,
          //             child: Text(c.name,
          //                 style: GoogleFonts.inter(
          //                     fontSize: 13, color: Colors.black87)))),
          //       ],
          //       onChanged: (val) {
          //         if (val != null)
          //           context
          //               .read<NursingCareBloc>()
          //               .add(SelectNursingCareCategoryEvent(val));
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  void _showDeleteDialog(NursingCareItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Service",
            style:
                GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text("Are you sure you want to delete ${item.details.name}?",
            style: GoogleFonts.inter(fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  Text("Cancel", style: GoogleFonts.inter(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final service =
                    NursingCareInjection.provideNursingCareService();
                await service.deleteNursingCare(item.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Deleted successfully'),
                      backgroundColor: Colors.green));
                  context
                      .read<NursingCareBloc>()
                      .add(const LoadNursingCareCategoriesEvent());
                }
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0),
            child: const Text("Delete"),
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
          Icon(Icons.person_outline, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text("No services found",
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
