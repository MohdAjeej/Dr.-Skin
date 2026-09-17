# Dr. Skin App - Complete Features Documentation

## 📱 App Overview
**Dr. Skin** is a comprehensive dermatology healthcare application that connects patients with dermatologists for skin condition diagnosis, treatment, and consultation. The app uses AI-powered skin analysis and provides seamless doctor-patient communication.

---

## 🎯 Core Features

### 1. **User Authentication & Authorization**

#### Patient Registration & Login
- ✅ Email/Username-based registration
- ✅ Secure password authentication
- ✅ Profile completion after registration
- ✅ Role-based access control (Patient/Doctor)
- ✅ Session management with JWT tokens
- ✅ Secure logout with complete session cleanup

#### Doctor Registration & Login
- ✅ Multi-step doctor registration wizard (4 steps):
  - **Step 1**: Basic Information (Name, Email, Phone)
  - **Step 2**: Professional Details (Dermatology-only specializations)
  - **Step 3**: Practice Information (Hospital/Clinic, Experience, Fees)
  - **Step 4**: Account Setup (Username, Password)
- ✅ 10+ Dermatology specializations:
  - General Dermatology
  - Cosmetic Dermatology
  - Pediatric Dermatology
  - Dermatopathology
  - Mohs Surgery
  - Laser Dermatology
  - Hair Restoration
  - Clinical Dermatology
  - Surgical Dermatology
  - Aesthetic Medicine
- ✅ Role-based navigation after login
- ✅ Doctor profile verification

---

### 2. **Patient Features**

#### Home Dashboard
- ✅ Personalized greeting with full name display
- ✅ Professional medical-themed UI
- ✅ Quick access to key features
- ✅ Dermatology-focused hero section
- ✅ Common skin concerns showcase
- ✅ Notification center

#### AI-Powered Skin Diagnosis
- ✅ **Camera Integration**
  - Take photo directly from camera
  - Upload from gallery
  - Image cropping functionality
- ✅ **AI Analysis**
  - Real-time skin condition detection
  - Multiple disease identification
  - Confidence score display
- ✅ **Results Display**
  - Disease name and description
  - Recommended actions
  - Doctor consultation suggestions
  - Treatment recommendations
- ✅ **Diagnosis History**
  - View past skin analysis
  - Track treatment progress
  - Access previous diagnoses
  - Disease detail pages

#### Find Dermatologists
- ✅ **Search & Filter**
  - Search by doctor name
  - Filter by dermatology specialization
  - View all registered dermatologists
- ✅ **Doctor Cards Display**
  - Doctor name and photo
  - Specialization tags
  - Experience and qualification
  - Hospital/Clinic information
  - Rating and reviews
  - Consultation fees (Online & Offline)
  - Availability status
- ✅ **Doctor Profiles**
  - Detailed professional information
  - Education and certifications
  - Practice location
  - Consultation modes

#### Appointment Booking
- ✅ **Booking Flow**
  - Select doctor from search
  - Choose consultation type (Online/Offline)
  - View available time slots
  - Calendar-based date selection
  - Time slot selection
- ✅ **Payment Integration**
  - Multiple payment methods
  - Razorpay payment gateway
  - Secure transaction processing
  - Payment confirmation
- ✅ **Appointment Management**
  - View upcoming appointments
  - View past appointments
  - Appointment status tracking
  - Appointment details page
  - Cancel/Reschedule options

#### Video Consultation
- ✅ **WebRTC Integration**
  - High-quality video calls
  - Audio communication
  - Screen sharing capability
- ✅ **Consultation Room Features**
  - Join video call with doctor
  - Real-time communication
  - Chat during consultation
  - Share images/reports
- ✅ **ZEGOCLOUD Integration**
  - Pre-built video call UI
  - Call quality management
  - Network optimization

#### Chat & Messaging
- ✅ Real-time messaging with doctors
- ✅ STOMP WebSocket integration
- ✅ Message history
- ✅ File/image sharing
- ✅ Typing indicators
- ✅ Message notifications

#### Profile Management
- ✅ **View Profile**
  - Personal information display
  - Profile picture
  - Contact details
