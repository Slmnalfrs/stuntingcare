import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/app_sizes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final s = AppSizes(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: s.appBarExpanded,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.primary,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.segment_rounded, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: 'Menu',
              ),
            ),
            title: Text(
              'StuntingCare',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: s.fontXl,
                letterSpacing: 1.1,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withAlpha(230),
                      colorScheme.primary.withAlpha(200),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      right: -10,
                      child: Icon(
                        Icons.favorite_rounded,
                        size: s.screenWidth * 0.38,
                        color: Colors.white.withAlpha(25),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: -20,
                      child: Container(
                        width: s.screenWidth * 0.28,
                        height: s.screenWidth * 0.28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(15),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          s.paddingLg,
                          MediaQuery.of(context).padding.top + 70,
                          s.paddingLg,
                          s.spacingLg),
                      child: Consumer<ProfileProvider>(
                        builder: (context, profileProvider, _) {
                          final profile = profileProvider.profile;
                          final name = profile?.nama.split(' ').first ?? 'Bunda';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Halo, $name! 👋',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: s.font3xl,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: s.spacingXS),
                              Text(
                                'Mari cegah stunting bersama untuk\nmasa depan si kecil yang gemilang.',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: s.fontMd,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(s.padding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Consumer<ProfileProvider>(
                  builder: (context, profileProvider, _) {
                    final profile = profileProvider.profile;
                    if (profile == null) return const SizedBox.shrink();

                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: s.spacingLg, horizontal: s.spacing),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(s.radiusXl),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(s, 'Usia', '${profile.usia}', Icons.cake_rounded),
                              _buildDivider(),
                              _buildStatItem(s, 'Tinggi', '${profile.tinggiBadan}', Icons.straighten_rounded),
                              _buildDivider(),
                              _buildStatItem(s, 'Berat', '${profile.beratBadanAwal}', Icons.fitness_center_rounded),
                            ],
                          ),
                        ),
                        SizedBox(height: s.spacingXL),
                      ],
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Layanan',
                      style: TextStyle(
                        fontSize: s.fontXl,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E1E1E),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s.spacing),
                _buildServiceCard(
                  context,
                  s: s,
                  title: 'AI Chatbot',
                  subtitle: 'Konsultasi & pencegahan stunting',
                  icon: Icons.psychology_rounded,
                  color: colorScheme.primary,
                  isFullWidth: true,
                  onTap: () => Navigator.pushNamed(context, '/chatbot'),
                ),
                SizedBox(height: s.spacing),
                Row(
                  children: [
                    Expanded(
                      child: _buildServiceCard(
                        context,
                        s: s,
                        title: 'Riwayat Chat',
                        subtitle: 'Lihat obrolan',
                        icon: Icons.question_answer_rounded,
                        color: const Color(0xFF10B981),
                        onTap: () => Navigator.pushNamed(context, '/chat-history'),
                      ),
                    ),
                    SizedBox(width: s.spacing),
                    Expanded(
                      child: _buildServiceCard(
                        context,
                        s: s,
                        title: 'Profil Saya',
                        subtitle: 'Data kesehatan',
                        icon: Icons.face_rounded,
                        color: const Color(0xFF8B5CF6),
                        onTap: () => Navigator.pushNamed(context, '/profile-form'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s.spacingXL),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(AppSizes s, String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(s.spacingSm),
          decoration: BoxDecoration(
            color: const Color(0xFF0891B2).withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF0891B2), size: s.iconSm),
        ),
        SizedBox(height: s.spacingXS),
        Text(
          value,
          style: TextStyle(
            fontSize: s.fontLg,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E1E1E),
            letterSpacing: -0.5,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: s.fontXs,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1.5,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required AppSizes s,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isFullWidth ? s.cardHeightFull : s.cardHeightHalf + 25,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(s.radius2x),
          border: Border.all(color: color.withValues(alpha: 0.08), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(isFullWidth ? s.padding : s.spacing),
          child: isFullWidth
              ? Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(s.spacingSm + 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(s.radiusLg),
                      ),
                      child: Icon(icon, color: color, size: s.iconLg),
                    ),
                    SizedBox(width: s.spacingLg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: s.fontXl,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1E1E1E),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: s.spacingXS / 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: s.fontSm,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: color.withValues(alpha: 0.3), size: s.iconMd + 4),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(s.spacing),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(s.radiusMd),
                      ),
                      child: Icon(icon, color: color, size: s.iconLg - 4),
                    ),
                    SizedBox(height: s.spacingLg),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: s.fontLg,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E1E1E),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: s.spacingXS / 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: s.fontSm,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
