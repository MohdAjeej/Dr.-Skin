import 'package:flutter/material.dart';

/// Dr. Skin App Professional Design System
/// Dermatology-focused healthcare application theme

class AppTheme {
  // ============= COLORS =============
  
  // Primary Colors - Medical Blue
  static const Color primaryColor = Color(0xFF2E5BFF);
  static const Color primaryDark = Color(0xFF1A3BB3);
  static const Color primaryLight = Color(0xFF6B8AFF);
  
  // Secondary Colors - Soft Purple/Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color secondaryLight = Color(0xFFA78BFA);
  
  // Dermatology Accent Colors
  static const Color skinTone = Color(0xFFFFF5F0);
  static const Color healthGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF1F5F9);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textWhite = Colors.white;
  
  // Status Colors
  static const Color statusConfirmed = Color(0xFF10B981);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusCancelled = Color(0xFFEF4444);
  static const Color statusCompleted = Color(0xFF6366F1);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  
  // ============= SPACING =============
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  
  // ============= BORDER RADIUS =============
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;
  static const double radiusFull = 999.0;
  
  // ============= TYPOGRAPHY =============
  
  // Display - Hero sections
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  // Heading - Section titles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );
  
  // Title - Card titles, list items
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.5,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.5,
  );
  
  // Body - Main content
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    height: 1.6,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.5,
  );
  
  // Caption - Small supporting text
  static const TextStyle captionLarge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    height: 1.4,
  );
  
  static const TextStyle captionMedium = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: textTertiary,
    height: 1.4,
  );
  
  // Button
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
  
  // ============= SHADOWS =============
  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      spreadRadius: 0,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      spreadRadius: 0,
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> shadowStrong = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      spreadRadius: 0,
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  
  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: primaryColor.withOpacity(0.2),
      spreadRadius: 0,
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  // ============= GRADIENTS =============
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );
  
  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FAFC), Colors.white],
  );
  
  // ============= DERMATOLOGY SPECIALIZATIONS =============
  /// ONLY dermatology-related specializations for doctor registration
  /// NO general medicine, cardiology, neurology, etc.
  static const List<Map<String, String>> dermatologySpecializations = [
    {
      'name': 'General Dermatology',
      'description': 'Comprehensive skin, hair, and nail care',
    },
    {
      'name': 'Cosmetic Dermatology',
      'description': 'Aesthetic treatments and procedures',
    },
    {
      'name': 'Pediatric Dermatology',
      'description': 'Skin conditions in children',
    },
    {
      'name': 'Surgical Dermatology',
      'description': 'Surgical treatment of skin conditions',
    },
    {
      'name': 'Dermatopathology',
      'description': 'Microscopic diagnosis of skin diseases',
    },
    {
      'name': 'Immunodermatology',
      'description': 'Immune-related skin disorders',
    },
    {
      'name': 'Procedural Dermatology',
      'description': 'Minimally invasive procedures',
    },
    {
      'name': 'Trichology',
      'description': 'Hair and scalp specialist',
    },
    {
      'name': 'Laser Dermatology',
      'description': 'Laser-based skin treatments',
    },
    {
      'name': 'Mohs Surgery',
      'description': 'Specialized skin cancer surgery',
    },
  ];
  
  /// Get list of specialization names only
  static List<String> get dermatologySpecializationNames =>
      dermatologySpecializations.map((s) => s['name']!).toList();
  
  // ============= SKIN CONCERNS =============
  static const List<Map<String, dynamic>> skinConcerns = [
    {
      'name': 'Acne',
      'icon': '🔴',
      'color': Color(0xFFFF6B6B),
    },
    {
      'name': 'Pigmentation',
      'icon': '🟤',
      'color': Color(0xFF8B7355),
    },
    {
      'name': 'Eczema',
      'icon': '🔵',
      'color': Color(0xFF4ECDC4),
    },
    {
      'name': 'Psoriasis',
      'icon': '🟣',
      'color': Color(0xFF95E1D3),
    },
    {
      'name': 'Rosacea',
      'icon': '🌸',
      'color': Color(0xFFFFB6C1),
    },
    {
      'name': 'Hair Loss',
      'icon': '💇',
      'color': Color(0xFF9B59B6),
    },
    {
      'name': 'Nail Disorders',
      'icon': '💅',
      'color': Color(0xFFE67E22),
    },
    {
      'name': 'Skin Allergies',
      'icon': '⚡',
      'color': Color(0xFFF39C12),
    },
  ];
  
  // ============= HELPER METHODS =============
  
  /// Get status color based on appointment status
  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
      case 'SCHEDULED':
        return statusConfirmed;
      case 'PENDING':
        return statusPending;
      case 'CANCELLED':
      case 'REJECTED':
      case 'NO_SHOW':
        return statusCancelled;
      case 'COMPLETED':
        return statusCompleted;
      default:
        return textSecondary;
    }
  }
  
  /// Get readable status text
  static String getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return 'Confirmed';
      case 'SCHEDULED':
        return 'Scheduled';
      case 'PENDING':
        return 'Pending';
      case 'CANCELLED':
        return 'Cancelled';
      case 'REJECTED':
        return 'Rejected';
      case 'NO_SHOW':
        return 'No Show';
      case 'COMPLETED':
        return 'Completed';
      case 'IN_PROGRESS':
        return 'In Progress';
      default:
        return status;
    }
  }
  
  /// Create a card decoration
  static BoxDecoration cardDecoration({
    Color? color,
    List<BoxShadow>? shadows,
    double? radius,
  }) {
    return BoxDecoration(
      color: color ?? cardColor,
      borderRadius: BorderRadius.circular(radius ?? radiusLarge),
      boxShadow: shadows ?? shadowSoft,
    );
  }
  
  /// Create a primary button decoration
  static BoxDecoration primaryButtonDecoration({bool enabled = true}) {
    return BoxDecoration(
      gradient: enabled ? primaryGradient : null,
      color: enabled ? null : borderLight,
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: enabled ? shadowPrimary : null,
    );
  }
  
  /// Create an outlined button decoration
  static BoxDecoration outlinedButtonDecoration() {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radiusMedium),
      border: Border.all(color: primaryColor, width: 1.5),
    );
  }
}
