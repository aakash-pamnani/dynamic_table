import 'package:dynamic_table/dynamic_table_source/reference.dart';

class FetchTillEmptyIterator<T> implements Iterator<T> {
  T? _current;
  T? Function () _fetch;

  FetchTillEmptyIterator(T? Function () fetch) : _fetch = fetch;

  @override
  T get current { if (_current != null) return _current!; throw Exception('No Value'); }

  @override
  bool moveNext() {
    _current = _fetch();
    return _current != null;
  }
}

class DynamicTableIndicesFetchTillEmptyQueryResult with Iterable<Reference<int>> {
  Reference<int>? Function () _fetch;

  DynamicTableIndicesFetchTillEmptyQueryResult(Reference<int>? Function () fetch) : _fetch = fetch;

  FetchTillEmptyIterator<Reference<int>> get iterator => FetchTillEmptyIterator(_fetch);
  
}
