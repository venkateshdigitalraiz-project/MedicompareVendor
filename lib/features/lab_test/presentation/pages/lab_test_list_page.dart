import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../bloc/lab_test_bloc.dart';
import '../bloc/lab_test_event.dart';
import '../bloc/lab_test_state.dart';
import '../../data/models/lab_test_model.dart';
import '../widgets/lab_test_card.dart';
import '../widgets/add_lab_test_sheet.dart';
import '../../lab_test_injection.dart';

class LabTestListPage extends StatefulWidget {
  const LabTestListPage({super.key});

  @override
  State<LabTestListPage> createState() => _LabTestListPageState();
}

class _LabTestListPageState extends State<LabTestListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<LabTestBloc>().add(LoadLabTestCategoriesEvent());
  }

  void _onScroll() {
    final state = context.read<LabTestBloc>().state;
    if (state is LabTestLoaded && !state.isLoadingMore) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final pagination = state.labTestResponse.pagination;
        if (pagination.page < pagination.totalPages) {
          context.read<LabTestBloc>().add(LoadLabTestsEvent(
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
          "Lab Tests",
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          _addLabTestButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<LabTestBloc, LabTestState>(
        builder: (context, state) {
          if (state is LabTestInitial || (state is LabTestLoading && !(context.read<LabTestBloc>().state is LabTestLoaded))) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LabTestError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }

          if (state is LabTestLoaded) {
            return Column(
              children: [
                _buildHeader(state),
                _buildFilters(state),
                Expanded(
                  child: state.labTestResponse.list.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<LabTestBloc>().add(LoadLabTestCategoriesEvent());
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: state.isLoadingMore ? state.labTestResponse.list.length + 1 : state.labTestResponse.list.length,
                            itemBuilder: (context, index) {
                              if (index >= state.labTestResponse.list.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.0),
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                );
                              }
                              final item = state.labTestResponse.list[index];
                              return _buildLabTestItem(item);
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

  Widget _addLabTestButton() {
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
                child: AddLabTestSheet(
                  onSuccess: () {
                    context.read<LabTestBloc>().add(LoadLabTestCategoriesEvent());
                  },
                ),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
        label: Text(
          "Add Lab Test",
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

  Widget _buildHeader(LabTestLoaded state) {
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
                child: const Icon(Icons.biotech_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lab Tests",
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B)),
                  ),
                  Text(
                    "Manage laboratory tests and vendors",
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(LabTestLoaded state) {
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
            onChanged: (val) => context.read<LabTestBloc>().add(SearchLabTestsEvent(val)),
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Search lab tests...",
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
                menuMaxHeight: 400,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.white,
                value: state.selectedCategoryId.isEmpty ? null : state.selectedCategoryId,
                hint: Text("All Categories", style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
                selectedItemBuilder: (BuildContext context) {
                  return [
                    DropdownMenuItem(value: '', child: Text("All Categories", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500))),
                    ...state.categories.map((c) => DropdownMenuItem(
                      value: c.id, 
                      child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500))
                    )),
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
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
                      child: Text("All Categories", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                  ),
                  ...state.categories.map((c) => DropdownMenuItem(
                    value: c.id, 
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[100]!))),
                      child: Text(c.name, style: GoogleFonts.inter(fontSize: 13, color: Colors.black87)),
                    ),
                  )),
                ],
                onChanged: (val) {
                  if (val != null) context.read<LabTestBloc>().add(SelectLabTestCategoryEvent(val));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLabTestItem(LabTestItem item) {
    return LabTestCard(
      item: item,
      onTap: () => context.push('/lab-test-details', extra: item),
      onEdit: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.9),
              child: AddLabTestSheet(
                editItem: item,
                onSuccess: () {
                   context.read<LabTestBloc>().add(const LoadLabTestsEvent());
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
            title: Text("Delete Lab Test", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            content: Text("Are you sure you want to delete ${item.details.name}? This action cannot be undone.", style: GoogleFonts.inter(fontSize: 14)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("Cancel", style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (c) => const Center(child: CircularProgressIndicator()),
                  );
                  
                  try {
                    final labService = LabTestInjection.provideLabTestService();
                    await labService.deleteLabTest(item.id);
                    if (context.mounted) {
                      Navigator.pop(context); // close loading
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lab test deleted successfully'), backgroundColor: Colors.green));
                      context.read<LabTestBloc>().add(LoadLabTestCategoriesEvent());
                    }
                  } catch (e) {
                    if (context.mounted) {
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
      },
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text("No lab tests found", style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
