import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/employee_list_bloc.dart';
import '../bloc/employee_list_event.dart';
import '../bloc/employee_list_state.dart';
import '../../domain/entities/employee_entity.dart';
import 'package:go_router/go_router.dart';
import '../../role_injection.dart';

class EmployeeListPage extends StatelessWidget {
  const EmployeeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RoleInjection.provideEmployeeListBloc()..add(LoadEmployeeList()),
      child: const _EmployeeListView(),
    );
  }
}

class _EmployeeListView extends StatelessWidget {
  const _EmployeeListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Match background color
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
              child: Icon(Icons.people_alt_outlined,
                  color: Colors.purple.shade900, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Staff Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Manage your team members',
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
              onPressed: () {
                context.push('/add-staff');
              },
              icon: const Icon(Icons.person_add_alt_1,
                  size: 18, color: Colors.white),
              label: const Text('Add Staff',
                  style: TextStyle(color: Colors.white)),
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
    return BlocBuilder<EmployeeListBloc, EmployeeListState>(
      builder: (context, state) {
        if (state is EmployeeListLoaded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatCard(
                                'Total Staff',
                                state.totalStaff.toString(),
                                Icons.people_outline,
                                Colors.blue)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _buildStatCard(
                                'Active',
                                state.activeStaff.toString(),
                                Icons.person_outline,
                                Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _buildStatCard(
                                'On Leave',
                                state.onLeaveStaff.toString(),
                                Icons.access_time,
                                Colors.orange)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: _buildStatCard(
                                'Departments',
                                state.departments.toString(),
                                Icons.shield_outlined,
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
                          'Total Staff',
                          state.totalStaff.toString(),
                          Icons.people_outline,
                          Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildStatCard(
                          'Active',
                          state.activeStaff.toString(),
                          Icons.person_outline,
                          Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildStatCard(
                          'On Leave',
                          state.onLeaveStaff.toString(),
                          Icons.access_time,
                          Colors.orange)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildStatCard(
                          'Departments',
                          state.departments.toString(),
                          Icons.shield_outlined,
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
                Text(value,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
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
                hintText: 'Search staff members...',
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
          BlocBuilder<EmployeeListBloc, EmployeeListState>(
            builder: (context, state) {
              if (state is EmployeeListLoading) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is EmployeeListLoaded) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 48,
                    ),
                    child: _buildDataTable(state.employees, context),
                  ),
                );
              } else if (state is EmployeeListError) {
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

  Widget _buildDataTable(List<EmployeeEntity> employees, BuildContext context) {
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
          dataRowHeight: 80,
          columns: const [
            DataColumn(label: Text('STAFF MEMBER')),
            DataColumn(label: Text('ROLE & DEPARTMENT')),
            DataColumn(label: Text('CONTACT')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: employees.map((employee) {
            return DataRow(
              cells: [
                DataCell(_buildStaffMemberCell(employee)),
                DataCell(_buildRoleCell(employee)),
                DataCell(_buildContactCell(employee)),
                DataCell(_buildStatusCell(employee)),
                DataCell(_buildActionsCell(context, employee)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStaffMemberCell(EmployeeEntity employee) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.purple.shade50,
          child: Icon(Icons.people_outline,
              color: Colors.purple.shade900, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(employee.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Text(employee.designation,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCell(EmployeeEntity employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Text(employee.role,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(employee.department,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      ],
    );
  }

  Widget _buildContactCell(EmployeeEntity employee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(Icons.email_outlined, size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(employee.email,
                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.phone_outlined, size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(employee.phone,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCell(EmployeeEntity employee) {
    bool isActive = employee.status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? Icons.person_outline : Icons.person_off_outlined,
              size: 16,
              color: isActive ? Colors.green.shade700 : Colors.red.shade700),
          const SizedBox(width: 4),
          Text(
            employee.status,
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

  Widget _buildActionsCell(BuildContext context, EmployeeEntity employee) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_red_eye_outlined,
              color: Colors.deepPurple),
          onPressed: () {},
          tooltip: 'View',
          splashRadius: 20,
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.blue),
          onPressed: () {
            context.push('/add-staff', extra: employee.id);
          },
          tooltip: 'Edit',
          splashRadius: 20,
        ),
      ],
    );
  }
}
