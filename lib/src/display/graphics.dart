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
 * The Graphics class exposes an easy to use API for generating vector drawing
 * instructions and drawing them to a specified context. Note that you can use
 * Graphics without any dependency on the Easel framework by calling
 * [DisplayObject.draw] directly, or it can be used with the [Shape] object to
 * draw vector graphics within the context of an Easel display list.
 *
 * ##Example
 *      var g = new createjs.Graphics();
 *          g.setStrokeStyle(1);
 *          g.beginStroke(createjs.Graphics.getRGB(0,0,0));
 *          g.beginFill(createjs.Graphics.getRGB(255,0,0));
 *          g.drawCircle(0,0,3);
 *
 *          var s = new createjs.Shape(g);
 *              s.x = 100;
 *              s.y = 100;
 *
 *          stage.addChild(s);
 *          stage.update();
 *
 * Note that all drawing methods in Graphics return the Graphics instance, so
 * they can be chained together. For example, the following line of code would
 * generate the instructions to draw a rectangle with a red stroke and blue
 * fill, then render it to the specified context2D:
 *
 *      myGraphics.beginStroke("#F00").beginFill("#00F").drawRect(20, 20, 100, 50).draw(myContext2D);
 *
 * ##Tiny API
 * The Graphics class also includes a "tiny API", which is one or two-letter
 * methods that are shortcuts for all of the Graphics methods. These methods are
 * great for creating compact instructions, and is used by the Toolkit for
 * CreateJS to generate readable code. All tiny methods are marked as protected,
 * so you can view them by enabling protected descriptions in the docs.
 *
 * <table border="1" style="background-color: #f5f5f5; width: 100%;">
 * <tr style="background-color: #cccccc;"><th>Tiny</th><th>Method</th>
 * <th>Tiny</th><th>Method</th></tr>
 * <tr><td>mt</td><td>[moveTo]</td>
 * <td>lt</td><td>[lineTo]</td></tr>
 * <tr><td>a/at</td><td>[arc] / [arcTo]</td>
 * <td>bt</td><td>[bezierCurveTo]</td></tr>
 * <tr><td>qt</td><td>[quadraticCurveTo] (also curveTo)</td>
 * <td>r</td><td>[rect]</td></tr>
 * <tr><td>cp</td><td>[closePath]</td>
 * <td>c</td><td>[clear]</td></tr>
 * <tr><td>f</td><td>[beginFill]</td>
 * <td>lf</td><td>[beginLinearGradientFill]</td></tr>
 * <tr><td>rf</td><td>[beginRadialGradientFill]</td>
 * <td>bf</td><td>[beginBitmapFill]</td></tr>
 * <tr><td>ef</td><td>[endFill]</td>
 * <td>ss</td><td>[setStrokeStyle]</td></tr>
 * <tr><td>s</td><td>[beginStroke]</td>
 * <td>ls</td><td>[beginLinearGradientStroke]</td></tr>
 * <tr><td>rs</td><td>[beginRadialGradientStroke]</td>
 * <td>bs</td><td>[beginBitmapStroke]</td></tr>
 * <tr><td>es</td><td>[endStroke]</td>
 * <td>dr</td><td>[drawRect]</td></tr>
 * <tr><td>rr</td><td>[drawRoundRect]</td>
 * <td>rc</td><td>[drawRoundRectComplex]</td></tr>
 * <tr><td>dc</td><td>[drawCircle]</td>
 * <td>de</td><td>[drawEllipse]</td></tr>
 * <tr><td>dp</td><td>[drawPolyStar]</td>
 * <td>p</td><td>[decodePath]</td></tr>
 * </table>
 * 
 * <br>
 * 
 * Here is the above example, using the tiny API instead.
 *
 *      myGraphics.s("#F00").f("#00F").r(20, 20, 100, 50).draw(myContext2D);
 */
class Graphics {

}
