// Add and Edit entries

import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

class AddEditItemScreen extends StatefulWidget {
  final Item? item;

  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  final _service = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameCtrl.text = widget.item!.name;
      _qtyCtrl.text = widget.item!.quantity.toString();
      _priceCtrl.text = widget.item!.price.toString();
      _categoryCtrl.text = widget.item!.category;
    }
  }
//delete
  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }
// Item functions
  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final item = Item(
      id: widget.item?.id,
      name: _nameCtrl.text.trim(),
      quantity: int.parse(_qtyCtrl.text.trim()),
      price: double.parse(_priceCtrl.text.trim()),
      category: _categoryCtrl.text.trim(),
      createdAt: widget.item?.createdAt ?? DateTime.now(),
    );

    if (widget.item == null) {
      await _service.addItem(item);
    } else {
      await _service.updateItem(item);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteItem() async {
    if (widget.item == null) return;
    await _service.deleteItem(widget.item!.id!);
    if (mounted) Navigator.pop(context);
  }
// Display
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Item' : 'Add Item'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteItem,
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: _qtyCtrl,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter quantity' : null,
              ),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter price' : null,
              ),
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveItem,
                child: Text(isEdit ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
