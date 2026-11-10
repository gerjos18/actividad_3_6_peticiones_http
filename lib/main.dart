
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PokeDexApp());
}

class PokeDexApp extends StatelessWidget {
  const PokeDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PokéDex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller =
      TextEditingController();

  Map<String, dynamic>? pokemon;
  bool loading = false;
  String? error;

  Future<void> buscarPokemon(String nombre) async {
    if (nombre.trim().isEmpty) return;

    setState(() {
      loading = true;
      error = null;
      pokemon = null;
    });

    try {
      final url = Uri.parse(
        'https://pokeapi.co/api/v2/pokemon/${nombre.toLowerCase().trim()}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          pokemon = data;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          error = 'No se encontró ese Pokémon.';
        });
      } else {
        setState(() {
          error = 'Error al consultar la API.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'No se pudo conectar a Internet.';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'PokéDex',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.catching_pokemon,
              size: 85,
              color: Colors.red,
            ),
            const Text(
              'Busca tu Pokémon',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ejemplo: pikachu',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: buscarPokemon,
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : () => buscarPokemon(controller.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(15),
                ),
                child: const Text('BUSCAR POKÉMON'),
              ),
            ),

            const SizedBox(height: 25),

            if (loading)
              const CircularProgressIndicator(),

            if (error != null)
              Text(
                error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),

            if (pokemon != null)
              mostrarPokemon(),
          ],
        ),
      ),
    );
  }

  Widget mostrarPokemon() {
    final imagen = pokemon!['sprites']['other']
        ['official-artwork']['front_default'];

    final tipos = (pokemon!['types'] as List)
        .map((tipo) => tipo['type']['name'])
        .join(', ');

    final habilidades = (pokemon!['abilities'] as List)
        .map((item) => item['ability']['name'])
        .join(', ');

    return Card(
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (imagen != null)
              Image.network(
                imagen,
                height: 180,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 80),
              ),

            Text(
              pokemon!['name'].toString().toUpperCase(),
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text('Número: #${pokemon!['id']}'),

            const Divider(height: 30),

            dato('Tipo', tipos),
            dato('Altura', '${pokemon!['height']} dm'),
            dato('Peso', '${pokemon!['weight']} hg'),
            dato('Habilidades', habilidades),
          ],
        ),
      ),
    );
  }

  Widget dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(valor),
          ),
        ],
      ),
    );
  }
}
