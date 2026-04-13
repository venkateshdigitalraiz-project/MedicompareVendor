import 'dart:async';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/medicine/presentation/bloc/medicine_bloc.dart';
import 'package:MediCompare/features/medicine/presentation/bloc/medicine_event.dart';
import 'package:MediCompare/features/medicine/presentation/bloc/medicine_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/medicine_card.dart';
import '../widgets/add_medicine_sheet.dart';
import 'package:MediCompare/core/utils/permission_handler.dart';
import '../../medicine_injection.dart';

class MedicineListPage extends StatefulWidget {
  const MedicineListPage({super.key});

  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // REQUIREMENT 2: Initialize data properly when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineBloc>().add(LoadMedicineCategoriesEvent());
    });
  }

  void _onScroll() {
    final state = context.read<MedicineBloc>().state;
    if (state is MedicineLoaded && !state.isLoadingMore) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 400) {
        final pagination = state.medicineResponse.pagination;
        if (pagination.page < pagination.totalPages) {
          context.read<MedicineBloc>().add(LoadMedicinesEvent(
                page: pagination.page + 1,
                categoryId: state.selectedCategoryId,
                search: state.searchQuery,
                isLoadMore: true,
              ));
        }
      }
    }
  }

  // REQUIREMENT 3: Helper for safe ID extraction
  List<String> _getExistingIds(MedicineState state) {
    if (state is MedicineLoaded) {
      return state.medicineResponse.list.map((m) => m.details.id).toList();
    }
    return [];
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
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Medicines",
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (PermissionHandler().hasPermission('medicine', 'add'))
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  final currentState = context.read<MedicineBloc>().state;
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(ctx).viewInsets.bottom),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(ctx).size.height * 0.9),
                        child: AddMedicineSheet(
                          // REQUIREMENT 1 & 3: Safe Extraction
                          existingIds: _getExistingIds(currentState),
                          onSuccess: () {
                            context
                                .read<MedicineBloc>()
                                .add(LoadMedicineCategoriesEvent());
                          },
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text("Add Medicine",
                    style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
      body: BlocBuilder<MedicineBloc, MedicineState>(
        builder: (context, state) {
          if (state is MedicineLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MedicineError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<MedicineBloc>()
                          .add(LoadMedicineCategoriesEvent()),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is MedicineLoaded) {
            final medicines = state.medicineResponse.list;
            // REQUIREMENT 6: Proper checking before accessing list
            if (medicines.isEmpty && !state.isLoadingMore && state.searchQuery.isEmpty) {
               return _buildEmptyState();
            }
            
            return Column(
              children: [
                _buildFilters(state),
                Expanded(
                  child: medicines.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async {
                            context
                                .read<MedicineBloc>()
                                .add(LoadMedicineCategoriesEvent());
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: state.isLoadingMore
                                ? medicines.length + 1
                                : medicines.length,
                            itemBuilder: (context, index) {
                              if (index >= medicines.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.0),
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                );
                              }
                              final medicine = medicines[index];
                              return MedicineCard(
                                item: medicine,
                                // REQUIREMENT 4: Safely push with non-null check
                                onTap: () {
                                  if (medicine.id.isNotEmpty) {
                                    context.push('/medicine-details', extra: medicine);
                                  }
                                },
                                onEdit: () {
                                  final innerState = context.read<MedicineBloc>().state;
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (ctx) => Padding(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(ctx)
                                              .viewInsets
                                              .bottom),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxHeight:
                                                MediaQuery.of(ctx).size.height *
                                                    0.9),
                                        child: AddMedicineSheet(
                                          editMedicine: medicine,
                                          // REQUIREMENT 1 & 3: Safe Extraction
                                          existingIds: _getExistingIds(innerState),
                                          onSuccess: () {
                                            context.read<MedicineBloc>().add(
                                                const LoadMedicinesEvent());
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text("Delete Medicine",
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      // REQUIREMENT 5: added null safety ?? ''
                                      content: Text(
                                          "Are you sure you want to delete ${medicine.details.name ?? 'this medicine'}? This action cannot be undone.",
                                          style:
                                              GoogleFonts.inter(fontSize: 14)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: Text("Cancel",
                                              style: GoogleFonts.inter(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(ctx);
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (c) => const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            );

                                            try {
                                              final medicineService =
                                                  MedicineInjection
                                                      .provideMedicineService();
                                              await medicineService
                                                  .deleteMedicine(medicine.id);
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            'Medicine deleted successfully'),
                                                        backgroundColor:
                                                            Colors.green));
                                                context.read<MedicineBloc>().add(
                                                    LoadMedicineCategoriesEvent());
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content:
                                                            Text(e.toString()),
                                                        backgroundColor:
                                                            Colors.red));
                                              }
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              elevation: 0),
                                          child: Text("Delete",
                                              style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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

  Widget _buildFilters(MedicineLoaded state) {
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
          TextField(
            controller: _searchController,
            onChanged: (val) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                context.read<MedicineBloc>().add(SearchMedicinesEvent(val));
              });
            },
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Search medicines...",
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
          GestureDetector(
            onTap: () => _showCategoryPicker(state),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.selectedCategoryId.isEmpty
                          ? "All Categories"
                          : (state.categories
                                      .where((c) => c.id == state.selectedCategoryId)
                                      .firstOrNull
                                      ?.name ??
                                  "Selected Category")
                              .replaceAll('|', ', '),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: state.selectedCategoryId.isEmpty
                            ? Colors.grey[600]
                            : Colors.black87,
                        fontWeight: state.selectedCategoryId.isEmpty
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 20, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker(MedicineLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String sheetSearch = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = state.categories.where((c) => 
              (c.name ?? '').toLowerCase().contains(sheetSearch.toLowerCase())
            ).toList();

            return Container(
              padding: const EdgeInsets.only(top: 8),
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Select Category",
                            style: GoogleFonts.inter(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      onChanged: (val) => setSheetState(() => sheetSearch = val),
                      decoration: InputDecoration(
                        hintText: "Search categories...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length + 1,
                      itemBuilder: (ctx, index) {
                        if (index == 0) {
                          return ListTile(
                            title: const Text("All Categories", 
                              style: TextStyle(fontWeight: FontWeight.bold)),
                            onTap: () {
                              context.read<MedicineBloc>().add(const SelectCategoryEvent(''));
                              Navigator.pop(context);
                            },
                          );
                        }
                        final cat = filtered[index - 1];
                        return ListTile(
                          title: Text((cat.name ?? '').replaceAll('|', ', ')),
                          trailing: state.selectedCategoryId == cat.id 
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                          onTap: () {
                            context.read<MedicineBloc>().add(SelectCategoryEvent(cat.id));
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            "No medicines found",
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
