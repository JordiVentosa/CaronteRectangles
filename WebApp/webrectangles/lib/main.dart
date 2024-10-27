import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:webrectangles/keys.dart';

void main() => runApp(PythonExerciseApp());

class PythonExerciseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 18.0, fontFamily: 'Courier'),
          titleMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: ExerciseHomePage(),
    );
  }
}

class ExerciseHomePage extends StatefulWidget {
  @override
  _ExerciseHomePageState createState() => _ExerciseHomePageState();
}

class _ExerciseHomePageState extends State<ExerciseHomePage> {
  final TextEditingController _textController = TextEditingController();
  String instructions = '';
  String expectedResult = '';
  String userCode = '';
  bool showInterpreter = false;

  Future<void> fetchExercise() async {
  String prompt = _textController.text;

  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {
      'Authorization': 'Bearer '+chatGPTApiKey,
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'model': 'gpt-4',
      'messages': [
        {
          'role': 'system',
          'content': 'Crea un exercici senzill de Python en català basat en la descripció proporcionada per l’usuari. Retorna el següent format: Pregunta[COS DE LA PREGUNTA] / Solucio[CODI SOLUCIO].'
        },
        {
          'role': 'user',
          'content': 'Crea un exercici de Python per a: $prompt'
        }
      ],
    }),
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final completion = jsonResponse['choices'][0]['message']['content'];

    // Parsing the result to split into problem and solution      
    print(completion);

    List<String> parts = completion.split('Solucio:');
    String exercisePrompt = parts[0].trim();  // Problem statement
    String solutionCode = parts.length > 1 ? parts[1].trim() : '';  // Solution

    setState(() {
      showInterpreter = true; // Show the interpreter
      instructions = exercisePrompt; // Display exercise prompt to the user
      expectedResult = solutionCode.split("```")[1].split('python')[1]; // Save solution for evaluation
    });
  } else {
    setState(() {
      instructions = 'Error al generar l’exercici.';
    });
  }
}



Future<void> evaluateUserCode() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/execute'), // Adjust the URL if deploying
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_code': userCode}),
    );  
    
    final ogResponse = await http.post(
      Uri.parse('http://127.0.0.1:5000/execute'), // Adjust the URL if deploying
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_code': expectedResult}),
    );
    if (response.statusCode == 200 && ogResponse.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final goodResponse = jsonDecode(ogResponse.body);

      final userOutput = jsonResponse['output'];
      final goodOutput = goodResponse['output'];
      setState(() {
        if (userOutput == goodOutput) {
          instructions += '\nCorrect! Your solution is correct.';
        } else {
          instructions += '\nIncorrect! Expected $goodOutput but got $userOutput.';
        }
      });
    } else {
      final errorResponse = jsonDecode(response.body);
      setState(() {
        instructions += '\nError: ${errorResponse["error"]}';
      });
    }
  }
  // New method to show hint dialog
  void showHint() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            'Hint',
            style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(
              expectedResult,
              style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Genera un exercici de Python',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: "Introdueix la descripció de l’exercici o titol de l'execici...",
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: fetchExercise,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Genera un nou exercici', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
              if (instructions.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text(
                    instructions,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (showInterpreter) ...[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.greenAccent, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'bash > python interpreter',
                        style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        onChanged: (value) {
                          userCode = value;
                        },
                        maxLines: 8,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                        decoration: const InputDecoration(
                          hintText: 'Escriu el teu codi python aqui...',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: evaluateUserCode,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('Exacuta i avalua el codi', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: showHint,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text('Pista', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
