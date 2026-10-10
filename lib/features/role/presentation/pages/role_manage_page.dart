import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/role_manage_bloc.dart';
import '../bloc/role_manage_event.dart';
import '../bloc/role_manage_state.dart';
import '../../domain/entities/role_entity.dart';
import '../../role_injection.dart';

class RoleManagePage extends StatelessWidget {
  const RoleManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RoleInjection.provideRoleManageBloc()..add(LoadRoleManageData()),
      child: const _RoleManageView(),
    );
  }
}

class _RoleManageView extends StatelessWidget {
  const _RoleManageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.shield_outlined,
                  color: Colors.purple.shade900, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Role Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Manage user roles and permissions',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await context.push('/add-new-role');
                if (context.mounted) {
                  context.read<RoleManageBloc>().add(LoadRoleManageData());
                }
              },
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label:
                  const Text('Add Role', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF311B6B),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildTableSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return BlocBuilder<RoleManageBloc, RoleManageState>(
      builder: (context, state) {
        if (state is RoleManageLoaded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatCard(
                                'Total Roles',
                                state.totalRoles.toString(),
                                Icons.shield_outlined,
                                Colors.blue)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _buildStatCard(
                                'Active Roles',
                                state.activeRoles.toString(),
                                Icons.check_circle_outline,
                                Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatCard(
                                'Inactive Roles',
                                state.inactiveRoles.toString(),
                                Icons.cancel_outlined,
                                Colors.red)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _buildStatCard(
                                'Total Staff',
                                state.totalStaff.toString(),
                                Icons.people_outline,
                                Colors.purple)),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                      child: _buildStatCard(
                          'Total Roles',
                          state.totalRoles.toString(),
                          Icons.shield_outlined,
                          Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildStatCard(
                          'Active Roles',
                          state.activeRoles.toString(),
                          Icons.check_circle_outline,
                          Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildStatCard(
                          'Inactive Roles',
                          state.inactiveRoles.toString(),
                          Icons.cancel_outlined,
                          Colors.red)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildStatCard(
                          'Total Staff',
                          state.totalStaff.toString(),
                          Icons.people_outline,
                          Colors.purple)),
                ],
              );
            },
          );
        }
        return const SizedBox(
            height: 100, child: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color == Colors.red && value == '0'
                        ? Colors.red
                        : (color == Colors.green
                            ? Colors.green
                            : const Color(0xFF1E293B)),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search roles...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          BlocBuilder<RoleManageBloc, RoleManageState>(
            builder: (context, state) {
              if (state is RoleManageLoading) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is RoleManageLoaded) {
                return _buildDataTable(state.roles, context);
              } else if (state is RoleManageError) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(child: Text('Error: ${state.message}')),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<RoleEntity> roles, BuildContext context) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.grey.shade200,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          dataRowHeight: 70,
          columns: const [
            DataColumn(label: Text('ROLE')),
            DataColumn(label: Text('PERMISSIONS')),
            DataColumn(label: Text('STAFF COUNT')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: roles.map((role) {
            return DataRow(
              cells: [
                DataCell(_buildRoleCell(role)),
                DataCell(Text('${role.permissionsCount} permissions',
                    style: TextStyle(color: Colors.grey.shade700))),
                DataCell(
                  Row(
                    children: [
                      Icon(Icons.people_outline,
                          size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 8),
                      Text('${role.staffCount}',
                          style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ),
                ),
                DataCell(_buildStatusCell(role)),
                DataCell(_buildActionsCell(context, role)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoleCell(RoleEntity role) {
    if (role.isSpecial) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          role.name,
          style: TextStyle(
            color: Colors.green.shade800,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      );
    } else {
      return Text(
        role.name,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }
  }

  Widget _buildStatusCell(RoleEntity role) {
    bool isActive = role.status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 16,
              color: isActive ? Colors.green.shade700 : Colors.red.shade700),
          const SizedBox(width: 4),
          Text(
            role.status,
            style: TextStyle(
              color: isActive ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCell(BuildContext context, RoleEntity role) {
    bool showDelete = role
        .isSpecial; // Assuming showDelete depends on isSpecial based on previous usage
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
          onPressed: () async {
            await context.push('/add-new-role', extra: role);
            if (context.mounted) {
              context.read<RoleManageBloc>().add(LoadRoleManageData());
            }
          },
          tooltip: 'Edit',
          splashRadius: 20,
        ),
        if (showDelete)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () {
              context.read<RoleManageBloc>().add(DeleteRole(role.id));
            },
            tooltip: 'Delete',
            splashRadius: 20,
          ),
      ],
    );
  }
}
/*this is sample UI in web portal. please design UI in role folder name in features directory. please must be followed clear architecture with bloc. class name and bloc name role_manage */