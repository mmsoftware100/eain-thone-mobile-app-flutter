import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../utils/localization_helper.dart';
import '../utils/number_formatter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'This Month';
  DateTime? _startDate;
  DateTime? _endDate;
  
  final List<String> _periods = [
    'This Week',
    'This Month', 
    'This Year',
    'Last Month',
    'Last Year',
    'Custom Range'
  ];

  @override
  void initState() {
    super.initState();
    _setDefaultDateRange();
  }

  void _setDefaultDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'This Week':
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = _startDate!.add(const Duration(days: 6));
        break;
      case 'This Month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'This Year':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year, 12, 31);
        break;
      case 'Last Month':
        _startDate = DateTime(now.year, now.month - 1, 1);
        _endDate = DateTime(now.year, now.month, 0);
        break;
      case 'Last Year':
        _startDate = DateTime(now.year - 1, 1, 1);
        _endDate = DateTime(now.year - 1, 12, 31);
        break;
    }
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    if (_startDate == null || _endDate == null) return transactions;
    
    return transactions.where((transaction) {
      final transactionDate = transaction.date;
      return transactionDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
             transactionDate.isBefore(_endDate!.add(const Duration(days: 1)));
    }).toList();
  }

  Map<String, double> _calculateSummary(List<Transaction> transactions) {
    double income = 0;
    double expense = 0;
    
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }
    
    return {
      'income': income,
      'expense': expense,
      'net': income - expense,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper.getString(context, 'dashboard')),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showPeriodSelector,
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          if (transactionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredTransactions = _getFilteredTransactions(transactionProvider.transactions);
          final summary = _calculateSummary(filteredTransactions);

          return RefreshIndicator(
            onRefresh: () async {
              await transactionProvider.refreshTransactions();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  _buildPeriodSelector(),
                  const SizedBox(height: 16),

                  // Summary Cards
                  _buildSummaryCards(summary),
                  const SizedBox(height: 24),

                  // Spending by Category Chart
                  _buildSectionHeader('Spending by Category'),
                  const SizedBox(height: 16),
                  _buildCategoryChart(filteredTransactions),
                  const SizedBox(height: 24),

                  // Balance Trend Chart
                  _buildSectionHeader('Balance Trend'),
                  const SizedBox(height: 16),
                  _buildBalanceTrendChart(filteredTransactions),
                  const SizedBox(height: 24),

                  // Monthly Comparison
                  _buildSectionHeader('Monthly Comparison'),
                  const SizedBox(height: 16),
                  _buildMonthlyComparisonChart(transactionProvider.transactions),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Period',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _selectedPeriod == 'Custom Range' && _startDate != null && _endDate != null
                        ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}'
                        : _selectedPeriod,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, double> summary) {
    return Column(
      children: [
        // Net Balance Card
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
                    _selectedPeriod,
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCategoryChart(List<Transaction> transactions) {
    final categoryData = <String, double>{};
    
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        categoryData[transaction.category] = 
            (categoryData[transaction.category] ?? 0) + transaction.amount;
      }
    }

    if (categoryData.isEmpty) {
      return _buildEmptyChart('No expense data available');
    }

    final sortedEntries = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: sortedEntries.first.value * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${sortedEntries[group.x.toInt()].key}\n\$${NumberFormatter.formatNumber(rod.toY)}',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value.toInt() < sortedEntries.length) {
                        final category = sortedEntries[value.toInt()].key;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            category.length > 8 ? '${category.substring(0, 8)}...' : category,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        '\$${NumberFormatter.formatNumber(value)}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: sortedEntries.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.value,
                      color: Colors.red[400],
                      width: 20,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceTrendChart(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyChart('No transaction data available');
    }

    // Sort transactions by date
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calculate running balance
    final spots = <FlSpot>[];
    double runningBalance = 0;
    
    for (int i = 0; i < sortedTransactions.length; i++) {
      final transaction = sortedTransactions[i];
      if (transaction.type == TransactionType.income) {
        runningBalance += transaction.amount;
      } else {
        runningBalance -= transaction.amount;
      }
      spots.add(FlSpot(i.toDouble(), runningBalance));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value.toInt() < sortedTransactions.length) {
                        final date = sortedTransactions[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MM/dd').format(date),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        '\$${NumberFormatter.formatNumber(value)}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyComparisonChart(List<Transaction> transactions) {
    final monthlyData = <String, Map<String, double>>{};
    
    for (final transaction in transactions) {
      final monthKey = DateFormat('MMM yyyy').format(transaction.date);
      monthlyData[monthKey] ??= {'income': 0, 'expense': 0};
      
      if (transaction.type == TransactionType.income) {
        monthlyData[monthKey]!['income'] = 
            monthlyData[monthKey]!['income']! + transaction.amount;
      } else {
        monthlyData[monthKey]!['expense'] = 
            monthlyData[monthKey]!['expense']! + transaction.amount;
      }
    }

    if (monthlyData.isEmpty) {
      return _buildEmptyChart('No monthly data available');
    }

    final sortedMonths = monthlyData.keys.toList()
      ..sort((a, b) => DateFormat('MMM yyyy').parse(a).compareTo(DateFormat('MMM yyyy').parse(b)));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: monthlyData.values
                  .map((data) => [data['income']!, data['expense']!].reduce((a, b) => a > b ? a : b))
                  .reduce((a, b) => a > b ? a : b) * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final month = sortedMonths[group.x.toInt()];
                    final type = rodIndex == 0 ? 'Income' : 'Expense';
                    return BarTooltipItem(
                      '$month\n$type: \$${NumberFormatter.formatNumber(rod.toY)}',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value.toInt() < sortedMonths.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            sortedMonths[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        '\$${NumberFormatter.formatNumber(value)}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: sortedMonths.asMap().entries.map((entry) {
                final monthData = monthlyData[entry.value]!;
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: monthData['income']!,
                      color: Colors.green[400],
                      width: 12,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    BarChartRodData(
                      toY: monthData['expense']!,
                      color: Colors.red[400],
                      width: 12,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Card(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPeriodSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Period',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...(_periods.map((period) => ListTile(
              title: Text(period),
              leading: Radio<String>(
                value: period,
                groupValue: _selectedPeriod,
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                    if (value != 'Custom Range') {
                      _setDefaultDateRange();
                    }
                  });
                  Navigator.pop(context);
                  if (value == 'Custom Range') {
                    _showCustomDatePicker();
                  }
                },
              ),
            ))),
          ],
        ),
      ),
    );
  }

  void _showCustomDatePicker() async {
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
      });
    }
  }
}