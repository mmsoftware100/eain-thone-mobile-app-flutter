import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/localization_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocalizationHelper.getString(context, 'settings')), elevation: 0),
      body: Consumer4<SyncProvider, TransactionProvider, LanguageProvider, AuthProvider>(
        builder: (context, syncProvider, transactionProvider, languageProvider, authProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Language Settings Section
              _buildSectionHeader(context, LocalizationHelper.getString(context, 'language')),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(LocalizationHelper.getString(context, 'language')),
                      subtitle: Text(languageProvider.isEnglish 
                        ? LocalizationHelper.getString(context, 'english')
                        : LocalizationHelper.getString(context, 'myanmar')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showLanguageDialog(context, languageProvider);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Authentication Section
              _buildSectionHeader(context, LocalizationHelper.getString(context, 'account')),
              Card(
                child: Column(
                  children: [
                    if (!authProvider.isAuthenticated) ...[
                      ListTile(
                        leading: const Icon(Icons.login, color: Colors.blue),
                        title: Text(LocalizationHelper.getString(context, 'login')),
                        subtitle: Text(LocalizationHelper.getString(context, 'loginToSync')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                      ),
                    ] else ...[
                      ListTile(
                        leading: const Icon(Icons.account_circle, color: Colors.green),
                        title: Text(authProvider.user?.name ?? 'User'),
                        subtitle: Text(authProvider.user?.email ?? ''),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to profile screen if needed
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: Text(LocalizationHelper.getString(context, 'logout')),
                        onTap: () async {
                          await authProvider.logout();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(LocalizationHelper.getString(context, 'loggedOut')),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sync Settings Section
              _buildSectionHeader(context, 'Sync Settings'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        syncProvider.isOnline
                            ? Icons.cloud_done
                            : Icons.cloud_off,
                        color: syncProvider.isOnline
                            ? Colors.green
                            : Colors.grey,
                      ),
                      title: const Text('Connection Status'),
                      subtitle: Text(
                        syncProvider.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: syncProvider.isOnline
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                      trailing: syncProvider.isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.sync),
                      title: const Text('Manual Sync'),
                      subtitle: const Text('Sync your data now'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: syncProvider.isSyncing
                          ? null
                          : () async {
                              try {
                                await syncProvider.syncNow();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Sync completed successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Sync failed: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.sync_alt),
                      title: const Text('Auto Sync'),
                      subtitle: const Text('Automatically sync when online'),
                      value: syncProvider.autoSyncEnabled,
                      onChanged: (value) {
                        syncProvider.setAutoSync(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Management Section
              _buildSectionHeader(context, 'Data Management'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.storage),
                      title: const Text('Local Data'),
                      subtitle: Text(
                        '${transactionProvider.transactions.length} transactions stored locally',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showDataInfoDialog(context, transactionProvider);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.refresh),
                      title: const Text('Refresh Data'),
                      subtitle: const Text(
                        'Reload transactions from local storage',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await transactionProvider.refreshTransactions();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data refreshed successfully'),
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_sweep,
                        color: Colors.red,
                      ),
                      title: const Text('Clear All Data'),
                      subtitle: const Text('Delete all local transactions'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showClearDataDialog(context, transactionProvider);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // App Settings Section
              _buildSectionHeader(context, 'App Settings'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('Theme'),
                      subtitle: const Text('Light theme'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Theme settings coming soon'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      subtitle: const Text('English'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Language settings coming soon'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Notifications'),
                      subtitle: const Text('Manage notification preferences'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification settings coming soon'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // About Section
              _buildSectionHeader(context, 'About'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('App Version'),
                      subtitle: const Text('1.0.0'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      subtitle: const Text('Get help and contact support'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Help & Support coming soon'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Policy'),
                      subtitle: const Text('View our privacy policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Privacy Policy coming soon'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  void _showDataInfoDialog(BuildContext context, TransactionProvider provider) {
    final syncedCount = provider.transactions.where((t) => t.isSynced).length;
    final unsyncedCount = provider.transactions.length - syncedCount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Local Data Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Transactions: ${provider.transactions.length}'),
            const SizedBox(height: 8),
            Text('Synced: $syncedCount'),
            Text('Not Synced: $unsyncedCount'),
            const SizedBox(height: 16),
            const Text(
              'Unsynced transactions will be uploaded when you go online.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(
    BuildContext context,
    TransactionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all local transactions? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement clear all data functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clear data functionality coming soon'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Radio<String>(
                value: 'en',
                groupValue: languageProvider.currentLocale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    languageProvider.changeLanguage(value);
                    Navigator.pop(context);
                  }
                },
              ),
              title: const Text('English'),
              onTap: () {
                languageProvider.changeLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Radio<String>(
                value: 'my',
                groupValue: languageProvider.currentLocale.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    languageProvider.changeLanguage(value);
                    Navigator.pop(context);
                  }
                },
              ),
              title: const Text('မြန်မာ'),
              onTap: () {
                languageProvider.changeLanguage('my');
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
