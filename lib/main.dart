import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const PortfolioApp());
}

// ──────────────────────────────────────────────
// APP ROOT
// ──────────────────────────────────────────────

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aung Khant Kyaw | Portfolio',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: AppColors.text,
          displayColor: AppColors.text,
        ),
      ),
      home: const PortfolioPage(),
    );
  }
}

// ──────────────────────────────────────────────
// MAIN PAGE
// ──────────────────────────────────────────────

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final ScrollController _controller = ScrollController();

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _launchUri(Uri uri) async {
    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) return;
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      body: Stack(
        children: [
          const ParticleBackground(),
          ScrollConfiguration(
            behavior: const _NoGlowScrollBehavior(),
            child: SingleChildScrollView(
              controller: _controller,
              child: Column(
                children: [
                  SizedBox(height: isMobile ? 70 : 90),
                  HeroSection(
                    key: _homeKey,
                    onProjects: () => _scrollTo(_projectsKey),
                    onContact: () => _scrollTo(_contactKey),
                    onDownload: () => _launchUri(
                      Uri.parse('https://example.com/aung-khant-kyaw-cv.pdf'),
                    ),
                  ),
                  AboutSection(key: _aboutKey, controller: _controller),
                  SkillsSection(key: _skillsKey, controller: _controller),
                  ExperienceSection(key: _experienceKey, controller: _controller),
                  ProjectsSection(key: _projectsKey, controller: _controller),
                  AchievementsSection(controller: _controller),
                  ContactSection(key: _contactKey, controller: _controller),
                  const FooterSection(),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: NavBar(
                controller: _controller,
                onHome: () => _scrollTo(_homeKey),
                onAbout: () => _scrollTo(_aboutKey),
                onSkills: () => _scrollTo(_skillsKey),
                onExperience: () => _scrollTo(_experienceKey),
                onProjects: () => _scrollTo(_projectsKey),
                onContact: () => _scrollTo(_contactKey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// ANIMATED PARTICLE CONSTELLATION BACKGROUND
// ──────────────────────────────────────────────

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late List<_Particle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(45, (_) => _Particle.random(_random));
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          return CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              time: _animController.value,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  double x, y, speedX, speedY, radius;
  _Particle(this.x, this.y, this.speedX, this.speedY, this.radius);

  factory _Particle.random(Random rng) {
    return _Particle(
      rng.nextDouble(),
      rng.nextDouble(),
      (rng.nextDouble() - 0.5) * 0.3,
      (rng.nextDouble() - 0.5) * 0.3,
      rng.nextDouble() * 1.8 + 0.6,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;

  _ParticlePainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.5),
        radius: 1.4,
        colors: [
          const Color(0xFF0F1B2D),
          AppColors.background,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Second radial glow (violet)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.6, 0.7),
        radius: 1.0,
        colors: [
          AppColors.accent.withOpacity(0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);

    // Particle positions
    final positions = <Offset>[];
    for (final p in particles) {
      final px = ((p.x + p.speedX * time) % 1.0) * size.width;
      final py = ((p.y + p.speedY * time) % 1.0) * size.height;
      positions.add(Offset(px, py));
    }

    // Draw connection lines
    final linePaint = Paint()
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const maxDist = 150.0;
    for (int i = 0; i < positions.length; i++) {
      for (int j = i + 1; j < positions.length; j++) {
        final dist = (positions[i] - positions[j]).distance;
        if (dist < maxDist) {
          final opacity = (1 - dist / maxDist) * 0.2;
          linePaint.color = AppColors.primary.withOpacity(opacity);
          canvas.drawLine(positions[i], positions[j], linePaint);
        }
      }
    }

    // Draw particles
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < positions.length; i++) {
      // Glow
      dotPaint.color = AppColors.primary.withOpacity(0.15);
      canvas.drawCircle(positions[i], particles[i].radius * 4, dotPaint);
      // Core
      dotPaint.color = AppColors.primary.withOpacity(0.6);
      canvas.drawCircle(positions[i], particles[i].radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.time != time;
}

// ──────────────────────────────────────────────
// NAVBAR — GLASS MORPHISM
// ──────────────────────────────────────────────

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.controller,
    required this.onHome,
    required this.onAbout,
    required this.onSkills,
    required this.onExperience,
    required this.onProjects,
    required this.onContact,
  });

  final ScrollController controller;
  final VoidCallback onHome;
  final VoidCallback onAbout;
  final VoidCallback onSkills;
  final VoidCallback onExperience;
  final VoidCallback onProjects;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ).createShader(bounds),
                  child: Text(
                    'Aung Khant Kyaw',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                if (isWide)
                  Row(
                    children: [
                      NavLink(label: 'Home', onTap: onHome),
                      NavLink(label: 'About', onTap: onAbout),
                      NavLink(label: 'Skills', onTap: onSkills),
                      NavLink(label: 'Experience', onTap: onExperience),
                      NavLink(label: 'Projects', onTap: onProjects),
                      NavLink(label: 'Contact', onTap: onContact),
                    ],
                  )
                else
                  PopupMenuButton<_NavSection>(
                    tooltip: 'Navigate',
                    color: AppColors.surface,
                    icon: Icon(Icons.menu_rounded, color: AppColors.text),
                    onSelected: (value) {
                      switch (value) {
                        case _NavSection.home:
                          onHome();
                          break;
                        case _NavSection.about:
                          onAbout();
                          break;
                        case _NavSection.skills:
                          onSkills();
                          break;
                        case _NavSection.experience:
                          onExperience();
                          break;
                        case _NavSection.projects:
                          onProjects();
                          break;
                        case _NavSection.contact:
                          onContact();
                          break;
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: _NavSection.home, child: Text('Home')),
                      PopupMenuItem(value: _NavSection.about, child: Text('About')),
                      PopupMenuItem(value: _NavSection.skills, child: Text('Skills')),
                      PopupMenuItem(value: _NavSection.experience, child: Text('Experience')),
                      PopupMenuItem(value: _NavSection.projects, child: Text('Projects')),
                      PopupMenuItem(value: _NavSection.contact, child: Text('Contact')),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _NavSection { home, about, skills, experience, projects, contact }

class NavLink extends StatefulWidget {
  const NavLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.primary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _hovered ? AppColors.primary : AppColors.text.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// HERO SECTION — Gradient text + typewriter
// ──────────────────────────────────────────────

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.onProjects,
    required this.onContact,
    required this.onDownload,
  });

  final VoidCallback onProjects;
  final VoidCallback onContact;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return SectionWrapper(
      padTop: 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                StaggerEntrance(
                  delay: 0,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent, AppColors.primary],
                      stops: [0.0, 0.5, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      'Aung Khant Kyaw',
                      style: GoogleFonts.inter(
                        fontSize: isWide ? 48 : 36,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                StaggerEntrance(
                  delay: 200,
                  child: TypewriterText(
                    texts: const [
                      'Flutter Developer',
                      'Mobile App Developer',
                      'Clean Architecture Advocate',
                      'UI/UX Enthusiast',
                    ],
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                StaggerEntrance(
                  delay: 400,
                  child: Text(
                    'I build scalable, clean, and user-focused mobile applications with Flutter and modern development practices.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                StaggerEntrance(
                  delay: 600,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      PrimaryButton(label: 'View Projects', onTap: onProjects),
                      SecondaryButton(label: 'Contact Me', onTap: onContact),
                      SecondaryButton(label: 'Download CV', onTap: onDownload),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isWide) const SizedBox(width: 40),
          if (isWide)
            Expanded(
              flex: 2,
              child: StaggerEntrance(
                delay: 500,
                child: CardContainer(
                  child: Column(
                    children: const [
                      OrbitingProfileImage(),
                      SizedBox(height: 16),
                      Text(
                        'Professional Flutter developer focused on clean architecture, performance, and polished user experiences.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// TYPEWRITER TEXT
// ──────────────────────────────────────────────

class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.texts,
    required this.style,
  });

  final List<String> texts;
  final TextStyle style;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  int _textIndex = 0;
  String _displayText = '';
  bool _isDeleting = false;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _blinkCursor();
  }

  Future<void> _blinkCursor() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) setState(() => _showCursor = !_showCursor);
    }
  }

  Future<void> _startTyping() async {
    while (mounted) {
      final fullText = widget.texts[_textIndex];

      // Type
      for (int i = 0; i <= fullText.length; i++) {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 60));
        if (mounted) setState(() => _displayText = fullText.substring(0, i));
      }

      await Future.delayed(const Duration(milliseconds: 2000));

      // Delete
      for (int i = fullText.length; i >= 0; i--) {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 35));
        if (mounted) {
          setState(() {
            _displayText = fullText.substring(0, i);
            _isDeleting = true;
          });
        }
      }

      _isDeleting = false;
      _textIndex = (_textIndex + 1) % widget.texts.length;
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_displayText, style: widget.style),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _showCursor ? 1.0 : 0.0,
          child: Text(
            '|',
            style: widget.style.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// ORBITING PROFILE IMAGE (atom/electron ring)
// ──────────────────────────────────────────────

class OrbitingProfileImage extends StatefulWidget {
  const OrbitingProfileImage({super.key});

  @override
  State<OrbitingProfileImage> createState() => _OrbitingProfileImageState();
}

class _OrbitingProfileImageState extends State<OrbitingProfileImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _OrbitPainter(progress: _controller.value),
            child: child,
          );
        },
        child: Center(
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF0E2A3A), Color(0xFF162038)],
              ),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double progress;
  _OrbitPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Orbit ring
    final ringPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, ringPaint);

    // Orbiting dot
    final angle = progress * 2 * pi;
    final dotX = center.dx + radius * cos(angle);
    final dotY = center.dy + radius * sin(angle);

    // Glow
    final glowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(dotX, dotY), 5, glowPaint);

    // Core dot
    final dotPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(Offset(dotX, dotY), 3, dotPaint);

    // Second orbit (opposite)
    final angle2 = progress * 2 * pi + pi;
    final dotX2 = center.dx + radius * cos(angle2);
    final dotY2 = center.dy + radius * sin(angle2);

    glowPaint.color = AppColors.accent.withOpacity(0.3);
    canvas.drawCircle(Offset(dotX2, dotY2), 4, glowPaint);

    dotPaint.color = AppColors.accent;
    canvas.drawCircle(Offset(dotX2, dotY2), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ──────────────────────────────────────────────
// STAGGER ENTRANCE ANIMATION
// ──────────────────────────────────────────────

class StaggerEntrance extends StatefulWidget {
  const StaggerEntrance({
    super.key,
    required this.child,
    this.delay = 0,
  });

  final Widget child;
  final int delay;

  @override
  State<StaggerEntrance> createState() => _StaggerEntranceState();
}

class _StaggerEntranceState extends State<StaggerEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}

// ──────────────────────────────────────────────
// ABOUT SECTION
// ──────────────────────────────────────────────

class AboutSection extends StatelessWidget {
  const AboutSection({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return SectionWrapper(
      title: 'About',
      child: RevealOnScroll(
        controller: controller,
        child: CardContainer(
          child: Text(
            'I am a Flutter and mobile app developer focused on delivering reliable, maintainable, and high-performance applications. My interests include Flutter, SwiftUI, clean architecture, performance optimization, and building user experiences that feel effortless and professional.',
            style: const TextStyle(color: AppColors.muted, height: 1.7),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// SKILLS SECTION
// ──────────────────────────────────────────────

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return SectionWrapper(
      title: 'Skills',
      child: RevealOnScroll(
        controller: controller,
        child: Wrap(
          spacing: 18,
          runSpacing: 18,
          children: const [
            SkillGroup(
              title: 'Mobile Development',
              icon: Icons.phone_iphone,
              skills: ['Flutter', 'Dart', 'SwiftUI'],
            ),
            SkillGroup(
              title: 'Backend / Services',
              icon: Icons.cloud,
              skills: ['Firebase', 'REST API', 'Authentication', 'Cloud Integration'],
            ),
            SkillGroup(
              title: 'State Management \n Architecture',
              icon: Icons.account_tree,
              skills: ['Provider', 'Riverpod', 'Clean Architecture', 'MVVM'],
            ),
            SkillGroup(
              title: 'Tools',
              icon: Icons.build,
              skills: ['Git', 'GitHub', 'Postman', 'Figma', 'Xcode', 'VS Code'],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// EXPERIENCE SECTION
// ──────────────────────────────────────────────

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return SectionWrapper(
      title: 'Experience',
      child: RevealOnScroll(
        controller: controller,
        child: CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Professional Summary',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
              ),
              SizedBox(height: 10),
              Text(
                'Worked on real-world mobile projects focused on clean UI implementation, API integration, debugging, and performance optimization. Collaborated with designers and developers, ensured maintainable architecture, and continuously improved through every release cycle.',
                style: TextStyle(color: AppColors.muted, height: 1.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// PROJECTS SECTION
// ──────────────────────────────────────────────

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final projects = [
      ProjectCardData(
        title: 'Shopping App',
        description:
            'E-commerce mobile app with product browsing, cart management, checkout flow, and user-friendly UI.',
        tech: ['Flutter', 'Firebase', 'REST API'],
        contribution: 'Built responsive UI and integrated cart and checkout features.',
      ),
      ProjectCardData(
        title: 'Portfolio App',
        description:
            'Personal portfolio application to showcase profile, skills, and completed projects.',
        tech: ['Flutter', 'Responsive UI'],
        contribution: 'Designed a polished layout and reusable UI components.',
      ),
    ];

    return SectionWrapper(
      title: 'Projects',
      child: RevealOnScroll(
        controller: controller,
        child: Wrap(
          spacing: 18,
          runSpacing: 18,
          children: projects
              .map(
                (project) => SizedBox(
                  width: 320,
                  child: ProjectCard(project: project),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// ACHIEVEMENTS SECTION
// ──────────────────────────────────────────────

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final items = [
      'Clean and maintainable code',
      'Strong UI implementation',
      'API integration experience',
      'Fast learner and adaptable developer',
    ];

    return SectionWrapper(
      title: 'Achievements & Strengths',
      child: RevealOnScroll(
        controller: controller,
        child: Wrap(
          spacing: 18,
          runSpacing: 18,
          children: items
              .map(
                (item) => SizedBox(
                  width: 260,
                  child: CardContainer(
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// CONTACT SECTION
// ──────────────────────────────────────────────

class ContactSection extends StatelessWidget {
  const ContactSection({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final contacts = [
      ContactItem(
        icon: Icons.mail,
        label: 'Email',
        value: 'aungkhantkyaw.dev@gmail.com',
        uri: Uri.parse('mailto:aungkhantkyaw.dev@gmail.com'),
      ),
      ContactItem(
        icon: Icons.code,
        label: 'GitHub',
        value: 'github.com/AKhantKyaw',
        uri: Uri.parse('https://github.com/AKhantKyaw'),
      ),
      ContactItem(
        icon: Icons.work,
        label: 'LinkedIn',
        value: 'linkedin.com/in/aung-khant-kyaw-530611240/',
        uri: Uri.parse('https://linkedin.com/in/aung-khant-kyaw-530611240/'),
      ),
      ContactItem(
        icon: Icons.phone,
        label: 'Phone',
        value: '+95 9 768 728 075',
        uri: Uri.parse('tel:+959768728075'),
      ),
      ContactItem(
        icon: Icons.location_on,
        label: 'Location',
        value: 'Mandalay, Myanmar',
        uri: Uri.parse('https://maps.google.com/?q=Mandalay%2C%20Myanmar'),
      ),
    ];

    return SectionWrapper(
      title: 'Contact',
      child: RevealOnScroll(
        controller: controller,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Open to remote opportunities, freelance projects, and full-time roles.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: contacts
                  .map(
                    (contact) => SizedBox(
                      width: 260,
                      child: ContactCard(item: contact),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// FOOTER — Gradient divider
// ──────────────────────────────────────────────

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gradient divider line
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primary,
                AppColors.accent,
                Colors.transparent,
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            '© 2026 Aung Khant Kyaw. All rights reserved.',
            style: TextStyle(color: AppColors.muted.withOpacity(0.7)),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// SECTION WRAPPER — with accent bar on title
// ──────────────────────────────────────────────

class SectionWrapper extends StatelessWidget {
  const SectionWrapper({
    super.key,
    this.title,
    this.child,
    this.padTop = 50,
  });

  final String? title;
  final Widget? child;
  final double padTop;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;
    final isTablet = width > 600 && width <= 900;
    final horizontalPadding = isWide ? 100.0 : (isTablet ? 40.0 : 20.0);
    final effectiveTop = isWide ? padTop : (padTop * 0.7);
    final bottomPadding = isWide ? 40.0 : 28.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        effectiveTop,
        horizontalPadding,
        bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                // Cyan accent bar
                Container(
                  width: 4,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title!,
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          child!,
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// CARD CONTAINER — Glass + glow border
// ──────────────────────────────────────────────

class CardContainer extends StatelessWidget {
  const CardContainer({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlowHoverCard(
      onTap: onTap,
      child: child,
    );
  }
}

class GlowHoverCard extends StatefulWidget {
  const GlowHoverCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<GlowHoverCard> createState() => _GlowHoverCardState();
}

class _GlowHoverCardState extends State<GlowHoverCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _glowAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() {
    setState(() => _hovered = true);
    _controller.forward();
  }

  void _onExit() {
    setState(() => _hovered = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, _) {
            final glow = _glowAnimation.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color.lerp(
                    AppColors.border,
                    AppColors.primary.withOpacity(0.5),
                    glow,
                  )!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05 + glow * 0.12),
                    blurRadius: 18 + glow * 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: widget.child,
            );
          },
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// SKILL GROUP — Icon pulse on hover
// ──────────────────────────────────────────────

class SkillGroup extends StatefulWidget {
  const SkillGroup({
    super.key,
    required this.title,
    required this.icon,
    required this.skills,
  });

  final String title;
  final IconData icon;
  final List<String> skills;

  @override
  State<SkillGroup> createState() => _SkillGroupState();
}

class _SkillGroupState extends State<SkillGroup>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(_pulse.value * 0.15),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Icon(widget.icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.skills
                  .map(
                    (skill) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.accent.withOpacity(0.08),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                        ),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// PROJECT CARD
// ──────────────────────────────────────────────

class ProjectCardData {
  ProjectCardData({
    required this.title,
    required this.description,
    required this.tech,
    required this.contribution,
  });

  final String title;
  final String description;
  final List<String> tech;
  final String contribution;
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});

  final ProjectCardData project;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            project.description,
            style: const TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: project.tech
                .map(
                  (tech) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.accent.withOpacity(0.08),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.15),
                      ),
                    ),
                    child: Text(
                      tech,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'Contribution: ${project.contribution}',
            style: const TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View Details'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// CONTACT CARD — Glow ring on icon
// ──────────────────────────────────────────────

class ContactItem {
  ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    this.uri,
  });

  final IconData icon;
  final String label;
  final String value;
  final Uri? uri;
}

class ContactCard extends StatefulWidget {
  const ContactCard({super.key, required this.item});

  final ContactItem item;

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      onTap: widget.item.uri == null ? null : () => _launch(widget.item.uri!),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(_hovered ? 0.2 : 0.1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(_hovered ? 0.3 : 0.0),
                  blurRadius: _hovered ? 12 : 0,
                ),
              ],
            ),
            child: MouseRegion(
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: Icon(
                widget.item.icon,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.item.value,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          if (widget.item.uri != null)
            Icon(
              Icons.open_in_new,
              size: 16,
              color: AppColors.muted.withOpacity(0.6),
            ),
        ],
      ),
    );
  }

  Future<void> _launch(Uri uri) async {
    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) return;
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

// ──────────────────────────────────────────────
// BUTTONS — Glow + smooth hover
// ──────────────────────────────────────────────

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_hovered ? 1.04 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(_hovered ? 0.35 : 0.15),
              blurRadius: _hovered ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: widget.onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatefulWidget {
  const SecondaryButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: OutlinedButton(
          onPressed: widget.onTap,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(
              color: _hovered ? AppColors.primary : AppColors.border,
              width: _hovered ? 1.5 : 1,
            ),
            foregroundColor: _hovered ? AppColors.primary : AppColors.text,
            backgroundColor:
                _hovered ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
          ),
          child: Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// SCROLL REVEAL ANIMATION
// ──────────────────────────────────────────────

class SimpleEntrance extends StatefulWidget {
  const SimpleEntrance({super.key, required this.child});

  final Widget child;

  @override
  State<SimpleEntrance> createState() => _SimpleEntranceState();
}

class _SimpleEntranceState extends State<SimpleEntrance> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 700),
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 700),
        offset: _visible ? Offset.zero : const Offset(0, 0.06),
        child: widget.child,
      ),
    );
  }
}

class RevealOnScroll extends StatefulWidget {
  const RevealOnScroll({
    super.key,
    required this.controller,
    required this.child,
  });

  final ScrollController controller;
  final Widget child;

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleScroll());
  }

  @override
  void didUpdateWidget(covariant RevealOnScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleScroll);
      widget.controller.addListener(_handleScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (_visible) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final position = renderBox.localToGlobal(Offset.zero).dy;
    final height = MediaQuery.of(context).size.height;
    if (position < height * 0.85) {
      setState(() => _visible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 700),
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.08),
        child: widget.child,
      ),
    );
  }
}

// ──────────────────────────────────────────────
// SCROLL BEHAVIOR
// ──────────────────────────────────────────────

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

// ──────────────────────────────────────────────
// COLOR PALETTE — DARK SCIENCE THEME
// ──────────────────────────────────────────────

class AppColors {
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color text = Color(0xFFE2E8F0);
  static const Color muted = Color(0xFF94A3B8);
  static const Color primary = Color(0xFF06B6D4);
  static const Color accent = Color(0xFF8B5CF6);
  static const Color border = Color(0xFF1E293B);
  static const Color chip = Color(0xFF0E2A3A);
  static const Color glow = Color(0x2606B6D4);
}
