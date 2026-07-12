import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/notifications/presentation/bloc/notification_state.dart';
import '../theme/app_colors.dart';
import 'responsive_layout.dart';

class WorkspaceShell extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? floatingActionButton;

  const WorkspaceShell({
    super.key,
    required this.child,
    required this.title,
    this.floatingActionButton,
  });

  void _onLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of the HelpDesk Lite workspace?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final currentRoute = GoRouterState.of(context).matchedLocation;
    
    final userName = authState is Authenticated ? authState.user.name : 'User';
    final userRole = authState is Authenticated ? authState.user.role.displayName : '';

    return Scaffold(
      appBar: ResponsiveLayout.isMobile(context)
          ? AppBar(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              actions: [
                _buildNotificationIcon(context, isCompact: true),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _onLogout(context),
                ),
              ],
            )
          : null,
      drawer: ResponsiveLayout.isMobile(context) ? _buildDrawer(context, userName, userRole, currentRoute) : null,
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          // Sidebar on Desktop/Tablet
          if (!ResponsiveLayout.isMobile(context))
            _buildSidebar(context, userName, userRole, currentRoute),
          
          // Main Content
          Expanded(
            child: Container(
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header for Web/Desktop
                  if (!ResponsiveLayout.isMobile(context))
                    Container(
                      height: 70,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          bottom: BorderSide(color: AppColors.border, width: 1),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Row(
                            children: [
                              _buildNotificationIcon(context, isCompact: false),
                              const SizedBox(width: 16),
                              Container(
                                width: 1,
                                height: 32,
                                color: AppColors.border,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    userRole,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.logout_outlined, color: AppColors.textSecondary),
                                tooltip: 'Log Out',
                                onPressed: () => _onLogout(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  
                  // Main Body
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ResponsiveLayout.isMobile(context)
          ? BottomNavigationBar(
              currentIndex: _getNavIndex(currentRoute),
              onTap: (index) => _onNavTap(context, index),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.confirmation_number_outlined),
                  activeIcon: Icon(Icons.confirmation_number),
                  label: 'Tickets',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildNotificationIcon(BuildContext context, {required bool isCompact}) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                isCompact ? Icons.notifications_none : Icons.notifications_none_outlined,
                color: AppColors.textPrimary,
              ),
              onPressed: () => context.push('/notifications'),
            ),
            if (state.unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${state.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    String userName,
    String userRole,
    String currentRoute,
  ) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo/Brand area
          Container(
            padding: const EdgeInsets.all(24),
            border: const Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
            child: const Row(
              children: [
                Icon(Icons.support_agent, color: AppColors.primary, size: 32),
                SizedBox(width: 12),
                Text(
                  'HelpDesk Lite',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Nav items
          _buildSidebarNavItem(
            context,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
            route: '/',
            isActive: currentRoute == '/',
          ),
          _buildSidebarNavItem(
            context,
            icon: Icons.confirmation_number_outlined,
            activeIcon: Icons.confirmation_number,
            label: 'Support Tickets',
            route: '/tickets',
            isActive: currentRoute.startsWith('/tickets'),
          ),
          _buildSidebarNavItem(
            context,
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            label: 'Notifications',
            route: '/notifications',
            isActive: currentRoute == '/notifications',
          ),
          const Spacer(),
          // Footer / Version
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workspace v1.0',
                  style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 11),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    String userName,
    String userRole,
    String currentRoute,
  ) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(userRole),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primary, size: 36),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: currentRoute == '/',
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.confirmation_number),
            title: const Text('Tickets'),
            selected: currentRoute.startsWith('/tickets'),
            onTap: () {
              Navigator.pop(context);
              context.go('/tickets');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            selected: currentRoute == '/notifications',
            onTap: () {
              Navigator.pop(context);
              context.go('/notifications');
            },
          ),
        ],
      ),
    );
  }

  int _getNavIndex(String currentRoute) {
    if (currentRoute.startsWith('/tickets')) return 1;
    return 0; // default to Dashboard
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 0) {
      context.go('/');
    } else if (index == 1) {
      context.go('/tickets');
    }
  }
}
