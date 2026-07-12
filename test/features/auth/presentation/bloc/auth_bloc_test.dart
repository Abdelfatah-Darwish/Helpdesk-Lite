import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helpdesk_lite/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:helpdesk_lite/features/auth/domain/entities/user.dart';
import 'package:helpdesk_lite/features/auth/domain/usecases/get_authenticated_user_usecase.dart';
import 'package:helpdesk_lite/features/auth/domain/usecases/login_usecase.dart';
import 'package:helpdesk_lite/features/auth/domain/usecases/logout_usecase.dart';
import 'package:helpdesk_lite/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:helpdesk_lite/features/auth/presentation/bloc/auth_event.dart';
import 'package:helpdesk_lite/features/auth/presentation/bloc/auth_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAuthRepository repository;
  late SharedPreferences sharedPreferences;
  late LoginUseCase loginUseCase;
  late LogoutUseCase logoutUseCase;
  late GetAuthenticatedUserUseCase getAuthenticatedUserUseCase;
  late AuthBloc authBloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    repository = MockAuthRepository(sharedPreferences: sharedPreferences);
    loginUseCase = LoginUseCase(repository);
    logoutUseCase = LogoutUseCase(repository);
    getAuthenticatedUserUseCase = GetAuthenticatedUserUseCase(repository);
    
    authBloc = AuthBloc(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      getAuthenticatedUserUseCase: getAuthenticatedUserUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc Tests', () {
    test('initial state should be AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Unauthenticated] when checking status on empty cache',
      build: () => authBloc,
      act: (bloc) => bloc.add(CheckAuthStatus()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Authenticated] when login is successful',
      build: () => authBloc,
      act: (bloc) => bloc.add(const LoginSubmitted(
        email: 'employee@company.com',
        password: 'password123',
      )),
      expect: () => [
        AuthLoading(),
        isA<Authenticated>().having((a) => a.user.email, 'email', 'employee@company.com')
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when login fails',
      build: () => authBloc,
      act: (bloc) => bloc.add(const LoginSubmitted(
        email: 'wrong@company.com',
        password: 'wrongpassword',
      )),
      expect: () => [
        AuthLoading(),
        isA<AuthError>().having((e) => e.message, 'message', 'Invalid email or password')
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Unauthenticated] when logout is requested',
      build: () => authBloc,
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );
  });
}
