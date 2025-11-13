class AppConstants {
  static const String appName = 'Durga Idol Maker';
  
  static const String baseUrl = 'https://api.durgaidolmaker.com'; //fastapi server for backend

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration toastDuration = Duration(seconds: 3); 

  static const double defaultPadding = 20.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 32.0;
  
  static const double borderRadius = 12.0;
  static const double largeRadius = 16.0;

  static const double smallIconSize = 16.0;
  static const double mediumIconSize = 24.0;
  static const double largeIconSize = 32.0;

  static const double fontSizeSmall = 12.0;
  static const double fontSizeBody = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 24.0;
  static const double fontSizeHeading = 28.0;
  
  static const List<String> expressions = ['Calm', 'Fierce', 'Kind', 'Motherly', 'Love'];
  static const List<String> emotionTypes = ['Joy', 'Serenity', 'Power', 'Compassion'];
  static const List<String> inspirationTypes = ['Scripture', 'Festival', 'Modern Theme'];
  static const List<String> materials = ['Gold', 'Silver', 'Brass', 'Clay', 'Wood'];
  static const List<String> colors = ['Red', 'Golden Yellow', 'Blue', 'Green', 'White'];
  static const List<String> drapeLStyles = ['Bengali', 'Punjabi', 'South Indian', 'Traditional'];
  
  static const Map<String, String> materialPrices = {
    'Clay': '₹150/Kg',
    'Paint': '₹150/Kg',
    'Bamboo': '₹150/Kg',
    'Straw': '₹30/bundle',
    'Fiber': '₹80/meter',
  };
  
  static const String statusNew = 'New';
  static const String statusInProgress = 'In Progress';
  static const String statusCompleted = 'Completed';
  static const String statusDelivered = 'Delivered';
  
  static const String whatsappUrlFormat = 'https://wa.me/';
}
