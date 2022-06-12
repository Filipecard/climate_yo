import 'package:climate_request/resquests/request_database.dart';
import 'package:flutter/material.dart';
import 'climateResponse/climateSearch.dart';
import 'dropDownSearch/dropDownSearch.dart';

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
              spaceBetween(),
              Row(
                children: [
                  const SizedBox(width: 2),
                  Flexible(
                    flex: 6,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: colorBackGroundInputs(),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: cidadeController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintStyle:
                                TextStyle(fontSize: 20.0, color: Colors.white),
                            hintText: 'Cidade:'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: colorBackGroundInputs(),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: estadoController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.center,
                        maxLength: 2,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: "",
                            hintStyle:
                                TextStyle(fontSize: 20.0, color: Colors.white),
                            hintText: 'Estado:'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                ],
              ),
              spaceBetween(),
              TextButton(
                onPressed: () {
                  if (cidadeController.text.isNotEmpty &&
                      estadoController.text.isNotEmpty) {
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
                      color: const Color.fromARGB(164, 160, 50, 50),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text('Buscar',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center),
                ),
              ),
              spaceBetween(),
              const SizedBox(height: 30),
              Container(
                height: 30,
                color: colorBackGroundInputs(),
                width: double.infinity,
                child: const Center(
                  child: Text(
                    'Favoritos',
                    style: TextStyle(color: Colors.white, fontSize: 20),
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
                              return TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClimateSearch(
                                        cidade: favoriteList[index]!['cidade'],
                                        estado: favoriteList[index]!['estado']),
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    favoriteList[index]!['cidade'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorBackGroundInputs(),
                                        fontSize: 21),
                                  ),
                                  subtitle: Text(
                                    favoriteList[index]!['estado'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorBackGroundInputs(),
                                        fontSize: 21),
                                  ),
                                  leading: const Icon(Icons.search),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                          );
                        } else if (json.hasError) {
                          return Text("${json.error}");
                        }
                        return const Center(child: CircularProgressIndicator());
                      })),
              spaceBetween(),
              Flexible(
                child: TextButton(
                  onPressed: (() => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DropDownSearch(),
                        ),
                      )),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: colorBackGroundInputs(),
                    ),
                    child: const Text(
                      "Selecione sua região",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 21),
                    ),
                  ),
                ),
              ),
              spaceBetween(),
            ],
          )),
    );
  }
}

Color colorBackGroundInputs() {
  return const Color.fromARGB(178, 9, 59, 145);
}

SizedBox spaceBetween() {
  return const SizedBox(height: 20);
}
