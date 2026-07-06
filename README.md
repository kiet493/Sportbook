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
│   │   └── booking_detail_page.dart
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