import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixora/features/auth/data/firebase_auth_repo.dart';
import 'package:pixora/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:pixora/features/auth/presentation/cubits/auth_states.dart';
import 'package:pixora/features/auth/presentation/pages/auth_page.dart';
import 'package:pixora/features/home/presentation/pages/home_page.dart';
import 'package:pixora/features/post/data/firebase_post_repo.dart';
import 'package:pixora/features/post/presentation/cubits/post_cubit.dart';
import 'package:pixora/features/profile/data/firebase_profile_repo.dart';
import 'package:pixora/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:pixora/features/search/data/firebase_search.dart';
import 'package:pixora/features/search/presentation/cubits/search_cubit.dart';
import 'package:pixora/features/storage/data/firebase_storage_repo.dart';
import 'package:pixora/themes/dark_mode.dart';
import 'package:pixora/themes/light_mode.dart';
import 'package:pixora/themes/theme_cubit.dart';

/*
APP- Root level

-------------------

Repositories for the database
  -firebase

Bloc Providers: for state management
  - auth
  - profile
  - post
  - searching
  - theme

Check Auth State
  - unauthenticated -> auth page(login/register)
  - authenticated -> home page



*/

class MyApp extends StatelessWidget {
  // auth repo
  final firebaseAuthRepo = FirebaseAuthRepo();

  //profile repo
  final firebaseProfileRepo = FirebaseProfileRepo();

  //storage repo
  final firebaseStorageRepo = FirebaseStorageRepo();

  //post repo
  final firebasePostRepo = FirebasePostRepo();

  //search repo
  final firebaseSearchRepo = FirebaseSearchRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //provide cubit to app
    return MultiBlocProvider(
      providers: [
        // auth cubit
        BlocProvider<AuthCubit>(
            create: (context) =>
                AuthCubit(authRepo: firebaseAuthRepo)..checkAuth()),

        // profile cubit
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
              profileRepo: firebaseProfileRepo,
              storageRepo: firebaseStorageRepo),
        ),

        //post cubit
        BlocProvider<PostCubit>(
            create: (context) => PostCubit(
                postRepo: firebasePostRepo, storageRepo: firebaseStorageRepo)),



        //search cubit
        BlocProvider<SearchCubit>(create: (context)=>SearchCubit(searchRepo: firebaseSearchRepo)),


        //theme cubit
        BlocProvider<ThemeCubit>(create: (context)=>ThemeCubit())
      ],


      //bloc builder: themes
      child: BlocBuilder<ThemeCubit, ThemeData>(builder: (context, currentTheme)=>MaterialApp(
        debugShowCheckedModeBanner: false,
        theme:currentTheme,


        //bloc builder: check current auth state
        home: BlocConsumer<AuthCubit, AuthState>(
          builder: (context, authState) {
            print(authState);
            //unauthenticated -> auth page (login/register)
            if (authState is Unauthenticated) {
              return const AuthPage();
            }

            //authenticated -> home page
            if (authState is Authenticated) {
              return const HomePage();
            }

            // loading..
            else {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },

          //listen for errors..
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ),)
    );
  }
}
