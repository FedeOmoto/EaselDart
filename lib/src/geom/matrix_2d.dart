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
 * Represents an affine transformation matrix, and provides tools for
 * constructing and concatenating matrixes.
 */
class Matrix2D {
  /// Multiplier for converting degrees to radians. Used internally by Matrix2D.
  static const double DEG_TO_RAD = PI / 180.0;

  /// Position (0, 0) in a 3x3 affine transformation matrix.
  double a;

  /// Position (0, 1) in a 3x3 affine transformation matrix.
  double b;

  /// Position (1, 0) in a 3x3 affine transformation matrix.
  double c;

  /// Position (1, 1) in a 3x3 affine transformation matrix.
  double d;

  /// Position (2, 0) in a 3x3 affine transformation matrix.
  double tx;

  /// Position (2, 1) in a 3x3 affine transformation matrix.
  double ty;

  /**
   * Property representing the alpha that will be applied to a display object.
   * This is not part of matrix operations, but is used for operations like
   * getConcatenatedMatrix to provide concatenated alpha values.
   */
  double alpha = 1.0;

  /**
   * Property representing the shadow that will be applied to a display object.
   * This is not part of matrix operations, but is used for operations like
   * getConcatenatedMatrix to provide concatenated shadow values.
   */
  Shadow shadow;

  /**
   * Property representing the compositeOperation that will be applied to a
   * display object. This is not part of matrix operations, but is used for
   * operations like getConcatenatedMatrix to provide concatenated
   * compositeOperation values. You can find a list of valid composite operations
   * at: [https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/
   * Canvas_tutorial/Compositing](https://developer.mozilla.org/en-US/docs/Web/
   * Guide/HTML/Canvas_tutorial/Compositing)
   */
  String compositeOperation;

  /**
   * Property representing the value for visible that will be applied to a
   * display object. This is not part of matrix operations, but is used for
   * operations like getConcatenatedMatrix to provide concatenated visible
   * values.
   */
  bool visible = true;

