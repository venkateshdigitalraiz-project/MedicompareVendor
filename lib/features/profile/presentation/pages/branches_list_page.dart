import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:MediCompare/core/constants/app_colors.dart';
import '../widgets/branch_list_tab.dart';
import 'add_branch_page.dart';

class BranchesListPage extends StatefulWidget {
  const BranchesListPage({super.key});

  @override
  State<BranchesListPage> createState() => _BranchesListPageState();
}

class _BranchesListPageState extends State<BranchesListPage> {
  final GlobalKey<BranchListTabState> _branchListKey =
      GlobalKey<BranchListTabState>();

  Future<void> _navigateToAddBranch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddBranchPage()),
    );
    if (result == true) {
      _branchListKey.currentState?.fetchBranches();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Manage Branches",
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 12.0),
        //     child: TextButton.icon(
        //       onPressed: _navigateToAddBranch,
        //       icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
        //       label: Text(
        //         "Add Branch",
        //         style: GoogleFonts.inter(
        //           color: Colors.white,
        //           fontWeight: FontWeight.bold,
        //           fontSize: 13,
        //         ),
        //       ),
        //       style: TextButton.styleFrom(
        //         backgroundColor: Colors.white.withOpacity(0.15),
        //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: BranchListTab(key: _branchListKey),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddBranch,
        backgroundColor: const Color(0xFF6B48FF),
        icon: const Icon(Icons.add_business_rounded,
            color: Colors.white, size: 20),
        label: Text(
          "Add New Branch",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    );
  }
}
