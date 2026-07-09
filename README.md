# Sportbook

Ứng dụng đặt sân thể thao - Flutter Mobile App.

## Project Structure
```text
lib/
├── main.dart
├── app.dart
├── firebase_options.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_constants.dart
│   │
│   ├── theme/
│   │   └── app_theme.dart
│   │
│   ├── utils/
│   │   ├── validator.dart
│   │   ├── formatter.dart
│   │   └── helpers.dart
│   │
│   └── widgets/
│       ├── app_button.dart
│       ├── app_textfield.dart
│       ├── loading.dart
│       └── empty_widget.dart
│
├── models/
│   ├── user_model.dart
│   ├── football_field_model.dart
│   ├── booking_model.dart
│   ├── review_model.dart
│   └── notification_model.dart
│
├── repositories/
│   ├── auth_repository.dart
│   ├── user_repository.dart
│   ├── field_repository.dart
│   ├── booking_repository.dart
│   └── review_repository.dart
│
├── services/
│   ├── Firebase/
│   │   ├── firebase_auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── storage_service.dart
│   │   └── notification_service.dart
│   │
│   └── SQLite/
│       ├── database_service.dart
│       ├── booking_local.dart
│       ├── field_local.dart
│       └── user_local.dart
│
├── viewmodels/
│   ├── base/
│   │   └── base_viewmodel.dart
│   ├── auth_viewmodel.dart
│   ├── home_viewmodel.dart
│   ├── field_viewmodel.dart
│   ├── booking_viewmodel.dart
│   ├── profile_viewmodel.dart
│   └── admin_viewmodel.dart
│
├── views/
│   ├── auth/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   └── forgot_password_page.dart
│   │
│   ├── home/
│   │   └── home_page.dart
│   │
│   ├── field/
│   │   ├── field_list_page.dart
│   │   ├── field_detail_page.dart
│   │   └── field_search_page.dart
│   │
│   ├── booking/
│   │   ├── booking_page.dart
│   │   ├── booking_history_page.dart
│   │   ├── booking_detail_page.dart
│   │   └── widgets/                # widget riêng cho từng màn booking
│   │
│   ├── profile/
│   │   ├── profile_page.dart
│   │   └── edit_profile_page.dart
│   │
│   └── admin/
│       ├── dashboard_page.dart
│       ├── manage_fields_page.dart
│       └── manage_bookings_page.dart
│
├── providers/
│   ├── firebase_provider.dart
│   ├── auth_provider.dart
│   ├── repository_provider.dart
│   └── viewmodel_provider.dart
│
└── routes/
    └── app_router.dart
```

## Architecture

Dự án theo mô hình **MVVM (Model – View – ViewModel) + Repository + Service**, dùng `provider` để inject dependency và `ChangeNotifier` để quản lý state.

### Luồng hoạt động

```
View ──binds──> ViewModel ──calls──> Repository ──> Service
  ▲                  │                       │
  │                  └──exposes state─────────┘
  └────────── listens via Provider ───────────┘
```

- **View** chỉ render UI và listen ViewModel. Không gọi trực tiếp Service/Repository.
- **ViewModel** chứa business logic và state (loading, error, data). Extend `BaseViewModel` (đặt trong `viewmodels/base/`).
- **Repository** tổng hợp nguồn dữ liệu (Firebase + SQLite cache) và cung cấp API duy nhất cho ViewModel.
- **Service** chỉ lo I/O thuần (Firestore, sqflite, FCM). Không chứa business rule.

### Quy ước từng tầng

| Tầng | Được phép | Không được |
| --- | --- | --- |
| **Model** | `toJson`/`fromJson`, `copyWith`, `==` | Import service, repo |
| **Service** | Raw I/O (Firestore, sqflite, FCM) | Business rule, format UI |
| **Repository** | Combine remote + local cache, đồng bộ dữ liệu | Biết về `BuildContext`, UI state |
| **ViewModel** | Gọi repository, quản lý state, điều phối nhiều repo | Chứa `Widget`, import `material.dart` (trừ `ChangeNotifier`) |
| **View** | `context.read/watch<VM>()`, widget tái sử dụng | Gọi service/repo trực tiếp, hard-code logic |

### State shape chuẩn trong ViewModel

```dart
abstract class BaseViewModel extends ChangeNotifier {
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  void setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void setError(String? msg) {
    _error = msg;
    notifyListeners();
  }
}
```

Mỗi ViewModel cụ thể (`BookingViewModel`, `AuthViewModel`, …) extend `BaseViewModel` và thêm state riêng (`bookings`, `user`, `fields`…).

### Ví dụ: User bấm "Đặt sân"

```
BookingPage (view)
  └─ onPressed -> context.read<BookingViewModel>().bookSlot(fieldId, time)
       │
       ▼
BookingViewModel
  ├─ setState(loading = true)
  └─ await bookingRepository.createBooking(...)
       │
       ▼
BookingRepository
  ├─ firestoreService.create(...)    // remote
  └─ bookingLocal.insert(...)        // local cache
       │
       ▼
ViewModel nhận result
  ├─ setState(loading = false, success = true)
  └─ notifyListeners()
       │
       ▼
BookingPage rebuild qua Consumer/Selector
```

### Dependency Injection

DI qua `lib/providers/` (khai báo trong `app.dart` với `MultiProvider`):

```dart
final repositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(
    remote: FirestoreService(),
    local: BookingLocal(DatabaseService.instance),
  );
});

final bookingViewModelProvider = ChangeNotifierProvider(
  (ref) => BookingViewModel(ref.read(repositoryProvider)),
);
```

### Checklist khi tạo feature mới

1. Tạo `Model` trong `models/` (toJson/fromJson).
2. Tạo `Service` nếu cần I/O mới (Firebase/SQLite).
3. Tạo `Repository` kết hợp service + cache.
4. Tạo `ViewModel` extend `BaseViewModel`, expose state + intents.
5. Đăng ký Provider trong `viewmodel_provider.dart`.
6. Tạo `Page` trong `views/<feature>/`, dùng `Consumer`/`Selector` để listen.
7. Thêm route trong `routes/app_router.dart`.
8. Nếu widget con phức tạp -> tách vào `views/<feature>/widgets/`.
9. Nếu widget có thể dùng cho feature khác -> đẩy lên `core/widgets/`.
