// Home screen 
// This screen displays the main inventory list
//Other functions added

import 'package:flutter/material.dart';
import '../models/items.dart';
import '../services/firestore_service.dart';
import 'add_edit_screen.dart';
import 'dashboard_screen.dart';


class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key});

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  // Firestore service instance for DB operations
  final _service = FirestoreService();

  // Holds the user's search query text (lowercased for matching)
  String _search = '';

  // Tracks if the user is currently selecting multiple items
  bool _selectionMode = false;

  // Stores IDs of selected inventory items (for bulk delete)
  final Set<String> _selectedIds = {};

  // Toggles the selection state of an item (adds/removes from selected set)
  void _toggleSelection(String itemId) {
    setState(() {
      if (_selectedIds.contains(itemId)) {
        _selectedIds.remove(itemId);
        // Exit selection mode automatically if nothing is selected
        if (_selectedIds.isEmpty) {
          _selectionMode = false;
        }
      } else {
        _selectedIds.add(itemId);
      }
    });
  }

  // Deletes all currently selected items from Firestore in one batch
  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final ids = _selectedIds.toList();
    await _service.deleteMultipleItems(ids);
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top AppBar
      appBar: AppBar(
        // Change title depending on selection mode
        title: _selectionMode
            ? Text('${_selectedIds.length} selected')
            : const Text('Inventory'),

        // AppBar actions
        actions: [
          // Analytics Dashboard button
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DashboardScreen()),
              );
            },
          ),

          // Close selection mode button
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _selectionMode = false;
                  _selectedIds.clear();
                });
              },
            ),
        ],
      ),

      // Body: Column with optional search bar + list of items
      body: Column(
        children: [
          // Search bar (only visible when not in selection mode)
          if (!_selectionMode)
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search item...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  setState(() {
                    _search = val.toLowerCase();
                  });
                },
              ),
            ),

          // Real-time inventory list via StreamBuilder
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: _service.getItemsStream(),
              builder: (context, snapshot) {
                // Error handling
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading items'));
                }

                // Loading indicator
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Data received: filter by search
                final allItems = snapshot.data!;
                final items = allItems
                    .where((item) =>
                        item.name.toLowerCase().contains(_search) ||
                        item.category.toLowerCase().contains(_search))
                    .toList();

                // Empty state message
                if (items.isEmpty) {
                  return const Center(child: Text('No items found.'));
                }

                // Build list of items
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final selected = _selectedIds.contains(item.id);

                    return ListTile(
                      // Long press = enter selection mode
                      onLongPress: () {
                        if (!_selectionMode) {
                          setState(() {
                            _selectionMode = true;
                            _selectedIds.add(item.id!);
                          });
                        }
                      },

                      // Tap = select or navigate to edit
                      onTap: () {
                        if (_selectionMode) {
                          _toggleSelection(item.id!);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditScreen(item: item),
                            ),
                          );
                        }
                      },

                      // Checkbox visible only when in selection mode
                      leading: _selectionMode
                          ? Checkbox(
                              value: selected,
                              onChanged: (_) {
                                _toggleSelection(item.id!);
                              },
                            )
                          : null,

                      // Item name and details
                      title: Text(item.name),
                      subtitle: Text(
                          'Qty: ${item.quantity} • \$${item.price.toStringAsFixed(2)} • ${item.category}'),

                      // Chevron icon for normal mode
                      trailing: !_selectionMode
                          ? const Icon(Icons.chevron_right)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button (only visible in normal mode)
      floatingActionButton: !_selectionMode
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddEditScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,

      // Bottom bar with bulk delete button (visible in selection mode)
      bottomNavigationBar: _selectionMode
          ? BottomAppBar(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _deleteSelected,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete selected'),
                    ),
                    const SizedBox(width: 12),
                    Text('${_selectedIds.length} item(s)'),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
