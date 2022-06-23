import 'dart:convert';

import 'package:climate_request/data/model/cidade.dart';
import 'package:climate_request/data/model/estado.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:http/http.dart' as http;
import '../climateResponse/climate_search.dart';

class DropDownSearch extends StatefulWidget {
  const DropDownSearch({Key? key}) : super(key: key);
  @override
  State<DropDownSearch> createState() => DropDownSearchState();
}

class DropDownSearchState extends State<DropDownSearch> {
  String lightImage =
      'https://images.unsplash.com/photo-1560803262-95a9de00a057?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8cGluayUyMHNraWVzfGVufDB8fDB8fA%3D%3D&w=1000&q=80';

  late Future<List<Estado>> futurePost;
  List<Estado> listPost = [];
  final ScrollController _scrollController = ScrollController();
  final String _baseUrl =
      'https://servicodados.ibge.gov.br/api/v1/localidades/estados/';

  final PagingController<int, Estado> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      fetchEstado();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Future<void> fetchEstado() async {
    try {
      final newItems = await fetch();
      final isLastPage = newItems.length < 30;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<List<Estado>> fetch() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load comments');
    }

    List jsonResponseList = jsonDecode(utf8.decode(response.bodyBytes));
    for (var item
        in jsonResponseList.map((data) => Estado.fromJson(data)).toList()) {
      listPost.add(item);
    }

    return jsonResponseList.map((data) => Estado.fromJson(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(lightImage), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Informe o estado:'),
          ),
          body: PagedListView<int, Estado>.separated(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Estado>(
                itemBuilder: (context, item, index) => Center(
                        child: Container(
                      color: const Color.fromARGB(10, 0, 0, 0),
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                _CitySearch(estadoSelected: item),
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            item.nome,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                          subtitle: Text(
                            'Sigla : ${item.sigla}\nRegião${item.regiao}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ))),
            separatorBuilder: (context, index) => const Divider(),
          ),
        ));
  }
}

class _CitySearch extends StatefulWidget {
  const _CitySearch({Key? key, required this.estadoSelected}) : super(key: key);

  final Estado estadoSelected;

  @override
  State<_CitySearch> createState() => _CitySearchState();
}

class _CitySearchState extends State<_CitySearch> {
  String lightImage =
      'https://images.unsplash.com/photo-1560803262-95a9de00a057?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8cGluayUyMHNraWVzfGVufDB8fDB8fA%3D%3D&w=1000&q=80';

  final String _baseUrl =
      'https://servicodados.ibge.gov.br/api/v1/localidades/estados';

  final PagingController<int, Cidade> _pagingController =
      PagingController(firstPageKey: 0);
  int lastItem = 0;
  int countRequests = 30;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      fetchCidade();
    });
    super.initState();
  }

  Future<void> fetchCidade() async {
    try {
      List<Cidade> listaCity = [];
      var allItens = await fetch();
      if (countRequests > allItens.length) countRequests = allItens.length;
      for (var i = lastItem; i < countRequests; i++) {
        listaCity.add(allItens[i]);
      }
      lastItem = countRequests;
      countRequests += 30;
      final newItems = listaCity;
      final isLastPage = newItems.length < 30;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<List<Cidade>> fetch() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/${widget.estadoSelected.id}/municipios'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load comments');
    }
    List jsonResponseList = jsonDecode(utf8.decode(response.bodyBytes));
    return jsonResponseList.map((data) => Cidade.fromJson(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(lightImage), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Informe a sua cidade:'),
        ),
        body: PagedListView<int, Cidade>.separated(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Cidade>(
            itemBuilder: (context, item, index) => Center(
                child: Container(
              color: const Color.fromARGB(10, 0, 0, 0),
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClimateSearch(
                        cidade: item.nome, estado: widget.estadoSelected.sigla),
                  ),
                ),
                child: ListTile(
                  title: Text(
                    item.nome,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            )),
          ),
          separatorBuilder: (context, index) => const Divider(),
        ),
      ),
    );
  }
}
