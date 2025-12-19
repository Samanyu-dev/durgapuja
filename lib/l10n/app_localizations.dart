import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Durga Idol Maker'**
  String get appTitle;

  /// No description provided for @helloArtisan.
  ///
  /// In en, this message translates to:
  /// **'Hello, Artisan'**
  String get helloArtisan;

  /// No description provided for @chooseModule.
  ///
  /// In en, this message translates to:
  /// **'Choose your module to get started'**
  String get chooseModule;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @financeDescription.
  ///
  /// In en, this message translates to:
  /// **'Track expenses, materials, and payments'**
  String get financeDescription;

  /// No description provided for @design.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get design;

  /// No description provided for @designDescription.
  ///
  /// In en, this message translates to:
  /// **'Create and customize idol designs'**
  String get designDescription;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @recordVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Record Voice Note'**
  String get recordVoiceNote;

  /// No description provided for @voiceNoteDescription.
  ///
  /// In en, this message translates to:
  /// **'Quickly capture your thoughts and ideas'**
  String get voiceNoteDescription;

  /// No description provided for @todaysExpenses.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Expenses'**
  String get todaysExpenses;

  /// No description provided for @materialsBought.
  ///
  /// In en, this message translates to:
  /// **'Materials Bought'**
  String get materialsBought;

  /// No description provided for @pendingPayments.
  ///
  /// In en, this message translates to:
  /// **'Pending Payments'**
  String get pendingPayments;

  /// No description provided for @viewReport.
  ///
  /// In en, this message translates to:
  /// **'View Report'**
  String get viewReport;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bengali.
  ///
  /// In en, this message translates to:
  /// **'বাংলা (Bengali)'**
  String get bengali;

  /// No description provided for @backToModuleSelection.
  ///
  /// In en, this message translates to:
  /// **'Back to Module Selection'**
  String get backToModuleSelection;

  /// No description provided for @voiceRecording.
  ///
  /// In en, this message translates to:
  /// **'Voice Recording'**
  String get voiceRecording;

  /// No description provided for @voiceRecordingDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap to start recording your voice note'**
  String get voiceRecordingDescription;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get startRecording;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @welcomeArtisan.
  ///
  /// In en, this message translates to:
  /// **'Welcome, artisan'**
  String get welcomeArtisan;

  /// No description provided for @ideaGeneration.
  ///
  /// In en, this message translates to:
  /// **'Idea Generation'**
  String get ideaGeneration;

  /// No description provided for @ideaGenerationDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate unique idol designs with AI'**
  String get ideaGenerationDesc;

  /// No description provided for @idolBuild.
  ///
  /// In en, this message translates to:
  /// **'Idol Build'**
  String get idolBuild;

  /// No description provided for @idolBuildDesc.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step guide to building your idol'**
  String get idolBuildDesc;

  /// No description provided for @decorationDetailing.
  ///
  /// In en, this message translates to:
  /// **'Decoration & Detailing'**
  String get decorationDetailing;

  /// No description provided for @decorationDetailingDesc.
  ///
  /// In en, this message translates to:
  /// **'Add details and decorations to your idol'**
  String get decorationDetailingDesc;

  /// No description provided for @idolPreviews.
  ///
  /// In en, this message translates to:
  /// **'Idol Previews'**
  String get idolPreviews;

  /// No description provided for @idolPreviewsDesc.
  ///
  /// In en, this message translates to:
  /// **'Showcase your creations'**
  String get idolPreviewsDesc;

  /// No description provided for @generateBackdrop.
  ///
  /// In en, this message translates to:
  /// **'Generate Backdrop'**
  String get generateBackdrop;

  /// No description provided for @generateBackdropDesc.
  ///
  /// In en, this message translates to:
  /// **'Create beautiful backdrops for your idols'**
  String get generateBackdropDesc;

  /// No description provided for @tryLights.
  ///
  /// In en, this message translates to:
  /// **'Try Lights'**
  String get tryLights;

  /// No description provided for @tryLightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Experiment with lighting effects'**
  String get tryLightsDesc;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @searchClients.
  ///
  /// In en, this message translates to:
  /// **'Search clients'**
  String get searchClients;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
