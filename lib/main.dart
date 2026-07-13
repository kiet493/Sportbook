import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/venue.dart';
import 'models/court_booking.dart';
import 'models/user_model.dart';
import 'firebase_options.dart';
import 'providers/firebase_providers.dart';
import 'providers/registration_providers.dart';
import 'routes/app_router.dart';
import 'views/admin/manage_users_page.dart';
import 'views/admin/manage_venues_page.dart';
import 'views/onboarding/onboarding_page.dart';
import 'views/auth/login_page.dart';
import 'views/auth/register_page.dart';
import 'views/home/home_page.dart';
import 'views/field/field_search_page.dart';
import 'views/field/favorites_page.dart';
import 'views/profile/profile_page.dart';
import 'views/field/field_detail_page.dart';
import 'views/booking/booking_page.dart';
import 'views/booking/booking_success_page.dart';
import 'views/booking/booking_history_page.dart';
import 'views/booking/booking_detail_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseStartupError = await _initializeFirebase();

  runApp(
    ProviderScope(
      overrides: [
        firebaseStartupErrorProvider.overrideWithValue(firebaseStartupError),
      ],
      child: const MyApp(),
    ),
  );
}

Future<String?> _initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    return null;
  } on StateError catch (e) {
    return e.message;
  } on FirebaseException catch (e) {
    return e.message ?? 'Không thể khởi tạo Firebase (${e.code})';
  } catch (e) {
    return 'Không thể khởi tạo Firebase: $e';
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportBook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const AppController(),
    );
  }
}

class AppController extends ConsumerStatefulWidget {
  const AppController({super.key});

  @override
  ConsumerState<AppController> createState() => _AppControllerState();
}

class _AppControllerState extends ConsumerState<AppController> {
  String _phase = "onboarding";
  String _screen =
      "home"; // home, search, history, favorites, profile, detail, booking, success, booking-detail

  Venue? _selectedVenue;
  late BookingInfo _selectedBooking;
  CourtBooking? _lastCreatedBooking;

  @override
  void initState() {
    super.initState();
    _selectedBooking = MOCK_BOOKINGS[0];
  }

  void _transitionPhase(String to) {
    setState(() {
      _phase = to;
      _screen = _initialScreenForPhase(to);
    });
  }

  String _initialScreenForPhase(String phase) {
    if (phase != "home") return "home";

    final user = ref.read(sessionProvider)?.user;
    if (user != null && user.isAdmin && !user.isBanned) {
      return "admin";
    }

    return "home";
  }

  void _goScreen(String s) {
    setState(() {
      _screen = s;
    });
  }

  void _goVenue(Venue v) {
    setState(() {
      _selectedVenue = v;
      _screen = "detail";
    });
  }

  void _goBooking() {
    if (_selectedVenue == null) return;
    setState(() {
      _screen = "booking";
    });
  }

  void _goSuccess() {
    setState(() {
      _screen = "success";
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activeWidget;

    if (_phase == "onboarding") {
      activeWidget = OnboardingPage(
        onComplete: () => _transitionPhase("login"),
        onSignIn: () => _transitionPhase("login"),
      );
    } else if (_phase == "login") {
      activeWidget = LoginPage(
        onSuccess: () => _transitionPhase("home"),
        onRegister: () => _transitionPhase("register"),
      );
    } else if (_phase == "register") {
      activeWidget = RegisterPage(
        onSuccess: () => _transitionPhase("login"),
        onLogin: () => _transitionPhase("login"),
      );
    } else {
      switch (_screen) {
        case "home":
          activeWidget = HomePage(
            onVenueTap: _goVenue,
            onNav: _goScreen,
            activeNav: _screen,
          );
          break;
        case "search":
          activeWidget = FieldSearchPage(
            onBack: () => _goScreen("home"),
            onVenueTap: _goVenue,
            onNav: _goScreen,
            activeNav: _screen,
          );
          break;
        case "history":
          activeWidget = BookingHistoryPage(
            onBack: () => _goScreen("home"),
            onViewDetail: (b) {
              setState(() {
                _selectedBooking = b;
                _screen = "booking-detail";
              });
            },
            onNav: _goScreen,
            activeNav: _screen,
          );
          break;
        case "booking-detail":
          activeWidget = BookingDetailPage(
            booking: _selectedBooking,
            onBack: () => _goScreen("history"),
          );
          break;
        case "favorites":
          activeWidget = FavoritesPage(onNav: _goScreen, activeNav: _screen);
          break;
        case "profile":
          activeWidget = ProfilePage(
            onNav: _goScreen,
            activeNav: _screen,
            onLogout: () => _transitionPhase("login"),
          );
          break;
        case "admin":
          activeWidget = RoleGuard(
            requiredRole: UserRole.admin,
            child: ManageUsersPage(onBack: () => _goScreen("home")),
          );
          break;
        case "manage-venues":
          activeWidget = RoleGuard(
            requiredRole: UserRole.staff,
            child: ManageVenuesPage(onBack: () => _goScreen("profile")),
          );
          break;
        case "detail":
          final venue = _selectedVenue;
          activeWidget = venue == null
              ? HomePage(
                  onVenueTap: _goVenue,
                  onNav: _goScreen,
                  activeNav: "home",
                )
              : FieldDetailPage(
                  venue: venue,
                  onBack: () => _goScreen("home"),
                  onBook: _goBooking,
                  onVenueTap: _goVenue,
                  onNav: _goScreen,
                  activeNav: "home",
                );
          break;
        case "booking":
          final venue = _selectedVenue;
          activeWidget = venue == null
              ? HomePage(
                  onVenueTap: _goVenue,
                  onNav: _goScreen,
                  activeNav: "home",
                )
              : BookingPage(
                  venue: venue,
                  onBack: () => _goScreen("detail"),
                  onConfirm: (booking) {
                    _lastCreatedBooking = booking;
                    _goSuccess();
                  },
                );
          break;
        case "success":
          final venue = _selectedVenue;
          activeWidget = venue == null
              ? HomePage(
                  onVenueTap: _goVenue,
                  onNav: _goScreen,
                  activeNav: "home",
                )
              : BookingSuccessPage(
                  venue: venue,
                  onHome: () => _goScreen("home"),
                  onViewBooking: () {
                    setState(() {
                      _selectedBooking = _lastCreatedBooking == null
                          ? MOCK_BOOKINGS[0]
                          : BookingInfo(
                              id: _lastCreatedBooking!.id,
                              venue: venue,
                              date: _lastCreatedBooking!.dateKey,
                              time: _lastCreatedBooking!.timeRange,
                              status: _lastCreatedBooking!.status,
                              amount: "${_lastCreatedBooking!.totalPrice}đ",
                              court: _lastCreatedBooking!.courtName,
                            );
                      _screen = "booking-detail";
                    });
                  },
                );
          break;
        default:
          activeWidget = HomePage(
            onVenueTap: _goVenue,
            onNav: _goScreen,
            activeNav: "home",
          );
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 40, spreadRadius: 2),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0.0, 0.03),
                end: Offset.zero,
              ).animate(animation);

              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey("$_phase-$_screen"),
              child: activeWidget,
            ),
          ),
        ),
      ),
    );
  }
}
