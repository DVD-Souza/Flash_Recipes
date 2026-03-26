import 'package:translator/translator.dart';

class TraducaoServico {
  final GoogleTranslator _translator = GoogleTranslator();

  // PRÉ-PROCESSAMENTO DO TEXTO
  Map<int, String> _mapearLinhas(String texto) {
    final linhas = texto.split('\n');
    final mapa = <int, String>{};

    var index = 1;
    for (final linha in linhas) {
      if (linha.trim().isNotEmpty) {
        mapa[index] = linha.trim();
        index++;
      }
    }

    return mapa;
  }

  String _limparLinha(String linha) {
    var texto = linha;

    texto = texto.replaceAll(RegExp(r'^\d+[\.\)]?\s*'), '');
    texto = texto.replaceAll(
      RegExp(
        r'\b\d+\s*(g|gr|grams|ml|kg|tablespoons|teaspoons|cups)\b',
        caseSensitive: false,
      ),
      '',
    );
    texto = texto.replaceAll(RegExp(r'\b\d+\b'), '');
    texto = texto.replaceAll(RegExp(r'\s{2,}'), ' ');

    return texto.trim();
  }

  List<String> _prepararBlocos(Map<int, String> mapa) {
    final blocos = <String>[];

    for (final linha in mapa.values) {
      final limpo = _limparLinha(linha);
      if (limpo.isNotEmpty) {
        blocos.add(limpo);
      }
    }

    return blocos;
  }

  // TRADUÇÃO DE BLOCOS
  Future<String> _traduzirBloco(String texto) async {
    try {
      final result = await _translator.translate(
        texto,
        from: 'en',
        to: 'pt',
      );

      final traduzido = result.text;

      if (traduzido.trim().isNotEmpty &&
          traduzido.trim().toLowerCase() != texto.trim().toLowerCase()) {
        return traduzido.trim();
      }

      return texto;
    } catch (_) {
      return texto;
    }
  }

  // RECONSTRUÇÃO DO TEXTO
  String _reconstruir(
    Map<int, String> original,
    List<String> traduzido,
  ) {
    final linhasFinais = <String>[];
    var index = 0;

    original.forEach((_, __) {
      if (index < traduzido.length) {
        linhasFinais.add(traduzido[index]);
        index++;
      }
    });

    return linhasFinais.join('\n\n');
  }

  // TRADUÇÃO COMPLETA
  Future<String> traduzirTexto(String texto) async {
    if (texto.trim().isEmpty) return texto;

    final mapaOriginal = _mapearLinhas(texto);
    final blocos = _prepararBlocos(mapaOriginal);

    final traduzidos = await Future.wait(
      blocos.map(_traduzirBloco),
    );

    return _reconstruir(mapaOriginal, traduzidos);
  }

  // TRADUÇÃO SIMPLES
  Future<String> traduzirSimples(
    String texto, {
    String from = 'en',
    String to = 'pt',
  }) async {
    try {
      final result =
          await _translator.translate(texto, from: from, to: to);
      return result.text;
    } catch (_) {
      return texto;
    }
  }
}
