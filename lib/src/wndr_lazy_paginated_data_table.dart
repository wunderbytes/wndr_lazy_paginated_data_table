import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wndr_lazy_paginated_data_table/src/controller.dart';

class _LazyDataTableSource<T> extends DataTableSource {
  _LazyDataTableSource({
    required this.elements,
    required this.totalRowCount,
    required this.pageNumber,
    required this.rowsPerPage,
    required this.buildRow,
    required this.buildLoadingRow,
  });
  final List<T> elements;
  final int totalRowCount;
  final int pageNumber;
  final int rowsPerPage;
  final DataRow Function(int index) buildRow;
  final DataRow Function(int index) buildLoadingRow;

  @override
  DataRow? getRow(int index) {
    final resultsLength = elements.length;
    final indexRangeStart = (pageNumber - 1) * rowsPerPage;
    final indexRangeEnd = pageNumber * rowsPerPage - 1;
    final isInIndexRange = index < indexRangeStart || index > indexRangeEnd;
    final isDataAvailableForIndex = index % rowsPerPage > resultsLength - 1;
    if (isInIndexRange || isDataAvailableForIndex) {
      return buildLoadingRow(index);
    }
    return buildRow(index % rowsPerPage);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => totalRowCount;

  @override
  int get selectedRowCount => 0;
}

/// A Material Design data table that shows data using multiple pages, and loads
/// data lazily.
///
/// A lazy paginated data table initially shows [initialRowsPerPage] rows of
/// data per page and provides controls for showing other pages.
///
/// Data is read from a [TableElementsController], whenever it is updated.
/// The widget is presented as a [Card].

class LazyPaginatedDataTable<T> extends StatefulWidget {
  /// Creates a widget describing a lazy [PaginatedDataTable] on a [Card].
  ///
  /// Pages are indexed from 1, rows are indexed from 0.
  ///
  /// The [header] should give the card's header, typically a [Text] widget.
  ///
  /// The [columns] argument must be a list of as many [DataColumn] objects as
  /// the table is to have columns, ignoring the leading checkbox column if any.
  /// The [columns] argument must have a length greater than zero and cannot be
  /// null.
  ///
  /// If the table is sorted, the column that provides the current primary key
  /// should be specified by index in [sortColumnIndex], 0 meaning the first
  /// column in [columns], 1 being the next one, and so forth.
  ///
  /// The actual sort order can be specified using [sortAscending]; if the sort
  /// order is ascending, this should be true (the default), otherwise it should
  /// be false.
  /// The [initialRowsPerPage] and [availableRowsPerPage] must not be null (they
  /// both have defaults, though, so don't have to be specified).
  ///
  /// Themed by [DataTableTheme]. [DataTableThemeData.decoration] is ignored.
  /// To modify the border or background color of the [PaginatedDataTable], use
  /// [CardTheme], since a [Card] wraps the inner [DataTable].
  const LazyPaginatedDataTable({
    super.key,
    this.header,
    this.actions,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSelectAll,
    this.dataRowHeight = kMinInteractiveDimension,
    this.headingRowHeight = 56.0,
    this.horizontalMargin = 24.0,
    this.columnSpacing = 56.0,
    this.showCheckboxColumn = true,
    this.showFirstLastButtons = false,
    this.initialFirstRowIndex = 0,
    this.dragStartBehavior = DragStartBehavior.start,
    this.arrowHeadColor,
    this.checkboxHorizontalMargin,
    this.controller,
    this.primary,
    this.tablekey,
    required this.onPageChanged,
    required this.columns,
    required this.rowBuilder,
    required this.loadingRowBuilder,
    this.initialRowsPerPage = defaultRowsPerPage,
    this.availableRowsPerPage = const <int>[
      defaultRowsPerPage,
      defaultRowsPerPage * 2,
      defaultRowsPerPage * 5,
      defaultRowsPerPage * 10
    ],
    this.onRowsPerPageChanged,
    required this.tableElementsController,
  });

