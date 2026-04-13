import 'dart:async';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/home_care/data/data_sources/home_care_service.dart';
import 'package:MediCompare/features/home_care/home_care_injection.dart';
import 'package:MediCompare/features/home_care/presentation/bloc/home_care_bloc.dart';
import 'package:MediCompare/features/home_care/presentation/bloc/home_care_event.dart';
import 'package:MediCompare/features/home_care/presentation/bloc/home_care_state.dart';
import 'package:MediCompare/features/home_care/presentation/widgets/home_care_card.dart';
import 'package:MediCompare/features/home_care/presentation/widgets/add_home_care_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:MediCompare/core/utils/permission_handler.dart';
import 'package:go_router/go_router.dart';

class HomeCareListPage extends StatefulWidget {
  const HomeCareListPage({super.key});

  @override
  State<HomeCareListPage> createState() => _HomeCareListPageState();
}

class _HomeCareListPageState extends State<HomeCareListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final HomeCareService _service = HomeCareInjection.provideHomeCareService();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  void _loadInitial() {
    context
        .read<HomeCareBloc>()
        .add(const LoadHomeCareListEvent(page: 1, isRefresh: true));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = context.read<HomeCareBloc>().state;
      if (state.status != HomeCareStatus.loading &&
          state.pagination != null &&
          state.pagination!.page < state.pagination!.totalPages) {
        context.read<HomeCareBloc>().add(LoadHomeCareListEvent(
              page: state.pagination!.page + 1,
              categoryId: state.selectedCategoryId ?? '',
              search: _searchController.text,
            ));
      }
    }
  }

  void _showAddEditSheet([dynamic item]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddHomeCareSheet(
          editItem: item,
          existingIds: context
              .read<HomeCareBloc>()
              .state
              .items
              .map((m) => m.details.id)
              .toList(),
          onSuccess: _loadInitial,
        ),
      ),
    );
  }

  Future<void> _deleteItem(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm Delete",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: const Text(
            "Are you sure you want to delete this healthcare service?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteHomeCare(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Service deleted successfully')));
          _loadInitial();
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(e.toString()), backgroundColor: Colors.red));
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Home Care Services",
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF8FAFC))),
            //  Text("Manage home care services and vendors", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFF8FAFC))),
          ],
        ),
        actions: [
          if (PermissionHandler().hasPermission('home-care', 'add'))
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add Service"),
                onPressed: () => _showAddEditSheet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
        ],
      ),
      body: BlocBuilder<HomeCareBloc, HomeCareState>(
        builder: (context, state) {
          return Column(
            children: [
              // Search and Filter Row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    // Search Row
                    TextField(
                      controller: _searchController,
                      style: GoogleFonts.inter(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Search healthcare services...",
                        prefixIcon: const Icon(Icons.search, size: 20),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.primary)),
                      ),
                      onChanged: (val) {
                        _debounce?.cancel();
                        _debounce =
                            Timer(const Duration(milliseconds: 500), () {
                          context
                              .read<HomeCareBloc>()
                              .add(SearchHomeCareEvent(val));
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Category Row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.selectedCategoryId ?? '',
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                                value: '',
                                child: Text("All Categories",
                                    style: GoogleFonts.inter(fontSize: 14))),
                            ...state.categories.map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name,
                                    style: GoogleFonts.inter(fontSize: 14)))),
                          ],
                          onChanged: (val) => context
                              .read<HomeCareBloc>()
                              .add(SelectHomeCareCategoryEvent(val ?? '')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: state.status == HomeCareStatus.loading &&
                        state.items.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.items.isEmpty
                        ? Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_repair_service_outlined,
                                  size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text("No Home Care Services Found",
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600])),
                            ],
                          ))
                        : RefreshIndicator(
                            onRefresh: () async => _loadInitial(),
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: state.items.length +
                                  (state.status == HomeCareStatus.loading
                                      ? 1
                                      : 0),
                              itemBuilder: (context, index) {
                                if (index < state.items.length) {
                                  final item = state.items[index];
                                  return HomeCareCard(
                                    item: item,
                                    onView: () => context
                                        .push('/homecare-details', extra: item),
                                    onEdit: () => _showAddEditSheet(item),
                                    onDelete: () => _deleteItem(item.id),
                                  );
                                }
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
