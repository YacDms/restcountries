import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'country.dart';
import 'quiz_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pays du Monde',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Ajout d’un thème clair et sombre simple possible ici
      ),
      home: const CountryListScreen(),
    );
  }
}

class CountryListScreen extends StatefulWidget {
  const CountryListScreen({super.key});

  @override
  CountryListScreenState createState() => CountryListScreenState();
}

class CountryListScreenState extends State<CountryListScreen> {
  late final Future<List<Country>> countriesFuture = fetchCountries();
  List<Country> allCountries = [];
  List<Country> filteredCountries = [];
  final TextEditingController searchController = TextEditingController();

  Future<List<Country>> fetchCountries() async {
    final response = await http.get(Uri.parse(
        'https://restcountries.com/v3.1/independent?independent=true'));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      if (body is List) {
        return body.map((json) => Country.fromJson(json)).toList();
      } else {
        throw Exception('Réponse inattendue (pas une liste)');
      }
    } else {
      throw Exception('Erreur réseau : ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      filterCountries(searchController.text);
    });
  }

  void filterCountries(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredCountries = allCountries
          .where((country) => country.name.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des Pays')),
      body: FutureBuilder<List<Country>>(
        future: countriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: const [
                LinearProgressIndicator(),
                Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun pays trouvé'));
          } else {
            if (allCountries.isEmpty) {
              allCountries = snapshot.data!;
              filteredCountries = allCountries; // Init liste filtrée
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Rechercher un pays',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),

                // AnimatedSwitcher pour un effet fluide lors du filtre
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: filteredCountries.isEmpty
                        ? const Center(
                            key: ValueKey('empty'),
                            child: Text('Aucun pays ne correspond à la recherche'),
                          )
                        : ListView.builder(
                            key: ValueKey('list'),
                            itemCount: filteredCountries.length,
                            itemBuilder: (context, index) {
                              final country = filteredCountries[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        country.flag,
                                        width: 50,
                                        height: 35,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(
                                      country.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    subtitle: Text('Capitale : ${country.capital}'),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (allCountries.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizScreen(countries: allCountries),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Les pays ne sont pas encore chargés')),
            );
          }
        },
        tooltip: 'Lancer le Quiz',
        child: const Icon(Icons.quiz),
      ),
    );
  }
}
