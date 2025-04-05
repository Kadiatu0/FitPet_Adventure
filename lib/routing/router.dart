import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// import 'package:permission_handler/permission_handler.dart';

import '../ui/home/view_model/home_viewmodel.dart';
import '../../ui/home/widgets/home_screen.dart';
import '../ui/community/widgets/community_main.dart';
import '../ui/cosmetics/view_model/cosmetics_viewmodel.dart';
import '../ui/cosmetics/widgets/cosmetics_screen.dart';
import '../ui/core/ui/loading.dart';
import '../ui/welcome/widgets/welcome_page.dart';
import '../ui/login_page/login_viemodel.dart';
import '../ui/login_page/login_page.dart';
import '../ui/signup_page/signup_page.dart';
import '../ui/rest_password/reset_password_page.dart';
import '../ui/choose_pet_page/choose_pet_page.dart';
import '../ui/leaderboard/leaderboard_page.dart';
import '../ui/friends_page/friends_page.dart';
import 'routes.dart';

GoRouter router(LoginViewModel loginViewModel) => GoRouter(
  initialLocation: Routes.home,
  refreshListenable: loginViewModel,
  routes: [
    GoRoute(path: Routes.loading, builder: (_, _) => Loading()),
    GoRoute(
      path: Routes.welcome,
      builder: (_, _) {
        return WelcomePage();
      },
    ),
    GoRoute(
      path: Routes.login,
      builder: (_, _) {
        return LoginPage();
      },
    ),
    GoRoute(
      path: Routes.signup,
      builder: (_, _) {
        return SignupPage();
      },
    ),
    GoRoute(
      path: Routes.resetPassword,
      builder: (_, _) {
        return ResetPasswordPage();
      },
    ),
    GoRoute(
      path: Routes.choosePet,
      builder: (_, _) {
        return ChoosePetPage();
      },
      redirect: _redirect,
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
      redirect: _redirect,
    ),
    GoRoute(
      path: Routes.leaderboard,
      builder: (_, _) {
        return LeaderboardPage();
      },
      redirect: _redirect,
    ),
    GoRoute(
      path: Routes.friends,
      builder: (_, _) {
        return FriendsPage();
      },
      redirect: _redirect,
    ),
    GoRoute(
      path: Routes.community,
      builder: (_, _) {
        return CommunityMain();
      },
      redirect: _redirect,
    ),
    GoRoute(
      path: Routes.cosmetics,
      builder: (context, _) {
        final viewModel = CosmeticsViewmodel(
          firestoreRepository: context.read(),
        );

        return CosmeticsScreen(viewModel: viewModel);
      },
      redirect: _redirect,
    ),
  ],
);

/// Redirects if the user is not logged in or has not granted permissions.
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final isLoggedIn = context.read<LoginViewModel>().isLoggedIn;
  if (!isLoggedIn) return Routes.welcome;

  // Don't need this for emulators.
  // if (!(await Permission.activityRecognition.request().isGranted)) {
  //   // User doesn't allow permission.
  //   return Routes.loading;
  // }

  // No need to redirect at all.
  return null;
}
