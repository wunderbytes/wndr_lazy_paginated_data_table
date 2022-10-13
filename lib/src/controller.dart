import 'package:flutter/material.dart';
import 'package:wndr_lazy_paginated_data_table/src/wndr_lazy_paginated_data_table.dart';

/// A controller with the purpose of communication between
/// [LazyPaginatedDataTable] and the rest of the application.
class TableElementsController<T> extends ChangeNotifier {
  /// Creates a controller to allow communication for the
  /// [LazyPaginatedDataTable].
  TableElementsController(this._elements, this._pageIndex, this._totalRowCount);

  /// The list of elements currently available.
  ///
  /// This value must not be null.
  /// It should change whenever a new page content is loaded.
  List<T> get elements => _elements;

  List<T> _elements;

  /// The index of the currently loaded page.
  ///
  /// This value must not be null.
  /// It should change whenever a new page content is loaded.
  int get pageIndex => _pageIndex;

  int _pageIndex;

  /// The total number of rows that are available to load.
  ///
  /// This value must not be null.
  int get totalRowCount => _totalRowCount;

  int _totalRowCount;

  /// Sets the value of the controller and notifies the listeners
  ///
  /// Whenever changes need to be on the receiving end, always use this
  /// function, and never change the values directly.
  void setValue(List<T> elements, int pageIndex, int totalRowCount) {
    _elements = elements;
    _pageIndex = pageIndex;
    _totalRowCount = totalRowCount;
    notifyListeners();
  }
}
