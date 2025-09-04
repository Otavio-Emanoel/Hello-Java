import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = const LinearGradient(
      colors: [Color(0xFF0B0B12), Color(0xFF141428), Color(0xFF0B0B12)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final sections = [
      (
        title: 'Introdução ao Java',
        file: 'assets/content/introducao-java.md',
        bullets: [
          'O que é Java?',
          'JDK, JRE e JVM',
          'Primeiro programa: Hello World',
        ],
      ),
      (
        title: 'Sintaxe Básica',
        file: 'assets/content/sintaxe-basica.md',
        bullets: [
          'Tipos primitivos',
          'Variáveis e operadores',
          'Entrada e saída (Scanner)',
        ],
      ),
      (
        title: 'Controle de Fluxo',
        file: 'assets/content/controle-de-fluxo.md',
        bullets: ['if/else', 'switch', 'loops for/while/do-while'],
      ),
      (
        title: 'Orientação a Objetos',
        file: 'assets/content/poo-basico.md',
        bullets: [
          'Classes e objetos',
          'Construtores',
          'Encapsulamento',
          'Herança e polimorfismo (introdução)',
        ],
      ),
      (
        title: 'Coleções e Arrays',
        file: 'assets/content/colecoes-arrays.md',
        bullets: [
          'Arrays e Arrays multidimensionais',
          'List, Set, Map (Visão geral)',
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Conteúdos', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bg),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sections.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final sec = sections[i];
            return _ContentCard(
              title: sec.title,
              bullets: sec.bullets,
              file: sec.file,
            );
          },
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String title;
  final String file;
  final List<String> bullets;
  const _ContentCard({
    required this.title,
    required this.file,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, color: Colors.purpleAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _ContentDetail(title: title, file: file),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...bullets
              .take(3)
              .map(
                (it) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    '• $it',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _ContentDetail extends StatelessWidget {
  final String title;
  final String file;
  const _ContentDetail({required this.title, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(file),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
            );
          }
          return Markdown(
            data: snap.data!,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(color: Colors.white70),
              h1: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              h2: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              codeblockDecoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              code: const TextStyle(
                color: Colors.greenAccent,
                fontFamily: 'monospace',
              ),
              listBullet: const TextStyle(color: Colors.white70),
            ),
            selectable: true,
            padding: const EdgeInsets.all(16),
          );
        },
      ),
    );
  }
}
