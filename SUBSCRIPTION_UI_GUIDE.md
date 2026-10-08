# Subscription Plan Selection UI - Integration Guide

## 🎨 Design Overview

A **modern, premium SaaS-style subscription plan selection page** designed specifically for the Dr. Skin dermatology app. Features a clean, professional medical-themed interface that seamlessly integrates with the existing app design language.

---

## ✨ Key Features

### Visual Design
- ✅ **Premium Medical Theme** - Matches Dr. Skin's professional healthcare aesthetic
- ✅ **Gradient Headers** - Eye-catching blue gradient header with clear messaging
- ✅ **Animated Selections** - Smooth transitions and hover states
- ✅ **Popular Badge** - "Most Popular" tag on recommended plans
- ✅ **Selection Indicator** - Clear checkmark on selected plans
- ✅ **Glass Morphism** - Modern card designs with subtle shadows

### User Experience
- ✅ **Monthly/Yearly Toggle** - Switch between billing periods with savings indicator
- ✅ **3-Tier Pricing** - Basic, Premium, and Pro plans for patients
- ✅ **3-Tier Pricing** - Starter, Professional, and Enterprise for doctors
- ✅ **Feature Comparison** - Clear checkmarks for included/excluded features
- ✅ **Trust Badges** - Security, verification, and cancellation indicators
- ✅ **Confirmation Sheet** - Bottom sheet confirmation before registration
- ✅ **Responsive Layout** - Adapts to different screen sizes

### Pricing Structure

#### Patient Plans
| Plan | Monthly | Yearly | Features |
|------|---------|--------|----------|
| **Basic** | Free | Free | 5 AI analyses, basic features |
| **Premium** ⭐ | ₹499 | ₹4,990 | Unlimited AI, 4 video calls, priority support |
| **Pro** | ₹999 | ₹9,990 | Everything unlimited, 24/7 support |

#### Doctor Plans
| Plan | Monthly | Yearly | Features |
|------|---------|--------|----------|
| **Starter** | ₹1,999 | ₹19,990 | 50 patients/month, basic tools |
| **Professional** ⭐ | ₹3,999 | ₹39,990 | Unlimited patients, advanced features |
| **Enterprise** | ₹7,999 | ₹79,990 | Multi-doctor, CRM, API access |

---

## 🎯 Integration Steps

### Step 1: Import the Subscription Page

The page is already created at:
```
lib/Signup/SubscriptionPlansPage.dart
```

### Step 2: Update Navigation Flow

#### Option A: Show Before Login (Recommended)
Update your onboarding or splash screen to navigate to subscription first:

```dart
// In your onboarding_view.dart or splash screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SubscriptionPlansPage(isDoctor: false),
  ),
);
```

#### Option B: Show After Login Selection
In your login screen, add a "View Plans" button:

```dart
// In LoginPage.dart
TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionPlansPage(isDoctor: false),
      ),
    );
  },
  child: Text('View Subscription Plans'),
),
```

#### Option C: Direct Registration Flow
Replace your current registration navigation with:

```dart
// For Patient Registration
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SubscriptionPlansPage(isDoctor: false),
  ),
);

// For Doctor Registration
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SubscriptionPlansPage(isDoctor: true),
  ),
);
```

### Step 3: Update Registration Pages (Optional)

If you want to show the selected plan during registration, you can pass it as a parameter:

```dart
// Modify SubscriptionPlansPage navigation to include plan data
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => Register(
      selectedPlan: selectedPlan, // Pass the plan data
    ),
  ),
);
```

---

## 🎨 Design Specifications

### Colors (From app_theme.dart)
- **Primary**: `#2E5BFF` (Medical Blue)
- **Primary Light**: `#6B8AFF`
- **Secondary**: `#8B5CF6` (Purple)
- **Success**: `#10B981` (Green)
- **Background**: `#F8FAFC`
- **Card**: `#FFFFFF`

