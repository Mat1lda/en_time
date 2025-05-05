import 'dart:async';
import 'dart:collection';

extension StreamExtension<T> on Stream<T> {
  Stream<T> startWith(T value) {
    return Stream.value(value).concatWith([this]);
  }
}

extension StreamsConcatExtension<T> on Stream<T> {
  Stream<T> concatWith(Iterable<Stream<T>> other) {
    return Stream.eventTransformed(
      Stream.fromIterable([this]..addAll(other)),
          (EventSink sink) => _ConcatStreamController(sink),
    );
  }
}

class _ConcatStreamController<T> implements EventSink<Stream<T>> {
  final EventSink<T> _sink;
  Stream<T>? _current;
  StreamSubscription<T>? _currentSubscription;
  bool _isComplete = false;
  Queue<Stream<T>> _streams = Queue();

  _ConcatStreamController(this._sink);

  @override
  void add(Stream<T> stream) {
    _streams.add(stream);
    if (_current == null) {
      _current = stream;
      _subscribe();
    }
  }

  void _subscribe() {
    _currentSubscription = _current!.listen(
      _sink.add,
      onError: _sink.addError,
      onDone: _onDone,
    );
  }

  void _onDone() {
    _currentSubscription = null;
    if (_streams.isEmpty) {
      if (_isComplete) _sink.close();
    } else {
      _current = _streams.removeFirst();
      _subscribe();
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _sink.addError(error, stackTrace);

  @override
  void close() {
    _isComplete = true;
    if (_currentSubscription == null) _sink.close();
  }
}