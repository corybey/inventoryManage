import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/items.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final _service = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Dashboard')),
      body: StreamBuilder<List<Item>>(
        stream: _service.getItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading dashboard'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          final totalItems = items.length;
          final totalValue = items.fold<double>(
              0.0, (sum, item) => sum + item.quantity * item.price);
          final lowStock = items.where((i) => i.quantity <= 0).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text('Overview', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatCard(label: 'Total Items', value: '$totalItems'),
                    const SizedBox(width: 12),
                    _StatCard(
                        label: 'Total Value',
                        value: '\$${totalValue.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Out of stock',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (lowStock.isEmpty)
                  const Text('All items in stock ✅')
                else
                  ...lowStock.map((item) => ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.category),
                        trailing: const Text('0'),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
