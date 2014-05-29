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
 * Provides helper functions for assembling a matrix for use with the
 * [ColorMatrixFilter], or can be used directly as the matrix for a
 * ColorMatrixFilter. Most methods return the instance to facilitate chained
 * calls.
 *
 * ##Example
 *      myColorMatrix.adjustHue(20).adjustBrightness(50);
 *
 * See [Filter] for an example of how to apply filters, or [ColorMatrixFilter]
 * for an example of how to use ColorMatrix to change a DisplayObject's color.
 */
class ColorMatrix {
  /// Array of delta values for contrast calculations.
  static const List<double> DELTA_INDEX = const <double>[0.0, 0.01, 0.02, 0.04,
      0.05, 0.06, 0.07, 0.08, 0.1, 0.11, 0.12, 0.14, 0.15, 0.16, 0.17, 0.18, 0.20,
      0.21, 0.22, 0.24, 0.25, 0.27, 0.28, 0.30, 0.32, 0.34, 0.36, 0.38, 0.40, 0.42,
      0.44, 0.46, 0.48, 0.5, 0.53, 0.56, 0.59, 0.62, 0.65, 0.68, 0.71, 0.74, 0.77,
      0.80, 0.83, 0.86, 0.89, 0.92, 0.95, 0.98, 1.0, 1.06, 1.12, 1.18, 1.24, 1.30,
      1.36, 1.42, 1.48, 1.54, 1.60, 1.66, 1.72, 1.78, 1.84, 1.90, 1.96, 2.0, 2.12,
      2.25, 2.37, 2.50, 2.62, 2.75, 2.87, 3.0, 3.2, 3.4, 3.6, 3.8, 4.0, 4.3, 4.7, 4.9,
      5.0, 5.5, 6.0, 6.5, 6.8, 7.0, 7.3, 7.5, 7.8, 8.0, 8.4, 8.7, 9.0, 9.4, 9.6, 9.8,
      10.0];

  /// Identity matrix values.
  static const List<double> IDENTITY_MATRIX = const <double>[1.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0,
      0.0, 0.0, 0.0, 0.0, 1.0];

  // The matrix values
  List<double> _values;

  ColorMatrix({double brightness: 0.0, double contrast: 0.0, double saturation:
      0.0, double hue: 0.0}) {
    reset();
    adjustColor(brightness: brightness, contrast: contrast, saturation:
        saturation, hue: hue);
  }

  List<double> get values => _values;

  void set values(List<double> list) {
    if (list.length != ColorMatrix.IDENTITY_MATRIX.length) {
      throw new StateError('ColorMatrix is 5x5 (25 long)');
    }

    _values = list;
  }

  /// Resets the matrix to identity values.
  ColorMatrix reset() {
    _values = new List<double>.from(ColorMatrix.IDENTITY_MATRIX, growable: false
        );
    return this;
  }

  /**
   * Shortcut method to adjust brightness, contrast, saturation and hue.
   * Equivalent to calling adjustHue(hue), adjustContrast(contrast),
   * adjustBrightness(brightness), adjustSaturation(saturation), in that order.
   */
  ColorMatrix adjustColor({double brightness: 0.0, double contrast: 0.0, double
      saturation: 0.0, double hue: 0.0}) {
    return adjustHue(hue)
        ..adjustContrast(contrast)
        ..adjustBrightness(brightness)
        ..adjustSaturation(saturation);
  }

  /**
   * Adjusts the brightness of pixel color by adding the specified value to the
   * red, green and blue channels. Positive values will make the image brighter,
   * negative values will make it darker.
   */
  ColorMatrix adjustBrightness(double value) {
    if (value == 0) return this;
    value = _cleanValue(value, 255.0);
    _multiplyMatrix(<double>[1.0, 0.0, 0.0, 0.0, value, 0.0, 1.0, 0.0, 0.0,
        value, 0.0, 0.0, 1.0, 0.0, value, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        1.0]);

    return this;
  }

