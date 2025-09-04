import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseScreen extends StatefulWidget {
  final int exerciseIndex;
  final IconData? heroIcon;
  final Color? heroColor;
  const ExerciseScreen({
    super.key,
    required this.exerciseIndex,
    this.heroIcon,
    this.heroColor,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  Map<String, dynamic>? exercise;
  bool loading = true;
  int currentQuestion = 0;
  int selectedIndex = -1;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final data = await rootBundle.loadString('assets/section-1-questions.json');
    final List<dynamic> list = json.decode(data);
    setState(() {
      exercise = list[widget.exerciseIndex];
      loading = false;
      currentQuestion = 0;
      selectedIndex = -1;
      score = 0;
    });
  }

  void _onSelect(int j) {
    if (selectedIndex != -1) return; // evita re-selecionar
    setState(() {
      selectedIndex = j;
      final q = (exercise!["questions"] as List)[currentQuestion];
      final correct = q["answer"] as int;
      if (j == correct) score++;
    });
  }

  Future<void> _saveResults({
    required int score,
    required int total,
    required int xpGain,
    required int coinsGain,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final idx = widget.exerciseIndex.toString();

    // carrega mapas existentes
    final bestStr = prefs.getString('bestScores');
    final totalsStr = prefs.getString('totals');
    final Map<String, dynamic> best = bestStr != null
        ? Map<String, dynamic>.from(json.decode(bestStr))
        : {};
    final Map<String, dynamic> totals = totalsStr != null
        ? Map<String, dynamic>.from(json.decode(totalsStr))
        : {};

    // atualiza best score se for maior
    final prevBest = (best[idx] as int?) ?? 0;
    if (score > prevBest) {
      best[idx] = score;
    }
    // guarda total de questões para cálculo de progresso no mapa
    totals[idx] = total;

    // atualiza XP/moedas
    final currentXp = prefs.getInt('xp') ?? 0;
    final currentCoins = prefs.getInt('coins') ?? 0;
    await prefs.setInt('xp', currentXp + xpGain);
    await prefs.setInt('coins', currentCoins + coinsGain);

    await prefs.setString('bestScores', json.encode(best));
    await prefs.setString('totals', json.encode(totals));
  }

  void _next(List questions) async {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedIndex = -1;
      });
    } else {
      // Final
      final int total = questions.length;
      final int xpGain = score * 10; // 10 XP por acerto
      final int coinsGain = score * 2; // 2 moedas por acerto
      await _saveResults(
        score: score,
        total: total,
        xpGain: xpGain,
        coinsGain: coinsGain,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1B1B25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Parabéns!', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Você acertou $score de $total questões.',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.flash_on, color: Colors.amberAccent),
                  const SizedBox(width: 6),
                  Text(
                    '+$xpGain XP',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.lightGreenAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '+$coinsGain moedas',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Continuar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
              ),
              onPressed: () {
                Navigator.of(context)
                  ..pop()
                  ..pop();
              },
              child: const Text('Voltar ao mapa'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading || exercise == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0B12),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Exercício', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
        ),
      );
    }
    final questions = exercise!["questions"] as List<dynamic>;
    final q = questions[currentQuestion];

    final heroTag = 'phase_${widget.exerciseIndex}';
    final heroColor = widget.heroColor ?? Colors.deepPurpleAccent;
    final heroIcon = widget.heroIcon ?? Icons.star;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          exercise!["title"] ?? "Exercício",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Fundo
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B0B12),
                  Color(0xFF141428),
                  Color(0xFF0B0B12),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra de progresso
                LinearProgressIndicator(
                  value: (currentQuestion + 1) / questions.length,
                  backgroundColor: Colors.white10,
                  color: Colors.deepPurpleAccent,
                  minHeight: 8,
                ),
                const SizedBox(height: 16),
                // Hero do nó
                Row(
                  children: [
                    Hero(
                      tag: heroTag,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: heroColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: heroColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: heroColor.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(heroIcon, color: Colors.white, size: 28),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Questão ${currentQuestion + 1} de ${questions.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Card da questão com transição
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0.02),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Container(
                      key: ValueKey(currentQuestion),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q["question"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate((q["options"] as List).length, (j) {
                            final bool answered = selectedIndex != -1;
                            final int correct = q["answer"] as int;
                            Color border = Colors.white10;
                            Color fill = Colors.white.withOpacity(0.02);
                            Color text = Colors.white;
                            IconData leading = Icons.circle_outlined;
                            Color leadingColor = Colors.deepPurpleAccent;

                            if (answered) {
                              if (j == correct) {
                                border = Colors.greenAccent;
                                fill = Colors.greenAccent.withOpacity(0.08);
                                text = Colors.greenAccent;
                                leading = Icons.check_circle_rounded;
                                leadingColor = Colors.greenAccent;
                              } else if (j == selectedIndex) {
                                border = Colors.redAccent;
                                fill = Colors.redAccent.withOpacity(0.08);
                                text = Colors.redAccent;
                                leading = Icons.cancel_rounded;
                                leadingColor = Colors.redAccent;
                              } else {
                                text = Colors.white70;
                              }
                            } else if (j == selectedIndex) {
                              border = Colors.deepPurpleAccent;
                              fill = Colors.deepPurpleAccent.withOpacity(0.10);
                              text = Colors.deepPurpleAccent;
                            }

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: fill,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: border, width: 2),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: answered ? null : () => _onSelect(j),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(leading, color: leadingColor),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          q["options"][j],
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: text,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Navegação
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: currentQuestion > 0
                          ? () => setState(() {
                              currentQuestion--;
                              selectedIndex = -1;
                            })
                          : null,
                      child: const Text(
                        'Anterior',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: selectedIndex == -1
                          ? null
                          : () => _next(questions),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        currentQuestion < questions.length - 1
                            ? Icons.arrow_forward
                            : Icons.flag,
                      ),
                      label: Text(
                        currentQuestion < questions.length - 1
                            ? 'Próxima'
                            : 'Finalizar',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
