import 'package:flutter/material.dart';
import 'package:motive_app_toy/feature/auth/widget/login_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.onSubmit,
    this.onGithubLogin,
    this.onGoogleLogin,
    this.onKakaoLogin,
    this.onForgotPassword,
    this.onRegister,
  });

  final void Function(String email, String password)? onSubmit;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onRegister;
  final VoidCallback? onGoogleLogin;
  final VoidCallback? onGithubLogin;
  final VoidCallback? onKakaoLogin;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    widget.onSubmit?.call(_emailController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 402),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // const BackHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 20, 26, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Motive에 오신 걸 환영해요',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: LoginColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '로그인하고 계속 진행해보세요',
                          style: TextStyle(
                            fontSize: 13,
                            color: LoginColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _FieldLabel('이메일 또는 전화번호'),
                        const SizedBox(height: 6),
                        _EmailField(
                          controller: _emailController,
                          onChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 18),
                        _FieldLabel('비밀번호'),
                        const SizedBox(height: 6),
                        _PasswordField(controller: _passwordController),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: widget.onForgotPassword,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: LoginColors.point,
                            ),
                            child: const Text(
                              '비밀번호를 잊으셨나요?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 47,
                          child: ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LoginColors.point,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              '로그인',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          '또는 다음으로 로그인',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: LoginColors.textPlaceholder,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SocialButton(
                          label: 'Google로 로그인',
                          iconUrl:
                              'https://img.icons8.com/?id=17949&format=png&size=64',
                          backgroundColor: Colors.white,
                          textColor: LoginColors.textPrimary,
                          borderColor: LoginColors.border,
                          onPressed: widget.onGoogleLogin,
                        ),
                        const SizedBox(height: 10),
                        _SocialButton(
                          label: '카카오로 로그인',
                          iconUrl:
                              'https://img.icons8.com/?id=BH0XTdh770dG&format=png&size=64',
                          backgroundColor: LoginColors.kakaoYellow,
                          textColor: LoginColors.kakaoText,
                          onPressed: widget.onKakaoLogin,
                        ),
                        const SizedBox(height: 10),
                        _SocialButton(
                          label: 'GitHub로 로그인',
                          iconUrl:
                              'https://img.icons8.com/?id=12599&format=png&size=64&color=ffffff',
                          backgroundColor: LoginColors.githubBlack,
                          textColor: Colors.white,
                          onPressed: widget.onGithubLogin,
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: TextButton(
                            onPressed: widget.onRegister,
                            style: TextButton.styleFrom(
                              foregroundColor: LoginColors.textPrimary,
                            ),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: LoginColors.textPrimary,
                                ),
                                children: [
                                  TextSpan(text: '계정이 없으신가요? '),
                                  TextSpan(
                                    text: '회원가입',
                                    style: TextStyle(color: LoginColors.point),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: LoginColors.textPrimary,
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LoginColors.point, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (_) => onChanged(),
              style: const TextStyle(
                fontSize: 14,
                color: LoginColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'example@motive.com',
                hintStyle: TextStyle(color: LoginColors.textPlaceholder),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            const Icon(Icons.check, size: 16, color: LoginColors.point),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LoginColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: true,
              style: const TextStyle(
                fontSize: 14,
                color: LoginColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: '비밀번호 입력',
                hintStyle: TextStyle(color: LoginColors.textPlaceholder),
              ),
            ),
          ),
          const Icon(
            Icons.visibility_off,
            size: 16,
            color: LoginColors.textPlaceholder,
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.iconUrl,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.onPressed,
  });

  final String label;
  final String iconUrl;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: borderColor != null
              ? BorderSide(color: borderColor!)
              : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              iconUrl,
              width: 16,
              height: 16,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.circle_outlined, size: 16, color: textColor),
            ),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 13, color: textColor)),
          ],
        ),
      ),
    );
  }
}
