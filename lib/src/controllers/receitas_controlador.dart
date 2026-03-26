import 'dart:async';
import 'package:flutter/material.dart';

import '../models/receita.dart';
import '../models/receita_traduzida.dart';
import '../services/api_receitas_servico.dart';
import '../services/traducao_servico.dart';
import '../services/banco_dados_servico.dart';

class ReceitasControlador extends ChangeNotifier {
  final ApiReceitasServico _api = ApiReceitasServico();
  final TraducaoServico _tradutor = TraducaoServico();
  final BancoDadosServico _banco = BancoDadosServico();

  final Map<String, ReceitaTraduzida> _cacheMemoria = {};
  final Set<String> _traduzindo = {};

  final Duration debounceDuration = const Duration(milliseconds: 500);
  Timer? _debounce;

  List<Receita> _todasReceitas = [];
  List<Receita> _receitasFiltradas = [];

  bool carregando = false;

  List<Receita> get receitas => _receitasFiltradas;


  // CARGA INICIAL
  Future<void> carregarReceitas() async {
    carregando = true;
    notifyListeners();

    try {
      _todasReceitas = await _api.buscarReceitas();
      _receitasFiltradas = [..._todasReceitas];
    } catch (_) {
      _todasReceitas = [];
      _receitasFiltradas = [];
    }

    carregando = false;
    notifyListeners();
  }

  // BUSCA LOCAL (ORIGINAL + TRADUZIDA)
  void buscarReceitas(String termo) {
    if (termo.isEmpty) {
      _receitasFiltradas = [..._todasReceitas];
    } else {
      final t = termo.toLowerCase();
      _receitasFiltradas = _todasReceitas.where((r) {
        final traducao = _cacheMemoria[r.id];
        final nomePt = traducao?.nomePt ?? '';
        return r.nome.toLowerCase().contains(t) ||
            nomePt.toLowerCase().contains(t);
      }).toList();
    }

    notifyListeners();
  }

  // TRADUÇÃO COMPLETA (DETALHES)
  Future<ReceitaTraduzida> traduzirReceita(Receita receita) async {
    final cache = _cacheMemoria[receita.id];
    if (cache != null && cache.instrucoesPt.isNotEmpty) return cache;

    final banco = await _banco.buscarTraducao(receita.id);
    if (banco != null && banco.instrucoesPt.isNotEmpty) {
      _cacheMemoria[receita.id] = banco;
      return banco;
    }

    final traducao = ReceitaTraduzida(
      idReceita: receita.id,
      nomePt: await _tradutor.traduzirSimples(receita.nome),
      categoriaPt: await _tradutor.traduzirSimples(receita.categoria),
      instrucoesPt: await _tradutor.traduzirTexto(receita.instrucoes),
    );

    await _banco.salvarTraducao(traducao);
    _cacheMemoria[receita.id] = traducao;

    return traducao;
  }

  ReceitaTraduzida? getTraducao(String id) => _cacheMemoria[id];

  // TRADUÇÃO LEVE (LISTAS)
  void traduzirSeNecessario(Receita receita) {
    if (_cacheMemoria.containsKey(receita.id)) return;
    if (_traduzindo.contains(receita.id)) return;

    _traduzindo.add(receita.id);

    _traduzirResumo(receita).then((_) async {
      final traduzida = await _banco.buscarTraducao(receita.id);
      if (traduzida != null) {
        _cacheMemoria[receita.id] = traduzida;
      }

      _traduzindo.remove(receita.id);
      notifyListeners();
    });
  }

  Future<void> _traduzirResumo(Receita receita) async {
    final existente = await _banco.buscarTraducao(receita.id);
    if (existente != null) return;

    final resumo = ReceitaTraduzida(
      idReceita: receita.id,
      nomePt: await _tradutor.traduzirSimples(receita.nome),
      categoriaPt: await _tradutor.traduzirSimples(receita.categoria),
      instrucoesPt: '',
    );

    _cacheMemoria[receita.id] = resumo;
  }


  // BUSCA REMOTA
  Future<Receita> buscarReceitaPorId(String id) {
    return _api.buscarReceitaPorId(id);
  }


  // BUSCA COM DEBOUNCE
  void buscarReceitasComDebounce(String termo) {
    _debounce?.cancel();
    _debounce = Timer(debounceDuration, () {
      buscarReceitas(termo);
    });
  }

  Future<String> traduzirTextoSimples(
    String texto, {
    String from = 'en',
    String to = 'pt',
  }) {
    return _tradutor.traduzirSimples(texto, from: from, to: to);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}