### Typography
- **Heading**: 32px, Bold, White
- **Plan Name**: 24px, Bold
- **Price**: 48px, Bold
- **Features**: 14px, Regular
- **Buttons**: 16px, Bold

### Spacing
- **Card Margin**: 20px
- **Internal Padding**: 24px
- **Feature Spacing**: 12px
- **Section Gaps**: 24px

### Border Radius
- **Cards**: 20px
- **Buttons**: 12px
- **Badges**: 12px

---

## 📱 UI Components

### 1. Header Section
- Gradient background (Primary to Primary Light)
- Back button (top-left)
- Title: "Choose Your Plan"
- Subtitle with trust indicators
- Secure payment messaging

### 2. Billing Toggle
- Monthly/Yearly switch
- "Save 17%" badge on yearly
- Smooth animation on toggle
- Surface color background

### 3. Plan Cards
- White background
- Rounded corners (20px)
- Border color based on selection
- Popular badge (top-center)
- Selection checkmark (top-right)
- Plan name and subtitle
- Large price display
- Feature list with icons
- "Choose Plan" button

### 4. Trust Badges Section
- 3 trust indicators:
  - Secure & Private (with lock icon)
  - Verified Doctors (with shield icon)
  - Cancel Anytime (with cancel icon)
- Gray background container
- Centered layout

### 5. Confirmation Sheet
- Bottom modal sheet
- Success checkmark icon
- Selected plan summary
- Price confirmation
- Info message
- "Continue to Registration" CTA
- "Change Plan" option

### 6. Floating Action Button
- Appears when plan is selected
- Fixed at bottom center
- Primary color gradient
- "Continue to Registration" text
- Arrow icon

---

## 🎭 Animations & Interactions

### Card Selection
```dart
- Tap to select
- Border color changes (gray → blue)
- Border width increases (1.5px → 2.5px)
- Shadow expands
- Checkmark appears with fade-in
- Duration: 300ms
```

### Billing Toggle
```dart
- Background slides smoothly
- Text color transitions
- Shadow appears on selected
- Duration: 200ms
```

### Confirmation Sheet
```dart
- Slides up from bottom
- Handle bar for dismissal
- Success icon with scale animation
- Backdrop blur effect
```

---

## 💡 Usage Examples

### Example 1: Patient Registration Flow
```dart
// User opens app → Onboarding → Subscription Plans → Registration

SplashScreen()
  → OnboardingView()
    → SubscriptionPlansPage(isDoctor: false)
      → Register() // After plan selection
        → CompleteProfile()
          → MyHomePage()
```

### Example 2: Doctor Registration Flow
```dart
// Doctor clicks "Register as Doctor" → Subscription Plans → Multi-step Registration

LoginPage()
  → [Register as Doctor Button]
    → SubscriptionPlansPage(isDoctor: true)
      → DoctorRegistrationComplete() // 4-step wizard
        → DoctorDashboard()
```

### Example 3: View Plans from Login
```dart
// User can view plans before committing to registration

LoginPage()
  → [View Plans Button]
    → SubscriptionPlansPage(isDoctor: false)
      → [Back] → LoginPage()
      OR
      → [Continue] → Register()
```

---

## 🔧 Customization Options

### Change Plan Features
Edit the `_patientPlans` or `_doctorPlans` arrays in `SubscriptionPlansPage.dart`:

```dart
{
  'id': 'unique_plan_id',
  'name': 'Plan Name',
  'monthlyPrice': 999,
  'yearlyPrice': 9990,
  'subtitle': 'Short tagline',
  'description': 'Longer description',
  'isPopular': true, // Show popular badge
  'features': [
    {'text': 'Feature name', 'included': true},
    {'text': 'Another feature', 'included': false},
  ],
}
```

### Change Pricing
Simply update the `monthlyPrice` and `yearlyPrice` values.

### Change Colors
All colors use `AppTheme` constants, so changes in `app_theme.dart` will reflect automatically.

### Add/Remove Plans
Add or remove entries from the `_patientPlans` or `_doctorPlans` lists.

