import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_sizes.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

class AddTransactionDialog extends StatefulWidget {
  final Function(Map<String, dynamic> transactionData)? onTransactionAdded;
  final List<Map<String, dynamic>>? categories;

  const AddTransactionDialog({
    super.key,
    this.onTransactionAdded,
    this.categories,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'expense';
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    // Initialize categories from the passed parameter
    _categories = widget.categories ?? [];

    // Set default category if any exist
    if (_currentCategories.isNotEmpty) {
      _selectedCategoryId = _currentCategories.first['id'];
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _currentCategories {
    final typeFilter = _selectedType == 'expense' ? 'expense' : 'income';
    return _categories.where((cat) => cat['type'] == typeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    'Add Transaction',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xl),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transaction Type
                      Text(
                        'Transaction Type',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeChip(
                              'expense',
                              'Expense',
                              Icons.trending_down,
                              Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: _buildTypeChip(
                              'income',
                              'Income',
                              Icons.trending_up,
                              Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter transaction description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Amount
                      Text(
                        'Amount',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Category
                      Text(
                        'Category',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      DropdownButtonFormField<int>(
                        value: _currentCategories.any((cat) => cat['id'] == _selectedCategoryId)
                            ? _selectedCategoryId
                            : _currentCategories.isNotEmpty
                                ? _currentCategories.first['id']
                                : null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        items: _currentCategories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category['id'],
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  category['icon'] ?? '📝',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: AppSizes.sm),
                                Flexible(
                                  child: Text(
                                    category['name'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value!;
                          });
                        },
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Date
                      Text(
                        'Date',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: AppSizes.md),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Notes (Optional)
                      Text(
                        'Notes (Optional)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          hintText: 'Add any additional notes...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          prefixIcon: const Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.xl),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: FilledButton(
                    onPressed: _isLoading ? null : _addTransaction,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Transaction'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon, Color color) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
          // Reset category when type changes
          if (_currentCategories.isNotEmpty) {
            _selectedCategoryId = _currentCategories.first['id'];
          }
        });
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Theme.of(context).colorScheme.outline,
              size: 20,
            ),
            const SizedBox(width: AppSizes.sm),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Theme.of(context).colorScheme.outline,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTransaction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final amount = double.parse(_amountController.text);
    final adjustedAmount = _selectedType == 'expense' ? -amount : amount;

    final transactionData = {
      'description': _descriptionController.text.trim(),
      'amount': adjustedAmount,
      'category_id': _selectedCategoryId,
      'transaction_date': _selectedDate.toIso8601String(),
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    };

    // Call the actual API through the BLoC
    context.read<DashboardBloc>().add(
          DashboardCreateTransactionRequested(transactionData),
        );

    // Show success message and close dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction is being added...'),
        backgroundColor: Colors.blue,
      ),
    );

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop();

    // Call the callback if provided
    if (widget.onTransactionAdded != null) {
      widget.onTransactionAdded!(transactionData);
    }
  }
}