  /// Initialization method. Can also be used to reinitialize the instance.
  void initialize([double a = 1.0, double b = 0.0, double c = 0.0, double d =
      1.0, double tx = 0.0, double ty = 0.0]) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
    this.tx = tx;
    this.ty = ty;
  }

  Matrix2D([double a = 1.0, double b = 0.0, double c = 0.0, double d =
      1.0, double tx = 0.0, double ty = 0.0]) {
    initialize(a, b, c, d, tx, ty);
  }

  /**
   * Concatenates the specified matrix properties with this matrix. All
   * parameters are required.
   */
  Matrix2D prepend(double a, double b, double c, double d, double tx, double ty)
      {
    if (a != 1.0 || b != 0.0 || c != 0.0 || d != 1.0) {
      double a1 = this.a;
      double c1 = this.c;

      this.a = a1 * a + this.b * c;
      this.b = a1 * b + this.b * d;
      this.c = c1 * a + this.d * c;
      this.d = c1 * b + this.d * d;
    }

    double tx1 = this.tx;
    this.tx = tx1 * a + this.ty * c + tx;
    this.ty = tx1 * b + this.ty * d + ty;

    return this;
  }

  /**
   * Appends the specified matrix properties with this matrix. All parameters
   * are required.
   */
  Matrix2D append(double a, double b, double c, double d, double tx, double ty)
      {
    double a1 = this.a;
    double b1 = this.b;
    double c1 = this.c;
    double d1 = this.d;

    this.a = a * a1 + b * c1;
    this.b = a * b1 + b * d1;
    this.c = c * a1 + d * c1;
    this.d = c * b1 + d * d1;
    this.tx = tx * a1 + ty * c1 + this.tx;
    this.ty = tx * b1 + ty * d1 + this.ty;

    return this;
  }

  /// Prepends the specified matrix with this matrix.
  Matrix2D prependMatrix(Matrix2D matrix) {
    prepend(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    prependProperties(matrix.alpha, matrix.shadow, matrix.compositeOperation,
        matrix.visible);
    return this;
  }

  /// Appends the specified matrix with this matrix.
  Matrix2D appendMatrix(Matrix2D matrix) {
    append(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
    appendProperties(matrix.alpha, matrix.shadow, matrix.compositeOperation,
        matrix.visible);
    return this;
  }

  /**
   * Generates matrix properties from the specified display object transform
   * properties, and prepends them with this matrix. For example, you can use
   * this to generate a matrix from a display object: var mtx = new Matrix2D();
   * mtx.prependTransform(o.x, o.y, o.scaleX, o.scaleY, o.rotation);
   */
  Matrix2D prependTransform(double x, double y, double scaleX, double
      scaleY, double rotation, double skewX, double skewY, [double regX = 0.0, double
      regY = 0.0]) {
    double cosine;
    double sine;

    if (rotation % 360.0 != 0.0) {
      cosine = cos(rotation * Matrix2D.DEG_TO_RAD);
      sine = sin(rotation * Matrix2D.DEG_TO_RAD);
    } else {
      cosine = 1.0;
      sine = 0.0;
    }

    if (regX != 0.0 || regY != 0.0) {
      // append the registration offset:
      tx -= regX;
      ty -= regY;
    }

    if (skewX != 0.0 || skewY != 0.0) {
      // TODO: can this be combined into a single prepend operation?
      skewX *= Matrix2D.DEG_TO_RAD;
      skewY *= Matrix2D.DEG_TO_RAD;
      prepend(cosine * scaleX, sine * scaleX, -sine * scaleY, cosine * scaleY,
          0.0, 0.0);
      prepend(cos(skewY), sin(skewY), -sin(skewX), cos(skewX), x, y);
    } else {
      prepend(cosine * scaleX, sine * scaleX, -sine * scaleY, cosine * scaleY,
          x, y);
    }

    return this;
  }

  /**
   * Generates matrix properties from the specified display object transform
   * properties, and appends them with this matrix. For example, you can use
   * this to generate a matrix from a display object: var mtx = new Matrix2D();
   * mtx.appendTransform(o.x, o.y, o.scaleX, o.scaleY, o.rotation);
   */
  Matrix2D appendTransform(double x, double y, double scaleX, double
      scaleY, double rotation, double skewX, double skewY, [double regX = 0.0, double
      regY = 0.0]) {
    double cosine;
    double sine;

    if (rotation % 360.0 != 0.0) {
      cosine = cos(rotation * Matrix2D.DEG_TO_RAD);
      sine = sin(rotation * Matrix2D.DEG_TO_RAD);
    } else {
      cosine = 1.0;
      sine = 0.0;
    }

    if (skewX != 0.0 || skewY != 0.0) {
      // TODO: can this be combined into a single append?
      skewX *= Matrix2D.DEG_TO_RAD;
      skewY *= Matrix2D.DEG_TO_RAD;
      append(cos(skewY), sin(skewY), -sin(skewX), cos(skewX), x, y);
      append(cosine * scaleX, sine * scaleX, -sine * scaleY, cosine * scaleY,
          0.0, 0.0);
    } else {
      append(cosine * scaleX, sine * scaleX, -sine * scaleY, cosine * scaleY, x,
          y);
    }

    if (regX != 0.0 || regY != 0.0) {
      // prepend the registration offset:
      tx -= regX * a + regY * c;
      ty -= regX * b + regY * d;
    }

    return this;
  }

  /// Applies a rotation transformation to the matrix.
  Matrix2D rotate(double angle) {
    double cosine = cos(angle);
    double sine = sin(angle);

    double a1 = a;
    double c1 = c;
    double tx1 = tx;

    a = a1 * cosine - this.b * sine;
    b = a1 * sine + this.b * cosine;
    c = c1 * cosine - this.d * sine;
    d = c1 * sine + this.d * cosine;
    tx = tx1 * cosine - this.ty * sine;
    ty = tx1 * sine + this.ty * cosine;

    return this;
  }

  /// Applies a skew transformation to the matrix.
  Matrix2D skew(double skewX, double skewY) {
    skewX = skewX * Matrix2D.DEG_TO_RAD;
    skewY = skewY * Matrix2D.DEG_TO_RAD;
    append(cos(skewY), sin(skewY), -sin(skewX), cos(skewX), 0.0, 0.0);
    return this;
  }

  /// Applies a scale transformation to the matrix.
  Matrix2D scale(double x, double y) {
    a *= x;
    d *= y;
    c *= x;
    b *= y;
    tx *= x;
    ty *= y;

    return this;
  }

  /// Translates the matrix on the x and y axes.
  Matrix2D translate(double x, double y) {
    tx += x;
    ty += y;
    return this;
  }

  /**
   * Sets the properties of the matrix to those of an identity matrix (one that
   * applies a null transformation).
   */
  Matrix2D identity() {
    alpha = a = d = 1.0;
    b = c = tx = ty = 0.0;
    shadow = compositeOperation = null;
    visible = true;

    return this;
  }

  /**
   * Inverts the matrix, causing it to perform the opposite transformation.
   * @method invert
   * @return {Matrix2D} This matrix. Useful for chaining method calls.
   **/
  Matrix2D invert() {
    double a1 = a;
    double b1 = b;
    double c1 = c;
    double d1 = d;
    double tx1 = tx;
    double n = a1 * d1 - b1 * c1;

    a = d1 / n;
    b = -b1 / n;
    c = -c1 / n;
    d = a1 / n;
    tx = (c1 * ty - d1 * tx1) / n;
    ty = -(a1 * ty - b1 * tx1) / n;

    return this;
  }

  /// Returns true if the matrix is an identity matrix.
  bool get isIdentity => tx == 0.0 && ty == 0.0 && a == 1.0 && b == 0.0 && c ==
      0.0 && d == 1.0;

  /// Transforms a point according to this matrix.
  Point<double> transformPoint(double x, double y) => new Point<double>(x * a +
      y * c + tx, x * b + y * d + ty);

  /**
   * Decomposes the matrix into transform properties (x, y, scaleX, scaleY, and
   * rotation). Note that this these values may not match the transform
   * properties you used to generate the matrix, though they will produce the
   * same visual results.
   */
  Matrix2D decompose(DisplayObject target) {
    // TODO: it would be nice to be able to solve for whether the matrix can be
    // decomposed into only scale/rotation even when scale is negative
    target.x = tx;
    target.y = ty;
    target.scaleX = sqrt(a * a + b * b);
    target.scaleY = sqrt(c * c + d * d);

    double skewX = atan2(-c, d);
    double skewY = atan2(b, a);

    if (skewX == skewY) {
      target.rotation = skewY / Matrix2D.DEG_TO_RAD;
      target.skewX = target.skewY = 0.0;

      if (a < 0.0 && d >= 0.0) {
        target.rotation += (target.rotation <= 0.0) ? 180.0 : -180.0;
      }
    } else {
      target.skewX = skewX / Matrix2D.DEG_TO_RAD;
      target.skewY = skewY / Matrix2D.DEG_TO_RAD;
    }

    return this;
  }

  /// Reinitializes all matrix properties to those specified.
  Matrix2D reinitialize([double a = 1.0, double b = 0.0, double c = 0.0, double
      d = 1.0, double tx = 0.0, double ty = 0.0, double alpha = 1.0, Shadow
      shadow, String compositeOperation, bool visible = true]) {
    initialize(a, b, c, d, tx, ty);
    this.alpha = alpha;
    this.shadow = shadow;
    this.compositeOperation = compositeOperation;
    this.visible = visible;

    return this;
  }

  /// Copies all properties from the specified matrix to this matrix.
  Matrix2D copy(matrix) => reinitialize(matrix.a, matrix.b, matrix.c, matrix.d,
      matrix.tx, matrix.ty, matrix.alpha, matrix.shadow, matrix.compositeOperation,
      matrix.visible);

  /// Appends the specified visual properties to the current matrix.
  Matrix2D appendProperties(double alpha, Shadow shadow, String
      compositeOperation, [bool visible = true]) {
    this.alpha *= alpha;
    this.shadow = shadow != null ? shadow : this.shadow;
    this.compositeOperation = compositeOperation != null ? compositeOperation :
        this.compositeOperation;
    this.visible = this.visible && visible;

    return this;
  }

  /// Prepends the specified visual properties to the current matrix.
  Matrix2D prependProperties(double alpha, Shadow shadow, String
      compositeOperation, [bool visible = true]) {
    this.alpha *= alpha;
    this.shadow = this.shadow != null ? this.shadow : shadow;
    this.compositeOperation = this.compositeOperation != null ?
        this.compositeOperation : compositeOperation;
    this.visible = this.visible && visible;

    return this;
  }

  /// Returns a [List] view of `this`.
  List<double> asList() => <double>[a, b, c, d, tx, ty];

  /// Returns a clone of the Matrix2D instance.
  Matrix2D clone() => (new Matrix2D()).copy(this);

  /// Returns a string representation of this object.
  @override
  String toString() => '[${runtimeType} (a=$a b=$b c=$c d=$d tx=$tx ty=$ty)]';
}
