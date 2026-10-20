import 'dart:convert';
import 'package:http/http.dart' as http;

class GiphyService {
  // Chave Giphy que já estava no projeto fornecido.
  final String _key = "tgltPxGTnCUC2WPhT2SL6ImRSDT8ryiB";

  Future<List> getGifs(String pesquisa) async {
    String termo = pesquisa.trim();
    if (termo.isEmpty) {
      termo = "space astronaut";
    } else {
      termo = "space astronaut $termo";
    }

    Uri url = Uri.https("api.giphy.com", "/v1/gifs/search", {
      "api_key": _key,
      "q": termo,
      "limit": "20",
      "rating": "g",
      "lang": "en",
    });

    http.Response resposta = await http.get(url);
    if (resposta.statusCode != 200) {
      throw Exception("Não foi possível carregar os GIFs.");
    }
    Map dados = json.decode(resposta.body);
    return dados["data"];
  }
}
