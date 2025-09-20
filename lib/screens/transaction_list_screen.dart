import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../utils/number_formatter.dart';
import 'transaction_detail_screen.dart';
import 'transaction_form_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  // Filter states
  TransactionType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedMonth = 'All';
  
  // Pagination
  final int _itemsPerPage = 20;
  int _currentPage = 0;
  
  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _currentPage = 0; // Reset to first page when searching
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    List<Transaction> filtered = transactions;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.description.toLowerCase().contains(_searchQuery) ||
               transaction.category.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Filter by transaction type
    if (_selectedType != null) {
      filtered = filtered.where((transaction) => transaction.type == _selectedType).toList();
    }

    // Filter by date range
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((transaction) {
        return transaction.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
               transaction.date.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter by month
    if (_selectedMonth != 'All') {
      final monthIndex = _getMonthIndex(_selectedMonth);
      filtered = filtered.where((transaction) {
        return transaction.date.month == monthIndex;
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  List<Transaction> _getPaginatedTransactions(List<Transaction> transactions) {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, transactions.length);
    
    if (startIndex >= transactions.length) return [];
    
    return transactions.sublist(startIndex, endIndex);
  }

  Map<String, double> _calculateSummary(List<Transaction> transactions) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'net': totalIncome - totalExpense,
    };
  }

  int _getMonthIndex(String monthName) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months.indexOf(monthName) + 1;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedMonth = 'All'; // Reset month filter when date range is selected
        _currentPage = 0;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _startDate = null;
      _endDate = null;
      _selectedMonth = 'All';
      _searchController.clear();
      _searchQuery = '';
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          if (transactionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredTransactions = _getFilteredTransactions(transactionProvider.transactions);
          final paginatedTransactions = _getPaginatedTransactions(filteredTransactions);
          final totalPages = (filteredTransactions.length / _itemsPerPage).ceil();
          final summary = _calculateSummary(filteredTransactions);

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Active Filters Display
              if (_hasActiveFilters()) _buildActiveFiltersChips(),

              // Summary Cards
              if (filteredTransactions.isNotEmpty) _buildSummaryCards(summary),

              // Results Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      '${filteredTransactions.length} transactions found',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    if (_hasActiveFilters())
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Clear All'),
                      ),
                  ],
                ),
              ),

              // Transaction List
              Expanded(
                child: filteredTransactions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: paginatedTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = paginatedTransactions[index];
                          return _buildTransactionCard(transaction);
                        },
                      ),
              ),

              // Pagination Controls
              if (totalPages > 1) _buildPaginationControls(totalPages),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.type == TransactionType.income
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          child: Icon(
            transaction.type == TransactionType.income
                ? Icons.add_circle_outline
                : Icons.remove_circle_outline,
            color: transaction.type == TransactionType.income
                ? Colors.green
                : Colors.red,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.category),
            Text(
              DateFormat('MMM dd, yyyy').format(transaction.date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Text(
          '${transaction.type == TransactionType.income ? '+' : '-'}\$${NumberFormatter.formatNumber(transaction.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: transaction.type == TransactionType.income
                ? Colors.green
                : Colors.red,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailScreen(transaction: transaction),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_selectedType != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(_selectedType == TransactionType.income ? 'Income' : 'Expense'),
                onDeleted: () {
                  setState(() {
                    _selectedType = null;
                    _currentPage = 0;
                  });
                },
              ),
            ),
          if (_selectedMonth != 'All')
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(_selectedMonth),
                onDeleted: () {
                  setState(() {
                    _selectedMonth = 'All';
                    _currentPage = 0;
                  });
                },
              ),
            ),
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}',
                ),
                onDeleted: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                    _currentPage = 0;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 0
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
            child: const Text('Previous'),
          ),
          Text(
            'Page ${_currentPage + 1} of $totalPages',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          ElevatedButton(
            onPressed: _currentPage < totalPages - 1
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedType != null ||
           _selectedMonth != 'All' ||
           (_startDate != null && _endDate != null) ||
           _searchQuery.isNotEmpty;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Transactions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Transaction Type Filter
              Text(
                'Transaction Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedType == null,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedType = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilterChip(
                      label: const Text('Income'),
                      selected: _selectedType == TransactionType.income,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedType = selected ? TransactionType.income : null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilterChip(
                      label: const Text('Expense'),
                      selected: _selectedType == TransactionType.expense,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedType = selected ? TransactionType.expense : null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Month Filter
              Text(
                'Month',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedMonth,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  'All',
                  'January', 'February', 'March', 'April', 'May', 'June',
                  'July', 'August', 'September', 'October', 'November', 'December'
                ].map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (value) {
                  setModalState(() {
                    _selectedMonth = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Date Range Filter
              Text(
                'Date Range',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _selectDateRange,
                child: Text(
                  _startDate != null && _endDate != null
                      ? '${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'
                      : 'Select Date Range',
                ),
              ),
              const SizedBox(height: 30),

              // Apply Filters Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentPage = 0;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, double> summary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Total Balance Card
          SizedBox(
            width: double.infinity,
            child: Card(
              color: summary['net']! >= 0 ? Colors.green[50] : Colors.red[50],
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Current Filter',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${NumberFormatter.formatNumber(summary['net']!)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: summary['net']! >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Net Balance',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Income and Expense Cards
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: Colors.green[600],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${NumberFormatter.formatNumber(summary['income']!)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          'Income',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.trending_down,
                          color: Colors.red[600],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${NumberFormatter.formatNumber(summary['expense']!)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        Text(
                          'Expenses',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}