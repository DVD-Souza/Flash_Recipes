import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/receitas_controlador.dart';
import '../controllers/favoritos_controlador.dart';
import '../models/receita.dart';
import '../models/receita_traduzida.dart';

class PaginaDetalhesReceita extends StatefulWidget {
  final Receita receita;

  const PaginaDetalhesReceita({
    super.key,
    required this.receita,
  });

  @override
  State<PaginaDetalhesReceita> createState() =>
      _PaginaDetalhesReceitaState();
}

class _PaginaDetalhesReceitaState extends State<PaginaDetalhesReceita> {
  late Future<ReceitaTraduzida> _future;

  @override
  void initState() {
    super.initState();

    _future = context
        .read<ReceitasControlador>()
        .traduzirReceita(widget.receita);
  }

  @override
  Widget build(BuildContext context) {
    final favoritos = context.watch<FavoritosControlador>();
    final receita = widget.receita;
    final estaFavorito = favoritos.estaFavorito(receita);

    return Scaffold(
      body: FutureBuilder<ReceitaTraduzida>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final traduzida = snapshot.data!;

          return Column(
            children: [
              // IMAGEM PRINCIPAL
              Hero(
                tag: receita.id,
                child: Image.network(
                  receita.miniatura,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // CONTEÚDO
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          traduzida.nomePt,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE0B2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            traduzida.categoriaPt,
                            style: const TextStyle(
                              color: Color(0xFFE65100),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Modo de Preparo',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          traduzida.instrucoesPt,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),

      // AÇÕES FLUTUANTES
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerTop,

      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              heroTag: 'voltar',
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
            FloatingActionButton(
              heroTag: 'favorito',
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                if (estaFavorito) {
                  favoritos.removerFavorito(receita);
                } else {
                  favoritos.adicionarFavorito(receita);
                }
              },
              child: Icon(
                estaFavorito
                    ? Icons.favorite
                    : Icons.favorite_outline,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}