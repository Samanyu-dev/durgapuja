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
    'dashboard_tab': {'en': 'Dashboard', 'bn': 'ড্যাশবোর্ড'},
    'all_sections_tab': {'en': 'All Sections', 'bn': 'সব সেকশন'},
    'materials_tab': {'en': 'Materials', 'bn': 'উপকরণ'},
    'no_pending_payments': {'en': 'No pending payments', 'bn': 'কোন বকেয়া পেমেন্ট নেই'},
    'finance_management': {'en': 'Finance Management', 'bn': 'ফাইন্যান্স ম্যানেজমেন্ট'},
    'material_tracker': {'en': 'Material Tracker', 'bn': 'ম্যাটেরিয়াল ট্র্যাকার'},
    'material_tracker_subtitle': {'en': 'Track costs, trends & usage analytics', 'bn': 'খরচ, দামের ওঠানামা ও ব্যবহারের বিশ্লেষণ দেখুন'},
    'samiti_funds': {'en': 'Samiti Funds', 'bn': 'সমিতির তহবিল'},
    'samiti_funds_subtitle': {'en': 'Manage community fund sources', 'bn': 'সমিতির অর্থের উৎসগুলি ম্যানেজ করুন'},
    'worker_funds': {'en': 'Worker Funds', 'bn': 'কর্মীর তহবিল'},
    'worker_funds_subtitle': {'en': 'Track worker payments and budgets', 'bn': 'কর্মীর পেমেন্ট ও বাজেট দেখুন'},
    'worker_details': {'en': 'Worker Details', 'bn': 'কর্মীর বিস্তারিত'},
    'worker_details_subtitle': {'en': 'View and manage worker information', 'bn': 'কর্মীর তথ্য দেখুন ও ম্যানেজ করুন'},
    'financial_reports': {'en': 'Financial Reports', 'bn': 'ফাইন্যান্স রিপোর্ট'},
    'financial_reports_subtitle': {'en': 'Detailed analytics and insights', 'bn': 'বিশদ বিশ্লেষণ ও ইনসাইটস'},

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
    'design': {'en': 'Design', 'bn': 'ডিজাইন'},
    'orders': {'en': 'Orders', 'bn': 'অর্ডার'},
    'finance': {'en': 'Finance', 'bn': 'ফাইনান্স'},
    'reports': {'en': 'Reports', 'bn': 'রিপোর্ট'},

    // Reports - Recent Transactions
    'recent_transactions': {'en': 'Recent Transactions', 'bn': 'সাম্প্রতিক লেনদেন'},
    'undo': {'en': 'Undo', 'bn': 'পূর্বাবস্থায় ফেরত'},
    'no_transactions': {'en': 'No recent transactions', 'bn': 'কোন সাম্প্রতিক লেনদেন নেই'},

    // Design module - create_design_screen
    'durga_idol_designer': {'en': 'Durga Idol Designer', 'bn': 'দুর্গা মূর্তি ডিজাইনার'},
    'create_your_durga_idol': {'en': 'Create Your Durga Idol', 'bn': 'আপনার দুর্গা মূর্তি তৈরি করুন'},
    'use_text_voice_or_reference': {'en': 'Use text, voice, or reference images', 'bn': 'টেক্সট, ভয়েস বা রেফারেন্স ছবি ব্যবহার করুন'},
    'describe_your_design': {'en': 'Describe Your Design', 'bn': 'আপনার ডিজাইন বর্ণনা করুন'},
    'prompt_hint_durga': {'en': 'E.g., Traditional Bengali Durga idol with golden jewelry and red saree...', 'bn': 'যেমন: সোনার গয়না ও লাল শাড়ি সহ ঐতিহ্যবাহী বাংলা দুর্গা মূর্তি...'},
    'confidence_label': {'en': 'Confidence', 'bn': 'নিশ্চয়তা'},
    'reference_images': {'en': 'Reference Images', 'bn': 'রেফারেন্স ছবি'},
    'reference_images_help': {'en': 'Add up to 3 reference images to guide the AI', 'bn': 'AI কে গাইড করতে সর্বোচ্চ ৩টি রেফারেন্স ছবি যোগ করুন'},
    'gallery': {'en': 'Gallery', 'bn': 'গ্যালারি'},
    'camera': {'en': 'Camera', 'bn': 'ক্যামেরা'},
    'generate_design': {'en': 'Generate Design', 'bn': 'ডিজাইন তৈরি করুন'},
    'quick_prompts': {'en': 'Quick Prompts', 'bn': 'দ্রুত প্রম্পট'},
    'accessibility_tips': {'en': 'Accessibility Tips', 'bn': 'অ্যাক্সেসিবিলিটি টিপস'},
    'design_tips': {'en': 'Design Tips', 'bn': 'ডিজাইন টিপস'},
    'scroll_for_button': {'en': 'Scroll down to access the Generate Design button', 'bn': 'ডিজাইন বাটন পেতে নিচে স্ক্রল করুন'},
    'page_scrollable': {'en': 'The page is designed to be scrollable for better accessibility', 'bn': 'ভাল অ্যাক্সেসের জন্য পেজ স্ক্রলযোগ্য'},
    'accessibility_button_help': {'en': 'If you\'re having trouble accessing the Generate Design button, try scrolling down the page. The button is positioned at the bottom of the content area to ensure it\'s accessible even when navigation bars are present.', 'bn': 'ডিজাইন বাটনে যেতে সমস্যা হলে পেজে নিচে স্ক্রল করুন। নেভিগেশন বারের পাশেও বাটন পেতে কনটেন্টের নিচের দিকে স্ক্রল করুন।'},
    'best_results_include': {'en': 'For best results, use detailed descriptions that include:', 'bn': 'সবচেয়ে ভাল ফলাফলের জন্য বিস্তারিত বর্ণনা ব্যবহার করুন:'},
    'specific_materials': {'en': 'Specific materials (gold, silver, wood)', 'bn': 'নির্দিষ্ট উপকরণ (সোনা, রূপা, কাঠ)'},
    'color_schemes': {'en': 'Color schemes and patterns', 'bn': 'রঙের স্কিম ও নকশা'},
    'traditional_vs_modern': {'en': 'Traditional vs modern styles', 'bn': 'ঐতিহ্যবাহী বনাম আধুনিক স্টাইল'},
    'cultural_elements': {'en': 'Specific cultural elements', 'bn': 'নির্দিষ্ট সাংস্কৃতিক উপাদান'},
    'tip_specific': {'en': 'Tip: The more specific your description, the better the AI can create your vision!', 'bn': 'টিপ: বর্ণনা যত নির্দিষ্ট, AI তত ভাল আপনার ভিশন তৈরি করতে পারবে!'},
    'max_3_images': {'en': 'Maximum 3 reference images allowed', 'bn': 'সর্বোচ্চ ৩টি রেফারেন্স ছবি অনুমোদিত'},
    'please_enter_prompt': {'en': 'Please enter a prompt', 'bn': 'অনুগ্রহ করে একটি প্রম্পট লিখুন'},

    // create_preview_screen
    'idol_preview_generator': {'en': 'Idol Preview Generator', 'bn': 'মূর্তি প্রিভিউ জেনারেটর'},
    'choose_preview_type': {'en': 'Choose preview type', 'bn': 'প্রিভিউ টাইপ নির্বাচন করুন'},
    'describe_scene': {'en': 'Describe the scene and setting', 'bn': 'দৃশ্য ও সেটিং বর্ণনা করুন'},
    'scene_hint': {'en': 'e.g., "traditional Bengali pandal with colorful lights"', 'bn': 'যেমন: "রঙিন আলো সহ ঐতিহ্যবাহী বাংলা প্যান্ডাল"'},
    'ai_generate_previews': {'en': 'AI will generate realistic scene previews', 'bn': 'AI বাস্তবসম্মত দৃশ্য প্রিভিউ তৈরি করবে'},
    'generate_preview': {'en': 'Generate Preview', 'bn': 'প্রিভিউ তৈরি করুন'},
    'please_enter_scene': {'en': 'Please enter scene description first', 'bn': 'প্রথমে দৃশ্যের বর্ণনা লিখুন'},
    'scene_preview': {'en': 'Scene Preview', 'bn': 'দৃশ্য প্রিভিউ'},
    'tap_to_zoom': {'en': 'Tap to zoom and explore the full scene', 'bn': 'জুম ও পুরো দৃশ্য দেখতে ট্যাপ করুন'},

    // create_prompt_screen
    'create_prompt': {'en': 'Create Prompt', 'bn': 'প্রম্পট তৈরি করুন'},
    'what_are_you_designing': {'en': 'What are you designing?', 'bn': 'কি ডিজাইন করছেন?'},
    'hint_idol_design': {'en': 'e.g., Idol Design for durga pooja', 'bn': 'যেমন: দুর্গা পূজার জন্য মূর্তি ডিজাইন'},
    'generated_prompts': {'en': 'Generated Prompts', 'bn': 'তৈরি প্রম্পট'},
    'generate_prompts': {'en': 'Generate Prompts', 'bn': 'প্রম্পট তৈরি করুন'},
    'edit_refine': {'en': 'Edit & Refine', 'bn': 'সম্পাদনা ও পরিমার্জনা'},
    'copy': {'en': 'Copy', 'bn': 'কপি'},

    // design_welcome_screen
    'durga_idol_design_studio': {'en': 'Durga Idol Design Studio', 'bn': 'দুর্গা মূর্তি ডিজাইন স্টুডিও'},
    'create_beautiful_with_ai': {'en': 'Create beautiful Durga Puja designs with AI assistance', 'bn': 'AI সহায়তায় সুন্দর দুর্গা পূজা ডিজাইন তৈরি করুন'},
    'choose_design_path': {'en': 'Choose Your Design Path', 'bn': 'আপনার ডিজাইন পথ বেছে নিন'},
    'create_new_design': {'en': 'Create New Design', 'bn': 'নতুন ডিজাইন তৈরি করুন'},
    'new_design_subtitle': {'en': 'Generate a new Durga idol design using text or voice prompts', 'bn': 'টেক্সট বা ভয়েস প্রম্পট দিয়ে নতুন দুর্গা মূর্তি ডিজাইন তৈরি করুন'},
    'image_to_image': {'en': 'Image-to-Image Generation', 'bn': 'ইমেজ টু ইমেজ জেনারেশন'},
    'image_to_image_subtitle': {'en': 'Transform existing images with AI enhancement and style transfer', 'bn': 'AI এনহ্যান্সমেন্ট ও স্টাইল ট্রান্সফার দিয়ে ছবি রূপান্তর করুন'},
    'edit_existing_design': {'en': 'Edit Existing Design', 'bn': 'আগের ডিজাইন সম্পাদনা করুন'},
    'edit_existing_subtitle': {'en': 'Modify and enhance previously created designs', 'bn': 'আগে তৈরি ডিজাইন পরিবর্তন ও উন্নত করুন'},
    'tap_to_edit': {'en': 'Tap-to-Edit', 'bn': 'ট্যাপ টু এডিট'},
    'tap_to_edit_subtitle': {'en': 'Trace and edit specific elements in your designs', 'bn': 'ডিজাইনে নির্দিষ্ট এলিমেন্ট ট্রেস ও এডিট করুন'},
    'tip_descriptive': {'en': 'Use descriptive prompts for better results', 'bn': 'ভাল ফলাফলের জন্য বর্ণনামূলক প্রম্পট ব্যবহার করুন'},
    'tip_voice': {'en': 'Try voice input for natural language descriptions', 'bn': 'প্রাকৃতিক ভাষার বর্ণনার জন্য ভয়েস ইনপুট চেষ্টা করুন'},
    'tip_upload': {'en': 'Upload reference images for image-to-image generation', 'bn': 'ইমেজ-টু-ইমেজের জন্য রেফারেন্স ছবি আপলোড করুন'},
    'tip_tap_edit': {'en': 'Use tap-to-edit for precise element modifications', 'bn': 'নির্দিষ্ট এলিমেন্ট পরিবর্তনের জন্য ট্যাপ-টু-এডিট ব্যবহার করুন'},
    'tip_experiment': {'en': 'Experiment with different styles and themes', 'bn': 'বিভিন্ন স্টাইল ও থিম নিয়ে পরীক্ষা করুন'},

    // element_edit_screen
    'edit_design_element': {'en': 'Edit Design Element', 'bn': 'ডিজাইন এলিমেন্ট সম্পাদনা করুন'},
    'back': {'en': 'Back', 'bn': 'পিছনে'},
    'original_design': {'en': 'Original Design', 'bn': 'মূল ডিজাইন'},
    'select_element_to_edit': {'en': 'Select Element to Edit', 'bn': 'সম্পাদনার জন্য এলিমেন্ট নির্বাচন করুন'},
    'edit_description': {'en': 'Edit Description', 'bn': 'বর্ণনা সম্পাদনা করুন'},
    'describe_what_to_change': {'en': 'Describe what you want to change...', 'bn': 'কি বদলাতে চান বর্ণনা করুন...'},
    'example_prompts': {'en': 'Example Prompts', 'bn': 'উদাহরণ প্রম্পট'},
    'apply_element_edit': {'en': 'Apply Element Edit', 'bn': 'এলিমেন্ট এডিট প্রয়োগ করুন'},
    'editing_element': {'en': 'Editing Element...', 'bn': 'এলিমেন্ট সম্পাদনা হচ্ছে...'},
    'try_tap_to_edit': {'en': 'Try Tap-to-Edit', 'bn': 'ট্যাপ-টু-এডিট চেষ্টা করুন'},
    'save': {'en': 'Save', 'bn': 'সেভ'},
    'edit_more': {'en': 'Edit More', 'bn': 'আরও সম্পাদনা'},
    'edited_design': {'en': 'Edited Design', 'bn': 'সম্পাদিত ডিজাইন'},
    'ai_modifying_element': {'en': 'AI is modifying the selected element while preserving the rest of your design', 'bn': 'AI নির্বাচিত এলিমেন্ট পরিবর্তন করছে এবং বাকি ডিজাইন রাখছে'},
    'edited_image_saved': {'en': 'Edited image saved', 'bn': 'সম্পাদিত ছবি সেভ হয়েছে'},

    // enhanced_image_editor_screen
    'your_design': {'en': 'Your Design', 'bn': 'আপনার ডিজাইন'},
    'back_to_design': {'en': 'Back to Design', 'bn': 'ডিজাইনে ফিরে যান'},
    'save_to_my_concepts': {'en': 'Save to My Concepts', 'bn': 'আমার কনসেপ্টে সেভ করুন'},
    'download': {'en': 'Download', 'bn': 'ডাউনলোড'},
    'edit_your_design': {'en': 'Edit Your Design', 'bn': 'আপনার ডিজাইন সম্পাদনা করুন'},
    'describe_how_to_edit': {'en': 'Describe how you want to edit...', 'bn': 'কিভাবে এডিট করতে চান বর্ণনা করুন...'},
    'reference_image': {'en': 'Reference Image', 'bn': 'রেফারেন্স ছবি'},
    'remove': {'en': 'Remove', 'bn': 'সরান'},
    'add_reference_image': {'en': 'Add Reference Image', 'bn': 'রেফারেন্স ছবি যোগ করুন'},
    'generate_edit': {'en': 'Generate Edit', 'bn': 'এডিট তৈরি করুন'},
    'create_new_design_btn': {'en': 'Create New Design', 'bn': 'নতুন ডিজাইন তৈরি করুন'},
    'creating_your_design': {'en': 'Creating your design...', 'bn': 'আপনার ডিজাইন তৈরি হচ্ছে...'},

    // image_to_image_screen
    'image_to_image_gen': {'en': 'Image-to-Image Generation', 'bn': 'ইমেজ টু ইমেজ জেনারেশন'},
    'image_selection': {'en': 'Image Selection', 'bn': 'ছবি নির্বাচন'},
    'original_image': {'en': 'Original Image', 'bn': 'মূল ছবি'},
    'select_image_to_transform': {'en': 'Select the image you want to transform', 'bn': 'যে ছবি রূপান্তর করতে চান সেটি নির্বাচন করুন'},
    'select_style_reference': {'en': 'Select style reference image', 'bn': 'স্টাইল রেফারেন্স ছবি নির্বাচন করুন'},
    'enhancement_mode': {'en': 'Enhancement Mode', 'bn': 'এনহ্যান্সমেন্ট মোড'},
    'choose_how_to_transform': {'en': 'Choose how you want to transform your image', 'bn': 'ছবি কিভাবে রূপান্তর করতে চান নির্বাচন করুন'},
    'enhance': {'en': 'Enhance', 'bn': 'এনহ্যান্স'},
    'style_transfer': {'en': 'Style Transfer', 'bn': 'স্টাইল ট্রান্সফার'},
    'creative_transform': {'en': 'Creative Transform', 'bn': 'ক্রিয়েটিভ ট্রান্সফর্ম'},
    'describe_transformation': {'en': 'Describe Your Transformation', 'bn': 'আপনার রূপান্তর বর্ণনা করুন'},
    'describe_change_enhance': {'en': 'Describe what you want to change or enhance in your image', 'bn': 'ছবিতে কি বদল বা এনহ্যান্স করতে চান বর্ণনা করুন'},
    'transform_your_image': {'en': 'Transform Your Image', 'bn': 'আপনার ছবি রূপান্তর করুন'},
    'transform_image': {'en': 'Transform Image', 'bn': 'ছবি রূপান্তর করুন'},
    'this_will_apply_ai': {'en': 'This will apply AI transformations to your selected image', 'bn': 'আপনার নির্বাচিত ছবিতে AI রূপান্তর প্রয়োগ হবে'},
    'processing': {'en': 'Processing...', 'bn': 'প্রসেসিং...'},
    'cancel': {'en': 'Cancel', 'bn': 'বাতিল'},

    // image_viewer_screen
    'failed_to_load_image': {'en': 'Failed to load image', 'bn': 'ছবি লোড হয়নি'},

    // my_concepts_screen
    'my_concepts': {'en': 'My Concepts', 'bn': 'আমার কনসেপ্ট'},
    'search_concepts': {'en': 'Search concepts', 'bn': 'কনসেপ্ট খুঁজুন'},
    'filters': {'en': 'Filters', 'bn': 'ফিল্টার'},
    'theme': {'en': 'Theme', 'bn': 'থিম'},
    'date': {'en': 'Date', 'bn': 'তারিখ'},
    'close': {'en': 'Close', 'bn': 'বন্ধ'},
    'edit': {'en': 'Edit', 'bn': 'সম্পাদনা'},
    'create_new_concept': {'en': 'Create new concept', 'bn': 'নতুন কনসেপ্ট তৈরি করুন'},

    // tap_to_edit_screen
    'tap_to_edit_title': {'en': 'Tap-to-Edit', 'bn': 'ট্যাপ টু এডিট'},
    'clear_selection': {'en': 'Clear Selection', 'bn': 'সিলেকশন সাফ করুন'},
    'select_image': {'en': 'Select Image', 'bn': 'ছবি নির্বাচন করুন'},
    'no_image_selected': {'en': 'No image selected\nTap the image icon to select one', 'bn': 'কোন ছবি নির্বাচন হয়নি\nএকটি নির্বাচন করতে ছবি আইকনে ট্যাপ করুন'},
    'tracing_confirmed': {'en': 'Tracing Confirmed', 'bn': 'ট্রেসিং নিশ্চিত'},
    'element_traced_ready': {'en': 'Element traced and ready for editing', 'bn': 'এলিমেন্ট ট্রেস করা হয়েছে এবং সম্পাদনার জন্য প্রস্তুত'},
    'confirm_selection': {'en': 'Confirm Selection', 'bn': 'নির্বাচন নিশ্চিত করুন'},
    'select_element_to_edit_short': {'en': 'Select Element to Edit', 'bn': 'সম্পাদনার জন্য এলিমেন্ট নির্বাচন করুন'},
    'selected': {'en': 'Selected', 'bn': 'নির্বাচিত'},
    'change_selection': {'en': 'Change selection', 'bn': 'নির্বাচন বদলান'},
    'apply_edit': {'en': 'Apply Edit', 'bn': 'এডিট প্রয়োগ করুন'},
    'image_saved': {'en': 'Image saved successfully!', 'bn': 'ছবি সফলভাবে সেভ হয়েছে!'},
    'trace_instruction': {'en': 'Trace around the element you want to edit with your finger', 'bn': 'আঙুল দিয়ে যে এলিমেন্ট এডিট করতে চান তার চারপাশে ট্রেস করুন'},
    'processing_edit': {'en': 'Processing your edit...', 'bn': 'আপনার এডিট প্রসেস করা হচ্ছে...'},
    'this_may_take_moment': {'en': 'This may take a moment', 'bn': 'এতে একটু সময় লাগতে পারে'},
    'edit_complete': {'en': 'Edit Complete!', 'bn': 'এডিট সম্পন্ন!'},
    'image_edited_success': {'en': 'Your image has been successfully edited.', 'bn': 'আপনার ছবি সফলভাবে সম্পাদনা হয়েছে।'},
    'view_edited_above': {'en': 'You can now view the edited image in the viewer above.', 'bn': 'এখন উপরের ভিউয়ারে সম্পাদিত ছবি দেখতে পারবেন।'},
    'image_edited_view_above': {'en': 'Image has been edited! View the result above.', 'bn': 'ছবি সম্পাদনা হয়েছে! উপরে ফলাফল দেখুন.'},
    'edit_tips': {'en': 'Edit Tips', 'bn': 'এডিট টিপস'},
    'for_best_editing': {'en': 'For best editing results:', 'bn': 'সবচেয়ে ভাল এডিটের জন্য:'},
    'be_specific': {'en': 'Be specific about what you want to change', 'bn': 'কি বদলাতে চান স্পষ্টভাবে বলুন'},
    'use_clear_language': {'en': 'Use clear, descriptive language', 'bn': 'পরিষ্কার, বর্ণনামূলক ভাষা ব্যবহার করুন'},
    'consider_element': {'en': 'Consider the element type you selected', 'bn': 'আপনি যে এলিমেন্ট টাইপ নির্বাচন করেছেন তা মাথায় রাখুন'},
    'use_example_prompts': {'en': 'Use example prompts as inspiration', 'bn': 'উদাহরণ প্রম্পট অনুপ্রেরণা হিসেবে ব্যবহার করুন'},
    'tip_precise': {'en': 'Tip: The more precise your description, the better the AI can make your edits!', 'bn': 'টিপ: বর্ণনা যত সঠিক, AI তত ভাল এডিট করতে পারবে!'},
    'select_image_source': {'en': 'Select Image Source', 'bn': 'ছবির উৎস নির্বাচন করুন'},
    'please_trace_and_select': {'en': 'Please trace an area and select element type', 'bn': 'অনুগ্রহ করে একটি অঞ্চল ট্রেস করুন ও এলিমেন্ট টাইপ নির্বাচন করুন'},
    'please_describe_changes': {'en': 'Please describe the changes', 'bn': 'অনুগ্রহ করে পরিবর্তন বর্ণনা করুন'},

    // create_backdrop_screen
    'create_backdrop': {'en': 'Generate Backdrop', 'bn': 'ব্যাকড্রপ তৈরি করুন'},
    'backdrop_generator': {'en': 'Backdrop Generator', 'bn': 'ব্যাকড্রপ জেনারেটর'},
    'backdrop_description_first': {'en': 'Please enter backdrop description first', 'bn': 'প্রথমে ব্যাকড্রপ বর্ণনা লিখুন'},

    // Snackbars / messages
    'voice_input_failed': {'en': 'Voice input failed to start', 'bn': 'ভয়েস ইনপুট চালু হয়নি'},
    'please_enter_valid_edit': {'en': 'Please enter a valid edit description', 'bn': 'অনুগ্রহ করে একটি বৈধ সম্পাদনা বর্ণনা লিখুন'},
    'element_edited_success': {'en': 'Element edited successfully!', 'bn': 'এলিমেন্ট সফলভাবে সম্পাদনা হয়েছে!'},
    'failed_to_edit_element': {'en': 'Failed to edit element', 'bn': 'এলিমেন্ট সম্পাদনা ব্যর্থ'},
    'enter_prompt_or_reference': {'en': 'Enter a prompt or add a reference image', 'bn': 'একটি প্রম্পট লিখুন বা রেফারেন্স ছবি যোগ করুন'},
    'image_not_ready': {'en': 'Image not ready. Please wait...', 'bn': 'ছবি প্রস্তুত নয়। অনুগ্রহ করে অপেক্ষা করুন...'},
    'saved_to_my_concepts': {'en': 'Saved to My Concepts', 'bn': 'আমার কনসেপ্টে সেভ হয়েছে'},
    'please_select_original_image': {'en': 'Please select an original image', 'bn': 'অনুগ্রহ করে একটি মূল ছবি নির্বাচন করুন'},
    'please_select_reference_style': {'en': 'Please select a reference image for style transfer', 'bn': 'স্টাইল ট্রান্সফারের জন্য রেফারেন্স ছবি নির্বাচন করুন'},
    'tip_try_modes': {'en': 'Tip: Try different enhancement modes (Enhance, Style Transfer, Creative) for the best results.', 'bn': 'টিপ: সবচেয়ে ভাল ফলাফলের জন্য বিভিন্ন এনহ্যান্সমেন্ট মোড চেষ্টা করুন।'},

    // Common
    'settings': {'en': 'Settings', 'bn': 'সেটিংস'},
  };
}