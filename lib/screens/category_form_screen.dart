import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _type;
  late IconData _icon;

  final List<IconData> _icons = [
    Icons.shopping_cart, Icons.fastfood, Icons.local_cafe, Icons.movie,
    Icons.train, Icons.flight, Icons.hotel, Icons.local_hospital,
    Icons.school, Icons.phone, Icons.lightbulb_outline, Icons.attach_money,
    Icons.home, Icons.build, Icons.card_giftcard, Icons.work,
    Icons.business, Icons.trending_up,
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.category?.name ?? '';
    _type = widget.category?.type ?? 'expense';
    _icon = widget.category?.icon ?? _icons[0];
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final categoryProvider = context.read<CategoryProvider>();
      if (widget.category == null) {
        // Add new category
        final newCategory = Category(name: _name, icon: _icon, type: _type);
        categoryProvider.addCategory(newCategory);
      } else {
        // Update existing category
        final updatedCategory = Category(
          id: widget.category!.id,
          name: _name,
          icon: _icon,
          type: _type,
        );
        categoryProvider.updateCategory(updatedCategory);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Category Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              const SizedBox(height: 20),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'expense', label: Text('Expense')),
                  ButtonSegment(value: 'income', label: Text('Income')),
                ],
                selected: {_type},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text('Select Icon', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _icons.length,
                  itemBuilder: (context, index) {
                    final icon = _icons[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _icon = icon;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _icon == icon ? Theme.of(context).primaryColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: _icon == icon ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Save Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
