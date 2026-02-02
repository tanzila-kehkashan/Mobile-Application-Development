import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static final LanguageProvider _instance = LanguageProvider._internal();
  factory LanguageProvider() => _instance;
  LanguageProvider._internal();

  String _currentLanguage = 'English';
  String get currentLanguage => _currentLanguage;

  // All translations
  static const Map<String, Map<String, String>> _translations = {
    'English': {
      // Common
      'app_name': 'Smart Inventory',
      'loading': 'Loading...',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'close': 'Close',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'error': 'Error',
      'success': 'Success',
      'submit': 'Submit',

      // Profile
      'my_profile': 'My Profile',
      'edit_profile': 'Edit Profile',
      'favourites': 'Favourites',
      'languages': 'Languages',
      'location': 'Location',
      'subscription': 'Subscription',
      'display': 'Display',
      'clear_cache': 'Clear Cache',
      'clear_history': 'Clear History',
      'log_out': 'Log Out',
      'settings': 'Settings',

      // Dashboard
      'dashboard': 'Dashboard',
      'products': 'Products',
      'total_stock': 'Total Stock',
      'low_stock': 'Low Stock',
      'search': 'Search',
      'add_product': 'Add Product',

      // Settings
      'notifications': 'Notifications',
      'help_faq': 'Help & FAQ',
      'contact_us': 'Contact Us',
      'about': 'About',
      'privacy_policy': 'Privacy Policy',
      'dark_mode': 'Dark Mode',

      // Messages
      'language_changed': 'Language changed to',
      'no_products': 'No products found',
      'no_favourites': 'No favourites yet',
    },
    'Urdu': {
      // Common
      'app_name': 'سمارٹ انوینٹری',
      'loading': 'لوڈ ہو رہا ہے...',
      'save': 'محفوظ کریں',
      'cancel': 'منسوخ',
      'delete': 'حذف کریں',
      'edit': 'ترمیم',
      'close': 'بند کریں',
      'yes': 'ہاں',
      'no': 'نہیں',
      'ok': 'ٹھیک ہے',
      'error': 'خرابی',
      'success': 'کامیابی',
      'submit': 'جمع کرائیں',

      // Profile
      'my_profile': 'میری پروفائل',
      'edit_profile': 'پروفائل میں ترمیم',
      'favourites': 'پسندیدہ',
      'languages': 'زبانیں',
      'location': 'مقام',
      'subscription': 'سبسکرپشن',
      'display': 'ڈسپلے',
      'clear_cache': 'کیش صاف کریں',
      'clear_history': 'تاریخ صاف کریں',
      'log_out': 'لاگ آؤٹ',
      'settings': 'ترتیبات',

      // Dashboard
      'dashboard': 'ڈیش بورڈ',
      'products': 'مصنوعات',
      'total_stock': 'کل اسٹاک',
      'low_stock': 'کم اسٹاک',
      'search': 'تلاش',
      'add_product': 'پروڈکٹ شامل کریں',

      // Settings
      'notifications': 'اطلاعات',
      'help_faq': 'مدد اور سوالات',
      'contact_us': 'ہم سے رابطہ کریں',
      'about': 'کے بارے میں',
      'privacy_policy': 'رازداری کی پالیسی',
      'dark_mode': 'ڈارک موڈ',

      // Messages
      'language_changed': 'زبان تبدیل ہو گئی',
      'no_products': 'کوئی پروڈکٹ نہیں ملی',
      'no_favourites': 'ابھی کوئی پسندیدہ نہیں',
    },
    'Arabic': {
      // Common
      'app_name': 'المخزون الذكي',
      'loading': 'جار التحميل...',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'close': 'إغلاق',
      'yes': 'نعم',
      'no': 'لا',
      'ok': 'موافق',
      'error': 'خطأ',
      'success': 'نجاح',
      'submit': 'إرسال',

      // Profile
      'my_profile': 'ملفي الشخصي',
      'edit_profile': 'تعديل الملف',
      'favourites': 'المفضلة',
      'languages': 'اللغات',
      'location': 'الموقع',
      'subscription': 'الاشتراك',
      'display': 'العرض',
      'clear_cache': 'مسح الذاكرة',
      'clear_history': 'مسح السجل',
      'log_out': 'تسجيل الخروج',
      'settings': 'الإعدادات',

      // Dashboard
      'dashboard': 'لوحة التحكم',
      'products': 'المنتجات',
      'total_stock': 'إجمالي المخزون',
      'low_stock': 'مخزون منخفض',
      'search': 'بحث',
      'add_product': 'إضافة منتج',

      // Settings
      'notifications': 'الإشعارات',
      'help_faq': 'المساعدة والأسئلة',
      'contact_us': 'اتصل بنا',
      'about': 'حول',
      'privacy_policy': 'سياسة الخصوصية',
      'dark_mode': 'الوضع الداكن',

      // Messages
      'language_changed': 'تم تغيير اللغة إلى',
      'no_products': 'لم يتم العثور على منتجات',
      'no_favourites': 'لا مفضلات بعد',
    },
    'Hindi': {
      // Common
      'app_name': 'स्मार्ट इन्वेंटरी',
      'loading': 'लोड हो रहा है...',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'close': 'बंद करें',
      'yes': 'हाँ',
      'no': 'नहीं',
      'ok': 'ठीक है',
      'error': 'त्रुटि',
      'success': 'सफलता',
      'submit': 'जमा करें',

      // Profile
      'my_profile': 'मेरी प्रोफाइल',
      'edit_profile': 'प्रोफाइल संपादित करें',
      'favourites': 'पसंदीदा',
      'languages': 'भाषाएं',
      'location': 'स्थान',
      'subscription': 'सदस्यता',
      'display': 'प्रदर्शन',
      'clear_cache': 'कैश साफ करें',
      'clear_history': 'इतिहास साफ करें',
      'log_out': 'लॉग आउट',
      'settings': 'सेटिंग्स',

      // Dashboard
      'dashboard': 'डैशबोर्ड',
      'products': 'उत्पाद',
      'total_stock': 'कुल स्टॉक',
      'low_stock': 'कम स्टॉक',
      'search': 'खोजें',
      'add_product': 'उत्पाद जोड़ें',

      // Settings
      'notifications': 'सूचनाएं',
      'help_faq': 'मदद और FAQ',
      'contact_us': 'संपर्क करें',
      'about': 'के बारे में',
      'privacy_policy': 'गोपनीयता नीति',
      'dark_mode': 'डार्क मोड',

      // Messages
      'language_changed': 'भाषा बदल गई',
      'no_products': 'कोई उत्पाद नहीं मिला',
      'no_favourites': 'अभी कोई पसंदीदा नहीं',
    },
    'Spanish': {
      // Common
      'app_name': 'Inventario Inteligente',
      'loading': 'Cargando...',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'edit': 'Editar',
      'close': 'Cerrar',
      'yes': 'Sí',
      'no': 'No',
      'ok': 'OK',
      'error': 'Error',
      'success': 'Éxito',
      'submit': 'Enviar',

      // Profile
      'my_profile': 'Mi Perfil',
      'edit_profile': 'Editar Perfil',
      'favourites': 'Favoritos',
      'languages': 'Idiomas',
      'location': 'Ubicación',
      'subscription': 'Suscripción',
      'display': 'Pantalla',
      'clear_cache': 'Borrar Caché',
      'clear_history': 'Borrar Historial',
      'log_out': 'Cerrar Sesión',
      'settings': 'Configuración',

      // Dashboard
      'dashboard': 'Panel',
      'products': 'Productos',
      'total_stock': 'Stock Total',
      'low_stock': 'Stock Bajo',
      'search': 'Buscar',
      'add_product': 'Agregar Producto',

      // Settings
      'notifications': 'Notificaciones',
      'help_faq': 'Ayuda y FAQ',
      'contact_us': 'Contáctenos',
      'about': 'Acerca de',
      'privacy_policy': 'Política de Privacidad',
      'dark_mode': 'Modo Oscuro',

      // Messages
      'language_changed': 'Idioma cambiado a',
      'no_products': 'No se encontraron productos',
      'no_favourites': 'Aún no hay favoritos',
    },
    'French': {
      // Common
      'app_name': 'Inventaire Intelligent',
      'loading': 'Chargement...',
      'save': 'Sauvegarder',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'close': 'Fermer',
      'yes': 'Oui',
      'no': 'Non',
      'ok': 'OK',
      'error': 'Erreur',
      'success': 'Succès',
      'submit': 'Soumettre',

      // Profile
      'my_profile': 'Mon Profil',
      'edit_profile': 'Modifier le Profil',
      'favourites': 'Favoris',
      'languages': 'Langues',
      'location': 'Emplacement',
      'subscription': 'Abonnement',
      'display': 'Affichage',
      'clear_cache': 'Vider le Cache',
      'clear_history': 'Effacer l\'Historique',
      'log_out': 'Déconnexion',
      'settings': 'Paramètres',

      // Dashboard
      'dashboard': 'Tableau de Bord',
      'products': 'Produits',
      'total_stock': 'Stock Total',
      'low_stock': 'Stock Faible',
      'search': 'Rechercher',
      'add_product': 'Ajouter un Produit',

      // Settings
      'notifications': 'Notifications',
      'help_faq': 'Aide et FAQ',
      'contact_us': 'Nous Contacter',
      'about': 'À Propos',
      'privacy_policy': 'Politique de Confidentialité',
      'dark_mode': 'Mode Sombre',

      // Messages
      'language_changed': 'Langue changée en',
      'no_products': 'Aucun produit trouvé',
      'no_favourites': 'Pas encore de favoris',
    },
    'Chinese': {
      // Common
      'app_name': '智能库存',
      'loading': '加载中...',
      'save': '保存',
      'cancel': '取消',
      'delete': '删除',
      'edit': '编辑',
      'close': '关闭',
      'yes': '是',
      'no': '否',
      'ok': '确定',
      'error': '错误',
      'success': '成功',
      'submit': '提交',

      // Profile
      'my_profile': '我的资料',
      'edit_profile': '编辑资料',
      'favourites': '收藏夹',
      'languages': '语言',
      'location': '位置',
      'subscription': '订阅',
      'display': '显示',
      'clear_cache': '清除缓存',
      'clear_history': '清除历史',
      'log_out': '退出登录',
      'settings': '设置',

      // Dashboard
      'dashboard': '仪表板',
      'products': '产品',
      'total_stock': '总库存',
      'low_stock': '低库存',
      'search': '搜索',
      'add_product': '添加产品',

      // Settings
      'notifications': '通知',
      'help_faq': '帮助和常见问题',
      'contact_us': '联系我们',
      'about': '关于',
      'privacy_policy': '隐私政策',
      'dark_mode': '深色模式',

      // Messages
      'language_changed': '语言已更改为',
      'no_products': '未找到产品',
      'no_favourites': '还没有收藏',
    },
  };

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('selected_language') ?? 'English';
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);
    notifyListeners();
  }

  String translate(String key) {
    final langMap = _translations[_currentLanguage];
    if (langMap != null && langMap.containsKey(key)) {
      return langMap[key]!;
    }
    // Fallback to English
    final englishMap = _translations['English'];
    if (englishMap != null && englishMap.containsKey(key)) {
      return englishMap[key]!;
    }
    return key;
  }

  // Static method for easy access
  static String tr(BuildContext context, String key) {
    return LanguageProvider().translate(key);
  }
}

// Global instance
final languageProvider = LanguageProvider();
