import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  final storage = FlutterSecureStorage();

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/onboarding1.jpg',
      title: 'Gérez votre cave avec facilité et plaisir',
      description:
          'Ne perdez plus jamais le contrôle de votre inventaire avec notre application intuitive !',
      icon: Icons.wine_bar,
    ),
    OnboardingPage(
      image: 'assets/images/onboarding2.jpg',
      title: 'Restez organisé avec notre équipe',
      description:
          'Suivez facilement vos stocks et gérez vos produits en toute simplicité',
      icon: Icons.inventory_2,
    ),
    OnboardingPage(
      image: 'assets/images/onboarding3.png',
      title: 'Recevez des alertes intelligentes',
      description:
          'Soyez notifié en temps réel des mouvements de stock et des alertes importantes',
      icon: Icons.notifications_active,
    ),
  ];

  @override
  void initState() {
    super.initState();
    storage.write(key: 'has_seen_onboarding', value: 'yes');

    //has_seen_onboarding
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onSkip() {
    _fadeController.forward().then((_) {
      Get.offAllNamed(Routes.LOGIN);
    });
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _scaleController.forward().then((_) {
        Get.offAllNamed(Routes.LOGIN);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Stack(
          children: [
            // Fond animé avec gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6C4BFF).withOpacity(0.05),
                    const Color(0xFFF8FAFF),
                    const Color(0xFF6C4BFF).withOpacity(0.02),
                  ],
                ),
              ),
            ).animate().fade(duration: 1000.ms),

            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                _fadeController.reset();
                _scaleController.reset();
                _fadeController.forward();
                _scaleController.forward();
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPageContent(_pages[index], index);
              },
            ),

            // Bouton Skip avec animation
            Positioned(
              top: 20,
              right: 20,
              child:
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: _onSkip,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Passer',
                        style: TextStyle(
                          color: Color(0xFF6C4BFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().slideX(
                    begin: 1,
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ),

            // Navigation du bas
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNavigation(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(OnboardingPage data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icône avec animation
          Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF6C4BFF), const Color(0xFF5A52E0)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C4BFF).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(data.icon, color: Colors.white, size: 40),
              )
              .animate()
              .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
              .then()
              .shimmer(delay: 1000.ms, duration: 1500.ms),

          const SizedBox(height: 40),

          // Image avec animation
          Container(
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    data.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              )
              .animate()
              .fade(delay: 400.ms, duration: 800.ms)
              .slideY(
                begin: 0.3,
                end: 0,
                delay: 400.ms,
                duration: 800.ms,
                curve: Curves.easeOutCubic,
              )
              .scale(delay: 600.ms, duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 50),

          // Titre avec animation
          _buildRichText(data.title)
              .animate()
              .fade(delay: 800.ms, duration: 600.ms)
              .slideY(
                begin: 0.3,
                end: 0,
                delay: 800.ms,
                duration: 600.ms,
                curve: Curves.easeOutCubic,
              ),

          const SizedBox(height: 20),

          // Description avec animation
          Text(
                data.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              )
              .animate()
              .fade(delay: 1000.ms, duration: 600.ms)
              .slideY(
                begin: 0.3,
                end: 0,
                delay: 1000.ms,
                duration: 600.ms,
                curve: Curves.easeOutCubic,
              ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildRichText(String text) {
    List<String> highlights = ["cave", "organisé", "alertes"];
    String highlightWord = highlights.firstWhere(
      (h) => text.toLowerCase().contains(h.toLowerCase()),
      orElse: () => "",
    );

    if (highlightWord.isEmpty) {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          height: 1.3,
        ),
      );
    }

    List<String> parts = text.split(
      RegExp(highlightWord, caseSensitive: false),
    );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          height: 1.3,
        ),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: highlightWord,
            style: TextStyle(
              color: Color(0xFF6C4BFF),
              background: Paint()
                ..color = const Color(0xFF6C4BFF).withOpacity(0.1)
                ..style = PaintingStyle.fill,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.8),
            Colors.white,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Forme décorative du bas
          Positioned.fill(child: CustomPaint(painter: _BottomWavePainter())),

          // Indicateurs de page
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDot(index: index),
              ),
            ),
          ),

          // Bouton suivant
          Positioned(
            bottom: 40,
            right: 30,
            child:
                Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6C4BFF),
                            const Color(0xFF5A52E0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C4BFF).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: _onNext,
                          child: Container(
                            width: 60,
                            height: 60,
                            child: Icon(
                              _currentPage == _pages.length - 1
                                  ? Icons.check
                                  : Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .scale(
                      delay: 1200.ms,
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    )
                    .then()
                    .shimmer(delay: 2000.ms, duration: 2000.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 10,
      width: _currentPage == index ? 30 : 10,
      decoration: BoxDecoration(
        gradient: _currentPage == index
            ? LinearGradient(
                colors: [const Color(0xFF6C4BFF), const Color(0xFF5A52E0)],
              )
            : null,
        color: _currentPage == index ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
        boxShadow: _currentPage == index
            ? [
                BoxShadow(
                  color: const Color(0xFF6C4BFF).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    ).animate().scale(
      delay: 1400.ms,
      duration: 300.ms,
      curve: Curves.elasticOut,
    );
  }
}

class _BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6C4BFF).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.5,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;
  final IconData icon;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.icon,
  });
}
