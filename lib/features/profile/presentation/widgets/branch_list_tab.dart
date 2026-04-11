import 'dart:async';

import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/core/utils/core_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../data/data_sources/branch_service.dart';
import '../../data/models/branch_model.dart';
import './branch_card.dart';
import './edit_branch_sheet.dart';

class BranchListTab extends StatefulWidget {
  const BranchListTab({super.key});

  @override
  State<BranchListTab> createState() => _BranchListTabState();
}

class _BranchListTabState extends State<BranchListTab> {
  final TextEditingController _searchController = TextEditingController();
  final BranchService _branchService =
      BranchService(CoreInjection.provideApiService());

  bool _isLoading = true;
  String _errorMessage = '';
  List<Branch> _branches = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches({String search = ''}) async {
    final trimmedSearch = search.trim();
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _branchService.getBranchList(search: trimmedSearch);
      if (mounted) {
        setState(() {
          List<Branch> fetchedItems = response.data.list;

          // Apply local filtering as a fallback if backend loosely filters
          if (trimmedSearch.isNotEmpty) {
            fetchedItems = fetchedItems.where((branch) {
              final searchLower = trimmedSearch.toLowerCase();
              return branch.name.toLowerCase().contains(searchLower) ||
                  branch.address.toLowerCase().contains(searchLower) ||
                  branch.email.toLowerCase().contains(searchLower);
            }).toList();
          }

          _branches = fetchedItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchBranches(search: query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: "Search branches...",
              hintStyle:
                  GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 20),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage.isNotEmpty)
            Expanded(
                child: Center(
                    child: Text(_errorMessage,
                        style: const TextStyle(color: Colors.red))))
          else if (_branches.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      "No branches found",
                      style: GoogleFonts.inter(
                          color: Colors.grey[500], fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchBranches(search: _searchController.text),
                child: ListView.builder(
                  itemCount: _branches.length,
                  itemBuilder: (context, index) {
                    return BranchCard(
                      branch: _branches[index],
                      onTap: () => context
                          .push('/branch-details/${_branches[index].id}'),
                      onEdit: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => EditBranchSheet(
                            branch: _branches[index],
                            onSuccess: () =>
                                _fetchBranches(search: _searchController.text),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
