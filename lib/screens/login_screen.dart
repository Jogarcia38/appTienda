import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/password_reveal.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? notice;

  const LoginScreen({super.key, this.notice});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    final notice = widget.notice;
    if (notice != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(notice)),
        );
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Error al iniciar sesión')),
      );
    }
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('La recuperación de contraseña todavía no está disponible')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF071423), Color(0xFF0E2C4E), Color(0xFF08111C)],
          ),
        ),
        child: Stack(
          children: const [
            _Bokeh(top: -40, left: -30, size: 180, color: Color(0x332F80ED)),
            _Bokeh(top: 80, right: 60, size: 90, color: Color(0x22FFFFFF)),
            _Bokeh(bottom: 40, left: 120, size: 70, color: Color(0x33FFFFFF)),
            _Bokeh(bottom: -20, right: -10, size: 160, color: Color(0x221565C0)),
            SafeArea(child: _LoginBody()),
          ],
        ),
      ),
    );
  }
}

class _Bokeh extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final Color color;

  const _Bokeh({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: wide ? const _WideCard() : const _CompactCard(),
                ),
                const SizedBox(height: 28),
                const Text(
                  'appTienda   |   Versión 1.0.0',
                  style: TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WideCard extends StatelessWidget {
  const _WideCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 18)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: const SizedBox(
          height: 580,
          child: Row(
            children: [
              Expanded(
                flex: 11,
                child: ClipPath(
                  clipper: _DiagonalClipper(),
                  child: _BrandPanel(),
                ),
              ),
              Expanded(
                flex: 10,
                child: _LoginForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  const _CompactCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 32, offset: Offset(0, 16)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: const Column(
          children: [
            _BrandPanel(compact: true),
            _LoginForm(),
          ],
        ),
      ),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  const _DiagonalClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.84, 0)
      ..quadraticBezierTo(size.width * 1.08, size.height * 0.42, size.width * 0.78, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _BrandPanel extends StatelessWidget {
  final bool compact;

  const _BrandPanel({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A3478), Color(0xFF1565C0), Color(0xFF1E88E5)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(32, compact ? 28 : 46, 36, compact ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _LogoMark(),
            const SizedBox(height: 22),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'app', style: TextStyle(color: Colors.white)),
                  TextSpan(text: 'Tienda', style: TextStyle(color: Color(0xFF8EDEFF))),
                ],
              ),
              style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, height: 1),
            ),
            const SizedBox(height: 10),
            Container(
              width: 74,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF7EC8FF),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gestión de Productos\nTecnológicos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!compact) ...[
              const Spacer(),
              const _TechStill(),
            ],
          ],
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x552F80ED), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 46),
    );
  }
}

class _TechStill extends StatelessWidget {
  const _TechStill();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(color: Color(0xFF10243F), shape: BoxShape.circle),
              child: const Icon(Icons.headphones, color: Color(0xFFD6DEE8), size: 26),
            ),
          ),
          Positioned(
            left: 58,
            bottom: 0,
            child: Column(
              children: [
                Container(
                  width: 132,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFB9D7FF), width: 4),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF163E86), Color(0xFF4DA3FF)],
                    ),
                  ),
                ),
                Container(
                  width: 156,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD5DEE8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 168,
            bottom: 18,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.watch, color: Color(0xFF1565C0), size: 20),
            ),
          ),
          Positioned(
            left: 198,
            bottom: 10,
            child: Container(
              width: 42,
              height: 74,
              decoration: BoxDecoration(
                color: const Color(0xFF101820),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF9CC7FF), width: 2),
              ),
              child: const Center(
                child: Icon(Icons.smartphone, color: Color(0xFF4DA3FF), size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    hideNativePasswordReveal();
  }

  void _togglePassword() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_LoginScreenState>()!;
    final auth = context.watch<AuthProvider>();

    return Stack(
      children: [
        const Positioned(
          top: 0,
          right: 0,
          child: CustomPaint(
            size: Size(110, 110),
            painter: _CornerPainter(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 54, 36, 28),
          child: Form(
            key: state._formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D2939),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Accede a tu cuenta en appTienda',
                  style: TextStyle(color: Color(0xFF667085), fontSize: 15),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: state._emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration('Usuario', Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa tu usuario';
                    }
                    if (!value.contains('@')) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Icon(Icons.lock_outline, color: Color(0xFF98A2B3)),
                      ),
                      Expanded(
                        child: TextFormField(
                          key: ValueKey(_obscurePassword),
                          controller: state._passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => state._login(),
                          decoration: const InputDecoration(
                            hintText: 'Contraseña',
                            filled: false,
                            isCollapsed: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            hintStyle: TextStyle(color: Color(0xFF98A2B3), fontWeight: FontWeight.w500),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contraseña';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        tooltip: _obscurePassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
                        onPressed: _togglePassword,
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: const Color(0xFF98A2B3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: auth.isLoading ? null : state._login,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF1A73E8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF1A73E8).withValues(alpha: 0.7),
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    icon: auth.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.login, size: 20),
                    label: Text(auth.isLoading ? 'Ingresando' : 'Ingresar'),
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFFE4E7EC))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '¿No tienes una cuenta?',
                        style: TextStyle(color: Color(0xFF98A2B3), fontSize: 13),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFE4E7EC))),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: state._openRegister,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A73E8),
                      side: const BorderSide(color: Color(0xFFD0D5DD)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 20),
                    label: const Text('Registrarme'),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    onPressed: state._forgotPassword,
                    icon: const Icon(Icons.key_outlined, size: 16, color: Color(0xFF1A73E8)),
                    label: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: Color(0xFF1A73E8),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF1A73E8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String hint, IconData icon, {Widget? suffix}) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Color(0xFFE4E7EC)),
    );

    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF98A2B3)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border,
      enabledBorder: border,
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFF1A73E8), width: 1.4),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final deep = Paint()..color = const Color(0xFF1A73E8);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.42, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height * 0.62)
        ..close(),
      deep,
    );
    final light = Paint()..color = const Color(0xFF4DA3FF);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.68, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height * 0.32)
        ..close(),
      light,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