- ✅ **Edit Profile**
  - Update first name, last name
  - Change phone number
  - Update date of birth
  - Change gender
  - Update address
  - Save changes with API sync
- ✅ **Account Settings**
  - Privacy policy access
  - Contact support
  - Logout functionality

#### Articles & Education
- ✅ Skin care articles
- ✅ Treatment guides
- ✅ Dermatology tips
- ✅ Search functionality
- ✅ Categorized content

#### Notifications
- ✅ Appointment reminders
- ✅ Diagnosis results
- ✅ Doctor messages
- ✅ System notifications
- ✅ In-app notification center

---

### 3. **Doctor Features**

#### Doctor Dashboard
- ✅ Professional dashboard UI
- ✅ Today's appointments overview
- ✅ Patient statistics
- ✅ Quick actions panel
- ✅ Earning summary
- ✅ Upcoming consultations

#### Appointment Management
- ✅ **View Appointments**
  - Today's appointments
  - Upcoming appointments
  - Past appointments
  - Appointment filtering
- ✅ **Appointment Details**
  - Patient information
  - Appointment time
  - Consultation type
  - Payment status
  - Patient history
- ✅ **Appointment Actions**
  - Accept appointments
  - Reject appointments
  - Reschedule appointments
  - Start video consultation
  - Add prescription

#### Availability Management
- ✅ **Time Slot Management**
  - Set working hours
  - Define time slots
  - Block unavailable dates
  - Recurring availability setup
- ✅ **Calendar Integration**
  - Visual calendar view
  - Drag-and-drop time slots
  - Multiple slot management
  - Day-wise configuration

#### Video Consultation (Doctor Side)
- ✅ Join patient video calls
- ✅ Consultation room controls
- ✅ Screen sharing for diagnosis
- ✅ Real-time patient interaction
- ✅ Consultation notes

#### Prescription Management
- ✅ Digital prescription creation
- ✅ Medication details
- ✅ Dosage instructions
- ✅ Treatment duration
- ✅ Follow-up recommendations
- ✅ Prescription history

#### Chat with Patients
- ✅ Real-time patient messaging
- ✅ Medical consultation chat
- ✅ Image/report sharing
- ✅ Chat history
- ✅ Multiple patient management

#### Doctor Profile Management
- ✅ **View Profile**
  - Professional information
  - Specialization display
  - Qualification details
  - Experience showcase
  - Consultation fees
- ✅ **Edit Profile**
  - Update name and contact
  - Change specialization
  - Update qualification
  - Modify experience
  - Update consultation fees
  - Change hospital/clinic info
  - Save changes with API sync

#### Earnings & Analytics
- ✅ Total earnings display
- ✅ Consultation statistics
- ✅ Patient count tracking
- ✅ Revenue breakdown
- ✅ Payment history

---

## 🎨 UI/UX Features

### Design System
- ✅ **Modern Material Design**
  - Custom color scheme
  - Gradient buttons and cards
  - Smooth animations
  - Professional medical theme
- ✅ **Responsive Layout**
  - Adaptive to different screen sizes
  - Tablet optimization
  - Portrait/landscape support
- ✅ **Custom Theme**
  - Primary gradient (Purple/Blue)
  - Success colors (Green)
  - Error colors (Red)
  - Warning colors (Orange)
  - Professional typography

### Navigation
- ✅ **Bottom Navigation**
  - 5 main tabs (Patient)
  - Home, Search, Camera, Chat, Profile
  - Smooth tab transitions
  - Active tab indicators
- ✅ **Doctor Bottom Navigation**
  - Dashboard, Appointments, Availability, Chat, Profile
  - Role-specific navigation
- ✅ **Drawer Navigation** (optional)
- ✅ **Back Navigation** with proper flow

### Animations & Transitions
- ✅ Page transitions
- ✅ Loading indicators
- ✅ Skeleton loaders
- ✅ Progress animations
- ✅ Lottie animations for states

---

## 🔧 Technical Features

### Backend Integration
- ✅ **RESTful API Integration**
  - Complete API service layer
  - Error handling
  - Response parsing
  - Token management
