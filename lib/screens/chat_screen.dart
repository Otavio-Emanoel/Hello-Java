import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  final List<_Msg> _messages = [
    _Msg(
      text: 'Bem-vindo ao Chat Java! Pergunte qualquer coisa sobre Java.',
      isUser: false,
    ),
  ];

  GenerativeModel? _model;
  bool _sending = false;
  int _dots = 0; // para animação simples "Gerando..."

  @override
  void initState() {
    super.initState();
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key != null && key.isNotEmpty) {
      _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: key);
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _messages.add(_Msg(text: text, isUser: true));
      _ctrl.clear();
      // placeholder "Gerando resposta..."
      _messages.add(_Msg(text: '::loading::', isUser: false));
    });

    // animação simples de pontinhos enquanto gera
    Future.doWhile(() async {
      if (!_sending) return false;
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _dots = (_dots + 1) % 4);
      return true;
    });

    String reply =
        'Não foi possível gerar resposta. Configure sua chave GEMINI_API_KEY no .env';

    if (_model != null) {
      try {
        final prompt =
            "Você é um tutor de Java. Responda de forma direta, objetiva, com exemplos curtos em Java, usando markdown. Pergunta: $text";
        final content = [Content.text(prompt)];
        final res = await _model!.generateContent(content);
        reply = res.text?.trim() ?? reply;
      } catch (e) {
        reply = 'Erro ao chamar Gemini: $e';
      }
    }

    if (!mounted) return;
    setState(() {
      _sending = false;
      _dots = 0;
      // remove placeholder ::loading::
      final idx = _messages.indexWhere((m) => m.text == '::loading::');
      if (idx != -1) _messages.removeAt(idx);
      _messages.add(_Msg(text: reply, isUser: false));
    });

    await Future.delayed(const Duration(milliseconds: 50));
    if (mounted) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Chat Java (Gemini)',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final isLoading = m.text == '::loading::';
                final bubble = Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 340),
                  decoration: BoxDecoration(
                    color: m.isUser
                        ? Colors.deepPurpleAccent.withOpacity(0.25)
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(m.isUser ? 14 : 4),
                      bottomRight: Radius.circular(m.isUser ? 4 : 14),
                    ),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: isLoading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Gerando resposta${'.' * _dots}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        )
                      : (m.isUser
                            ? Text(
                                m.text,
                                style: const TextStyle(color: Colors.white),
                              )
                            : MarkdownBody(
                                data: m.text,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(color: Colors.white),
                                  code: const TextStyle(
                                    fontFamily: 'monospace',
                                    color: Colors.white,
                                  ),
                                  codeblockPadding: const EdgeInsets.all(8),
                                  codeblockDecoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                ),
                              )),
                );
                return Align(
                  alignment: m.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: bubble,
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: const BoxDecoration(
                color: Color(0xFF121225),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Pergunte algo sobre Java...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sending ? null : _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.send),
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

class _Msg {
  final String text;
  final bool isUser;
  _Msg({required this.text, required this.isUser});
}
