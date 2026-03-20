import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/diagnostic/diagnostic_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../bloc/diagnostic_bloc.dart';
import '../bloc/diagnostic_event.dart';
import '../bloc/diagnostic_state.dart';
import '../../data/models/diagnostic_model.dart';
import '../widgets/diagnostic_card.dart';
import '../widgets/add_diagnostic_sheet.dart';

class DiagnosticListPage extends StatefulWidget {
  const DiagnosticListPage({super.key});

  @override
  State<DiagnosticListPage> createState() => _DiagnosticListPageState();
}

class _DiagnosticListPageState extends State<DiagnosticListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<DiagnosticBloc>().add(const LoadDiagnosticCategoriesEvent());
  }

  void _onScroll() {
    final state = context.read<DiagnosticBloc>().state;
    if (state is DiagnosticLoaded && !state.isLoadingMore) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final pagination = state.diagnosticResponse.pagination;
        if (pagination.page < pagination.totalPages) {
          context.read<DiagnosticBloc>().add(LoadDiagnosticsEvent(
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

  void _showAddSheet({DiagnosticItem? editItem}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
          child: AddDiagnosticSheet(
            editItem: editItem,
            onSuccess: () {
              context.read<DiagnosticBloc>().add(const LoadDiagnosticCategoriesEvent());
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: Text("Diagnostics", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: _showAddSheet,
              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: Text("Add Diagnostic", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<DiagnosticBloc, DiagnosticState>(
        builder: (context, state) {
          if (state is DiagnosticInitial || state is DiagnosticLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DiagnosticError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          if (state is DiagnosticLoaded) {
            return Column(
              children: [
                _buildFilters(state),
                Expanded(
                  child: state.diagnosticResponse.list.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async => context.read<DiagnosticBloc>().add(const LoadDiagnosticCategoriesEvent()),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: state.isLoadingMore
                                ? state.diagnosticResponse.list.length + 1
                                : state.diagnosticResponse.list.length,
                            itemBuilder: (context, index) {
                              if (index >= state.diagnosticResponse.list.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                );
                              }
                              final item = state.diagnosticResponse.list[index];
                              return DiagnosticCard(
                                item: item,
                                onTap: () => context.push('/diagnostic-details', extra: item),
                                onEdit: () => _showAddSheet(editItem: item),
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

  Widget _buildFilters(DiagnosticLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) => context.read<DiagnosticBloc>().add(SearchDiagnosticsEvent(val)),
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Search diagnostics...",
              hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, size: 20),
              prefixIconColor: Colors.grey[400],
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFF), borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                menuMaxHeight: 400,
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.white,
                value: state.selectedCategoryId.isEmpty ? null : state.selectedCategoryId,
                hint: Text("All Categories", style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text("All Categories", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                  ...state.categories.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name, style: GoogleFonts.inter(fontSize: 13, color: Colors.black87)),
                  )),
                ],
                onChanged: (val) {
                  if (val != null) context.read<DiagnosticBloc>().add(SelectDiagnosticCategoryEvent(val));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(DiagnosticItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Diagnostic", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text("Are you sure you want to delete ${item.details.name}?", style: GoogleFonts.inter(fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
              try {
                final service = DiagnosticInjection.provideDiagnosticService();
                await service.deleteDiagnostic(item.id);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diagnostic deleted successfully'), backgroundColor: Colors.green));
                  context.read<DiagnosticBloc>().add(const LoadDiagnosticCategoriesEvent());
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
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
          Icon(Icons.biotech_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text("No diagnostics found", style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400])),
          const SizedBox(height: 8),
          Text("Tap '+ Add Diagnostic' to get started", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
