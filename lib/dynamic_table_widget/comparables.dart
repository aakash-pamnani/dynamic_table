import 'package:dynamic_table/dynamic_table_widget/logging.dart';
import 'package:dynamic_table/utils/logging.dart';

sealed class ComparableValueBase<T>
    implements Comparable<ComparableValueBase<T>> {
  T get editedValue;
  bool operator >(ComparableValueBase<T> other);
  bool operator >=(ComparableValueBase<T> other) =>
      (this > other || this == other);
  bool operator <(ComparableValueBase<T> other);
  bool operator <=(ComparableValueBase<T> other) =>
      (this < other || this == other);
  bool isEqual(ComparableValueBase<T> other);

  @override
  bool operator ==(Object other) {
    if (other is! ComparableValueBase<T>) return false;
    return isEqual(other);
  }

  @override
  int get hashCode => editedValue.hashCode;

  @override
  int compareTo(ComparableValueBase<T> other) {
    if (this == other) {
      return 0;
    }
    if (this < other) {
      return -1;
    }
    if (this > other) {
      return 1;
    }
    throw Exception("Could not compare values");
  }

  ComparableValueBase() {}

  factory ComparableValueBase.map(T value) {
    return switch (value) {
      (num value) =>
        (ComparableNum<num>(value: value)) as ComparableValueBase<T>,
      (DateTime value) =>
        (ComparableDatetime<DateTime>(value: value))
            as ComparableValueBase<T>,
      (Object value) => throw [
          LoggingWidget.loggingFailure
        ].severeAndThrow(() => "Invalid data type. | value: ${value.toString()}"),
    };
  }
}

class ComparableDatetime<T extends DateTime> extends ComparableValueBase<T> {
  ComparableDatetime({required T value}) : this.value = value;

  final T value;
  @override
  T get editedValue => value;

  bool operator >(ComparableValueBase<T> other) =>
      this.editedValue.isAfter(other.editedValue);
  bool operator >=(ComparableValueBase<T> other) =>
      this.editedValue.isAfter(other.editedValue) ||
      this.editedValue.isAtSameMomentAs(other.editedValue);
  bool operator <(ComparableValueBase<T> other) =>
      this.editedValue.isBefore(other.editedValue);
  bool operator <=(ComparableValueBase<T> other) =>
      this.editedValue.isBefore(other.editedValue) ||
      this.editedValue.isAtSameMomentAs(other.editedValue);
  bool isEqual(ComparableValueBase<T> other) =>
      this.editedValue.isAtSameMomentAs(other.editedValue);
}

class ComparableNum<T extends num> extends ComparableValueBase<T> {
  ComparableNum({required T value}) : this.value = value;

  final T value;
  @override
  T get editedValue => value;

  bool operator >(ComparableValueBase<T> other) =>
      this.editedValue > other.editedValue;
  bool operator >=(ComparableValueBase<T> other) =>
      this.editedValue >= other.editedValue;
  bool operator <(ComparableValueBase<T> other) =>
      this.editedValue < other.editedValue;
  bool operator <=(ComparableValueBase<T> other) =>
      this.editedValue <= other.editedValue;
  bool isEqual(ComparableValueBase<T> other) =>
      this.editedValue == other.editedValue;
}
