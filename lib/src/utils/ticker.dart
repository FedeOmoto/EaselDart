// Copyright 2014 Federico Omoto
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of easel_dart;

/**
 * The Ticker provides  a centralized tick or heartbeat broadcast at a set
 * interval. Listeners can subscribe to the tick event to be notified when a set
 * time interval has elapsed.
 *
 * Note that the interval that the tick event is called is a target interval,
 * and may be broadcast at a slower interval during times of high CPU load. The
 * Ticker class uses a static interface (ex. `Ticker.getPaused()`) and should
 * not be instantiated.
 *
 * ##Example
 *      createjs.Ticker.addEventListener("tick", handleTick);
 *      function handleTick(event) {
 *          // Actions carried out each frame
 *          if (!event.paused) {
 *              // Actions carried out when the Ticker is not paused.
 *          }
 *      }
 *
 * To update a stage every tick, the [Stage] instance can also be used as a
 * listener, as it will automatically update when it receives a tick event:
 *
 *      createjs.Ticker.addEventListener("tick", stage);
 */
class Ticker extends create_dart.EventDispatcher {
  /**
   * In this mode, Ticker uses the requestAnimationFrame API, but attempts to
   * synch the ticks to target framerate. It uses a simple heuristic that
   * compares the time of the RAF return to the target time for the current
   * frame and dispatches the tick when the time is within a certain threshold.
   *
   * This mode has a higher variance for time between frames than TIMEOUT, but
   * does not require that content be time based as with RAF while gaining the
   * benefits of that API (screen synch, background throttling).
   *
   * Variance is usually lowest for framerates that are a divisor of the RAF
   * frequency. This is usually 60, so framerates of 10, 12, 15, 20, and 30 work
   * well.
   *
   * Falls back on TIMEOUT if the requestAnimationFrame API is not supported.
   */
  static const String RAF_SYNCHED = 'synched';

  /**
   * In this mode, Ticker passes through the requestAnimationFrame heartbeat,
   * ignoring the target framerate completely. Because requestAnimationFrame
   * frequency is not deterministic, any content using this mode should be time
   * based. You can leverage [getTime] and the tick event object's "delta"
   * properties to make this easier.
   *
   * Falls back on TIMEOUT if the requestAnimationFrame API is not supported.
   */
  static const String RAF = 'raf';

  /**
   * In this mode, Ticker uses the setTimeout API. This provides predictable,
   * adaptive frame timing, but does not provide the benefits of
   * requestAnimationFrame (screen synch, background throttling).
   */
  static const String TIMEOUT = 'timeout';

  /// Answer the singleton instance of the Ticker class.
  static Ticker get current => Ticker._singleton;

  static final Ticker _singleton = new Ticker._internal();

  /**
   * Deprecated in favour of [timingMode], and will be removed in a future
   * version. If true, timingMode will use [RAF_SYNCHED] by default.
   */
  bool useRAF = false;

  /**
   * Specifies the timing api (setTimeout or requestAnimationFrame) and mode to
   * use. See [TIMEOUT], [RAF], and [RAF_SYNCHED] for mode details.
   */
  String timingMode;

  /**
   * Specifies a maximum value for the delta property in the tick event object.
   * This is useful when building time based animations and systems to prevent
   * issues caused by large time gaps caused by background tabs, system sleep,
   * alert dialogs, or other blocking routines. Double the expected frame
   * duration is often an effective value (ex. maxDelta=50 when running at
   * 40fps).
   * 
   * This does not impact any other values (ex. time, runTime, etc), so you may
   * experience issues if you enable maxDelta when using both delta and other
   * values.
   * 
   * If 0, there is no maximum.
   */
  double maxDelta = 0.0;

  bool _paused = false;
  bool _inited = false;
  double _startTime = 0.0;
  double _pausedTime = 0.0;
  int _ticks = 0;
  int _pausedTicks = 0;
  double _interval = 50.0;
  double _lastTime = 0.0;
  List<double> _times;
  List<double> _tickTimes;
  int _timerId;
  Timer _timer;
  bool _raf = true;

