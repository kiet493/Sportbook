import 'package:flutter/material.dart';
import 'models/venue.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/success_screen.dart';
import 'screens/booking_history_screen.dart';
import 'views/booking/booking_detail_page.dart';

void main() {
  runApp(const MyApp());
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
      home: const AppController(),
    );
  }
}

class AppController extends StatefulWidget {
  const AppController({super.key});

  @override
  State<AppController> createState() => _AppControllerState();
}

class _AppControllerState extends State<AppController> {
  String _phase = "onboarding"; // onboarding, login, register, home
  String _screen =
      "home"; // home, search, history, favorites, profile, detail, booking, success, booking-detail

  late Venue _selectedVenue;
  late BookingInfo _selectedBooking;

  @override
  void initState() {
    super.initState();
    // Default initial selections
    _selectedVenue = VENUES[0];
    _selectedBooking = MOCK_BOOKINGS[0];
  }

  void _transitionPhase(String to) {
    setState(() {
      _phase = to;
      _screen = "home"; // Reset sub screen on phase change
    });
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

    // 1. Onboarding Phase
    if (_phase == "onboarding") {
      activeWidget = OnboardingScreen(
        onComplete: () => _transitionPhase("login"),
        onSignIn: () => _transitionPhase("login"),
      );
    }
    // 2. Login Phase
    else if (_phase == "login") {
      activeWidget = LoginScreen(
        onSuccess: () => _transitionPhase("home"),
        onRegister: () => _transitionPhase("register"),
      );
    }
    // 3. Register Phase
    else if (_phase == "register") {
      activeWidget = RegisterScreen(
        onSuccess: () => _transitionPhase("login"),
        onLogin: () => _transitionPhase("login"),
      );
    }
    // 4. Home Phase (sub-navigation screens)
    else {
      switch (_screen) {
        case "home":
          activeWidget = HomeScreen(
            onVenueTap: _goVenue,
            onNav: _goScreen,
            activeNav: _screen,
          );
          break;
        case "search":
          activeWidget = SearchScreen(
            onBack: () => _goScreen("home"),
            onVenueTap: _goVenue,
            onNav: _goScreen,
            activeNav: _screen,
          );
          break;
        case "history":
          activeWidget = BookingHistoryScreen(
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
          activeWidget = FavoritesScreen(onNav: _goScreen, activeNav: _screen);
          break;
        case "profile":
          activeWidget = ProfileScreen(
            onNav: _goScreen,
            activeNav: _screen,
            onLogout: () => _transitionPhase("login"),
          );
          break;
        case "detail":
          activeWidget = DetailScreen(
            venue: _selectedVenue,
            onBack: () => _goScreen("home"),
            onBook: _goBooking,
            onNav: _goScreen,
            activeNav: "home",
          );
          break;
        case "booking":
          activeWidget = BookingScreen(
            venue: _selectedVenue,
            onBack: () => _goScreen("detail"),
            onConfirm: _goSuccess,
          );
          break;
        case "success":
          activeWidget = SuccessScreen(
            venue: _selectedVenue,
            onHome: () => _goScreen("home"),
            onViewBooking: () {
              setState(() {
                _selectedBooking = MOCK_BOOKINGS[0];
                _screen = "booking-detail";
              });
            },
          );
          break;
        default:
          activeWidget = HomeScreen(
            onVenueTap: _goVenue,
            onNav: _goScreen,
            activeNav: "home",
          );
      }
    }

    // High fidelity transition matching the CSS `@keyframes screen-in`
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
