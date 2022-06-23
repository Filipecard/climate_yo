import 'package:climate_request/styles/format_widgets.dart';
import 'package:flutter/material.dart';
import 'climateResponse/climate_search.dart';
import 'controller/resquests/request_database.dart';
import 'dropDownSearch/drop_down_search.dart';

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

  bool controllersNotEmpty() {
    return cidadeController.text.isNotEmpty && estadoController.text.isNotEmpty;
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
              onPressed: () {
                if (controllersNotEmpty()) {
                  Navigator.push(
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
                        String stateName = favoriteList[index]!['cidade'];
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
