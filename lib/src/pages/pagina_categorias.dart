import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'pagina_receitas_da_categoria.dart';
import '../services/traducao_servico.dart';

class PaginaCategorias extends StatefulWidget {
  const PaginaCategorias({super.key});

  @override
  State<PaginaCategorias> createState() => _PaginaCategoriasState();
}

class _PaginaCategoriasState extends State<PaginaCategorias> {
  bool carregando = true;
  List categorias = [];

  final Map<String, String> _cacheTraducao = {};
  final TraducaoServico _tradutor = TraducaoServico();

  @override
  void initState() {
    super.initState();
    carregarCategorias();
  }


  // CARGA E TRADUÇÃO DAS CATEGORIAS
  Future<void> carregarCategorias() async {
    final url = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/categories.php',
    );

    final resp = await http.get(url);
    if (resp.statusCode != 200) return;

    final json = jsonDecode(resp.body);

    setState(() {
      categorias = json['categories'];
      carregando = false;
    });

    for (final categoria in categorias) {
      final nome = categoria['strCategory'];

      if (_cacheTraducao.containsKey(nome)) continue;

      final traduzido = await _tradutor.traduzirSimples(nome);
      _cacheTraducao[nome] = traduzido;

      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: categorias.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (_, index) {
                  final categoria = categorias[index];

                  final nomeOriginal = categoria['strCategory'];
                  final nomeExibicao =
                      _cacheTraducao[nomeOriginal] ?? nomeOriginal;

                  return _CategoriaCard(
                    nomeOriginal: nomeOriginal,
                    nomeExibicao: nomeExibicao,
                    imagem: categoria['strCategoryThumb'],
                  );
                },
              ),
            ),
    );
  }
}

class _CategoriaCard extends StatelessWidget {
  final String nomeOriginal;
  final String nomeExibicao;
  final String imagem;

  const _CategoriaCard({
    required this.nomeOriginal,
    required this.nomeExibicao,
    required this.imagem,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaginaReceitasDaCategoria(
              categoriaNome: nomeOriginal,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                imagem,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              nomeExibicao,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}