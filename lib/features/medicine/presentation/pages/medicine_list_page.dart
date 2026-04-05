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
  }

  void _onScroll() {
    final state = context.read<MedicineBloc>().state;
    if (state is MedicineLoaded && !state.isLoadingMore) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
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
                        existingIds: (context.read<MedicineBloc>().state
                                as MedicineLoaded)
                            .medicineResponse
                            .list
                            .map((m) => m.details.id)
                            .toList(),
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
                                onTap: () => context.push('/medicine-details',
                                    extra: medicine),
                                onEdit: () {
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
                                          existingIds: (context
                                                  .read<MedicineBloc>()
                                                  .state as MedicineLoaded)
                                              .medicineResponse
                                              .list
                                              .map((m) => m.details.id)
                                              .toList(),
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
                                      content: Text(
                                          "Are you sure you want to delete ${medicine.details.name}? This action cannot be undone.",
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
                                            // Show loading indicator
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
                                                Navigator.pop(
                                                    context); // close loading
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
                                                Navigator.pop(
                                                    context); // close loading
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
          // Search Bar
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
                  // This builds the selected item displayed when menu is CLOSED
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
                      child: e.child,
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
                    context.read<MedicineBloc>().add(SelectCategoryEvent(val));
                  }
                },
              ),
            ),
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
