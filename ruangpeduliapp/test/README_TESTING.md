# Testing Structure untuk Fitur Masyarakat - Ruang Peduli

Dokumentasi lengkap struktur testing untuk semua fitur masyarakat di aplikasi Ruang Peduli.

## 📁 Struktur Folder

```
test/
├── unit/
│   └── masyarakat/
│       ├── services/
│       │   ├── masyarakat_service_test.dart
│       │   ├── chatbot_service_test.dart
│       │   └── donation_service_test.dart
│       └── models/
│           ├── panti_model_test.dart
│           ├── kebutuhan_model_test.dart
│           └── donation_model_test.dart
├── widget/
│   └── masyarakat/
│       └── screens/
│           ├── home/
│           │   ├── home_masyarakat_screen_test.dart
│           │   ├── panti_detail_screen_test.dart
│           │   ├── kebutuhan_screen_test.dart
│           │   ├── berita_detail_screen_test.dart
│           │   └── video_player_screen_test.dart
│           ├── chatbot/
│           │   └── chatbot_masyarakat_screen_test.dart
│           ├── profile/
│           │   ├── profile_screen_test.dart
│           │   └── edit_profil_screen_test.dart
│           ├── search/
│           │   └── search_screen_test.dart
│           ├── notification/
│           │   └── notification_screen_test.dart
│           ├── history/
│           │   └── history_screen_test.dart
│           └── transaksi/
│               └── transaksi_screen_test.dart
├── test_helpers.dart        # Helper functions untuk testing
└── mock_data.dart          # Mock data untuk testing
```

## 🎯 Jenis Testing

### 1. Unit Tests (`unit/masyarakat/`)
Unit tests untuk menguji business logic tanpa UI:
- **Services**: API calls, data processing, business logic
- **Models**: Data serialization/deserialization, validation

### 2. Widget Tests (`widget/masyarakat/`)
Widget tests untuk menguji UI components dan interactions:
- Screen rendering
- User interactions (tap, scroll, input)
- Navigation
- State management
- Error handling

## 📝 File Testing untuk Setiap Fitur

### Home Screen (`home_masyarakat_screen_test.dart`)
**Purpose**: Menguji tampilan utama aplikasi masyarakat
**Test Coverage**:
- Screen rendering
- Display list panti, berita, kebutuhan
- Navigation ke detail screens
- Loading & error states

**Related Files**:
- `lib/masyarakat/home/home_masyarakat_screen.dart`

### Panti Detail Screen (`panti_detail_screen_test.dart`)
**Purpose**: Menguji detail informasi panti
**Test Coverage**:
- Display panti information
- Contact functionality (call, email)
- Location navigation
- Donation button
- Image display

**Related Files**:
- `lib/masyarakat/home/panti_detail_screen.dart`

### Kebutuhan Screen (`kebutuhan_screen_test.dart`)
**Purpose**: Menguji tampilan kebutuhan/needs
**Test Coverage**:
- List kebutuhan display
- Filtering & sorting
- Progress bar display
- Detail navigation
- Empty state handling

**Related Files**:
- `lib/masyarakat/home/kebutuhan_screen.dart`

### Berita Detail Screen (`berita_detail_screen_test.dart`)
**Purpose**: Menguji tampilan detail berita
**Test Coverage**:
- Content display with markdown
- Image handling
- Share functionality
- Like/bookmark feature
- Related articles

**Related Files**:
- `lib/masyarakat/home/berita_detail_screen.dart`

### Video Player Screen (`video_player_screen_test.dart`)
**Purpose**: Menguji video player functionality
**Test Coverage**:
- Video playback controls
- Fullscreen mode
- Progress tracking
- Volume control
- Error handling

**Related Files**:
- `lib/masyarakat/home/video_player_screen.dart`

### Chatbot Screen (`chatbot_masyarakat_screen_test.dart`)
**Purpose**: Menguji AI chatbot interface
**Test Coverage**:
- Message sending/receiving
- Bot response display
- Typing indicator
- Quick replies
- Chat history
- Suggestions display

**Related Files**:
- `lib/masyarakat/chatbot/chatbot_masyarakat_screen.dart`

### Profile Screen (`profile_screen_test.dart`)
**Purpose**: Menguji tampilan profil pengguna
**Test Coverage**:
- Profile info display
- Donation history
- User statistics
- Edit profile navigation
- Logout functionality

**Related Files**:
- `lib/masyarakat/profile/profile_screen.dart`

### Edit Profile Screen (`edit_profil_screen_test.dart`)
**Purpose**: Menguji edit profil pengguna
**Test Coverage**:
- Form field editing
- Image upload
- Form validation
- Save/cancel actions
- Success/error messages

**Related Files**:
- `lib/masyarakat/profile/edit_profil_screen.dart`

