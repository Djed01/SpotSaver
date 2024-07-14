part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initPost();
  _initLocation();
  final supabase = await Supabase.initialize(
      url: AppSecrets.supabaseUrl, anonKey: AppSecrets.supabaseAnonKey);

  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;

  serviceLocator.registerLazySingleton(() => supabase.client);

  serviceLocator.registerLazySingleton(
    () => Hive.box(
      name: 'blogs',
    ),
  );

  serviceLocator.registerFactory(() => InternetConnection());

  //core
  serviceLocator.registerLazySingleton(
    () => AppUserCubit(),
  );
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(
      serviceLocator(),
    ),
  );
}

void _initAuth() {
  // Datasource
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => UserSignUp(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogin(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserLogout(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ChangePassword(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CurrentUser(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        userLogout: serviceLocator(),
        changePassword: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}

void _initPost() {
  // Datasource
  serviceLocator
    ..registerFactory<PostRemoteDataSource>(
      () => PostRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<PostLocalDataSource>(() => PostLocalDataSourceImpl(
          serviceLocator(),
        ))
    // Repository
    ..registerFactory<PostRepository>(
      () => PostRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // Usecases
    ..registerFactory(
      () => UploadPost(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetAllPosts(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetPosts(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetFavouritePosts(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetUserPosts(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => AddPostToFavourites(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => RemovePostFromFavourites(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => DeletePost(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UpdatePost(
        serviceLocator(),
      ),
    )
    // Bloc
    ..registerLazySingleton(
      () => PostBloc(
          uploadPost: serviceLocator(),
          getAllPosts: serviceLocator(),
          getPosts: serviceLocator(),
          getFavouritePosts: serviceLocator(),
          getUserPosts: serviceLocator(),
          addPostToFavourites: serviceLocator(),
          removePostFromFavourites: serviceLocator(),
          deletePost: serviceLocator(),
          updatePost: serviceLocator(),
          appUserCubit: serviceLocator()),
    );
}

void _initLocation() {
  // Datasource
  serviceLocator.registerFactory<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(
      location: Location(),
    ),
  );

  // Repository
  serviceLocator.registerFactory<LocationRepository>(
    () => LocationRepositoryImpl(
      dataSource: serviceLocator(),
    ),
  );

  // Usecases
  serviceLocator.registerFactory(
    () => GetCurrentLocation(
      serviceLocator(),
    ),
  );

  // Bloc
  serviceLocator.registerLazySingleton(
    () => LocationBloc(
      getCurrentLocation: serviceLocator(),
    ),
  );
}
