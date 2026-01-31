import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

enum AppLanguage {
  en,
  bn,
}

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  AppLanguage _currentLanguage = AppLanguage.en;

  AppLanguage get currentLanguage => _currentLanguage;

  LanguageService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      if (languageCode != null) {
        _currentLanguage = languageCode == 'bn' ? AppLanguage.bn : AppLanguage.en;
        notifyListeners();
      }
    } catch (e) {
      // Default to English if loading fails
      _currentLanguage = AppLanguage.en;
    }
  }

  Future<void> toggleLanguage() async {
    _currentLanguage = _currentLanguage == AppLanguage.en
        ? AppLanguage.bn
        : AppLanguage.en;
    await _saveLanguage();
    notifyListeners();
  }

  Future<void> _saveLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _languageKey,
        _currentLanguage == AppLanguage.bn ? 'bn' : 'en',
      );
    } catch (e) {
      // Handle error silently
    }
  }

  String getText(String key) {
    return _translations[key]?[_currentLanguage == AppLanguage.bn ? 'bn' : 'en'] ?? key;
  }

  // Translations map
  static const Map<String, Map<String, String>> _translations = {
    // Finance Home Screen
    'app_name': {'en': 'App Name', 'bn': 'অ্যাপের নাম'},
    'hello_artisan': {'en': 'Hello, Artisan', 'bn': 'হ্যালো, কারিগর'},
    'record_voice_note': {'en': 'Record Voice Note', 'bn': 'ভয়েস নোট রেকর্ড করুন'},
    'tap_to_record': {'en': 'Tap to record your transaction details', 'bn': 'আপনার লেনদেনের বিবরণ রেকর্ড করতে ট্যাপ করুন'},
    'listening': {'en': 'Listening...', 'bn': 'শুনছি...'},
    'tap_again_to_stop': {'en': 'Listening... tap again to stop', 'bn': 'শুনছি... বন্ধ করতে আবার ট্যাপ করুন'},
    'example_inputs': {'en': 'Example inputs:', 'bn': 'উদাহরণ ইনপুট:'},
    'total_income': {'en': 'Total Income', 'bn': 'মোট আয়'},
    'total_expenses': {'en': 'Total Expenses', 'bn': 'মোট ব্যয়'},
    'current_balance': {'en': 'Current Balance', 'bn': 'বর্তমান ব্যালেন্স'},
    'pending_payments': {'en': 'Pending Payments', 'bn': 'বকেয়া পেমেন্ট'},
    'upcoming_deliveries': {'en': 'Upcoming Deliveries', 'bn': 'আসন্ন ডেলিভারি'},
    'no_upcoming_deliveries': {'en': 'No upcoming deliveries', 'bn': 'কোন আসন্ন ডেলিভারি নেই'},
    'mark_as_completed': {'en': 'Mark as completed', 'bn': 'সম্পন্ন হিসাবে চিহ্নিত করুন'},
    'unable_to_start_listening': {'en': 'Unable to start listening', 'bn': 'শোনা শুরু করতে অক্ষম'},
    'recording_unsuccessful': {'en': 'Recording unsuccessful, please try again', 'bn': 'রেকর্ডিং ব্যর্থ, অনুগ্রহ করে আবার চেষ্টা করুন'},
    'recorded_successfully': {'en': 'Recorded successfully', 'bn': 'সফলভাবে রেকর্ড করা হয়েছে'},
    'confirm_transaction': {'en': 'Confirm transaction', 'bn': 'লেনদেন নিশ্চিত করুন'},
    'bengali_text': {'en': '🗣 Bengali Text', 'bn': '🗣 বাংলা পাঠ্য'},
    'english_text': {'en': '🌍 English Text', 'bn': '🌍 ইংরেজি পাঠ্য'},
    'classified_result': {'en': 'Classified Result', 'bn': 'শ্রেণীবদ্ধ ফলাফল'},
    'no_discard': {'en': '❌ NO, DISCARD', 'bn': '❌ না, বাতিল করুন'},
    'yes_correct': {'en': '✅ YES, THIS IS CORRECT', 'bn': '✅ হ্যাঁ, এটি সঠিক'},
    'intent': {'en': 'Intent', 'bn': 'ইচ্ছা'},
    'name': {'en': 'Name', 'bn': 'নাম'},
    'amount': {'en': 'Amount', 'bn': 'পরিমাণ'},
    'category': {'en': 'Category', 'bn': 'বিভাগ'},
    'worker_type': {'en': 'Worker Type', 'bn': 'কর্মীর ধরন'},
    'idol_type': {'en': 'Idol Type', 'bn': 'মূর্তির ধরন'},
    'confidence': {'en': 'Confidence', 'bn': 'আত্মবিশ্বাস'},
    'day_delay': {'en': 'day delay', 'bn': 'দিন বিলম্ব'},
    'days_delay': {'en': 'days delay', 'bn': 'দিন বিলম্ব'},

    // Clients Screen
    'search': {'en': 'Search', 'bn': 'খুঁজুন'},
    'due_today': {'en': 'Due Today', 'bn': 'আজ প্রাপ্য'},
    'due_tomorrow': {'en': 'Due Tomorrow', 'bn': 'আগামীকাল প্রাপ্য'},
    'due': {'en': 'Due', 'bn': 'প্রাপ্য'},
    'add_new_client': {'en': 'Add new client', 'bn': 'নতুন ক্লায়েন্ট যোগ করুন'},
    'in_days': {'en': 'in', 'bn': 'মধ্যে'},
    'days': {'en': 'days', 'bn': 'দিন'},
    'record_payment_if_complete': {'en': 'Record Payment if complete', 'bn': 'সম্পন্ন হলে পেমেন্ট রেকর্ড করুন'},
    'delivery_done': {'en': 'Delivery Done', 'bn': 'ডেলিভারি সম্পন্ন'},

    // Reports Screen
    'profits': {'en': 'Profits', 'bn': 'লাভ'},
    'total_profit': {'en': 'Total profit', 'bn': 'মোট লাভ'},
    'project_profits': {'en': 'Project Profits', 'bn': 'প্রকল্পের লাভ'},
    'last_6_months': {'en': 'Last 6 months', 'bn': 'গত ৬ মাস'},
    'last_year': {'en': 'Last year', 'bn': 'গত বছর'},
    'all_years': {'en': 'All years', 'bn': 'সব বছর'},
    'material_expenses': {'en': 'Material Expenses', 'bn': 'উপাদান ব্যয়'},
    'transactions': {'en': 'Transactions', 'bn': 'লেনদেন'},
    'detailed_reports': {'en': 'Detailed Reports', 'bn': 'বিস্তারিত প্রতিবেদন'},
    'payment_from_samiti': {'en': 'Payment from Samiti', 'bn': 'সমিতি থেকে পেমেন্ট'},
    'purchase_of_clay': {'en': 'Purchase of Clay', 'bn': 'মাটির ক্রয়'},
    'durga_puja_idols': {'en': 'Durga Puja Idols', 'bn': 'দুর্গা পূজার মূর্তি'},

    // Home Screen
    'welcome_artisan': {'en': 'Welcome, artisan', 'bn': 'স্বাগতম, কারিগর'},
    'idea_generation': {'en': 'Idea Generation', 'bn': 'ধারণা তৈরি'},
    'generate_unique_idol_designs': {'en': 'Generate unique idol designs with AI', 'bn': 'AI দিয়ে অনন্য মূর্তি ডিজাইন তৈরি করুন'},
    'idol_build': {'en': 'Idol Build', 'bn': 'মূর্তি তৈরি'},
    'step_by_step_guide': {'en': 'Step-by-step guide to building your idol', 'bn': 'আপনার মূর্তি তৈরির ধাপে ধাপে নির্দেশিকা'},
    'decoration_detailing': {'en': 'Decoration & Detailing', 'bn': 'সাজসজ্জা এবং বিস্তারিত'},
    'add_details_decorations': {'en': 'Add details and decorations to your idol', 'bn': 'আপনার মূর্তিতে বিস্তারিত এবং সাজসজ্জা যোগ করুন'},
    'idol_previews': {'en': 'Idol Previews', 'bn': 'মূর্তির প্রিভিউ'},
    'showcase_creations': {'en': 'Showcase your creations', 'bn': 'আপনার সৃষ্টি প্রদর্শন করুন'},
    'generate_backdrop': {'en': 'Generate Backdrop', 'bn': 'ব্যাকড্রপ তৈরি করুন'},
    'try_lights': {'en': 'Try Lights', 'bn': 'লাইট চেষ্টা করুন'},

    // Bottom Navigation
    'home': {'en': 'Home', 'bn': 'হোম'},
    'orders': {'en': 'Orders', 'bn': 'অর্ডার'},

    // Reports - Recent Transactions
    'recent_transactions': {'en': 'Recent Transactions', 'bn': 'সাম্প্রতিক লেনদেন'},
    'undo': {'en': 'Undo', 'bn': 'পূর্বাবস্থায় ফেরত'},
    'no_transactions': {'en': 'No recent transactions', 'bn': 'কোন সাম্প্রতিক লেনদেন নেই'},

    // Common
    'settings': {'en': 'Settings', 'bn': 'সেটিংস'},
  };
}