### Search Screen (`search_screen_test.dart`)
**Purpose**: Menguji fitur pencarian
**Test Coverage**:
- Search input
- Results display
- Filtering options
- Search history
- Navigation to results

**Related Files**:
- `lib/masyarakat/search/` (assumsi)

### Notification Screen (`notification_screen_test.dart`)
**Purpose**: Menguji tampilan notifikasi
**Test Coverage**:
- Notification list display
- Mark as read/unread
- Delete notification
- Notification filtering
- Empty state

**Related Files**:
- `lib/masyarakat/notification/` (assumsi)

### History Screen (`history_screen_test.dart`)
**Purpose**: Menguji history/riwayat tayang
**Test Coverage**:
- History list display
- Sort by recent
- Item removal
- Clear all functionality
- Search in history

**Related Files**:
- `lib/masyarakat/history/` (assumsi)

### Transaksi Screen (`transaksi_screen_test.dart`)
**Purpose**: Menguji tampilan riwayat donasi
**Test Coverage**:
- Transaction list display
- Status display
- Filtering & sorting
- Receipt download
- Statistics display
- Retry failed donation

**Related Files**:
- `lib/masyarakat/transaksi/` (assumsi)

## 🛠️ Helper Functions & Mock Data

### test_helpers.dart
Helper functions untuk mempermudah writing tests:

```dart
// Build widget untuk testing
buildTestableWidget(Widget widget)
buildTestableWidgetWithTheme({required Widget widget, ThemeData? theme})
pumpWidgetAndSettle(WidgetTester tester, Widget widget)

// Finding widgets
findText(String text)
findButton(String label)

// Interactions
tapWidget(WidgetTester tester, Finder finder)
enterText(WidgetTester tester, String text)
scrollToWidget(WidgetTester tester, Finder finder)
waitForWidget(WidgetTester tester, Finder finder)
```

### mock_data.dart
Constant mock data untuk testing:

```dart
// Mock lists
mockPantiList
mockKebutuhanList
mockBeritaList
mockDonationHistory
mockUserProfile
mockChatHistory
mockNotifications

// Helper functions
createMockPanti({...})
createMockKebutuhan({...})
createMockDonation({...})
```

## 🚀 Cara Menjalankan Tests

### Run semua tests
```bash
flutter test
```

### Run tests spesifik folder
```bash
flutter test test/widget/masyarakat/screens/home/
flutter test test/unit/masyarakat/services/
```

### Run test file tertentu
```bash
flutter test test/widget/masyarakat/screens/home/home_masyarakat_screen_test.dart
```

### Run dengan coverage
```bash
flutter test --coverage
```

### Watch mode (auto rerun ketika ada perubahan)
```bash
flutter test --watch
```

## 📊 Test Coverage

Target coverage untuk fitur masyarakat:
- **Unit Tests**: 80%+ coverage untuk services & models
- **Widget Tests**: 70%+ coverage untuk UI screens
- **Overall**: 75%+ coverage untuk seluruh layer

## 🎓 Best Practices

### 1. Widget Testing
```dart
testWidgets('Widget renders correctly', (WidgetTester tester) async {
  await pumpWidgetAndSettle(tester, MyWidget());
  expect(find.byType(MyWidget), findsOneWidget);
});
```

### 2. Unit Testing
```dart
test('Service function returns correct data', () async {
  final result = await myService.getData();
  expect(result, isNotNull);
  expect(result.id, 1);
});
```

### 3. Using Mock Data
```dart
import 'package:ruangpeduliapp/test/mock_data.dart';

testWidgets('Display mock panti list', (WidgetTester tester) async {
  // Gunakan mockPantiList dari mock_data.dart
  expect(mockPantiList, isNotEmpty);
});
```

### 4. Testing Async Operations
```dart
testWidgets('Async operation completes', (WidgetTester tester) async {
  await future;
  await tester.pumpAndSettle();
  expect(result, expectedValue);
});
```

## 📚 Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Widget Testing Guide](https://flutter.dev/docs/testing/ui-testing)
- [Unit Testing Guide](https://flutter.dev/docs/testing/unit-testing)
- [Test Package Documentation](https://pub.dev/packages/test)

## ✅ Next Steps

1. Implement actual test cases dalam template files
2. Mock dependencies (API calls, services)
3. Integrate dengan CI/CD pipeline
4. Setup coverage reporting
5. Add integration tests untuk user flows

## 📝 Notes

- Semua test files diberi suffix `_test.dart`
- Gunakan descriptive test names
- Satu test file untuk satu screen/service
- Update tests ketika ada perubahan pada feature
- Maintain test coverage above 75%

---

**Created**: May 5, 2026  
**Version**: 1.0.0  
**Project**: Ruang Peduli - Mobile App Testing
