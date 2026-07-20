import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/venue.dart';
import 'models/court_booking.dart';
import 'models/user_model.dart';
import 'models/community_models.dart';
import 'firebase_options.dart';
import 'providers/firebase_providers.dart';
import 'providers/booking_providers.dart';
import 'providers/registration_providers.dart';
import 'routes/app_router.dart';
import 'services/Firebase/firebase_functions_client.dart';
import 'views/admin/admin_dashboard_page.dart';
import 'views/admin/manage_venues_page.dart';
import 'views/onboarding/onboarding_page.dart';
import 'views/auth/login_page.dart';
import 'views/auth/register_page.dart';
import 'views/auth/forgot_password_page.dart';
import 'views/auth/splash_page.dart';
import 'views/home/home_page.dart';
import 'views/field/field_list_page.dart';
import 'views/field/favorites_page.dart';
import 'views/profile/profile_page.dart';
import 'views/profile/change_password_page.dart';
import 'views/profile/edit_profile_page.dart';
import 'views/event/event_detail_page.dart';
import 'views/event/event_list_page.dart';
import 'views/event/join_event_page.dart';
import 'views/event/create_event_page.dart';
import 'views/matchmaking/create_matchmaking_page.dart';
import 'views/matchmaking/matchmaking_detail_page.dart';
import 'views/matchmaking/matchmaking_list_page.dart';
import 'views/field/field_detail_page.dart';
import 'views/booking/booking_page.dart';
import 'views/booking/booking_success_page.dart';
import 'views/booking/booking_history_page.dart';
import 'views/booking/booking_detail_page.dart';
import 'views/payment/payment_page.dart';
import 'views/payment/transaction_history_page.dart';
import 'views/notification/notifications_page.dart';
import 'views/staff/staff_dashboard_page.dart';
import 'views/news/news_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseStartupError = await _initializeFirebase();
  if (firebaseStartupError == null && kDebugMode) {
    functions.useFunctionsEmulator(
      functionsEmulatorHost,
      functionsEmulatorPort,
    );
  }

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
  String _phase = "splash";
  String _screen =
      "home"; // home, search, history, favorites, profile, detail, booking, success, booking-detail

  Venue? _selectedVenue;
  BookingInfo? _selectedBooking;
  CourtBooking? _lastCreatedBooking;
  List<CourtBooking> _lastCreatedBookings = const [];
  SportEvent? _selectedEvent;
  MatchmakingRoom? _selectedRoom;

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
    if (user != null && user.isStaff && !user.isBanned) {
      return "staff";
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

  void _rebook(Venue venue) {
    setState(() {
      _selectedVenue = venue;
      _lastCreatedBooking = null;
      _lastCreatedBookings = const [];
      _screen = 'booking';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activeWidget;

    if (_phase == "splash") {
      activeWidget = SplashPage(
        onComplete: () => _transitionPhase("onboarding"),
      );
    } else if (_phase == "onboarding") {
      activeWidget = OnboardingPage(
        onComplete: () => _transitionPhase("login"),
        onSignIn: () => _transitionPhase("login"),
      );
    } else if (_phase == "login") {
      activeWidget = LoginPage(
        onSuccess: () => _transitionPhase("home"),
        onRegister: () => _transitionPhase("register"),
        onForgotPassword: () => _transitionPhase("forgot-password"),
      );
    } else if (_phase == "forgot-password") {
      activeWidget = ForgotPasswordPage(
        onBack: () => _transitionPhase("login"),
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
          activeWidget = FieldListPage(
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
            onRebook: _rebook,
            onNav: _goScreen,
            activeNav: _screen,
          );
          break;
        case "booking-detail":
          final booking = _selectedBooking;
          activeWidget = booking == null
              ? BookingHistoryPage(
                  onBack: () => _goScreen('home'),
                  onViewDetail: (selected) {
                    setState(() => _selectedBooking = selected);
                  },
                  onRebook: _rebook,
                  onNav: _goScreen,
                  activeNav: 'history',
                )
              : BookingDetailPage(
                  booking: booking,
                  onBack: () => _goScreen("history"),
                  onRebook: () => _rebook(booking.venue),
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
        case "edit-profile":
          activeWidget = EditProfilePage(onBack: () => _goScreen("profile"));
          break;
        case "change-password":
          activeWidget = ChangePasswordPage(onBack: () => _goScreen("profile"));
          break;
        case "events":
          activeWidget = EventListPage(
            onBack: () => _goScreen("home"),
            onOpenEvent: (event) {
              setState(() {
                _selectedEvent = event;
                _screen = "event-detail";
              });
            },
            onOpenMatchmaking: () => _goScreen("matchmaking"),
            onCreate: () => _goScreen("create-event"),
          );
          break;
        case "create-event":
          activeWidget = CreateEventPage(
            onBack: () => _goScreen("events"),
            onCreated: (event) {
              setState(() {
                _selectedEvent = event;
                _screen = "event-payment";
              });
            },
          );
          break;
        case "event-payment":
          final event = _selectedEvent;
          activeWidget = event == null
              ? EventListPage(
                  onBack: () => _goScreen("home"),
                  onOpenEvent: (selected) {
                    setState(() {
                      _selectedEvent = selected;
                      _screen = "event-detail";
                    });
                  },
                  onOpenMatchmaking: () => _goScreen("matchmaking"),
                  onCreate: () => _goScreen("create-event"),
                )
              : PaymentPage(
                  event: event,
                  onBack: () => _goScreen("create-event"),
                  onPaid: (_) => _goScreen("events"),
                );
          break;
        case "event-detail":
          final event = _selectedEvent;
          activeWidget = event == null
              ? EventListPage(
                  onBack: () => _goScreen("home"),
                  onOpenEvent: (selected) {
                    setState(() => _selectedEvent = selected);
                  },
                  onOpenMatchmaking: () => _goScreen("matchmaking"),
                  onCreate: () => _goScreen("create-event"),
                )
              : EventDetailPage(
                  event: event,
                  onBack: () => _goScreen("events"),
                  onJoin: () => _goScreen("join-event"),
                );
          break;
        case "join-event":
          final event = _selectedEvent;
          activeWidget = event == null
              ? EventListPage(
                  onBack: () => _goScreen("home"),
                  onOpenEvent: (_) {},
                  onOpenMatchmaking: () => _goScreen("matchmaking"),
                  onCreate: () => _goScreen("create-event"),
                )
              : JoinEventPage(
                  event: event,
                  onBack: () => _goScreen("event-detail"),
                  onSuccess: () => _goScreen("events"),
                );
          break;
        case "matchmaking":
          activeWidget = MatchmakingListPage(
            onBack: () => _goScreen("home"),
            onCreate: () => _goScreen("create-matchmaking"),
            onOpenRoom: (room) {
              setState(() {
                _selectedRoom = room;
                _screen = "matchmaking-detail";
              });
            },
            onOpenEvents: () => _goScreen("events"),
          );
          break;
        case "create-matchmaking":
          activeWidget = CreateMatchmakingPage(
            onBack: () => _goScreen("matchmaking"),
            onBookCourt: () => _goScreen("search"),
            onCreated: (room) {
              setState(() {
                _selectedRoom = room;
                _screen = "matchmaking-detail";
              });
            },
          );
          break;
        case "matchmaking-detail":
          final room = _selectedRoom;
          activeWidget = room == null
              ? MatchmakingListPage(
                  onBack: () => _goScreen("home"),
                  onCreate: () => _goScreen("create-matchmaking"),
                  onOpenRoom: (_) {},
                  onOpenEvents: () => _goScreen("events"),
                )
              : MatchmakingDetailPage(
                  room: room,
                  onBack: () => _goScreen("matchmaking"),
                );
          break;
        case "admin":
          activeWidget = RoleGuard(
            requiredRole: UserRole.admin,
            child: AdminDashboardPage(
              onLogout: () => _transitionPhase('login'),
            ),
          );
          break;
        case "staff":
          activeWidget = RoleGuard(
            requiredRole: UserRole.staff,
            child: StaffDashboardPage(
              onLogout: () => _transitionPhase('login'),
            ),
          );
          break;
        case "manage-venues":
          activeWidget = RoleGuard(
            requiredRole: UserRole.admin,
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
                  onConfirm: (bookings) {
                    final booking = bookings.first;
                    final checkoutBooking = booking.copyWith(
                      totalPrice: bookings.fold<int>(
                        0,
                        (total, item) => total + item.totalPrice,
                      ),
                    );
                    setState(() {
                      _lastCreatedBooking = checkoutBooking;
                      _lastCreatedBookings = bookings;
                      _selectedBooking = bookingInfoFromCourtBooking(
                        checkoutBooking,
                        venue: venue,
                      );
                      _screen = 'payment';
                    });
                  },
                );
          break;
        case "payment":
          activeWidget = _lastCreatedBookings.isEmpty
              ? HomePage(
                  onVenueTap: _goVenue,
                  onNav: _goScreen,
                  activeNav: "home",
                )
              : PaymentPage(
                  bookings: _lastCreatedBookings,
                  onBack: () => _goScreen('booking'),
                  onPaid: (_) => _goScreen('success'),
                );
          break;
        case "transactions":
          activeWidget = TransactionHistoryPage(
            onBack: () => _goScreen('profile'),
          );
          break;
        case "notifications":
          activeWidget = NotificationsPage(onBack: () => _goScreen('home'));
          break;
        case "news":
          activeWidget = NewsPage(onBack: () => _goScreen('home'));
          break;
        case "success":
          final venue = _selectedVenue;
          final createdBooking = _lastCreatedBooking;
          activeWidget = venue == null || createdBooking == null
              ? HomePage(
                  onVenueTap: _goVenue,
                  onNav: _goScreen,
                  activeNav: "home",
                )
              : BookingSuccessPage(
                  venue: venue,
                  booking: createdBooking,
                  onHome: () => _goScreen("home"),
                  onViewBooking: () {
                    _goScreen("booking-detail");
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
