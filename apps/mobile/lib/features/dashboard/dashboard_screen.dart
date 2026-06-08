import 'package:flutter/material.dart';

import '../../app/router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _DashboardAction('Business setup', AppRoutes.businessSetup),
      _DashboardAction('Menu', AppRoutes.menu),
      _DashboardAction('QR', AppRoutes.qr),
      _DashboardAction('Subscription', AppRoutes.subscription),
      _DashboardAction('Staff scanner', AppRoutes.staffScanner),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: actions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final action = actions[index];

          return Card(
            child: ListTile(
              title: Text(action.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed(action.route),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardAction {
  const _DashboardAction(this.title, this.route);

  final String title;
  final String route;
}
