import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/repositories/firebase/firestore_repository.dart';
import '../ui/home/view_model/home_viewmodel.dart';
import '../../ui/home/widgets/home_screen.dart';
import '../ui/leaderboard/widgets/leaderboard_screen.dart';
import '../ui/community/widgets/community_screen.dart';
import '../ui/cosmetics/view_model/cosmetics_viewmodel.dart';
import '../ui/cosmetics/widgets/cosmetics_screen.dart';
import '../ui/core/ui/loading.dart';
import 'routes.dart';

// Delete these and replace with auth pages.
import '../ui/temp_login/view_model/login_view_model.dart';
import '../ui/temp_login/widgets/login_screen.dart';

// Replace firebase with auth repository later.
GoRouter router(FirestoreRepository firestoreRepository) => GoRouter(
  initialLocation: Routes.home,
  redirect: _redirect,
  refreshListenable: firestoreRepository,
  routes: [
    GoRoute(path: Routes.loading, builder: (_, _) => Loading()),
    GoRoute(
      path: Routes.login,
      builder: (context, _) {
        // Temporary, replace with auth repository later.
        final viewModel = LoginViewModel(firestoreRepository: context.read());
        return LoginScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, _) {
        final viewModel = HomeViewModel(
          pedometerRepository: context.read(),
          firestoreRepository: context.read(),
        );

        return HomeScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.leaderboard,
      builder: (context, _) {
        return LeaderboardScreen();
      },
    ),
    GoRoute(
      path: Routes.community,
      builder: (context, _) {
        return CommunityScreen();
      },
    ),
    GoRoute(
      path: Routes.cosmetics,
      builder: (context, _) {
        final viewModel = CosmeticsViewmodel(
          firestoreRepository: context.read(),
        );

        return CosmeticsScreen(viewModel: viewModel);
      },
    ),
  ],
);

/// Redirects if the user is not logged in or has not granted permissions.
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  // Replace with auth repository later on.
  final isLoggedIn = context.read<FirestoreRepository>().isLoggedIn;
  if (!isLoggedIn) return Routes.login;
  final loggingIn = state.matchedLocation == Routes.login;

  // If user is logged in but still on the login page, go to the homepage.
  if (loggingIn) return Routes.home;

  if (!(await Permission.activityRecognition.request().isGranted)) {
    // User doesn't allow permission.
    return Routes.loading;
  }

  // No need to redirect at all.
  return null;
}
