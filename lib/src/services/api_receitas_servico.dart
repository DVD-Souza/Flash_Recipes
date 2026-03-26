import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/receita.dart';

class ApiReceitasServico {
  final String _urlBase =
      'https://www.themealdb.com/api/json/v1/1/search.php?s=';

  // BUSCA INICIAL DE RECEITAS
  Future<List<Receita>> buscarReceitas() async {
    final resposta = await http.get(Uri.parse(_urlBase));

    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar receitas');
    }

    final json = jsonDecode(resposta.body);
    final lista = json['meals'] as List;

    return lista.map((e) => Receita.fromJson(e)).toList();
  }

  // BUSCA POR TERMO
  Future<List<Receita>> buscarReceitasPorTermo(
    String urlCompleta,
  ) async {
    final resposta = await http.get(Uri.parse(urlCompleta));

    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar receitas');
    }

    final json = jsonDecode(resposta.body);
    final lista = json['meals'];

    if (lista == null) return [];

    return (lista as List)
        .map((e) => Receita.fromJson(e))
        .toList();
  }

  // BUSCA POR ID
  Future<Receita> buscarReceitaPorId(String id) async {
    final url = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id',
    );

    final resposta = await http.get(url);

    if (resposta.statusCode != 200) {
      throw Exception('Erro ao buscar receita');
    }

    final json = jsonDecode(resposta.body);
    return Receita.fromJson(json['meals'][0]);
  }
}