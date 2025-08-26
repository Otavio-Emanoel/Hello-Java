import 'package:flutter/material.dart';
import 'exercise_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fases (ícone, cor e status)
    final phases = List.generate(10, (i) {
      switch (i) {
        case 0:
          return (icon: Icons.star, color: Colors.deepPurple, locked: false);
        case 1:
          return (icon: Icons.book, color: Colors.green, locked: false);
        case 2:
          return (icon: Icons.volume_up, color: Colors.green, locked: false);
        case 3:
          return (icon: Icons.star, color: Colors.amber, locked: false);
        case 4:
          return (icon: Icons.book, color: Colors.green, locked: false);
        case 5:
          return (icon: Icons.star, color: Colors.green, locked: false);
        case 6:
          return (icon: Icons.book, color: Colors.green, locked: false);
        case 7:
          return (icon: Icons.star, color: Colors.green, locked: false);
        case 8:
          return (icon: Icons.book, color: Colors.green, locked: false);
        case 9:
          return (icon: Icons.school, color: Colors.deepPurple, locked: false);
        default:
          return (icon: Icons.star, color: Colors.green, locked: false);
      }
    });

    final icons = [
      for (int i = 0; i < phases.length; i++)
        _PhaseIcon(
          icon: phases[i].icon,
          color: phases[i].color,
          locked: phases[i].locked,
          heroTag: 'phase_$i',
        ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: const Text(
          'HelloJava',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F6F2), Color(0xFFEDEAF7), Color(0xFFF7F6F2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          children: [
            // Card da seção
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.25),
                    blurRadius: 16,
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
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Road com curvas e nós
            _MapRoad(
              icons: icons,
              onTap: (index) {
                if (phases[index].locked) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExerciseScreen(
                      exerciseIndex: index,
                      heroIcon: phases[index].icon,
                      heroColor: phases[index].color,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.volume_up), label: ''),
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

    // sombra da estrada
    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // estrada principal
    final road = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(positions.first.dx, positions.first.dy);
    for (int i = 0; i < positions.length - 1; i++) {
      final p1 = positions[i];
      final p2 = positions[i + 1];
      final control = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      path.quadraticBezierTo(control.dx, control.dy, p2.dx, p2.dy);
    }

    // desenha com sombra + cor
    canvas.drawPath(path, shadow);
    canvas.drawPath(path, road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PhaseIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool locked;
  final String heroTag;
  const _PhaseIcon({
    required this.icon,
    required this.color,
    required this.heroTag,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = locked ? Colors.grey : color;
    final Color fillColor = locked
        ? Colors.grey[200]!
        : color.withOpacity(0.15);
    final Color iconColor = locked ? Colors.grey : color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(child: Icon(icon, color: iconColor, size: 34)),
    );
  }
}