- ✅ **Endpoints**
  - Authentication APIs
  - Patient profile APIs
  - Doctor profile APIs
  - Appointment APIs
  - Diagnosis APIs
  - Chat APIs
  - Payment APIs

### Real-Time Communication
- ✅ **WebSocket (STOMP)**
  - Real-time chat
  - Live notifications
  - Presence detection
- ✅ **WebRTC**
  - Video calls
  - Audio calls
  - Screen sharing

### Local Storage
- ✅ SharedPreferences for user data
- ✅ Token persistence
- ✅ User role storage
- ✅ Session management

### State Management
- ✅ StatefulWidget-based state
- ✅ setState for UI updates
- ✅ FutureBuilder for async data
- ✅ StreamBuilder for real-time data

### Image Handling
- ✅ **Image Picker**
  - Camera capture
  - Gallery selection
  - Multiple image support
- ✅ **Image Cropper**
  - Crop functionality
  - Aspect ratio control
  - Rotation support
- ✅ **Cached Network Images**
  - Fast image loading
  - Automatic caching
  - Placeholder support

### Payment Integration
- ✅ **Razorpay SDK**
  - Credit/Debit cards
  - UPI payments
  - Net banking
  - Wallets
  - Payment verification

### Third-Party Services
- ✅ **ZEGOCLOUD** - Video calls
- ✅ **Razorpay** - Payments
- ✅ **Firebase** (optional) - Push notifications
- ✅ **Google Fonts** - Typography

---

## 📊 Data Models

### User Roles
1. **ROLE_NORMAL** - Patient
2. **ROLE_DOCTOR** - Doctor

### Key Data Structures

#### Patient Profile
```dart
{
  "userId": int,
  "firstName": String,
  "lastName": String,
  "email": String,
  "phoneNumber": String,
  "dateOfBirth": String,
  "gender": String,
  "address": String
}
```

#### Doctor Profile
```dart
{
  "doctorId": int,
  "name": String,
  "email": String,
  "phoneNumber": String,
  "special": List<String>,
  "qualification": String,
  "experience": String,
  "hospitalName": String,
  "onlineConsultation": int,
  "offlineConsultation": int,
  "imageUrl": String
}
```

#### Appointment
```dart
{
  "appointmentId": int,
  "patientId": int,
  "doctorId": int,
  "appointmentDate": String,
  "timeSlot": String,
  "consultationType": String, // "ONLINE" | "OFFLINE"
  "status": String, // "PENDING" | "CONFIRMED" | "COMPLETED" | "CANCELLED"
  "paymentStatus": String
}
```

#### Diagnosis
```dart
{
  "diagnosisId": int,
  "userId": int,
  "diseaseName": String,
  "imageUrl": String,
  "confidence": double,
  "createdAt": String,
  "recommendations": List<String>
}
```

---

## 🔐 Security Features

### Authentication
- ✅ JWT token-based authentication
- ✅ Secure password storage
- ✅ Token expiration handling
- ✅ Automatic token refresh

### Authorization
- ✅ Role-based access control
- ✅ Route protection
- ✅ API endpoint authorization
- ✅ Profile-specific data access

### Data Protection
- ✅ HTTPS communication
- ✅ Secure API calls
- ✅ Encrypted local storage
- ✅ Session timeout

---

## 📱 Platform Support

### Android
- ✅ Android 5.0+ (API 21+)
- ✅ Material Design compliance
- ✅ Native features integration
- ✅ Push notifications
- ✅ Camera access
- ✅ File storage

### iOS (Potential)
- 🔄 iOS 12.0+
- 🔄 Cupertino widgets
- 🔄 Apple guidelines compliance

---

## 🚀 Performance Optimizations

- ✅ **Image Caching** - Fast loading with cached_network_image
- ✅ **Lazy Loading** - Load data on demand
- ✅ **Code Splitting** - Modular architecture
- ✅ **Asset Optimization** - Tree-shaken icons
- ✅ **Memory Management** - Proper disposal
- ✅ **Network Optimization** - Efficient API calls

---

## 📦 Dependencies & Packages

