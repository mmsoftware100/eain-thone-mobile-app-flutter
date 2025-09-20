import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/sync_provider.dart';
import '../models/transaction.dart';
import '../utils/number_formatter.dart';
import 'transaction_form_screen.dart';
import 'transaction_detail_screen.dart';
import 'transaction_list_screen.dart';
import 'settings_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().initialize();
      context.read<SyncProvider>().startPeriodicSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Expenses'),
        elevation: 0,
        actions: [
          // Sync Status Indicator
          Consumer<SyncProvider>(
            builder: (context, syncProvider, child) {
              return IconButton(
                icon: syncProvider.isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        syncProvider.isOnline
                            ? Icons.cloud_done
                            : Icons.cloud_off,
                        color: syncProvider.isOnline
                            ? Colors.green
                            : Colors.orange,
                      ),
                onPressed: () {
                  if (syncProvider.isOnline) {
                    syncProvider.syncNow();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No internet connection'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
              );
            },
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          if (transactionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await transactionProvider.refreshTransactions();
              if (context.mounted) {
                context.read<SyncProvider>().syncNow();
              }
            },
            child: CustomScrollView(
              slivers: [
                // Summary Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildSummaryCards(transactionProvider),
                  ),
                ),

                // Recent Transactions Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TransactionListScreen(),
                              ),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Transactions List
                transactionProvider.transactions.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions yet',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the + button to add your first expense',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final transaction =
                              transactionProvider.transactions[index];
                          return _buildTransactionTile(transaction);
                        }, childCount: transactionProvider.transactions.length),
                      ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Add Transaction'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCards(TransactionProvider provider) {
    final summary = provider.getMonthlySummary();

    return Column(
      children: [
        // Total Balance Card
        SizedBox(
          width: double.infinity,
          child: Card(
            // update color based on value , if balance plus show positive color , if negative show red
            color: (summary['income']! - summary['expense']!) >= 0
                ? Colors.green[50]
                : Colors.red[50],
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'This Month',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${NumberFormatter.formatNumber(summary['income']! - summary['expense']!)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: (summary['income']! - summary['expense']!) >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Net Balance',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
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
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.red[600]),
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

  Widget _buildTransactionTile(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
          child: Icon(
            _getCategoryIcon(transaction.category),
            color: isIncome ? Colors.green[700] : Colors.red[700],
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
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}\$${NumberFormatter.formatNumber(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green[700] : Colors.red[700],
                fontSize: 16,
              ),
            ),
            if (!transaction.isSynced)
              Icon(Icons.sync_disabled, size: 16, color: Colors.orange[600]),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TransactionDetailScreen(transaction: transaction),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'utilities':
        return Icons.electrical_services;
      case 'salary':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }
}
