import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // Use correct options
  );
}


Future<void> registerServices() async {
  getIt.registerLazySingleton<AuthService>(() => AuthService());
}
