import 'dart:convert';
import 'package:climate_request/data/model/estado.dart';
import 'package:climate_request/styles/format_widgets.dart';
import 'package:flutter/material.dart';
import 'climate_search.dart';
import '../../controller/resquests/request_database.dart';
import 'drop_down_search.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

//  https://api.hgbrasil.com/weather?key=9e3472d6&city_name=Campinas,SP
// https://servicodados.ibge.gov.br/api/v1/localidades/estados/
// https://servicodados.ibge.gov.br/api/v1/localidades/estados/22/municipios

class _HomePageState extends State<HomePage> {
  List favoriteList = [];
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController cidadeController = TextEditingController();
  TextEditingController estadoController = TextEditingController();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<List> fetchData() async {
    var response = await RequestDataBase().getData();

    if (response.statusCode != 200) {
      throw Exception('Failed to load favoritos');
    }
    favoriteList = response.data;
    return favoriteList;
  }

  Future<bool> controllersNotEmpty(context) async {
    if (cidadeController.text.isEmpty || estadoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Preencha todos os campos!'),
      ));
      return false;
    }
    return true;
  }

  Future<bool> validateSearch(context) async {
    final stateResponse = await http.get(Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados/${estadoController.text}'));

    final cityResponse = await http.get(Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/municipios/${cidadeController.text}'));

    if (json.decode(stateResponse.body).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Não foi possivel localizar esse estado!'),
      ));
      return false;
    }

    if (json.decode(cityResponse.body).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Não foi possivel localizar essa cidade!'),
      ));
      return false;
    }

    final cityStateId = jsonDecode(cityResponse.body)['microrregiao']
        ['mesorregiao']['UF']['id'];

    final state = Estado.fromJson(jsonDecode(stateResponse.body));

    if (cityStateId != state.id) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Essa cidade não pertence a esse estado!'),
      ));
      return false;
    }

    return true;
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
        body: ListView(
          scrollDirection: Axis.vertical,
          children: [
            spaceBetween,
            Row(
              children: [
                const SizedBox(width: 2),
                Flexible(
                  flex: 6,
                  child: baseStyle.inputContainer(
                    baseStyle.inputTextField(cidadeController, 'Cidade'),
                  ),
                ),
                const SizedBox(width: 2),
                Flexible(
                  flex: 1,
                  child: baseStyle.inputContainer(
                    baseStyle.inputTextField(estadoController, 'Estado'),
                  ),
                ),
                const SizedBox(width: 2),
              ],
            ),
            spaceBetween,
            TextButton(
              onPressed: () async {
                if (await controllersNotEmpty(context) &&
                    await validateSearch(context)) {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClimateSearch(
                            cidade: cidadeController.text,
                            estado: estadoController.text),
                      ));
                }
              },
              child: Container(
                width: 180,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: Color.fromARGB(213, 0, 238, 167),
                    borderRadius: BorderRadius.circular(10)),
                child: Text('Buscar',
                    style: baseTextStyle, textAlign: TextAlign.center),
              ),
            ),
            spaceBetween,
            const SizedBox(height: 30),
            Container(
              height: 50,
              color: baseStyle.colorBackGroundInputs,
              width: double.infinity,
              child: Center(
                child: Text(
                  'Favoritos',
                  style: baseStyle.textStyleBase(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              height: 400,
              width: double.infinity,
              color: Colors.white54,
              child: FutureBuilder<List>(
                future: fetchData(),
                builder: (context, json) {
                  if (json.hasData) {
                    return ListView.separated(
                      scrollDirection: Axis.vertical,
                      itemCount: favoriteList.length,
                      itemBuilder: (BuildContext context, int index) {
                        String cityName = favoriteList[index]!['cidade'];
                        String stateName = favoriteList[index]!['estado'];
                        return TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClimateSearch(
                                  cidade: cityName, estado: stateName),
                            ),
                          ),
                          child: ListTile(
                            title: Text(cityName, style: textStyleNormalFont),
                            subtitle:
                                Text(stateName, style: textStyleNormalFont),
                            leading: const Icon(Icons.search),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                    );
                  } else if (json.hasError) {
                    return Text("${json.error}");
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            spaceBetween,
            Flexible(
              child: TextButton(
                onPressed: (() => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DropDownSearch(),
                      ),
                    )),
                child: baseStyle.inputContainer(
                  Text(
                    "Selecione sua região",
                    textAlign: TextAlign.center,
                    style: baseTextStyle,
                  ),
                  paddingValue: 10,
                ),
              ),
            ),
            spaceBetween,
          ],
        ),
      ),
    );
  }
}

FormatWidgets baseStyle = FormatWidgets();
var spaceBetween = baseStyle.spaceBetween();
var baseTextStyle = baseStyle.textStyleBase();
var textStyleNormalFont =
    baseStyle.textStyleBase(fontWeight: FontWeight.normal);
