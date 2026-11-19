# City Revival AG Church — Flutter Mobile Application (Android & iOS)

The official cross-platform mobile application for **City Revival AG Church** (Tiruchirappalli, Tamil Nadu, India), led by Senior Pastor **Rev. Dr. Jerry Daniel**.

---

## 🏛️ Sacred Modernism UI/UX Design System

The application is styled following the **Sacred Modernism** design philosophy, balancing royal ecclesiastical heritage with contemporary mobile responsiveness:

| Attribute | Value / Specification | Role |
| :--- | :--- | :--- |
| **Primary Brand** | `#6F1728` | Royal Burgundy / Wine |
| **Divine Accent** | `#D4AF37` | Metallic Gold |
| **Light Surface** | `#FBF7F0` | Warm Cream / Parchment |
| **Dark Surface** | `#0F1117` | Velvet Charcoal / Night Mode |
| **Live Badge** | `#E11D48` | Vibrant Ruby Red (pulsing animation) |
| **Headings & Scripture** | `Cinzel` / `Playfair Display` | Sacred serif elegance |
| **Body & Controls** | `Montserrat` / `Inter` | Clean legibility |
| **Tamil Scripture** | `Noto Sans Tamil` / `Mukta Malar` | 1.6 line-height for authentic readability |

---

## ⚡ The 6 Core Features Implemented

### 1. Daily Promise Verse (Tamil & English Together)
- Front-and-center card at the top of the Home Screen.
- Displays today's Scripture in **both English and Tamil stacked together** on the same card with custom borders.
- **1-Tap WhatsApp Share**: Formats both verses with church branding, reference, date, and inspirational header, opening WhatsApp directly.
- **Previous Verses Archive**: Believers can browse past daily verses and share anytime.

### 2. Instant Announcements & Push Notifications
- Integrated with `flutter_local_notifications` for phone lock screen alerts.
- Covers Fasting Prayers, Conventions, and Youth Meetings.
- **Sunday Live Broadcast Alert**: Automatic reminders before Sunday services (6:00 AM, 8:30 AM, 10:45 AM).
- Tapping any announcement flyer opens the rich details view with direct sharing.

### 3. Sunday Live Stream & Sermon Video Hub
- Dedicated live badge when Sunday service is streaming on YouTube.
- Watch past sermon series directly inside the app using `youtube_player_flutter`.
- Filter sermons by Speaker (Rev. Dr. Jerry Daniel, Pastor Joseph, Pastor Paul, or All) and Series.
- **Audio Listening Mode**: Toggle off video to save data and listen in high fidelity.
- Search sermons by English/Tamil title or scripture reference.

### 4. Paripoorana Jeevan Magazine Reader
- Displays 38+ issues grouped by Year (2026, 2025, 2024...) with period badges ('Jan - Feb', 'Nov - Dec').
- Native PDF viewer (`flutter_pdfview`) with zoom, page navigation, and fullscreen mode.
- **Download for Offline Reading**: Saves PDF locally (`path_provider` & `dio`) so church members can read anywhere without internet.
- Direct streaming support for Supabase public CDN & Google Drive links.

### 5. 1-Tap UPI Giving & Building Fund
- Direct native UPI Intent: Tapping **[Google Pay]**, **[PhonePe]**, or **[Paytm]** launches the respective UPI app with Church UPI ID (`cityrevivalag@sbi`), Account Name (`CITY REVIVAL AG CHURCH`), amount, and purpose pre-filled.
- Tap-to-copy Bank Account & IFSC details with haptic feedback & animated toast.
- **Vision 2035 Church Building Fund**: Dedicated progress visualizer (Target ₹10 Cr, Raised ₹4.35 Cr) for raising the 5,000-seat sanctuary in Tiruchirappalli.

### 6. Confidential Prayer Requests
- Private prayer submission form: Requester Name, Phone/WhatsApp, Category, Prayer Need.
- **"Submit Anonymously"** toggle switch (hides personal identity).
- Inserts directly into `public.prayer_requests` in Supabase.
- Celebratory confirmation screen with comforting Scripture promise (Philippians 4:6) and confirmation.

---

## 🛠️ Architecture & Tech Stack

```
lib/
├── app.dart                                # MaterialApp, theme config
├── main.dart                               # Entry point, Supabase & notification init
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                 # Sacred Modernism color palette
│   │   └── app_constants.dart              # Church info, UPI, timings, Supabase URLs
│   ├── network/
│   │   └── supabase_client.dart            # SupabaseClient & Riverpod providers
│   ├── services/
│   │   └── notification_service.dart       # Lock screen alerts & service reminders
│   ├── theme/
│   │   └── app_theme.dart                  # Light and Dark theme, Tamil typography
│   ├── utils/
│   │   ├── share_helper.dart               # WhatsApp status & universal share
│   │   └── upi_helper.dart                 # GPay, PhonePe, Paytm NPCI UPI launcher
│   └── widgets/
│       ├── live_badge.dart                 # Pulsing ruby red LIVE badge
│       ├── sacred_button.dart              # Royal burgundy & metallic gold button
│       ├── sacred_card.dart                # Card with gold border & parchment styling
│       └── shimmer_loading.dart            # Skeleton loader
└── features/
    ├── daily_verse/                        # Feature 1
    ├── announcements/                      # Feature 2
    ├── sermons/                            # Feature 3
    ├── magazine/                           # Feature 4
    ├── giving/                             # Feature 5
    ├── prayer/                             # Feature 6
    └── home/                               # Home feed & Bottom navigation shell
```

---

## 🚀 Getting Started

1. **Prerequisites**: Ensure Flutter 3.19+ and Dart 3.3+ are installed.
2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run on Android / iOS**:
   ```bash
   flutter run
   ```
4. **Build Release APK / Bundle**:
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```
