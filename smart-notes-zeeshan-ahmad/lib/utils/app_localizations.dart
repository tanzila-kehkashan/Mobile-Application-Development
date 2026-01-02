import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Settings Screen
      'settings': 'Settings',
      'appearance': 'Appearance',
      'color_blind_mode': 'Color Blind Mode',
      'dark_mode': 'Dark Mode',
      'preferences': 'Preferences',
      'notifications': 'Notifications',
      'language': 'Language',
      'select_language': 'Select Language',
      
      // Profile Screen
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'full_name': 'Full Name',
      'email': 'Email',
      'account_info': 'Account Information',
      'statistics': 'Statistics',
      'total_notes': 'Total Notes',
      'scanned_notes': 'Scanned',
      'update_profile': 'Update Profile',
      'enter_name': 'Enter your name',
      
      // My Notes Screen
      'my_notes': 'My Notes',
      'search_notes': 'Search notes...',
      'no_notes_found': 'No notes found',
      'new_note': 'New Note',
      
      // Common
      'save': 'Save',
      'cancel': 'Cancel',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
      'just_now': 'Just now',
      'days_ago': 'days ago',
      'hours_ago': 'hours ago',
      'day_ago': 'day ago',
      'hour_ago': 'hour ago',
    },
    'es': {
      // Settings Screen
      'settings': 'Ajustes',
      'appearance': 'Apariencia',
      'color_blind_mode': 'Modo Daltonismo',
      'dark_mode': 'Modo Oscuro',
      'preferences': 'Preferencias',
      'notifications': 'Notificaciones',
      'language': 'Idioma',
      'select_language': 'Seleccionar Idioma',
      
      // Profile Screen
      'profile': 'Perfil',
      'edit_profile': 'Editar Perfil',
      'full_name': 'Nombre Completo',
      'email': 'Correo',
      'account_info': 'Información de Cuenta',
      'statistics': 'Estadísticas',
      'total_notes': 'Total de Notas',
      'scanned_notes': 'Escaneadas',
      'update_profile': 'Actualizar Perfil',
      'enter_name': 'Ingrese su nombre',
      
      // My Notes Screen
      'my_notes': 'Mis Notas',
      'search_notes': 'Buscar notas...',
      'no_notes_found': 'No se encontraron notas',
      'new_note': 'Nueva Nota',
      
      // Common
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'error': 'Error',
      'success': 'Éxito',
      'loading': 'Cargando...',
      'just_now': 'Ahora mismo',
      'days_ago': 'días atrás',
      'hours_ago': 'horas atrás',
      'day_ago': 'día atrás',
      'hour_ago': 'hora atrás',
    },
    'fr': {
      // Settings Screen
      'settings': 'Paramètres',
      'appearance': 'Apparence',
      'color_blind_mode': 'Mode Daltonien',
      'dark_mode': 'Mode Sombre',
      'preferences': 'Préférences',
      'notifications': 'Notifications',
      'language': 'Langue',
      'select_language': 'Choisir la Langue',
      
      // Profile Screen
      'profile': 'Profil',
      'edit_profile': 'Modifier le Profil',
      'full_name': 'Nom Complet',
      'email': 'E-mail',
      'account_info': 'Informations du Compte',
      'statistics': 'Statistiques',
      'total_notes': 'Notes Totales',
      'scanned_notes': 'Numérisées',
      'update_profile': 'Mettre à Jour',
      'enter_name': 'Entrez votre nom',
      
      // My Notes Screen
      'my_notes': 'Mes Notes',
      'search_notes': 'Rechercher...',
      'no_notes_found': 'Aucune note trouvée',
      'new_note': 'Nouvelle Note',
      
      // Common
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'error': 'Erreur',
      'success': 'Succès',
      'loading': 'Chargement...',
      'just_now': 'À l\'instant',
      'days_ago': 'jours',
      'hours_ago': 'heures',
      'day_ago': 'jour',
      'hour_ago': 'heure',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
