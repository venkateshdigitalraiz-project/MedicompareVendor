import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/dental_service/dental_service_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../bloc/dental_service_bloc.dart';
import '../bloc/dental_service_event.dart';
import '../bloc/dental_service_state.dart';
import '../../data/models/dental_service_model.dart';
import '../widgets/dental_service_card.dart';
import '../widgets/add_dental_service_sheet.dart';

class DentalServiceListPage extends StatefulWidget {
  const DentalServiceListPage({super.key});

  @override
  State<DentalServiceListPage> createState() => _DentalServiceListPageState();
}

class _DentalServiceListPageState extends State<DentalServiceListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final state = context.read<DentalServiceBloc>().state;
    if (state is DentalServiceLoaded && !state.isLoadingMore) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        final pagination = state.response.pagination;
        if (pagination.page < pagination.totalPages) {
          context.read<DentalServiceBloc>().add(LoadDentalServiceListEvent(
                page: pagination.page + 1,
                isLoadMore: true,
              ));
        }
      }
    }
  }

  void _showAddEditSheet({DentalServiceItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.9),
          child: AddDentalServiceSheet(
            editItem: item,
            onSuccess: () {
              context.read<DentalServiceBloc>().add(const LoadDentalServiceCategoriesEvent());
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Dental Treatments",
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showAddEditSheet(),
              icon: const Icon(Icons.add, size: 16),
              label: Text("Add Treatment", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<DentalServiceBloc, DentalServiceState>(
        builder: (context, state) {
          if (state is DentalServiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DentalServiceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DentalServiceBloc>().add(const LoadDentalServiceCategoriesEvent()),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }
          if (state is DentalServiceLoaded) {
            final list = state.response.list;
            return Column(
              children: [
                _buildSearchAndFilter(state),
                Expanded(
                  child: list.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async => context.read<DentalServiceBloc>().add(const LoadDentalServiceCategoriesEvent()),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: state.isLoadingMore ? list.length + 1 : list.length,
                            itemBuilder: (context, index) {
                              if (index >= list.length) {
                                return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(strokeWidth: 2)));
                              }
                              final item = list[index];
                              return DentalServiceCard(
                                item: item,
                                onTap: () => context.push('/dental-details', extra: item),
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

  Widget _buildSearchAndFilter(DentalServiceLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (val) => context.read<DentalServiceBloc>().add(SearchDentalServiceEvent(val)),
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: "Search treatments...",
              hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 12),
          // Category Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFF), borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                dropdownColor: Colors.white,
                value: state.selectedCategoryId.isEmpty ? null : state.selectedCategoryId,
                hint: Text("All Categories", style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text("All Categories", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  ),
                  ...state.categories.map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name, style: GoogleFonts.inter(fontSize: 13, color: Colors.black87)),
                      )),
                ],
                onChanged: (val) {
                  if (val != null) {
                    context.read<DentalServiceBloc>().add(SelectDentalServiceCategoryEvent(val));
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
          Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text("No treatments found", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[300])),
        ],
      ),
    );
  }

  void _showDeleteDialog(DentalServiceItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Treatment", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text("Are you sure you want to delete ${item.details.name}?", style: GoogleFonts.inter(fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel", style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w600))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final service = DentalServiceInjection.provideDentalServiceService();
                await service.deleteDentalService(item.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Treatment deleted successfully'), backgroundColor: Colors.green));
                  context.read<DentalServiceBloc>().add(const LoadDentalServiceCategoriesEvent());
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
            child: Text("Delete", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