### Core Dependencies
- `flutter` - Framework
- `http` - HTTP requests
- `shared_preferences` - Local storage
- `provider` - State management (if used)

### UI/UX Packages
- `google_nav_bar` - Bottom navigation
- `flutter_spinkit` - Loading animations
- `lottie` - Lottie animations
- `cached_network_image` - Image caching
- `smooth_page_indicator` - Page indicators
- `table_calendar` - Calendar widget

### Media & Files
- `image_picker` - Camera/gallery
- `image_cropper` - Image cropping
- `file_picker` - File selection
- `camera` - Camera access

### Communication
- `flutter_webrtc` - Video calls
- `stomp_dart_client` - WebSocket chat
- `zego_uikit_prebuilt_call` - Video UI
- `audioplayers` - Audio playback

### Payment
- `razorpay_flutter` - Payment gateway

### Utilities
- `intl` - Date formatting
- `uuid` - Unique IDs
- `permission_handler` - Permissions

---

## 🎯 Key User Journeys

### Patient Journey
1. **Registration** → Profile Setup → Home Dashboard
2. **Diagnosis** → Camera/Upload → AI Analysis → Results → Doctor Suggestion
3. **Find Doctor** → Search/Filter → View Profile → Book Appointment
4. **Appointment** → Select Slot → Payment → Confirmation
5. **Consultation** → Join Video Call → Chat → Receive Prescription

### Doctor Journey
1. **Registration** → 4-Step Wizard → Profile Verification
2. **Dashboard** → View Appointments → Manage Schedule
3. **Availability** → Set Time Slots → Block Dates
4. **Patient Consultation** → Accept Appointment → Join Video Call
5. **Prescription** → Create Prescription → Send to Patient

---

## 🔄 Recent Updates & Fixes

### Latest Features (Current Version)
- ✅ **Full Name Display** - Shows patient/doctor full name instead of email
- ✅ **Editable Profiles** - Both patient and doctor can edit profiles
- ✅ **Role-Based Navigation** - Proper routing after login
- ✅ **Removed Debug Buttons** - Cleaned "Go to Second Page" button
- ✅ **Disease History** - View past diagnoses with details
- ✅ **Enhanced Error Handling** - Better API error messages
- ✅ **Debug Logging** - Doctor list fetch diagnostics

### Bug Fixes
- ✅ Fixed profile loading based on user role
- ✅ Fixed logout to clear all session data
- ✅ Fixed profile edit navigation
- ✅ Fixed compilation errors
- ✅ Fixed missing disease detail page

---

## 📄 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout

### Patient APIs
- `GET /api/profile/get-userProfile` - Get patient profile
- `PUT /api/profile/updateProfile` - Update patient profile
- `POST /api/diagnosis/upload` - Upload skin image
- `GET /api/diagnosis/history` - Get diagnosis history

### Doctor APIs
- `GET /api/doctors/get-all-doctors` - Get all doctors
- `GET /api/doctors/get-doctor-profile` - Get doctor profile
- `PUT /api/doctors/update-profile` - Update doctor profile
- `GET /api/doctors/{id}/availability` - Get doctor availability
- `POST /api/doctors/availability` - Set availability

### Appointment APIs
- `POST /api/appointments/book` - Book appointment
- `GET /api/appointments/patient/{id}` - Get patient appointments
- `GET /api/appointments/doctor/{id}` - Get doctor appointments
- `PUT /api/appointments/{id}/status` - Update appointment status

---

## 🏗️ Project Structure

