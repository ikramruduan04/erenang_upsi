import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/app_theme.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // SIDEBAR
          Container(
            width: 250,
            color: AppTheme.surface,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "e-renang Admin",
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                _SidebarItem(
                  icon: LucideIcons.layoutDashboard,
                  label: "Dashboard",
                  isActive: true,
                ),
                _SidebarItem(icon: LucideIcons.calendarDays, label: "Bookings"),
                _SidebarItem(icon: LucideIcons.users, label: "Users"),
                const Spacer(),
                _SidebarItem(icon: LucideIcons.logOut, label: "Log Out"),
              ],
            ),
          ),

          // MAIN CONTENT
          Expanded(
            child: Column(
              children: [
                // TOP BAR
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search bookings...',
                            prefixIcon: const Icon(
                              LucideIcons.search,
                              color: AppTheme.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppTheme.background,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      const CircleAvatar(
                        backgroundColor: AppTheme.accentBlue,
                        child: Icon(LucideIcons.user, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // ANALYTICS & CRUD LIST
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Recent Bookings",
                          style: TextStyle(
                            fontSize: 20,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Here you would use a FutureBuilder with DatabaseService.getBookings()
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3, // Dummy count
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: ListTile(
                                  title: const Text(
                                    "Student A",
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    "Pending - 12 Oct 2026",
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          LucideIcons.checkCircle,
                                          color: Colors.green,
                                        ),
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          LucideIcons.trash,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.accentBlue.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.accentBlue : AppTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.accentBlue : AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