  factory Ticker() {
    throw new UnsupportedError(
        'Ticker cannot be instantiated, use Ticker.current');
  }

  Ticker._internal();

  @override
  create_dart.EventListener addEventListener(String
      type, create_dart.EventListener listener, [bool useCapture = false]) {
    if (_inited == false) init();
    return super.addEventListener(type, listener, useCapture);
  }

  /**
   * Starts the tick. This is called automatically when the first listener is
   * added.
   */
  void init() {
    if (_inited) return;
    _inited = true;
    _times = new List<double>();
    _tickTimes = new List<double>();
    _startTime = _getTime();
    _times.add(_lastTime = 0.0);
    setInterval(_interval);
  }

  /**
   * Stops the Ticker and removes all listeners. Use init() to restart the
   * Ticker.
   */
  void reset() {
    window.cancelAnimationFrame(_timerId);
    removeAllEventListeners('tick');
  }

  /**
   * Sets the target time (in milliseconds) between ticks. Default is 50 (20
   * FPS).
   *
   * Note actual time between ticks may be more than requested depending on CPU
   * load.
   */
  setInterval(double interval) {
    _interval = interval;
    if (!_inited) return;
    _setupTick();
  }

  /// Returns the current target time between ticks, as set with [setInterval].
  double get getInterval => _interval;

  /**
   * Sets the target frame rate in frames per second (FPS). For example, with an
   * interval of 40, `getFPS()` will return 25 (1000ms per second divided by 40
   * ms per tick = 25fps).
   */
  void set setFPS(double value) => setInterval(1000 / value);

  /**
   * Returns the target frame rate in frames per second (FPS). For example, with
   * an interval of 40, `getFPS()` will return 25 (1000ms per second divided by
   * 40 ms per tick = 25fps).
   */
  double get getFPS => 1000 / _interval;

  /**
   * Returns the average time spent within a tick. This can vary significantly
   * from the value provided by getMeasuredFPS because it only measures the time
   * spent within the tick execution stack. 
   * 
   * Example 1: With a target FPS of 20, getMeasuredFPS() returns 20fps, which
   * indicates an average of 50ms between the end of one tick and the end of the
   * next. However, getMeasuredTickTime() returns 15ms. This indicates that
   * there may be up to 35ms of "idle" time between the end of one tick and the
   * start of the next.
   *
   * Example 2: With a target FPS of 30, getFPS() returns 10fps, which indicates
   * an average of 100ms between the end of one tick and the end of the next.
   * However, getMeasuredTickTime() returns 20ms. This would indicate that
   * something other than the tick is using ~80ms (another script, DOM
   * rendering, etc).
   */
  double getMeasuredTickTime([int ticks]) {
    double ttl = 0.0;
    if (_tickTimes.length < 1) return -1.0;

    // by default, calculate average for the past ~1 second:
    ticks = ticks != null ? ticks : getFPS.round();
    ticks = min(_tickTimes.length, ticks);

    for (int i = 0; i < ticks; i++) {
      ttl += _tickTimes[i];
    }

    return ttl / ticks;
  }

  /// Returns the actual frames / ticks per second.
  double getMeasuredFPS([int ticks]) {
    if (_times.length < 2) return -1.0;

    // by default, calculate fps for the past ~1 second:
    ticks = ticks != null ? ticks : getFPS.round();
    ticks = min(_tickTimes.length - 1, ticks);

    return 1000 / ((_times[0] - _times[ticks]) / ticks);
  }