```
lib/
├── Api/
│   └── ApiService.dart          # API integration layer
├── BottomPages/
│   ├── BottomNav.dart           # Bottom navigation (Patient)
│   ├── mainhomepage.dart        # Patient home dashboard
│   ├── profilepage.dart         # Profile page
│   ├── chatPage.dart            # Chat interface
│   ├── CameraIconPage.dart      # Camera/upload page
│   └── searchCompPage.dart      # Article search
├── Doctor/
│   ├── DoctorBottomNav.dart     # Doctor navigation
│   ├── DoctorDashboard.dart     # Doctor home
│   ├── DoctorAppointments.dart  # Appointment management
│   ├── DoctorAvailability.dart  # Time slot management
│   └── VideoConsultationRoom.dart # Video call (doctor)
├── Patient/
│   ├── DermatologyDoctorSearch.dart # Find doctors
│   ├── PatientAppointments.dart     # Patient appointments
│   └── DoctorSearchPage.dart        # Doctor search (legacy)
├── Otherspages/
│   ├── AppointmentSlotsAndPayment.dart # Booking flow
│   ├── EditProfilePage.dart     # Edit profile (universal)
│   ├── DiagonisesResultPage.dart # AI results
│   ├── DiseaseHistoryPage.dart  # Diagnosis history
│   ├── preiviodiagdetailedpage.dart # History details
│   ├── DoctorProfilePage.dart   # Doctor profile view
│   ├── NotificationPage.dart    # Notifications
│   └── Completeprofile.dart     # Profile completion
├── Signup/
│   ├── LoginPage.dart           # Login screen
│   ├── Register.dart            # Patient registration
│   ├── DoctorRegistrationComplete.dart # Doctor registration wizard
│   └── onboarding_view.dart     # Onboarding screens
├── Components/
│   ├── app_theme.dart           # Theme configuration
│   └── color.dart               # Color constants
└── main.dart                    # App entry point
```

---

## 🎓 Usage Instructions

### For Patients
1. **Register** → Enter details → Complete profile
2. **Diagnose** → Click camera icon → Take/upload photo → View results
3. **Find Doctor** → Home → "Find a Dermatologist" → Select doctor
4. **Book Appointment** → Choose consultation type → Select slot → Pay
5. **Consultation** → Join video call at appointment time

### For Doctors
1. **Register** → Complete 4-step wizard → Verify profile
2. **Set Availability** → Go to Availability tab → Set time slots
3. **Manage Appointments** → View appointments → Accept/Reject
4. **Consultation** → Join video call → Prescribe treatment
5. **Track Earnings** → View dashboard → Check statistics

---

## 🐛 Known Issues & Limitations

### Current Issues
- 🔍 Book appointment may not show if doctors list is empty in database
- 🔄 Some deprecated Flutter widgets (willPopScope, withOpacity)
- 📱 iOS build not tested

### Limitations
- No offline mode
- No multi-language support
- Limited to dermatology specialization
- Requires active internet connection

---

## 🔮 Future Enhancements

### Planned Features
- [ ] Push notifications (Firebase)
- [ ] Prescription PDF generation
- [ ] Medical reports upload
- [ ] Insurance integration
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Offline diagnosis history
- [ ] Voice notes in chat
- [ ] Doctor ratings & reviews
- [ ] Advanced search filters
- [ ] Appointment reminders (SMS/Email)
- [ ] Telemedicine compliance features

---

## 📞 Support & Contact

- **Email**: support@drskin.app
- **Website**: [www.drskin.app](https://www.drskin.app)
- **GitHub**: [Repository Link](https://github.com/MohdAjeej/Dr.-Skin)

---

## 📄 License

Proprietary - All rights reserved

---

## 👥 Development Team

- **Lead Developer**: [Your Name]
- **UI/UX Designer**: [Designer Name]
- **Backend Team**: [Team Names]
- **QA Team**: [QA Names]

---

## 📊 App Statistics

- **Total Screens**: 35+
- **API Endpoints**: 20+
- **User Roles**: 2 (Patient, Doctor)
- **Specializations**: 10+ (Dermatology focused)
- **APK Size**: 132.7 MB
- **Min Android Version**: 5.0 (API 21)
- **Target Android Version**: 13 (API 33)

---

## 🎯 Version History

### v1.0.0 (Current)
- ✅ Complete patient flow
- ✅ Complete doctor flow
- ✅ AI skin diagnosis
- ✅ Video consultation
- ✅ Appointment booking
- ✅ Payment integration
- ✅ Real-time chat
- ✅ Profile management
- ✅ Role-based authentication

---

**Last Updated**: January 2025  
**Document Version**: 1.0  
**App Version**: 1.0.0
