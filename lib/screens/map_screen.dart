import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/icon.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'HelloJava',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.orange),
                SizedBox(width: 10),
                Text('4'),
                SizedBox(width: 16),
                Icon(Icons.star, color: Colors.blue),
                SizedBox(width: 10),
                Text('240'),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/map_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(),
            ),
          ),
          ListView(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.2),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.school, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
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
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PhaseIcon(
                    icon: Icons.lock,
                    color: Colors.grey,
                    locked: true,
                  ),
                  _PhaseIcon(icon: Icons.star, color: Colors.green),
                  _PhaseIcon(icon: Icons.volume_up, color: Colors.green),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PhaseIcon(icon: Icons.book, color: Colors.green),
                  _PhaseIcon(icon: Icons.star, color: Colors.amber),
                  _PhaseIcon(icon: Icons.book, color: Colors.green),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PhaseIcon(icon: Icons.star, color: Colors.green),
                  _PhaseIcon(icon: Icons.book, color: Colors.green),
                  _PhaseIcon(icon: Icons.star, color: Colors.green),
                ],
              ),
              // Espaço extra para o fim da lista
              const SizedBox(height: 48),
            ],
          ),
        ],
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

class _PhaseIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool locked;
  const _PhaseIcon({
    required this.icon,
    required this.color,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = locked ? Colors.grey : color;
    final Color fillColor = locked
        ? Colors.grey[200]!
        : color.withOpacity(0.15);
    final Color iconColor = locked ? Colors.grey : color;
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.18),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: Icon(icon, color: iconColor, size: 32)),
    );
  }
}
