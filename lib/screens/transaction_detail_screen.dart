import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'transaction_form_screen.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionFormScreen(
                    transaction: transaction,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Card
            Card(
              elevation: 4,
              color: isIncome ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      isIncome ? Icons.trending_up : Icons.trending_down,
                      size: 48,
                      color: isIncome ? Colors.green[700] : Colors.red[700],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isIncome ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transaction.type.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isIncome ? Colors.green[600] : Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Details Section
            _buildDetailCard(
              context,
              'Transaction Details',
              [
                _DetailItem(
                  icon: Icons.description,
                  label: 'Description',
                  value: transaction.description,
                ),
                _DetailItem(
                  icon: Icons.category,
                  label: 'Category',
                  value: transaction.category,
                ),
                _DetailItem(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: DateFormat('EEEE, MMM dd, yyyy').format(transaction.date),
                ),
                _DetailItem(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: DateFormat('hh:mm a').format(transaction.date),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sync Status Section
            _buildDetailCard(
              context,
              'Sync Status',
              [
                _DetailItem(
                  icon: transaction.isSynced ? Icons.cloud_done : Icons.sync_disabled,
                  label: 'Status',
                  value: transaction.isSynced ? 'Synced' : 'Not Synced',
                  valueColor: transaction.isSynced ? Colors.green : Colors.orange,
                ),
                _DetailItem(
                  icon: Icons.schedule,
                  label: 'Created',
                  value: DateFormat('MMM dd, yyyy at hh:mm a').format(transaction.createdAt),
                ),
                _DetailItem(
                  icon: Icons.update,
                  label: 'Last Updated',
                  value: DateFormat('MMM dd, yyyy at hh:mm a').format(transaction.updatedAt),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionFormScreen(
                            transaction: transaction,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share functionality coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    String title,
    List<_DetailItem> items,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => _buildDetailRow(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, _DetailItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            item.icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              item.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: item.valueColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}