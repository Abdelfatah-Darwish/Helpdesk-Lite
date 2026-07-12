import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginSubmitted(
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
    }
  }

  void _fillMockCredentials(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ResponsiveLayout(
              mobile: _buildLoginForm(theme, size.width, isCompact: true),
              tablet: _buildLoginForm(theme, 480, isCompact: false),
              desktop: _buildLoginForm(theme, 540, isCompact: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme, double width, {required bool isCompact}) {
    return Container(
      width: width,
      padding: EdgeInsets.all(isCompact ? 16.0 : 32.0),
      decoration: isCompact
          ? null
          : BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Identity Header
            const Icon(
              Icons.support_agent_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'HelpDesk Lite',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to your internal support workspace',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Email Field
            CustomTextField(
              label: 'Corporate Email',
              hint: 'email@company.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 20),

            // Password Field
            CustomTextField(
              label: 'Password',
              hint: '••••••••',
              controller: _passwordController,
              isPassword: true,
              prefixIcon: Icons.lock_outlined,
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 24),

            // Submit Button
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return CustomButton(
                  label: 'Log In',
                  onPressed: _onLoginPressed,
                  isLoading: state is AuthLoading,
                );
              },
            ),
            const SizedBox(height: 32),

            // Mock Credentials Section (V1 Helper)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick access mock roles:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMockCredentialRow('Employee:', 'employee@company.com'),
                  const SizedBox(height: 8),
                  _buildMockCredentialRow('Support Staff:', 'support@company.com'),
                  const SizedBox(height: 8),
                  _buildMockCredentialRow('Manager:', 'manager@company.com'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockCredentialRow(String roleLabel, String email) {
    return InkWell(
      onTap: () => _fillMockCredentials(email, 'password123'),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              roleLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              email,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
