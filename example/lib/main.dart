import 'package:flutter/material.dart';
import 'package:wndr_lazy_paginated_data_table/wndr_lazy_paginated_data_table.dart';

const _totalDataCount = 26;

const itemList = [
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
];

final _mockNotifier = MockNotifier();
const _initialRowsPerPage = 2;

class MockNotifier extends ChangeNotifier {
  List<String> elements = [];
  int currentPageNumber = 1;
  int? totalRowsCount;

  Future<void> query(int pageIndex, int rowsPerPage) async {
    await Future.delayed(const Duration(seconds: 1));
    final startIndex = (pageIndex - 1) * rowsPerPage;
    final endIndex = startIndex + rowsPerPage <= itemList.length ? startIndex + rowsPerPage : itemList.length;
    elements = itemList.sublist(startIndex, endIndex);
    currentPageNumber = pageIndex;
    totalRowsCount = _totalDataCount;
    notifyListeners();
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wndr_lazy_paginated_data_table example',
      theme: ThemeData(primarySwatch: Colors.blue, scaffoldBackgroundColor: Colors.blue[50]),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _tableKey = GlobalKey<PaginatedDataTableState>();
  final _tableElementsController = TableElementsController<String>([], 1, 0);

  @override
  void initState() {
    _mockNotifier.addListener(_notifierListener);
    _mockNotifier.query(1, _initialRowsPerPage);
    super.initState();
  }

  void _notifierListener() {
    _tableElementsController.setValue(
      _mockNotifier.elements,
      _mockNotifier.currentPageNumber,
      _mockNotifier.totalRowsCount!,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _mockNotifier.totalRowsCount == null
                ? const Center(child: CircularProgressIndicator())
                : LazyPaginatedDataTable<String>(
                    tablekey: _tableKey,
                    initialRowsPerPage: _initialRowsPerPage,
                    availableRowsPerPage: const [_initialRowsPerPage, _initialRowsPerPage * 2, _initialRowsPerPage * 3],
                    onPageChanged: (indexOfFirstRow, rowsPerPage) {
                      final pageNumber = (indexOfFirstRow ~/ rowsPerPage) + 1;

                      _mockNotifier.query(pageNumber, rowsPerPage);
                    },
                    columns: const [DataColumn(label: Text('Character'))],
                    rowBuilder: (context, index, element) {
                      return DataRow.byIndex(
                        index: index,
                        cells: [DataCell(Text(element))],
                      );
                    },
                    loadingRowBuilder: (context, index) {
                      return DataRow.byIndex(
                        index: index,
                        cells: const [DataCell(SizedBox(width: 48, child: LinearProgressIndicator()))],
                      );
                    },
                    tableElementsController: _tableElementsController,
                  ),
          ),
        ],
      ),
    );
  }
}