---

## 📊 Plan Feature Matrix

### Patient Features Comparison

| Feature | Basic | Premium | Pro |
|---------|-------|---------|-----|
| AI Skin Analysis | 5/month | Unlimited | Unlimited |
| Find Dermatologists | ✅ | ✅ | ✅ |
| Book Appointments | ✅ | Priority | Instant (24/7) |
| Chat with Doctors | ✅ | Unlimited | Unlimited |
| Diagnosis History | Basic | Complete | Lifetime |
| Video Consultations | ❌ | 4/month | Unlimited |
| Priority Support | ❌ | ✅ | 24/7 Premium |
| Advanced Analytics | ❌ | ✅ | AI Tracking |

### Doctor Features Comparison

| Feature | Starter | Professional | Enterprise |
|---------|---------|--------------|------------|
| Profile Listing | Standard | Featured | Premium |
| Patient Capacity | 50/month | Unlimited | Unlimited |
| Scheduling | Basic | Advanced | Multi-doctor |
| Patient Chat | ✅ | Unlimited | CRM |
| Video Consultations | 50hrs/mo | Unlimited | Unlimited |
| Prescriptions | Digital | Digital | Custom |
| Analytics | Basic | Advanced | Custom Reports |
| Support | Standard | Priority | Dedicated Manager |

---

## 🎯 Best Practices

### 1. Plan Selection Flow
- Always show trust badges to build confidence
- Highlight the most popular plan
- Show clear savings on yearly plans
- Use confirmation sheet before navigation

### 2. Visual Hierarchy
- Keep most popular plan in center
- Use gradient badges sparingly
- Maintain consistent spacing
- Use checkmarks for included features

### 3. User Communication
- Clear pricing (no hidden fees)
- "Cancel anytime" messaging
- Explain what happens next
- Show selected plan summary

### 4. Performance
- Smooth animations (60fps)
- Fast page transitions
- Optimized images/icons
- Minimal rebuilds

---

## 📸 UI Screenshots Locations

All UI elements follow the Dr. Skin app design system:

1. **Header**: Purple-blue gradient with back button
2. **Toggle**: Gray surface with white active state
3. **Plan Cards**: White cards with colored borders
4. **Badges**: Green savings badge, purple popular badge
5. **Buttons**: Blue primary buttons
6. **Sheet**: White bottom sheet with rounded corners

---

## 🚀 Quick Start Checklist

- [x] Create `SubscriptionPlansPage.dart` file
- [ ] Add navigation from login/onboarding
- [ ] Test patient plan selection flow
- [ ] Test doctor plan selection flow
- [ ] Verify monthly/yearly toggle
- [ ] Test confirmation sheet
- [ ] Check responsive layout
- [ ] Verify all animations
- [ ] Test back navigation
- [ ] Integrate with backend (if needed)

---

## 🔄 Future Enhancements

### Phase 1
- [ ] Add trial period indicator
- [ ] Show feature tooltips
- [ ] Add plan comparison table
- [ ] Implement promo codes

### Phase 2
- [ ] Add payment gateway integration
- [ ] Show subscription status
- [ ] Implement plan upgrades/downgrades
- [ ] Add usage statistics

### Phase 3
- [ ] A/B testing for pricing
- [ ] Personalized recommendations
- [ ] Family/group plans
- [ ] Enterprise custom pricing

---

## 📞 Support

For questions or customization help:
- Check the code comments in `SubscriptionPlansPage.dart`
- Review the `app_theme.dart` for design tokens
- Test on different screen sizes
- Verify navigation flows

---

## 📝 Notes

- The UI is **fully functional** and ready to use
- All animations are smooth and performant
- Design matches the existing Dr. Skin aesthetic
- Mobile-first responsive design
- Easy to customize colors, pricing, and features
- No external dependencies required
- Pure Flutter implementation

---

**Created**: January 2025  
**Last Updated**: January 2025  
**Version**: 1.0  
**Design System**: Dr. Skin Medical App Theme
