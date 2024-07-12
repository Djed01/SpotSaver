import 'package:flutter/material.dart';
import 'package:spot_saver/core/theme/app_pallete.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key, required this.onSelectScreen});

  final void Function(String identifier) onSelectScreen;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: [
        DrawerHeader(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppPallete.gradient1,
                AppPallete.gradient2.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              const Image(
                image: AssetImage('assets/icons/icon.png'),
                width: 48,
                height: 48,
              ),
              const SizedBox(width: 18),
              Text(
                'Spot Saver',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppPallete.whiteColor,
                    ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(
            Icons.lock,
            size: 24,
            color: AppPallete.whiteColor,
          ),
          title: Text(
            'Change Password',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: AppPallete.whiteColor, fontSize: 24),
          ),
          onTap: () {
            onSelectScreen('change_password');
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.logout,
            size: 24,
            color: AppPallete.whiteColor,
          ),
          title: Text(
            'Logout',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: AppPallete.whiteColor, fontSize: 24),
          ),
          onTap: () {
            onSelectScreen('logout');
          },
        ),
      ]),
    );
  }
}
