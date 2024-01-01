import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';

/// Throttles function calls with the [interval] provided.
/// Also make sures to call the last Action after the elapsed interval
class Throttler {
  final Duration interval;
  FutureOr<void> Function()? _lastAction;
  Timer? _timer;
  DateTime? _lastActionTime;

  Throttler({required this.interval});

  void run(FutureOr<void> Function() action) {
    if (_lastActionTime == null ||
        (DateTime.now().difference(_lastActionTime!) > interval)) {
      action();
      _lastActionTime = DateTime.now();
      _timer?.cancel();
    } else {
      // Schedule a timer to be executed after the difference
      _timer?.cancel();
      _timer = Timer(DateTime.now().difference(_lastActionTime!), _callAndRest);
    }
  }

  void _callAndRest() {
    _lastAction?.call();
    _timer = null;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _lastAction = null;
    _lastActionTime = null;
  }
}

/// Creates a [Throttler] that will be disposed automatically. If no [interval] is provided, a
/// default interval of 300ms is used to throttle the function calls
Throttler useThrottler({
  Duration interval = const Duration(milliseconds: 300),
  List<Object?>? keys,
}) =>
    use(_ThrottleHook(interval: interval, keys: keys));

class _ThrottleHook extends Hook<Throttler> {
  const _ThrottleHook({
    required this.interval,
    List<Object?>? keys,
  }) : super(keys: keys);

  final Duration interval;

  @override
  HookState<Throttler, Hook<Throttler>> createState() => _ThrottlerHookState();
}

class _ThrottlerHookState extends HookState<Throttler, _ThrottleHook> {
  late final throttler = Throttler(interval: hook.interval);

  @override
  Throttler build(_) => throttler;

  @override
  void dispose() => throttler.dispose();

  @override
  String get debugLabel => 'useThrottler';
}
