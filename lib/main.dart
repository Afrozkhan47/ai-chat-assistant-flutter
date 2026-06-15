import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/service_locator.dart';
import 'data/repositories/conversation_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'presentation/blocs/conversation/conversation_bloc.dart';
import 'presentation/blocs/conversation/conversation_event.dart';
import 'presentation/blocs/settings/settings_bloc.dart';
import 'presentation/blocs/settings/settings_event.dart';
import 'presentation/blocs/settings/settings_state.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ConversationBloc(getIt<ConversationRepository>())
            ..add(LoadConversations()),
        ),
        BlocProvider(
          create: (_) => SettingsBloc(getIt<SettingsRepository>())
            ..add(LoadSettings()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final darkMode =
              state is SettingsLoaded ? state.settings.darkMode : false;

          return MaterialApp(
            title: 'AI Chatbot',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
