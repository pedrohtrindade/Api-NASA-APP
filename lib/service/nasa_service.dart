import 'dart:convert';
import 'package:http/http.dart' as http;

class NasaService {
  // COLOQUE SUA API KEY DA NASA ENTRE AS ASPAS ABAIXO.
  // Você pode obter uma chave em https://api.nasa.gov/
  final String apiKey = "u3Ay6NgIuH1Ffzqtk1bNgdbMoY0eYvZQF8OnvO3R";

  Future<Map> getApod() async {
    Uri url = Uri.https("science.nasa.gov", "/wp-json/wp/v2/apod-basic/", {
      "api_key": apiKey,
    });

    http.Response resposta = await http.get(url).timeout(Duration(seconds: 20));

    if (resposta.statusCode != 200) {
      throw Exception("A NASA respondeu com o código ${resposta.statusCode}.");
    }

    dynamic dados = json.decode(resposta.body);

    if (dados is List){
      if (dados.isEmpty){
        throw Exception("A NASA não retornou dados do APOD.");
      }
      return dados [0] as Map;
    }
    if (dados is Map){
      return dados;
    }

    throw Exception("Formato de resposta APOD não reconhecido");
  }

  Future<Map> getClimaMarte() async {
    Uri url = Uri.https("api.nasa.gov", "/insight_weather/", {
      "api_key": apiKey,
      "feedtype": "json",
      "ver": "1.0",
    });
    http.Response resposta = await http.get(url);
    if (resposta.statusCode != 200) {
      throw Exception("O serviço de clima do InSight não está disponível.");
    }
    return json.decode(resposta.body);
  }
}
