import 'dart:convert';
import 'package:climate_request/home_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'climate.dart';

class ClimateSearch extends StatefulWidget {
  const ClimateSearch({Key? key, required this.cidade, required this.estado})
      : super(key: key);

  final String cidade;
  final String estado;

  @override
  State<ClimateSearch> createState() => _ClimateSearchState();
}

// https://servicodados.ibge.gov.br/api/v1/localidades/estados/
// https://servicodados.ibge.gov.br/api/v1/localidades/estados/22/municipios

class _ClimateSearchState extends State<ClimateSearch> {
  bool isFavorite = false;

  // a key da url pode ser alterada, fazendo login no site você pode criar sua própria key,
  // como é uma amostra grátis, essa chave possui limite de requisições diárias, contudo há
  // pacotes pagos no site para ampliar suas requisições.
  final String _baseUrl =
      'https://api.hgbrasil.com/weather?key=48dab000&city_name';

  Future<Climate> fetch() async {
    final response = await http
        .get(Uri.parse('$_baseUrl=${widget.cidade},${widget.estado}'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load comments');
    }

    final favoriteResp = await Dio().get('http://localhost:3000/data');
    List listCitys = favoriteResp.data;

    for (var i = 0; i < listCitys.length; i++) {
      if (listCitys[i]['cidade'].toString().toLowerCase() ==
              widget.cidade.toLowerCase() &&
          listCitys[i]['estado'].toString().toLowerCase() ==
              widget.estado.toLowerCase()) {
        isFavorite = true;
        break;
      }
    }

    return Climate.fromJson(jsonDecode(response.body));
  }

  void _addToFavorite(String cidade, String estado) async {
    if (!isFavorite) {
      final favoriteResp = await Dio().post(
        'http://localhost:3000/data',
        data: {
          "id": "${cidade.toLowerCase()}-${estado.toLowerCase()}",
          "cidade": cidade,
          "estado": estado
        },
      );
      setState(() {
        isFavorite = true;
      });
    } else {
      final favoriteResp = await Dio().delete(
          'http://localhost:3000/data/${cidade.toLowerCase()}-${estado.toLowerCase()}');
      setState(() {
        isFavorite = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/sky_image.jpg'), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('YoClimate'),
          automaticallyImplyLeading: false,
        ),
        body: FutureBuilder<Climate>(
          future: fetch(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var result = snapshot.data!;
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('${widget.cidade}\n${widget.estado}',
                                style: StyleText()),
                          ),
                          const SizedBox(
                            width: 50,
                          ),
                          Expanded(
                              child: Text('Data: ${result.data}',
                                  style: StyleText())),
                          const SizedBox(
                            width: 50,
                          ),
                          Expanded(
                              child: Text('Hora: \n${result.hora}',
                                  style: StyleText())),
                        ],
                      )),
                  const SizedBox(
                    height: 50,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white60,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        ListTile(
                          leading: const Icon(Icons.device_thermostat),
                          title: Text(
                            'Temperatura:',
                            textAlign: TextAlign.center,
                            style: StyleText(),
                          ),
                          subtitle: Text(
                            '${result.temperatura}° C',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(
                            'Descrição:',
                            textAlign: TextAlign.center,
                            style: StyleText(),
                          ),
                          subtitle: Text(
                            result.descricao,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          leading: const Icon(Icons.air),
                          title: Text(
                            'Velocidade do Vento:',
                            textAlign: TextAlign.center,
                            style: StyleText(),
                          ),
                          subtitle: Text(
                            result.velVento,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          leading: const Icon(Icons.water_drop),
                          title: Text(
                            'Humidade:',
                            textAlign: TextAlign.center,
                            style: StyleText(),
                          ),
                          subtitle: Text(
                            '${result.humidade}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20)
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextButton(
                          onPressed: () =>
                              _addToFavorite(widget.cidade, widget.estado),
                          child: Icon(Icons.star,
                              color: isFavorite
                                  ? Colors.amber
                                  : Color.fromARGB(92, 75, 75, 75),
                              size: 30),
                        ),
                      ),
                      Container(
                          width: 300,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.blueAccent,
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            ),
                            child: const Text(
                              'Buscar novamente',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          )),
                    ],
                  )
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

// ignore: non_constant_identifier_names
Container ContainerStyleHomePage(String text) {
  return Container(
      width: 300,
      height: 50,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.blueAccent,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 21),
      ));
}

// ignore: non_constant_identifier_names
TextStyle StyleText() {
  return const TextStyle(
      color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold);
}
