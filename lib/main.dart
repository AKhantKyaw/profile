import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const PortfolioApp());
}



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
          brightness: Brightness.light,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme().apply(
          bodyColor: AppColors.text,
          displayColor: AppColors.text,
        ),
      ),
      home: const PortfolioPage(),
    );
  }
}

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
          const Background(),
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
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Aung Khant Kyaw',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.text,
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
                    icon: const Icon(Icons.menu_rounded),
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
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.chip : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: AppColors.text.withOpacity(_hovered ? 1 : 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

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
                SimpleEntrance(
                  child: Text(
                    'Aung Khant Kyaw',
                    style: GoogleFonts.inter(
                      fontSize: isWide ? 44 : 34,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Flutter Developer | Mobile App Developer',
                  style: TextStyle(
                    color: AppColors.text.withOpacity(0.75),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'I build scalable, clean, and user-focused mobile applications with Flutter and modern development practices.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    PrimaryButton(label: 'View Projects', onTap: onProjects),
                    SecondaryButton(label: 'Contact Me', onTap: onContact),
                    SecondaryButton(label: 'Download CV', onTap: onDownload),
                  ],
                ),
              ],
            ),
          ),
          if (isWide) const SizedBox(width: 40),
          if (isWide)
            Expanded(
              flex: 2,
              child: CardContainer(
                child: Column(
                  children: const [
                    ProfileImage(),
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
        ],
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFE9EEF9), Color(0xFFD5DFF5)],
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Text(
          'Profile Image',
          style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

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
              title: 'State Management / Architecture',
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
                style: TextStyle(fontWeight: FontWeight.w600),
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
      // ProjectCardData(
      //   title: 'Delivery App',
      //   description:
      //       'Mobile application for delivery tracking, order updates, and status management.',
      //   tech: ['Flutter', 'API Integration', 'Provider'],
      //   contribution: 'Implemented live tracking UI and efficient state updates.',
      // ),
      ProjectCardData(
        title: 'Portfolio App',
        description:
            'Personal portfolio application to showcase profile, skills, and completed projects.',
        tech: ['Flutter', 'Responsive UI'],
        contribution: 'Designed a polished layout and reusable UI components.',
      ),
      // ProjectCardData(
      //   title: 'Admin / Dashboard App',
      //   description:
      //       'Business-focused app for managing content, products, or operational data.',
      //   tech: ['Flutter', 'API', 'State Management'],
      //   contribution: 'Built data management flows and optimized navigation patterns.',
      // ),
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
                    child: Text(item, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

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

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        '© 2026 Aung Khant Kyaw. All rights reserved.',
        style: TextStyle(color: AppColors.muted.withOpacity(0.9)),
      ),
    );
  }
}

class SectionWrapper extends StatelessWidget {
  const SectionWrapper({
    super.key,
    this.title,
    this.child ,
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
            Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
          ],
          child!,
        ],
      ),
    );
  }
}

class CardContainer extends StatelessWidget {
  const CardContainer({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class SkillGroup extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      backgroundColor: AppColors.chip,
                      side: BorderSide.none,
                      labelStyle: const TextStyle(fontSize: 12),
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
          Text(project.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(project.description, style: const TextStyle(color: AppColors.muted, height: 1.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: project.tech
                .map(
                  (tech) => Chip(
                    label: Text(tech),
                    backgroundColor: AppColors.chip,
                    side: BorderSide.none,
                    labelStyle: const TextStyle(fontSize: 12),
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
            child: TextButton(
              onPressed: () {},
              child: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }
}

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

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.item});

  final ContactItem item;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      onTap: item.uri == null ? null : () => _launch(item.uri!),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: Icon(item.icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(item.value, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          if (item.uri != null)
            Icon(Icons.open_in_new, size: 16, color: AppColors.muted.withOpacity(0.8)),
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

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppColors.border),
        foregroundColor: AppColors.text,
      ),
      child: Text(label),
    );
  }
}

class HoverCard extends StatefulWidget {
  const HoverCard({super.key, required this.child});

  final Widget child;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: _hovered ? 1.02 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          child: widget.child,
        ),
      ),
    );
  }
}

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
  const RevealOnScroll({super.key, required this.controller, required this.child});

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
      duration: const Duration(milliseconds: 600),
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 600),
        offset: _visible ? Offset.zero : const Offset(0, 0.06),
        child: widget.child,
      ),
    );
  }
}

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF6F8FC),
            Color(0xFFF1F4FA),
            Color(0xFFFDFEFF),
          ],
        ),
      ),
    );
  }
}

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

class AppColors {
  static const Color background = Color(0xFFF6F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF0F172A);
  static const Color muted = Color(0xFF5B6478);
  static const Color primary = Color(0xFF2563EB);
  static const Color border = Color(0xFFE3E8F2);
  static const Color chip = Color(0xFFF0F4FF);
}