  /// The table card's optional header.
  ///
  /// This is typically a [Text] widget, but can also be a [Row] of
  /// [TextButton]s. To show icon buttons at the top end side of the table with
  /// a header, set the [actions] property.
  ///
  /// If items in the table are selectable, then, when the selection is not
  /// empty, the header is replaced by a count of the selected items. The
  /// [actions] are still visible when items are selected.
  final Widget? header;

  /// Icon buttons to show at the top end side of the table. The [header] must
  /// not be null to show the actions.
  ///
  /// Typically, the exact actions included in this list will vary based on
  /// whether any rows are selected or not.
  ///
  /// These should be size 24.0 with default padding (8.0).
  final List<Widget>? actions;

  /// The configuration and labels for the columns in the table.
  final List<DataColumn> columns;

  /// The current primary sort key's column.
  ///
  /// See [DataTable.sortColumnIndex].
  final int? sortColumnIndex;

  /// Whether the column mentioned in [sortColumnIndex], if any, is sorted
  /// in ascending order.
  ///
  /// See [DataTable.sortAscending].
  final bool sortAscending;

  /// Invoked when the user selects or unselects every row, using the
  /// checkbox in the heading row.
  ///
  /// See [DataTable.onSelectAll].
  final ValueSetter<bool?>? onSelectAll;

  /// The height of each row (excluding the row that contains column headings).
  ///
  /// This value is optional and defaults to kMinInteractiveDimension if not
  /// specified.
  final double dataRowHeight;

  /// The height of the heading row.
  ///
  /// This value is optional and defaults to 56.0 if not specified.
  final double headingRowHeight;

  /// The horizontal margin between the edges of the table and the content
  /// in the first and last cells of each row.
  ///
  /// When a checkbox is displayed, it is also the margin between the checkbox
  /// the content in the first data column.
  ///
  /// This value defaults to 24.0 to adhere to the Material Design
  /// specifications.
  ///
  /// If [checkboxHorizontalMargin] is null, then [horizontalMargin] is also the
  /// margin between the edge of the table and the checkbox, as well as the
  /// margin between the checkbox and the content in the first data column.
  final double horizontalMargin;

  /// The horizontal margin between the contents of each data column.
  ///
  /// This value defaults to 56.0 to adhere to the Material Design
  /// specifications.
  final double columnSpacing;

  /// {@macro flutter.material.dataTable.showCheckboxColumn}
  final bool showCheckboxColumn;

  /// Flag to display the pagination buttons to go to the first and last pages.
  final bool showFirstLastButtons;

  /// The index of the first row to display when the widget is first created.
  final int? initialFirstRowIndex;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// Horizontal margin around the checkbox, if it is displayed.
  ///
  /// If null, then [horizontalMargin] is used as the margin between the edge
  /// of the table and the checkbox, as well as the margin between the checkbox
  /// and the content in the first data column. This value defaults to 24.0.
  final double? checkboxHorizontalMargin;

  /// Defines the color of the arrow heads in the footer.
  final Color? arrowHeadColor;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? controller;

  /// {@macro flutter.widgets.scroll_view.primary}
  final bool? primary;

  /// Invoked when the user switches to another page.
  ///
  /// indexOfFirstRow is the index of the first row on the currently displayed
  /// page. rowsPerPage is the currently set rows per page
  final void Function(int indexOfFirstRow, int rowsPerPage) onPageChanged;

  /// Invoked when the user selects a different number of rows per page.
  ///
  /// If this is null, then the value given by [initialRowsPerPage] will be used
  /// and no affordance will be provided to change the value.
  final void Function(int? rowsPerPage)? onRowsPerPageChanged;

  /// Builder function responsible for building the rows in the table
  /// with a [T] element.
  final DataRow Function(BuildContext context, int index, T element) rowBuilder;

  /// Builder function responsible for building the rows
  /// when no element is present.
  final DataRow Function(BuildContext context, int index) loadingRowBuilder;

  /// The number of rows to show on each page (initially).
  final int initialRowsPerPage;

