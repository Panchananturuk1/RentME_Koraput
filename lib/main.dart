import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: MaterialApp(
            title: 'RentMe Koraput',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: const Color(0xFF0EA5E9),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF0EA5E9),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Inter',
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
            ),
            home: const AuthWrapper(),
            onGenerateRoute: (settings) {
              // Handle regular routes
              switch (settings.name) {
                case '/login':
                  return MaterialPageRoute(builder: (context) => const LoginScreen());
                case '/signup':
                  return MaterialPageRoute(builder: (context) => const SignupScreen());
                case '/forgot-password':
                  return MaterialPageRoute(builder: (context) => const ForgotPasswordScreen());
                case '/reset-password':
                  return MaterialPageRoute(builder: (context) => const ResetPasswordScreen());
                case '/dashboard':
                  return MaterialPageRoute(builder: (context) => const DashboardScreen());
                default:
                  return MaterialPageRoute(builder: (context) => const AuthWrapper());
              }
            },
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkForPasswordReset();
  }

  void _checkForPasswordReset() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Debug: Print current URL information
      print('Current URL: ${Uri.base}');
      print('Fragment: ${Uri.base.fragment}');
      print('Query: ${Uri.base.query}');
      print('All query parameters: ${Uri.base.queryParameters}');
      
      // Check if we're on web and have a password reset URL
      // Check both fragment (for #access_token&refresh_token) and query (for ?code=)
      bool isPasswordReset = false;
      String? refreshToken;
      String? code;
      String? tokenHash;
      
      // Check fragment for direct token-based reset
      if (Uri.base.fragment.contains('refresh_token') && 
          Uri.base.fragment.contains('type=recovery')) {
        final fragment = Uri.base.fragment;
        print('Password reset detected in fragment! Fragment: $fragment');
        final params = Uri.splitQueryString(fragment);
        refreshToken = params['refresh_token'];
        tokenHash = params['token_hash'];
        isPasswordReset = true;
      }
      
      // Check query parameters for code-based reset
      final queryParams = Uri.base.queryParameters;
      if (queryParams.containsKey('code')) {
        code = queryParams['code'];
        print('Password reset code detected in query! Code: $code');
        isPasswordReset = true;
      }
      
      // Also check for token_hash in query parameters
      if (queryParams.containsKey('token_hash')) {
        tokenHash = queryParams['token_hash'];
        print('Token hash detected in query! TokenHash: $tokenHash');
        isPasswordReset = true;
      }
      
      if (isPasswordReset) {
        print('Navigating to reset password screen...');
        // Navigate to reset password screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              refreshToken: refreshToken,
              resetCode: code,
              tokenHash: tokenHash,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show splash screen while loading
        if (authProvider.isLoading) {
          return const SplashScreen();
        }

        // Navigate based on authentication status
        if (authProvider.isLoggedIn) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
