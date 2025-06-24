import 'package:flutter/material.dart';
import 'country.dart';

class QuizScreen extends StatefulWidget {
  final List<Country> countries;

  const QuizScreen({super.key, required this.countries});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Country> quizCountries;
  int currentQuestionIndex = 0;
  int score = 0;
  bool answered = false;
  String? selectedAnswer;
  List<String> currentChoices = [];

  @override
  void initState() {
    super.initState();
    quizCountries = widget.countries..shuffle();
    quizCountries = quizCountries.take(10).toList();
    generateChoices();
  }

  void generateChoices() {
    final currentCountry = quizCountries[currentQuestionIndex];

    final otherCapitals = widget.countries
        .where((c) => c.name != currentCountry.name)
        .map((c) => c.capital)
        .toSet()
        .toList()
      ..shuffle();

    final options = otherCapitals.take(3).toList()
      ..add(currentCountry.capital)
      ..shuffle();

    setState(() {
      currentChoices = options;
    });
  }

  void checkAnswer(String answer) {
    if (answered) return;

    setState(() {
      answered = true;
      selectedAnswer = answer;
      if (answer == quizCountries[currentQuestionIndex].capital) {
        score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (currentQuestionIndex < quizCountries.length - 1) {
        setState(() {
          currentQuestionIndex++;
          answered = false;
          selectedAnswer = null;
        });
        generateChoices();
      } else {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Quiz terminé'),
            content: Text('Votre score : $score / ${quizCountries.length}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    quizCountries.shuffle();
                    quizCountries = quizCountries.take(10).toList();
                    currentQuestionIndex = 0;
                    score = 0;
                    answered = false;
                    selectedAnswer = null;
                  });
                  generateChoices();
                },
                child: const Text('Rejouer'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCountry = quizCountries[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz : Capitales'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / quizCountries.length,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Question ${currentQuestionIndex + 1} / ${quizCountries.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  'Quelle est la capitale de ${currentCountry.name} ?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    currentCountry.flag,
                    width: 60,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...currentChoices.map((capital) {
              final isCorrect = capital == currentCountry.capital;
              final isSelected = selectedAnswer == capital;

              Color getColor() {
                if (!answered) return Colors.blue;
                if (isCorrect) return Colors.green;
                if (isSelected && !isCorrect) return Colors.red;
                return Colors.grey.shade300;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: getColor(),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => checkAnswer(capital),
                  child: Text(
                    capital,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
