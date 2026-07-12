import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helpdesk_lite/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:helpdesk_lite/features/auth/domain/usecases/get_authenticated_user_usecase.dart';
import 'package:helpdesk_lite/features/auth/domain/usecases/login_usecase.dart';
import 'package:helpdesk_lite/features/auth/domain/usecases/logout_usecase.dart';
import 'package:helpdesk_lite/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:helpdesk_lite/features/auth/presentation/pages/login_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AuthBloc authBloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();
    final repo = MockAuthRepository(sharedPreferences: sharedPrefs);
    authBloc = AuthBloc(
      loginUseCase: LoginUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
      getAuthenticatedUserUseCase: GetAuthenticatedUserUseCase(repo),
    );
  });

  tearDown(() {
    authBloc.close();
  });

  Widget createWidgetUnderValues(Widget child) {
    return BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('should render login layout fields and headers', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderValues(const LoginPage()));

      // Verify branding headers are shown
      expect(find.text('HelpDesk Lite'), findsOneWidget);
      expect(find.text('Sign in to your internal support workspace'), findsOneWidget);

      // Verify form input labels
      expect(find.text('Corporate Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Verify submit button is rendered
      expect(find.text('Log In'), findsOneWidget);

      // Verify mock credentials quick links section is rendered
      expect(find.text('Quick access mock roles:'), findsOneWidget);
      expect(find.text('employee@company.com'), findsOneWidget);
      expect(find.text('support@company.com'), findsOneWidget);
      expect(find.text('manager@company.com'), findsOneWidget);
    });

    testWidgets('should show validation messages on blank inputs submit', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderValues(const LoginPage()));

      // Tap Log In without filling details
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      // Check validation error texts appear
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
  });
}