  /**
   * Adjusts the contrast of pixel color.
   * Positive values will increase contrast, negative values will decrease contrast.
   */
  ColorMatrix adjustContrast(double value) {
    if (value == 0) return this;
    value = _cleanValue(value, 100.0);
    double x;

    if (value < 0) {
      x = 127 + value / 100 * 127;
    } else {
      x = value % 1;
      if (x == 0) {
        x = ColorMatrix.DELTA_INDEX[value.toInt()];
      } else {
        // use linear interpolation for more granularity.
        x = ColorMatrix.DELTA_INDEX[(value.toInt())] * (1 - x) +
            ColorMatrix.DELTA_INDEX[(value.toInt()) + 1] * x;
      }
      x = x * 127 + 127;
    }

    _multiplyMatrix(<double>[x / 127, 0.0, 0.0, 0.0, 0.5 * (127 - x), 0.0, x /
        127, 0.0, 0.0, 0.5 * (127 - x), 0.0, 0.0, x / 127, 0.0, 0.5 * (127 - x), 0.0,
        0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0]);

    return this;
  }

  /**
   * Adjusts the color saturation of the pixel.
   * Positive values will increase saturation, negative values will decrease
   * saturation (trend towards greyscale).
   */
  ColorMatrix adjustSaturation(double value) {
    if (value == 0) return this;
    value = _cleanValue(value, 100.0);
    double x = 1 + ((value > 0) ? 3 * value / 100 : value / 100);
    double lumR = 0.3086;
    double lumG = 0.6094;
    double lumB = 0.0820;

    _multiplyMatrix(<double>[lumR * (1 - x) + x, lumG * (1 - x), lumB * (1 - x),
        0.0, 0.0, lumR * (1 - x), lumG * (1 - x) + x, lumB * (1 - x), 0.0, 0.0, lumR *
        (1 - x), lumG * (1 - x), lumB * (1 - x) + x, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 0.0, 1.0]);

    return this;
  }

  /// Adjusts the hue of the pixel color.
  ColorMatrix adjustHue(double value) {
    if (value == 0) return this;
    value = _cleanValue(value, 180.0) / 180 * PI;
    double cosVal = cos(value);
    double sinVal = sin(value);
    double lumR = 0.213;
    double lumG = 0.715;
    double lumB = 0.072;

    _multiplyMatrix(<double>[lumR + cosVal * (1 - lumR) + sinVal * (-lumR), lumG
        + cosVal * (-lumG) + sinVal * (-lumG), lumB + cosVal * (-lumB) + sinVal * (1 -
        lumB), 0.0, 0.0, lumR + cosVal * (-lumR) + sinVal * (0.143), lumG + cosVal * (1
        - lumG) + sinVal * (0.140), lumB + cosVal * (-lumB) + sinVal * (-0.283), 0.0,
        0.0, lumR + cosVal * (-lumR) + sinVal * (-(1 - lumR)), lumG + cosVal * (-lumG) +
        sinVal * (lumG), lumB + cosVal * (1 - lumB) + sinVal * (lumB), 0.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0]);

    return this;
  }

  /// Concatenates (multiplies) the specified matrix with this one.
  ColorMatrix concat(ColorMatrix matrix) {
    _multiplyMatrix(matrix._values);
    return this;
  }

  /// Returns a clone of this ColorMatrix.
  ColorMatrix clone() => new ColorMatrix()..copyMatrix(this);

  /// Return a length 25 (5x5) list instance containing this matrix's values.
  List<double> toList() => new List<double>.from(_values, growable: false);

  /// Copy the specified matrix's values to this matrix.
  ColorMatrix copyMatrix(ColorMatrix matrix) {
    _values = new List<double>.from(matrix._values, growable: false);
    return this;
  }

  /// Returns a string representation of this object.
  @override
  String toString() => '[${runtimeType}]';

  void _multiplyMatrix(List<double> matrix) {
    List<double> col = new List<double>(ColorMatrix.IDENTITY_MATRIX.length);

    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        col[j] = matrix[j + i * 5];
      }

      for (int j = 0; j < 5; j++) {
        double val = 0.0;

        for (int k = 0; k < 5; k++) {
          val += matrix[j + k * 5] * col[k];
        }

        _values[j + i * 5] = val;
      }
    }
  }

  // Make sure values are within the specified range, hue has a limit of 180,
  // brightness is 255, others are 100.
  double _cleanValue(double value, double limit) {
    return min(limit, max(-limit, value));
  }
}
