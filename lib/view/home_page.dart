import 'package:flutter/material.dart';
import 'package:apk_giphy/service/giphy_service.dart';
import 'package:apk_giphy/service/nasa_service.dart';
import 'package:apk_giphy/view/gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final GiphyService giphyService = GiphyService();
  final NasaService nasaService = NasaService();

  int _tela = 0;
  bool _carregando = false;
  String _erro = "";
  List _gifs = [];
  Map? _apod;
  Map? _clima;

  @override
  void initState() {
    super.initState();
    _buscarGifs();
  }

  Future<void> _buscarGifs() async {
    setState(() {
      _carregando = true;
      _erro = "";
    });
    try {
      List resultado = await giphyService.getGifs(_controller.text);
      setState(() {
        _gifs = resultado;
        _carregando = false;
        if (_gifs.isEmpty) {
          _erro = "Nenhum GIF encontrado. Tente outra palavra.";
        }
      });
    } catch (e) {
      setState(() {
        _carregando = false;
        _erro = "Erro ao carregar os GIFs. Verifique a internet.";
      });
    }
  }

  Future<void> _buscarApod() async {
    setState(() {
      _tela = 1;
      _carregando = true;
      _erro = "";
    });
    try {
      Map resultado = await nasaService.getApod();
      setState(() {
        _apod = resultado;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _carregando = false;
        _erro =
            "Falha no APOD: $e";
      });
    }
  }

  Future<void> _buscarClima() async {
    setState(() {
      _tela = 2;
      _carregando = true;
      _erro = "";
    });
    try {
      Map resultado = await nasaService.getClimaMarte();
      setState(() {
        _clima = resultado;
        _carregando = false;
        if ((resultado["sol_keys"] as List).isEmpty) {
          _erro = "A API não retornou dados de clima.";
        }
      });
    } catch (e) {
      setState(() {
        _carregando = false;
        _erro =
            "O clima do InSight pode estar indisponível. A missão terminou e os dados são históricos.";
      });
    }
  }

  void _abrirGifs() {
    setState(() {
      _tela = 0;
    });
    _buscarGifs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Explorando o Espaço"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Pesquise GIFs do espaço",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _buscarGifs,
                ),
              ),
              onSubmitted: (valor) => _buscarGifs(),
            ),
          ),
          Wrap(
            spacing: 6.0,
            children: [
              ElevatedButton(onPressed: _abrirGifs, child: Text("GIFs")),
              ElevatedButton(
                onPressed: _buscarApod,
                child: Text("Imagem APOD"),
              ),
              ElevatedButton(
                onPressed: _buscarClima,
                child: Text("Clima de Marte"),
              ),
            ],
          ),
          Expanded(child: _conteudo()),
        ],
      ),
    );
  }

  String _limparHtml(String texto) {
  return texto
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

  Widget _conteudo() {
    if (_carregando) {
      return Center(child: CircularProgressIndicator());
    }
    if (_erro.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(_erro, textAlign: TextAlign.center),
        ),
      );
    }
    if (_tela == 0) {
      if (_gifs.isEmpty) {
        return Center(child: Text("Pesquise por um GIF do espaço."));
      }
      return GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _gifs.length,
        itemBuilder: (context, index) {
          Map gif = _gifs[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GifPage(gif)),
              );
            },
            child: Image.network(
              gif["images"]["fixed_height"]["url"],
              fit: BoxFit.cover,
            ),
          );
        },
      );
    }
    if (_tela == 1) {
      if (_apod == null) {
        return Center(child: Text("Toque em Imagem APOD para carregar."));
      }
      return SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              _apod!["title"] ?? "Imagem do dia",
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 8.0),
            if (_apod!["media_type"] == "image")
              Image.network(_apod!["hdurl"] ?? _apod!["url"])
            else
              Text("O conteúdo do APOD de hoje é um vídeo: ${_apod!["url"]}"),
            SizedBox(height: 8.0),
              Text(_limparHtml(_apod!["explanation"] ?? "Sem descrição.")),
          ],
        ),
      );
    }
    if (_clima == null) {
      return Center(child: Text("Toque em Clima de Marte para carregar."));
    }
    List sols = _clima!["sol_keys"];
    String ultimoSol = sols.last;
    Map dadosSol = _clima![ultimoSol];
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Clima histórico de Marte", style: TextStyle(fontSize: 20.0)),
          SizedBox(height: 12.0),
          Text("Sol: $ultimoSol"),
          Text("Temperatura média: ${dadosSol["AT"]["av"] ?? "Sem dados"} °C"),
          Text("Pressão média: ${dadosSol["PRE"]["av"] ?? "Sem dados"} Pa"),
          Text("Vento médio: ${dadosSol["HWS"]["av"] ?? "Sem dados"} m/s"),
          SizedBox(height: 12.0),
          Text("Dados históricos da missão InSight."),
        ],
      ),
    );
  }
}
