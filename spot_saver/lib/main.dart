import 'package:flutter/material.dart';
import 'package:spot_saver/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:spot_saver/core/theme/theme.dart';
import 'package:spot_saver/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:spot_saver/features/auth/presentation/pages/login_page.dart';
import 'package:spot_saver/features/comment/presentation/bloc/comment_bloc.dart';
import 'package:spot_saver/features/post/presentation/bloc/post_bloc.dart';
import 'package:spot_saver/features/post/presentation/pages/posts_page.dart';
import 'package:spot_saver/init_dependencies.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => serviceLocator<AppUserCubit>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<AuthBloc>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<PostBloc>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<CommentBloc>(),
      )
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blog App',
      theme: AppTheme.darkThemeMode,
      home: BlocSelector<AppUserCubit, AppUserState, bool>(
        selector: (state) {
          return state is AppUserLoggedIn;
        },
        builder: (context, isLoggedIn) {
          if (isLoggedIn) {
            return const PostsPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