  /**
   * Changes the "paused" state of the Ticker, which can be retrieved by the
   * [getPaused] method, and is passed as the "paused" property of the `tick`
   * event. When the ticker is paused, all listeners will still receive a tick
   * event, but the `paused` property will be false.
   *
   * Note that in EaselJS v0.5.0 and earlier, "pauseable" listeners would
   * **not** receive the tick callback when Ticker was paused. This is no longer
   * the case.
   *
   * ##Example
   *      createjs.Ticker.addEventListener("tick", handleTick);
   *      createjs.Ticker.setPaused(true);
   *      function handleTick(event) {
   *          console.log("Paused:", event.paused, createjs.Ticker.getPaused());
   *      }
   */
  void set setPaused(bool value) {
    _paused = value;
  }

  /**
   * Returns a boolean indicating whether Ticker is currently paused, as set
   * with [setPaused]. When the ticker is paused, all listeners will still
   * receive a tick event, but this value will be false.
   *
   * Note that in EaselJS v0.5.0 and earlier, "pauseable" listeners would
   * **not** receive the tick callback when Ticker was paused. This is no longer
   * the case.
   *
   * ##Example
   *      createjs.Ticker.addEventListener("tick", handleTick);
   *      createjs.Ticker.setPaused(true);
   *      function handleTick(event) {
   *          console.log("Paused:", createjs.Ticker.getPaused());
   *      }
   */
  bool get getPaused => _paused;

  /**
   * Returns the number of milliseconds that have elapsed since Ticker was
   * initialized. For example, you could use this in a time synchronized
   * animation to determine the exact amount of time that has elapsed.
   */
  double getTime([bool runTime = false]) {
    return _getTime() - _startTime - (runTime ? _pausedTime : 0);
  }

  /**
   * Similar to getTime(), but returns the time included with the current (or
   * most recent) tick event object.
   */
  double getEventTime([bool runTime = false]) {
    return (_lastTime != 0 ? _lastTime : _startTime) - (runTime ? _pausedTime :
        0);
  }

  /// Returns the number of ticks that have been broadcast by Ticker.
  int getTicks([bool pauseable = false]) {
    return _ticks - (pauseable ? _pausedTicks : 0);
  }

  void _handleSynch(num highResTime) {
    double time = _getTime() - _startTime;
    _timerId = null;
    _setupTick();

    // run if enough time has elapsed, with a little bit of flexibility to be early:
    if (time - _lastTime >= (_interval - 1) * 0.97) {
      _tick();
    }
  }

  void _handleRAF(num highResTime) {
    _timerId = null;
    _setupTick();
    _tick();
  }

  void _handleTimeout() {
    _timerId = null;
    _setupTick();
    _tick();
  }

  void _setupTick() {
    if (_timerId != null) return; // avoid duplicates

    String mode;

    if (timingMode != null) {
      mode = timingMode;
    } else if (useRAF && Ticker.RAF_SYNCHED != null) {
      mode = Ticker.RAF_SYNCHED;
    }

    if (mode == Ticker.RAF_SYNCHED || mode == Ticker.RAF) {
      _timerId = window.requestAnimationFrame(mode == Ticker.RAF ? _handleRAF :
          _handleSynch);
      _raf = true;
      return;
    }

    _raf = false;
    _timer = new Timer(new Duration(milliseconds: _interval.round()),
        _handleTimeout);
  }

  void _tick() {
    double time = _getTime() - _startTime;
    double elapsedTime = time - _lastTime;
    _ticks++;

    if (_paused) {
      _pausedTicks++;
      _pausedTime += elapsedTime;
    }

    _lastTime = time;

    if (hasEventListener('tick')) {
      TickEvent event = new TickEvent();
      event.delta = (maxDelta != 0 && elapsedTime > maxDelta) ? maxDelta :
          elapsedTime;
      event.paused = _paused;
      event.time = time;
      event.runTime = time - _pausedTime;
      dispatchEvent(event);
    }

    _tickTimes.insert(0, _getTime() - time);

    while (_tickTimes.length > 100) {
      _tickTimes.removeLast();
    }

    _times.insert(0, time);

    while (_times.length > 100) {
      _times.removeLast();
    }
  }

  double _getTime() => window.performance.now();
}
