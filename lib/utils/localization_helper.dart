import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LocalizationHelper {
  static const Map<String, String> _englishStrings = {
    'appTitle': 'Eainthone',
    'dashboard': 'Dashboard',
    'transactions': 'Transactions',
    'settings': 'Settings',
    'addTransaction': 'Add Transaction',
    'income': 'Income',
    'expense': 'Expense',
    'language': 'Language',
    'english': 'English',
    'myanmar': 'မြန်မာ',
    'login': 'Login',
    'syncSettings': 'Sync Settings',
    'manualSync': 'Manual Sync',
    'autoSync': 'Auto Sync',
    'dataManagement': 'Data Management',
    'localData': 'Local Data',
    'refreshData': 'Refresh Data',
    'clearAllData': 'Clear All Data',
    'selectLanguage': 'Select Language',
    'cancel': 'Cancel',
    'totalIncome': 'Total Income',
    'totalExpense': 'Total Expense',
    'balance': 'Balance',
    'thisMonth': 'This Month',
    'lastMonth': 'Last Month',
    'thisYear': 'This Year',
    'customRange': 'Custom Range',
    'account': 'Account',
    'loginToSync': 'Login to sync your data',
    'loggedOut': 'Logged out successfully',
    'logout': 'Logout',
    'noTransactions': 'No transactions found',
    'food': 'Food',
    'transport': 'Transport',
    'shopping': 'Shopping',
    'entertainment': 'Entertainment',
    'health': 'Health',
    'education': 'Education',
    'utilities': 'Utilities',
    'salary': 'Salary',
    'business': 'Business',
    'investment': 'Investment',
    'other': 'Other',
  };

  static const Map<String, String> _myanmarStrings = {
    'appTitle': 'အိမ်သုံး',
    'dashboard': 'ဒက်ရှ်ဘုတ်',
    'transactions': 'ငွေသွင်းထုတ်မှတ်တမ်း',
    'settings': 'ဆက်တင်များ',
    'addTransaction': 'ငွေသွင်းထုတ်ထည့်ရန်',
    'income': 'ဝင်ငွေ',
    'expense': 'ထွက်ငွေ',
    'language': 'ဘာသာစကား',
    'english': 'English',
    'myanmar': 'မြန်မာ',
    'login': 'လော့ဂ်အင်',
    'syncSettings': 'ထပ်တူပြုခြင်းဆက်တင်များ',
    'manualSync': 'လက်ဖြင့်ထပ်တူပြုခြင်း',
    'autoSync': 'အလိုအလျောက်ထပ်တူပြုခြင်း',
    'dataManagement': 'ဒေတာစီမံခန့်ခွဲမှု',
    'localData': 'ဒေသတွင်းဒေတာ',
    'refreshData': 'ဒေတာပြန်လည်ရယူခြင်း',
    'clearAllData': 'ဒေတာအားလုံးရှင်းလင်းခြင်း',
    'selectLanguage': 'ဘာသာစကားရွေးချယ်ရန်',
    'cancel': 'ပယ်ဖျက်ရန်',
    'totalIncome': 'စုစုပေါင်းဝင်ငွေ',
    'totalExpense': 'စုစုပေါင်းထွက်ငွေ',
    'balance': 'လက်ကျန်ငွေ',
    'thisMonth': 'ယခုလ',
    'lastMonth': 'ပြီးခဲ့သောလ',
    'thisYear': 'ဒီနှစ်',
      'customRange': 'စိတ်ကြိုက်ရွေးချယ်မှု',
      'account': 'အကောင့်',
      'loginToSync': 'သင့်ဒေတာများကို ထပ်တူပြုရန် လော့ဂ်အင်ဝင်ပါ',
      'loggedOut': 'အောင်မြင်စွာ လော့ဂ်အောက်ဖြစ်ပါပြီ',
      'logout': 'လော့ဂ်အောက်',
      'noTransactions': 'ငွေသွင်းထုတ်မှတ်တမ်းမရှိပါ',
    'food': 'အစားအသောက်',
    'transport': 'သယ်ယူပို့ဆောင်ရေး',
    'shopping': 'ဈေးဝယ်ခြင်း',
    'entertainment': 'ဖျော်ဖြေရေး',
    'health': 'ကျန်းမာရေး',
    'education': 'ပညာရေး',
    'utilities': 'အသုံးအဆောင်',
    'salary': 'လစာ',
    'business': 'လုပ်ငန်း',
    'investment': 'ရင်းနှီးမြှုပ်နှံမှု',
    'other': 'အခြား',
  };

  static String getString(BuildContext context, String key) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final strings = languageProvider.isEnglish ? _englishStrings : _myanmarStrings;
    return strings[key] ?? key;
  }

  static String getCategoryName(BuildContext context, String category) {
    return getString(context, category.toLowerCase());
  }
}