  /// The options to offer for the rowsPerPage.
  ///
  /// [initialRowsPerPage] must be a value in this list.
  ///
  /// The values in this list should be sorted in ascending order.
  final List<int> availableRowsPerPage;

  /// A [GlobalKey] for managing the state of the table.
  final GlobalKey<PaginatedDataTableState>? tablekey;

  /// A controller responsible for updating the value of the table.
  final TableElementsController<T> tableElementsController;

  /// If [initialRowsPerPage] is not set, this will be its value.
  static const int defaultRowsPerPage = 10;

  @override
  State<LazyPaginatedDataTable<T>> createState() {
    return _LazyPaginatedDataTableState<T>();
  }
}

class _LazyPaginatedDataTableState<T> extends State<LazyPaginatedDataTable<T>> {
  late final int _defaultRowsPerPage;
  late int _rowsPerPage;
  late final GlobalKey<PaginatedDataTableState> _tableKey;

  @override
  void initState() {
    _defaultRowsPerPage = widget.initialRowsPerPage;
    _rowsPerPage = widget.initialRowsPerPage;
    _tableKey = widget.tablekey ?? GlobalKey<PaginatedDataTableState>();
    widget.tableElementsController.addListener(_controllerListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.tableElementsController.removeListener(_controllerListener);
    super.dispose();
  }

  void _controllerListener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      key: _tableKey,
      header: widget.header,
      actions: widget.actions,
      columns: widget.columns,
      sortColumnIndex: widget.sortColumnIndex,
      sortAscending: widget.sortAscending,
      onSelectAll: widget.onSelectAll,
      dataRowHeight: widget.dataRowHeight,
      headingRowHeight: widget.headingRowHeight,
      horizontalMargin: widget.horizontalMargin,
      columnSpacing: widget.columnSpacing,
      showCheckboxColumn: widget.showCheckboxColumn,
      showFirstLastButtons: widget.showFirstLastButtons,
      initialFirstRowIndex: widget.initialFirstRowIndex,
      dragStartBehavior: widget.dragStartBehavior,
      arrowHeadColor: widget.arrowHeadColor,
      checkboxHorizontalMargin: widget.checkboxHorizontalMargin,
      controller: widget.controller,
      primary: widget.primary,
      availableRowsPerPage: [
        _defaultRowsPerPage,
        _defaultRowsPerPage * 2,
        _defaultRowsPerPage * 3,
      ],
      rowsPerPage: _rowsPerPage,
      onPageChanged: (indexOfFirstRow) {
        return widget.onPageChanged(indexOfFirstRow, _rowsPerPage);
      },
      onRowsPerPageChanged: (value) {
        _rowsPerPage = value ?? _defaultRowsPerPage;
        if (widget.onRowsPerPageChanged != null) {
          // ignore: prefer_null_aware_method_calls
          widget.onRowsPerPageChanged!(value);
        }
        _tableKey.currentState?.pageTo(0);
        widget.onPageChanged(0, _rowsPerPage);
        setState(() {});
      },
      source: _LazyDataTableSource<T>(
        elements: widget.tableElementsController.elements,
        totalRowCount: widget.tableElementsController.totalRowCount,
        pageNumber: widget.tableElementsController.pageIndex,
        rowsPerPage: _rowsPerPage,
        buildRow: (index) {
          final dataRow = widget.rowBuilder(
            context,
            index % _rowsPerPage,
            widget.tableElementsController.elements[index],
          );
          if (dataRow.cells.length != widget.columns.length) {
            throw Exception(
              'The length of buildRow cells must be the same as the length of the columns. dataRow cells length: ${dataRow.cells.length}, columns legth: ${widget.columns.length}',
            );
          }
          return dataRow;
        },
        buildLoadingRow: (int index) {
          final dataRow = widget.loadingRowBuilder(context, index);
          if (dataRow.cells.length != widget.columns.length) {
            throw Exception(
              'The length of buildLoadingRow cells must be the same as the length of the columns. buildLoadingRow cells length: ${dataRow.cells.length}, columns legth: ${widget.columns.length}',
            );
          }
          return dataRow;
        },
      ),
    );
  }
}
