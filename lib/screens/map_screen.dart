import 'package:flutter/material.dart';
import 'exercise_screen.dart';
import 'dart:ui' show ImageFilter;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Map<String, dynamic> _best = {}; // melhor pontuação por lição
  Map<String, dynamic> _totals =
      {}; // total de questões por lição (preenchido ao concluir)
  int _xp = 0;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final bestStr = prefs.getString('bestScores');
    final totalsStr = prefs.getString('totals');
    setState(() {
      _best = bestStr != null
          ? Map<String, dynamic>.from(json.decode(bestStr))
          : {};
      _totals = totalsStr != null
          ? Map<String, dynamic>.from(json.decode(totalsStr))
          : {};
      _xp = prefs.getInt('xp') ?? 0;
      _coins = prefs.getInt('coins') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fases (ícone, cor e status)
    final phases = List.generate(10, (i) {
      switch (i) {
        case 0:
          return (
            icon: Icons.star,
            color: Colors.deepPurpleAccent,
            locked: false,
          );
        case 1:
          return (icon: Icons.book, color: Colors.tealAccent, locked: false);
        case 2:
          return (
            icon: Icons.extension,
            color: Colors.pinkAccent,
            locked: false,
          );
        case 3:
          return (icon: Icons.star, color: Colors.amber, locked: false);
        case 4:
          return (
            icon: Icons.book,
            color: Colors.lightBlueAccent,
            locked: false,
          );
        case 5:
          return (icon: Icons.star, color: Colors.greenAccent, locked: false);
        case 6:
          return (icon: Icons.book, color: Colors.cyanAccent, locked: false);
        case 7:
          return (icon: Icons.star, color: Colors.orangeAccent, locked: false);
        case 8:
          return (icon: Icons.book, color: Colors.purpleAccent, locked: false);
        case 9:
          return (
            icon: Icons.school,
            color: Colors.deepPurpleAccent,
            locked: false,
          );
        default:
          return (icon: Icons.star, color: Colors.blueAccent, locked: false);
      }
    });

    final icons = [
      for (int i = 0; i < phases.length; i++)
        _PhaseIcon(
          icon: phases[i].icon,
          color: phases[i].color,
          locked: phases[i].locked,
          heroTag: 'phase_$i',
          badgeText: (_best['$i'] ?? 0) > 0
              ? (_totals['$i'] != null
                    ? '${_best['$i']}/${_totals['$i']}'
                    : '${_best['$i']})')
              : null,
          completed: _totals['$i'] != null && _best['$i'] == _totals['$i'],
        ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'HelloJava',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1440), Color(0xFF0B0B12)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          _StatChip(
            icon: Icons.flash_on,
            label: '$_xp',
            color: Colors.amberAccent,
          ),
          const SizedBox(width: 8),
          _StatChip(
            icon: Icons.monetization_on,
            label: '$_coins',
            color: Colors.lightGreenAccent,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Fundo com gradiente escuro
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B0B12),
                  Color(0xFF121225),
                  Color(0xFF0B0B12),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Radial glow sutil
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.12),
                      Colors.transparent,
                    ],
                    radius: 0.9,
                    center: const Alignment(0, -0.8),
                  ),
                ),
              ),
            ),
          ),
          // Conteúdo
          ListView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            children: [
              // Card translúcido da seção (glass)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.school, color: Colors.white, size: 32),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seção 1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Aprenda Java Básico',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
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
              const SizedBox(height: 28),

              // Road com curvas e nós
              _MapRoad(
                icons: icons,
                onTap: (index) {
                  if (!mounted) return;
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => ExerciseScreen(
                            exerciseIndex: index,
                            heroIcon: phases[index].icon,
                            heroColor: phases[index].color,
                          ),
                        ),
                      )
                      .then((_) => _loadProgress());
                },
              ),

              const SizedBox(height: 48),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121225),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.extension), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

class _MapRoad extends StatelessWidget {
  final List<_PhaseIcon> icons;
  final void Function(int index)? onTap;
  const _MapRoad({required this.icons, this.onTap});

  @override
  Widget build(BuildContext context) {
    const double nodeSize = 82;
    const double gapY = 130;
    const double sidePadding = 24;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double leftX = sidePadding + nodeSize / 2;
        final double rightX = constraints.maxWidth - sidePadding - nodeSize / 2;

        final positions = <Offset>[];
        for (int i = 0; i < icons.length; i++) {
          final bool isLeft = i.isEven;
          final double x = isLeft ? leftX : rightX;
          final double y = i * gapY + nodeSize / 2;
          positions.add(Offset(x, y));
        }

        final totalHeight = (icons.length - 1) * gapY + nodeSize + 24;

        return SizedBox(
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Estrada com curvas
              Positioned.fill(
                child: CustomPaint(painter: _RoadPainter(positions: positions)),
              ),
              // Nós (fases)
              for (int i = 0; i < icons.length; i++)
                Positioned(
                  left: positions[i].dx - nodeSize / 2,
                  top: positions[i].dy - nodeSize / 2,
                  child: SizedBox(
                    width: nodeSize,
                    height: nodeSize,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(nodeSize / 2),
                        onTap: onTap != null ? () => onTap!(i) : null,
                        child: Hero(tag: icons[i].heroTag, child: icons[i]),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RoadPainter extends CustomPainter {
  final List<Offset> positions;
  _RoadPainter({required this.positions});

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    final path = Path()..moveTo(positions.first.dx, positions.first.dy);
    for (int i = 0; i < positions.length - 1; i++) {
      final p1 = positions[i];
      final p2 = positions[i + 1];
      final control = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      path.quadraticBezierTo(control.dx, control.dy, p2.dx, p2.dy);
    }

    // Glow externo (ciano)
    final glowOuter = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    // Glow interno (roxo)
    final glowInner = Paint()
      ..color = Colors.purpleAccent.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    // Estrada principal
    final road = Paint()
      ..color = const Color(0xFF8E7CFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Highlight suave no centro
    final highlight = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Ordem: glows -> estrada -> highlight
    canvas.drawPath(path, glowOuter);
    canvas.drawPath(path, glowInner);
    canvas.drawPath(path, road);
    canvas.drawPath(path, highlight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PhaseIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool locked;
  final String heroTag;
  final String? badgeText;
  final bool completed;
  const _PhaseIcon({
    required this.icon,
    required this.color,
    required this.heroTag,
    this.locked = false,
    this.badgeText,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = completed
        ? Colors.greenAccent
        : (locked ? Colors.white24 : color);
    final Color fillColor = locked
        ? Colors.white.withOpacity(0.05)
        : color.withOpacity(0.12);
    final Color iconColor = Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: fillColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: (completed ? Colors.greenAccent : color).withOpacity(
                  0.35,
                ),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(child: Icon(icon, color: iconColor, size: 34)),
        ),
        if (completed)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.black),
            ),
          )
        else if (badgeText != null)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                badgeText!,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
