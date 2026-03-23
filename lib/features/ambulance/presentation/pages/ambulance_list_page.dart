import '../../../../core/constants/app_colors.dart';
import '../bloc/ambulance_bloc.dart';
import '../bloc/ambulance_event.dart';
import '../bloc/ambulance_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../widgets/ambulance_card.dart';
import '../widgets/add_ambulance_sheet.dart';

class AmbulanceListPage extends StatefulWidget {
  const AmbulanceListPage({super.key});

  @override
  State<AmbulanceListPage> createState() => _AmbulanceListPageState();
}

class _AmbulanceListPageState extends State<AmbulanceListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Cache the last known loaded state so non-list states don't wipe the UI
  AmbulanceLoaded? _lastLoadedState;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  void _loadInitialData() {
    if (mounted) {
      context.read<AmbulanceBloc>().add(const GetAmbulanceListEvent());
    }
  }

  void _onScroll() {
    final state = context.read<AmbulanceBloc>().state;
    if (state is AmbulanceLoaded && !state.isLoadingMore) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final pagination = state.ambulanceList.pagination;
        if (pagination.page < pagination.totalPages) {
          context.read<AmbulanceBloc>().add(GetAmbulanceListEvent(
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

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.9),
          child: BlocProvider.value(
            value: context.read<AmbulanceBloc>(),
            child: AddAmbulanceSheet(
              // onSuccess is handled by the list page's BlocConsumer listener
              onSuccess: () {},
            ),
          ),
        ),
      ),
    );
  }

  void _openEditSheet(dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.9),
          child: BlocProvider.value(
            value: context.read<AmbulanceBloc>(),
            child: AddAmbulanceSheet(
              editAmbulance: item,
              // onSuccess is handled by the list page's BlocConsumer listener
              onSuccess: () {},
            ),
          ),
        ),
      ),
    );
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
          "Ambulance Services",
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
              onPressed: _openAddSheet,
              icon: const Icon(Icons.add, size: 18),
              label: Text("Add Service",
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
      body: BlocConsumer<AmbulanceBloc, AmbulanceState>(
        listener: (context, state) {
          // Cache the loaded state whenever we get a fresh one
          if (state is AmbulanceLoaded) {
            _lastLoadedState = state;
          }
          if (state is AmbulanceOperationSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green),
                );
                _loadInitialData();
              }
            });
          }
        },
        builder: (context, state) {
          // Use the latest loaded state regardless of current bloc state
          if (state is AmbulanceLoaded) {
            _lastLoadedState = state;
          }

          // Show loading spinner only on first load (no cached state yet)
          if (state is AmbulanceLoading && _lastLoadedState == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AmbulanceError && _lastLoadedState == null) {
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
                      onPressed: _loadInitialData,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          }

          // Render from cached state if available
          final displayState = _lastLoadedState;
          if (displayState == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = displayState.ambulanceList.items;
          return Column(
            children: [
              _buildSearchBar(displayState),
              Expanded(
                child: items.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          _loadInitialData();
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: displayState.isLoadingMore
                              ? items.length + 1
                              : items.length,
                          itemBuilder: (context, index) {
                            if (index >= items.length) {
                              return const Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 24.0),
                                child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              );
                            }
                            final item = items[index];
                            return AmbulanceCard(
                              item: item,
                              onTap: () =>
                                  context.push('/ambulance-details', extra: item),
                              onEdit: () => _openEditSheet(item),
                              onDelete: () => _showDeleteDialog(item),
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

  Widget _buildSearchBar(AmbulanceLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<AmbulanceBloc>().add(GetAmbulanceListEvent(
            search: value,
            categoryId: state.selectedCategoryId,
          ));
        },
        decoration: InputDecoration(
          hintText: "Search ambulance services...",
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.airport_shuttle_outlined,
              size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No ambulance services found",
            style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your first service by clicking the + button",
            style:
                GoogleFonts.inter(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(dynamic item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Service",
            style:
                GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(
            "Are you sure you want to delete ${item.name}? This action cannot be undone.",
            style: GoogleFonts.inter(fontSize: 14)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel",
                style: GoogleFonts.inter(
                    color: Colors.grey[600], fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<AmbulanceBloc>()
                  .add(DeleteAmbulanceEvent(item.id));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
