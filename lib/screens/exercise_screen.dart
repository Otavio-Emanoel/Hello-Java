import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class ExerciseScreen extends StatefulWidget {
  final int exerciseIndex;
  final IconData? heroIcon;
  final Color? heroColor;
  const ExerciseScreen({super.key, required this.exerciseIndex, this.heroIcon, this.heroColor});

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

  void _next(List questions) {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedIndex = -1;
      });
    } else {
      // Final
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Parabéns!'),
          content: Text('Você acertou $score de ${questions.length} questões.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            ElevatedButton(
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
        appBar: AppBar(title: const Text('Exercício')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final questions = exercise!["questions"] as List<dynamic>;
    final q = questions[currentQuestion];

    final heroTag = 'phase_${widget.exerciseIndex}';
    final heroColor = widget.heroColor ?? Colors.deepPurple;
    final heroIcon = widget.heroIcon ?? Icons.star;

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise!["title"] ?? "Exercício"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de progresso
            LinearProgressIndicator(
              value: (currentQuestion + 1) / questions.length,
              backgroundColor: Colors.deepPurple.shade100,
              color: Colors.deepPurple,
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
                          color: heroColor.withOpacity(0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(heroIcon, color: heroColor, size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Questão ${currentQuestion + 1} de ${questions.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple,
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
                child: Card(
                  key: ValueKey(currentQuestion),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q["question"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate((q["options"] as List).length, (j) {
                          final bool answered = selectedIndex != -1;
                          final int correct = q["answer"] as int;
                          Color border = Colors.grey.shade300;
                          Color fill = Colors.white;
                          Color text = Colors.black87;
                          IconData leading = Icons.circle_outlined;
                          Color leadingColor = Colors.deepPurple;

                          if (answered) {
                            if (j == correct) {
                              border = Colors.green;
                              fill = Colors.green.withOpacity(0.08);
                              text = Colors.green.shade800;
                              leading = Icons.check_circle_rounded;
                              leadingColor = Colors.green;
                            } else if (j == selectedIndex) {
                              border = Colors.red;
                              fill = Colors.red.withOpacity(0.08);
                              text = Colors.red.shade800;
                              leading = Icons.cancel_rounded;
                              leadingColor = Colors.red;
                            }
                          } else if (j == selectedIndex) {
                            border = Colors.deepPurple;
                            fill = Colors.deepPurple.withOpacity(0.06);
                            text = Colors.deepPurple.shade800;
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
                                        style: TextStyle(fontSize: 16, color: text),
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
                  child: const Text('Anterior'),
                ),
                ElevatedButton.icon(
                  onPressed: selectedIndex == -1
                      ? null
                      : () => _next(questions),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(
                    currentQuestion < questions.length - 1 ? Icons.arrow_forward : Icons.flag,
                  ),
                  label: Text(
                    currentQuestion < questions.length - 1 ? 'Próxima' : 'Finalizar',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
