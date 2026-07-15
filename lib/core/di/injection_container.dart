import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/repositories/mock_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_authenticated_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/notifications/data/repositories/mock_notification_repository.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/tickets/data/repositories/mock_ticket_repository.dart';
import '../../features/tickets/domain/repositories/ticket_repository.dart';
import '../../features/tickets/domain/usecases/assign_ticket_usecase.dart';
import '../../features/tickets/domain/usecases/create_ticket_usecase.dart';
import '../../features/tickets/domain/usecases/get_ticket_by_id_usecase.dart';
import '../../features/tickets/domain/usecases/get_tickets_usecase.dart';
import '../../features/tickets/domain/usecases/update_ticket_status_usecase.dart';
import '../../features/tickets/presentation/bloc/ticket_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Features - Authentication
  // Blocs
 sl.registerLazySingleton<AuthBloc>(
  () => AuthBloc(
    loginUseCase: sl(),
    logoutUseCase: sl(),
    getAuthenticatedUserUseCase: sl(),
  ),
);

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetAuthenticatedUserUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => MockAuthRepository(sharedPreferences: sl()),
  );

  // Features - Tickets
  // Blocs
  sl.registerFactory(() => TicketBloc(
        getTicketsUseCase: sl(),
        createTicketUseCase: sl(),
        assignTicketUseCase: sl(),
        updateTicketStatusUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => GetTicketsUseCase(sl()));
  sl.registerLazySingleton(() => CreateTicketUseCase(sl()));
  sl.registerLazySingleton(() => AssignTicketUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTicketStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetTicketByIdUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<TicketRepository>(
    () => MockTicketRepository(sharedPreferences: sl()),
  );

  // Features - Notifications
  // Blocs
  sl.registerFactory(() => NotificationBloc(repository: sl()));

  // Repositories
  sl.registerLazySingleton<NotificationRepository>(
    () => MockNotificationRepository(sharedPreferences: sl()),
  );
}
