import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_saver/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:spot_saver/core/common/widgets/loader.dart';
import 'package:spot_saver/core/utils/show_snackbar.dart';
import 'package:spot_saver/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:spot_saver/features/auth/presentation/widgets/auth_field.dart';
import 'package:spot_saver/features/auth/presentation/widgets/auth_gradient_button.dart';

class ChangePasswordPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const ChangePasswordPage());
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showSnackBar(context, state.message);
            } else if (state is AuthChangePasswordSuccess) {
              showSnackBar(context, "Password changed successfully!");
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Loader();
            }
            return SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    AuthField(
                      hintText: 'Old Password',
                      controller: oldPasswordController,
                      isObscureText: true,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    AuthField(
                      hintText: 'New Password',
                      controller: newPasswordController,
                      isObscureText: true,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    AuthField(
                      hintText: 'Confirm New Password',
                      controller: confirmPasswordController,
                      isObscureText: true,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    AuthGradientButton(
                      buttonText: 'Change Password',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (newPasswordController.text.trim() ==
                              confirmPasswordController.text.trim()) {
                            context.read<AuthBloc>().add(AuthChangePassword(
                                  email: (context.read<AppUserCubit>().state
                                          as AppUserLoggedIn)
                                      .user
                                      .email,
                                  oldPassword:
                                      oldPasswordController.text.trim(),
                                  newPassword:
                                      newPasswordController.text.trim(),
                                ));
                          } else {
                            showSnackBar(context, "Passwords do not match");
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
