import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/favoritos_controlador.dart';
import '../controllers/receitas_controlador.dart';
import '../models/receita.dart';
import 'pagina_detalhes_receita.dart';

class PaginaFavoritos extends StatelessWidget {
  const PaginaFavoritos({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritos = context.watch<FavoritosControlador>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: favoritos.favoritos.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma receita favoritada',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoritos.favoritos.length,
              itemBuilder: (_, index) {
                return _CardFavorito(
                  receita: favoritos.favoritos[index],
                );
              },
            ),
    );
  }
}

class _CardFavorito extends StatelessWidget {
  final Receita receita;

  const _CardFavorito({
    required this.receita,
  });

  @override
  Widget build(BuildContext context) {
    final favoritos = context.watch<FavoritosControlador>();
    final controlador = context.watch<ReceitasControlador>();

    final traducao = controlador.getTraducao(receita.id);
    final nome = traducao?.nomePt ?? receita.nome;
    final categoria = traducao?.categoriaPt ?? receita.categoria;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaginaDetalhesReceita(
              receita: receita,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // IMAGEM
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                receita.miniatura,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),


            // INFORMAÇÕES
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

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
                      categoria,
                      style: const TextStyle(
                        color: Color(0xFFE65100),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 28,
                      ),
                      onPressed: () {
                        favoritos.removerFavorito(receita);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}