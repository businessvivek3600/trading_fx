import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '/database/functions.dart';
import '/database/model/response/inbox_model.dart';
import '/providers/inbox_provider.dart';
import '/utils/app_default_loading.dart';
import '/utils/color.dart';

import 'package:get/get.dart';
import '/constants/assets_constants.dart';
import '/sl_container.dart';
import '/utils/default_logger.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/skeleton.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// import 'dart:html' as html;

import 'package:html/parser.dart';

const htmlData = r"""
<section class="tab-content detail-tab-readme-content -active markdown-body"><h1 class="hash-header" id="flutter_html">flutter_html <a href="#flutter_html" class="hash-link">#</a></h1>
<p><a href="https://pub.dev/packages/flutter_html"><img src="https://img.shields.io/pub/v/flutter_html.svg" alt="pub package"></a>
<a href="https://codecov.io/gh/Sub6Resources/flutter_html" rel="ugc"><img src="https://codecov.io/gh/Sub6Resources/flutter_html/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://circleci.com/gh/Sub6Resources/flutter_html" rel="ugc"><img src="https://circleci.com/gh/Sub6Resources/flutter_html.svg?style=svg" alt="CircleCI"></a>
<a href="https://github.com/Sub6Resources/flutter_html/blob/master/LICENSE" rel="ugc"><img src="https://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="MIT License"></a></p>
<p>A Flutter widget for rendering HTML and CSS as Flutter widgets.</p>
<div class="-pub-pre-copy-container"><pre><code class="language-dart hljs" data-highlighted="yes">Widget build(context) {
  <span class="hljs-keyword">return</span> Html(
    data: <span class="hljs-string">&lt;h1&gt;Hello, World!&lt;/h1&gt;
&lt;p&gt;&lt;span style="font-style:italic;"&gt;flutter_html&lt;/span&gt; supports a variety of HTML and CSS tags and attributes.&lt;/p&gt;
&lt;p&gt;Over a hundred static tags are supported out of the box.&lt;/p&gt;
&lt;p&gt;Or you can even define your own using an &lt;code&gt;Extension&lt;/code&gt;: &lt;flutter&gt;&lt;/flutter&gt;&lt;/p&gt;
&lt;p&gt;Its easy to add custom styles to your Html as well using the &lt;code&gt;Style&lt;/code&gt; class:&lt;/p&gt;
&lt;p class="fancy"&gt;Here's a fancy &amp;lt;p&amp;gt; element!&lt;/p&gt;
</span>,
    extensions: [
      TagExtension(
        tagsToExtend: {<span class="hljs-string">"flutter"</span>},
        child: <span class="hljs-keyword">const</span> FlutterLogo(),
      ),
    ],
    style: {
      <span class="hljs-string">"p.fancy"</span>: Style(
        textAlign: TextAlign.center,
        padding: <span class="hljs-keyword">const</span> EdgeInsets.all(<span class="hljs-number">16</span>),
        backgroundColor: Colors.grey,
        margin: Margins(left: Margin(<span class="hljs-number">50</span>, Unit.px), right: Margin.auto()),
        width: Width(<span class="hljs-number">300</span>, Unit.px),
        fontWeight: FontWeight.bold,
      ),
    },
  );
}
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<p>becomes...</p>
<img src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/example/screenshots/flutter_html_readme_screenshot.png" alt="A screenshot showing the above code snippet rendered using flutter_html">
<h2 class="hash-header" id="table-of-contents">Table of Contents: <a href="#table-of-contents" class="hash-link">#</a></h2>
<ul>
<li>
<p><a href="https://github.com/Sub6Resources/flutter_html/wiki/Supported-HTML-Elements" rel="ugc">Supported HTML Tags</a></p>
</li>
<li>
<p><a href="https://github.com/Sub6Resources/flutter_html/wiki/Supported-CSS-Attributes" rel="ugc">Supported CSS Attributes</a></p>
</li>
<li>
<p><a href="#why-this-package">Why flutter_html?</a></p>
</li>
<li>
<p><a href="#migration-guides">Migration Guide</a></p>
</li>
<li>
<p><a href="#api-reference">API Reference</a></p>
<ul>
<li>
<p><a href="#constructors">Constructors</a></p>
</li>
<li>
<p><a href="#parameters">Parameters Table</a></p>
</li>
</ul>
</li>
<li>
<p><a href="#external-packages">External Packages</a></p>
<ul>
<li>
<p><a href="#flutter_html_all"><code>flutter_html_all</code></a></p>
</li>
<li>
<p><a href="#flutter_html_audio"><code>flutter_html_audio</code></a></p>
</li>
<li>
<p><a href="#flutter_html_iframe"><code>flutter_html_iframe</code></a></p>
</li>
<li>
<p><a href="#flutter_html_math"><code>flutter_html_math</code></a></p>
</li>
<li>
<p><a href="#flutter_html_svg"><code>flutter_html_svg</code></a></p>
</li>
<li>
<p><a href="#flutter_html_table"><code>flutter_html_table</code></a></p>
</li>
<li>
<p><a href="#flutter_html_video"><code>flutter_html_video</code></a></p>
</li>
</ul>
</li>
<li>
<p><a href="#faq">Frequently Asked Questions</a></p>
</li>
<li>
<p><a href="#example">Example</a></p>
</li>
</ul>
<h2 class="hash-header" id="why-this-package">Why this package? <a href="#why-this-package" class="hash-link">#</a></h2>
<p>This package is designed with simplicity in mind. Originally created to allow basic rendering of HTML content into the Flutter widget tree,
this project has expanded to include support for basic styling as well!</p>
<p>If you need something more robust and customizable, the package also provides a number of extension APIs for extremely granular control over widget rendering!</p>
<h2 class="hash-header" id="migration-guides">Migration Guides <a href="#migration-guides" class="hash-link">#</a></h2>
<p><a href="https://github.com/Sub6Resources/flutter_html/wiki/Migration-Guides#300" rel="ugc">3.0.0 Migration Guide</a></p>
<h2 class="hash-header" id="api-reference">API Reference: <a href="#api-reference" class="hash-link">#</a></h2>
<p>For the full API reference, see <a href="https://pub.dev/documentation/flutter_html/latest/">here</a>.</p>
<p>For a full example, see <a href="https://github.com/Sub6Resources/flutter_html/tree/master/example" rel="ugc">here</a>.</p>
<p>Below, you will find brief descriptions of the parameters the<code>Html</code> widget accepts and some code snippets to help you use this package.</p>
<h3 class="hash-header" id="constructors">Constructors: <a href="#constructors" class="hash-link">#</a></h3>
<p>The package currently has two different constructors - <code>Html()</code> and <code>Html.fromDom()</code>.</p>
<p>The <code>Html()</code> constructor is for those who would like to directly pass HTML from the source to the package to be rendered.</p>
<p>If you would like to modify or sanitize the HTML before rendering it, then <code>Html.fromDom()</code> is for you - you can convert the HTML string to a <code>Document</code> and use its methods to modify the HTML as you wish. Then, you can directly pass the modified <code>Document</code> to the package. This eliminates the need to parse the modified <code>Document</code> back to a string, pass to <code>Html()</code>, and convert back to a <code>Document</code>, thus cutting down on load times.</p>
<h3 class="hash-header" id="parameters">Parameters: <a href="#parameters" class="hash-link">#</a></h3>
<table>
<thead>
<tr>
<th>Parameters</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>data</code></td>
<td>The HTML data passed to the <code>Html</code> widget. This is required and cannot be null when using <code>Html()</code>.</td>
</tr>
<tr>
<td><code>document</code></td>
<td>The DOM document passed to the <code>Html</code> widget. This is required and cannot be null when using <code>Html.fromDom()</code>.</td>
</tr>
<tr>
<td><code>onLinkTap</code></td>
<td>Optional. A function that defines what the widget should do when a link is tapped. The function exposes the <code>src</code> of the link as a <code>String</code> to use in your implementation.</td>
</tr>
<tr>
<td><code>extensions</code></td>
<td>Optional. A powerful API that allows you to customize everything when rendering a specific HTML tag.</td>
</tr>
<tr>
<td><code>shrinkWrap</code></td>
<td>Optional. A <code>bool</code> used while rendering different widgets to specify whether they should be shrink-wrapped or not, like <code>ContainerSpan</code></td>
</tr>
<tr>
<td><code>onlyRenderTheseTags</code></td>
<td>Optional. An exclusive set of elements the <code>Html</code> widget should render. Note that your html will be wrapped in <code>&lt;body&gt;</code> and <code>&lt;html&gt;</code> if it isn't already, so you should include those in this list.</td>
</tr>
<tr>
<td><code>doNotRenderTheseTags</code></td>
<td>Optional. A set of tags that should not be rendered by the <code>Html</code> widget.</td>
</tr>
<tr>
<td><code>style</code></td>
<td>Optional. A powerful API that allows you to customize the style that should be used when rendering a specific HTMl tag.</td>
</tr>
</tbody>
</table>
<p>More examples and in-depth details are available:</p>
<ul>
<li><a href="https://github.com/Sub6Resources/flutter_html/wiki/How-To-Use-Style" rel="ugc">Style</a>.</li>
<li><a href="https://github.com/Sub6Resources/flutter_html/wiki/How-To-Use-Extensions" rel="ugc">HtmlExtension</a></li>
</ul>
<h2 class="hash-header" id="external-packages">External Packages <a href="#external-packages" class="hash-link">#</a></h2>
<h3 class="hash-header" id="flutter_html_all"><code>flutter_html_all</code> <a href="#flutter_html_all" class="hash-link">#</a></h3>
<p>This package is simply a convenience package that exports all the other external packages below. You should use this if you plan to render all the tags that require external dependencies.</p>
<h3 class="hash-header" id="flutter_html_audio"><code>flutter_html_audio</code> <a href="#flutter_html_audio" class="hash-link">#</a></h3>
<p>This package renders audio elements using the <a href="https://pub.dev/packages/chewie_audio"><code>chewie_audio</code></a> and the <a href="https://pub.dev/packages/video_player"><code>video_player</code></a> plugin.</p>
<p>The package considers the attributes <code>controls</code>, <code>loop</code>, <code>src</code>, <code>autoplay</code>, <code>width</code>, and <code>muted</code> when rendering the audio widget.</p>
<h4 id="adding-the-audiohtmlextension">Adding the <code>AudioHtmlExtension</code>:</h4>
<p>Add the dependency to your pubspec.yaml:</p>
<div class="-pub-pre-copy-container"><pre><code data-highlighted="yes" class="hljs language-undefined">flutter pub add flutter_html_audio
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<div class="-pub-pre-copy-container"><pre><code class="language-dart hljs" data-highlighted="yes"><span class="hljs-keyword">import</span> <span class="hljs-string">'package:flutter_html_audio/flutter_html_audio'</span>;

Widget html = Html(
  data: myHtml,
  extensions: [
    AudioHtmlExtension(),
  ],
);
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<h3 class="hash-header" id="flutter_html_iframe"><code>flutter_html_iframe</code> <a href="#flutter_html_iframe" class="hash-link">#</a></h3>
<p>This package renders iframes using the <a href="https://pub.dev/packages/webview_flutter"><code>webview_flutter</code></a> plugin.</p>
<p>When rendering iframes, the package considers the width, height, and sandbox attributes.</p>
<p>Sandbox controls the JavaScript mode of the webview - a value of <code>null</code> or <code>allow-scripts</code> will set <code>javascriptMode: JavascriptMode.unrestricted</code>, otherwise it will set <code>javascriptMode: JavascriptMode.disabled</code>.</p>
<h4 id="adding-the-iframehtmlextension">Adding the <code>IframeHtmlExtension</code>:</h4>
<p>Add the dependency to your pubspec.yaml:</p>
<div class="-pub-pre-copy-container"><pre><code data-highlighted="yes" class="hljs language-undefined">flutter pub add flutter_html_iframe
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<div class="-pub-pre-copy-container"><pre><code class="language-dart hljs" data-highlighted="yes"><span class="hljs-keyword">import</span> <span class="hljs-string">'package:flutter_html_iframe/flutter_html_iframe'</span>;

Widget html = Html(
  data: myHtml,
  extensions: [
    IframeHtmlExtension(),
  ],
);
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<p>You can set the <code>navigationDelegate</code> of the webview with the <code>navigationDelegate</code> property on <code>IframeHtmlExtension</code>. This allows you to block or allow the loading of certain URLs.</p>
<h3 class="hash-header" id="flutter_html_math"><code>flutter_html_math</code> <a href="#flutter_html_math" class="hash-link">#</a></h3>
<p>This package renders MathML elements using the <a href="https://pub.dev/packages/flutter_math_fork"><code>flutter_math_fork</code></a> plugin.</p>
<p>When rendering MathML, the package takes the MathML data within the <code>&lt;math&gt;</code> tag and tries to parse it to Tex. Then, it will pass the parsed string to <code>flutter_math_fork</code>.</p>
<p>Because this package is parsing MathML to Tex, it may not support some functionalities. The current list of supported tags can be found <a href="https://github.com/Sub6Resources/flutter_html/wiki/First-Party-Extensions#flutter_html_math" rel="ugc">on the Wiki</a>, but some of these only have partial support at the moment.</p>
<h4 id="adding-the-mathhtmlextension">Adding the <code>MathHtmlExtension</code>:</h4>
<p>Add the dependency to your pubspec.yaml:</p>
<div class="-pub-pre-copy-container"><pre><code data-highlighted="yes" class="hljs language-undefined">flutter pub add flutter_html_math
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<div class="-pub-pre-copy-container"><pre><code class="language-dart hljs" data-highlighted="yes"><span class="hljs-keyword">import</span> <span class="hljs-string">'package:flutter_html_math/flutter_html_math'</span>;

Widget html = Html(
  data: myHtml,
  extensions: [
    MathHtmlExtension(),
  ],
);
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<p>If the parsing errors, you can use the <code>onMathErrorBuilder</code> property of <code>MathHtmlException</code> to catch the error and potentially fix it on your end.</p>
<p>The function exposes the parsed Tex <code>String</code>, as well as the error and error with type from <code>flutter_math_fork</code> as a <code>String</code>.</p>
<p>You can analyze the error and the parsed string, and finally return a new instance of <code>Math.tex()</code> with the corrected Tex string.</p>
<h4 id="tex">Tex</h4>
<p>If you have a Tex string you'd like to render inside your HTML you can do that using the same <a href="https://pub.dev/packages/flutter_math_fork"><code>flutter_math_fork</code></a> plugin.</p>
<p>Use a custom tag inside your HTML (an example could be <code>&lt;tex&gt;</code>), and place your <strong>raw</strong> Tex string inside.</p>
<p>Then, use the <code>extensions</code> parameter to add the widget to render Tex. It could look like this:</p>
<div class="-pub-pre-copy-container"><pre><code class="language-dart hljs" data-highlighted="yes">Widget htmlWidget = Html(
  data: <span class="hljs-string">r&lt;tex&gt;i\hbar\frac{\partial}{\partial t}\Psi(\vec x,t) = -\frac{\hbar}{2m}\nabla^2\Psi(\vec x,t)+ V(\vec x)\Psi(\vec x,t)&lt;/tex&gt;</span>,
  extensions: [
    TagExtension(
      tagsToExtend: {<span class="hljs-string">"tex"</span>},
      builder: (extensionContext) {
        <span class="hljs-keyword">return</span> Math.tex(
          extensionContext.innerHtml,
          mathStyle: MathStyle.display,
          textStyle: extensionContext.styledElement?.style.generateTextStyle(),
          onErrorFallback: (FlutterMathException e) {
            <span class="hljs-comment">//optionally try and correct the Tex string here</span>
            <span class="hljs-keyword">return</span> Text(e.message);
          },
        );
      }
    ),
  ],
);
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<h3 class="hash-header" id="flutter_html_svg"><code>flutter_html_svg</code> <a href="#flutter_html_svg" class="hash-link">#</a></h3>
<p>This package renders svg elements using the <a href="https://pub.dev/packages/flutter_svg"><code>flutter_svg</code></a> plugin.</p>
<p>When rendering SVGs, the package takes the SVG data within the <code>&lt;svg&gt;</code> tag and passes it to <code>flutter_svg</code>. The <code>width</code> and <code>height</code> attributes are considered while rendering, if given.</p>
<p>The package also exposes a few ways to render SVGs within an <code>&lt;img&gt;</code> tag, specifically base64 SVGs, asset SVGs, and network SVGs.</p>
<h4 id="adding-the-svghtmlextension">Adding the <code>SvgHtmlExtension</code>:</h4>
<p>Add the dependency to your pubspec.yaml:</p>
<div class="-pub-pre-copy-container"><pre><code data-highlighted="yes" class="hljs language-undefined">flutter pub add flutter_html_svg
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<div class="-pub-pre-copy-container"><pre><code class="language-dart hljs" data-highlighted="yes"><span class="hljs-keyword">import</span> <span class="hljs-string">'package:flutter_html_svg/flutter_html_svg'</span>;

Widget html = Html(
  data: myHtml,
  extensions: [
    SvgHtmlExtension(),
  ],
);
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<h3 class="hash-header" id="flutter_html_table"><code>flutter_html_table</code> <a href="#flutter_html_table" class="hash-link">#</a></h3>
<p>This package renders table elements using the <a href="https://pub.dev/packages/flutter_layout_grid"><code>flutter_layout_grid</code></a> plugin.</p>
<p>When rendering table elements, the package tries to calculate the best fit for each element and size its cell accordingly. <code>Rowspan</code>s and <code>colspan</code>s are considered in this process, so cells that span across multiple rows and columns are rendered as expected. Heights are determined intrinsically to maintain an optimal aspect ratio for the cell.</p>
<h4 id="adding-the-tablehtmlextension">Adding the <code>TableHtmlExtension</code>:</h4>
<p>Add the dependency to your pubspec.yaml:</p>
<div class="-pub-pre-copy-container"><pre><code data-highlighted="yes" class="hljs language-undefined">flutter pub add flutter_html_table
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<div class="-pub-pre-copy-container"><pre><code class="language-dart hljs" data-highlighted="yes"><span class="hljs-keyword">import</span> <span class="hljs-string">'package:flutter_html_table/flutter_html_table'</span>;

Widget html = Html(
  data: myHtml,
  extensions: [
    TableHtmlExtension(),
  ],
);
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<h3 class="hash-header" id="flutter_html_video"><code>flutter_html_video</code> <a href="#flutter_html_video" class="hash-link">#</a></h3>
<p>This package renders video elements using the <a href="https://pub.dev/packages/chewie"><code>chewie</code></a> and the <a href="https://pub.dev/packages/video_player"><code>video_player</code></a> plugin.</p>
<p>The package considers the attributes <code>controls</code>, <code>loop</code>, <code>src</code>, <code>autoplay</code>, <code>poster</code>, <code>width</code>, <code>height</code>, and <code>muted</code> when rendering the video widget.</p>
<h4 id="adding-the-videohtmlextension">Adding the <code>VideoHtmlExtension</code>:</h4>
<p>Add the dependency to your pubspec.yaml:</p>
<div class="-pub-pre-copy-container"><pre><code data-highlighted="yes" class="hljs language-undefined">flutter pub add flutter_html_video
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<div class="-pub-pre-copy-container"><pre><code class="language-dart hljs" data-highlighted="yes"><span class="hljs-keyword">import</span> <span class="hljs-string">'package:flutter_html_video/flutter_html_video'</span>;

Widget html = Html(
  data: myHtml,
  extensions: [
    VideoHtmlExtension(),
  ],
);
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<h2 class="hash-header" id="faq">FAQ <a href="#faq" class="hash-link">#</a></h2>
<h3 class="hash-header" id="why-cant-i-get-audioiframemathsvgtablevideo-to-show-up">Why can't I get <code>&lt;audio&gt;</code>/<code>&lt;iframe&gt;</code>/<code>&lt;math&gt;</code>/<code>&lt;svg&gt;</code>/<code>&lt;table&gt;</code>/</h3>
<p>Have you followed the instructions as described <a href="#external-packages">above</a>?</p>
<p>If so, feel free to file an issue or start a discussion for some extra help.</p>
<h3 class="hash-header" id="how-can-i-render-latex-in-my-html">How can I render <code>LaTex</code> in my HTML? <a href="#how-can-i-render-latex-in-my-html" class="hash-link">#</a></h3>
<p>See the <a href="#tex">above example</a>.</p>
<h3 class="hash-header" id="how-do-i-use-this-inside-of-a-row">How do I use this inside of a <code>Row()</code>? <a href="#how-do-i-use-this-inside-of-a-row" class="hash-link">#</a></h3>
<p>If you'd like to use this widget inside of a <code>Row()</code>, make sure to set <code>shrinkWrap: true</code> and place your widget inside expanded:</p>
<div class="-pub-pre-copy-container"><pre><code class="language-dart hljs" data-highlighted="yes">Widget row = Row(
   children: [
        Expanded(
            child: Html(
              shrinkWrap: <span class="hljs-keyword">true</span>,
              <span class="hljs-comment">//other params</span>
            )
        ),
	    <span class="hljs-comment">//whatever other widgets</span>
   ]
);
</code></pre><div class="-pub-pre-copy-button" title="copy to clipboard"></div><div class="-pub-pre-copy-feedback">copied to clipboard</div></div>
<h2 class="hash-header" id="example">Example <a href="#example" class="hash-link">#</a></h2>
<table width="100%" cellpadding="0" cellspacing="0" xss="removed"><tbody><tr xss="removed"><td valign="top" xss="removed"><b>Hello vivek malik (vivekmalik2466m),</b></td></tr><tr xss="removed"><td valign="top" xss="removed"><br>Your withdrawal for&nbsp;<b>USDT TRC20 203.81200000</b>&nbsp;has been completed.<br>You can view the invoice by logging in to your back office.</td></tr><tr xss="removed"><td valign="top" xss="removed"><b><span class="il">My</span>&nbsp;<span class="il">Car</span>&nbsp;Club</b><p>Support Team</p></td></tr></tbody></table>
<table>
<tbody><tr>
<td><img src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/example/screenshots/flutter_html_screenshot.png" alt="A screenshot showing the result of running the example"></td>
<td><img src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/example/screenshots/flutter_html_screenshot1.png" alt="A second screenshot showing the result of running the example"></td>
<td><img src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/example/screenshots/flutter_html_screenshot2.png" alt="A third screenshot showing the result of running the example"></td>
<td><img src="https://raw.githubusercontent.com/Sub6Resources/flutter_html/master/example/screenshots/flutter_html_screenshot3.png" alt="A fourth screenshot showing the result of running the example"></td>
</tr>
</tbody></table>
</section>
""";
const htmlData2 =
    r"""<html lang="en"><head><style id="ace-github">.ace-github .ace_gutter {background: #e8e8e8;color: #AAA;}.ace-github  {background: #fff;color: #000;}.ace-github .ace_keyword {font-weight: bold;}.ace-github .ace_string {color: #D14;}.ace-github .ace_variable.ace_class {color: teal;}.ace-github .ace_constant.ace_numeric {color: #099;}.ace-github .ace_constant.ace_buildin {color: #0086B3;}.ace-github .ace_support.ace_function {color: #0086B3;}.ace-github .ace_comment {color: #998;font-style: italic;}.ace-github .ace_variable.ace_language  {color: #0086B3;}.ace-github .ace_paren {font-weight: bold;}.ace-github .ace_boolean {font-weight: bold;}.ace-github .ace_string.ace_regexp {color: #009926;font-weight: normal;}.ace-github .ace_variable.ace_instance {color: teal;}.ace-github .ace_constant.ace_language {font-weight: bold;}.ace-github .ace_cursor {color: black;}.ace-github.ace_focus .ace_marker-layer .ace_active-line {background: rgb(255, 255, 204);}.ace-github .ace_marker-layer .ace_active-line {background: rgb(245, 245, 245);}.ace-github .ace_marker-layer .ace_selection {background: rgb(181, 213, 255);}.ace-github.ace_multiselect .ace_selection.ace_start {box-shadow: 0 0 3px 0px white;}.ace-github.ace_nobold .ace_line > span {font-weight: normal !important;}.ace-github .ace_marker-layer .ace_step {background: rgb(252, 255, 0);}.ace-github .ace_marker-layer .ace_stack {background: rgb(164, 229, 101);}.ace-github .ace_marker-layer .ace_bracket {margin: -1px 0 0 -1px;border: 1px solid rgb(192, 192, 192);}.ace-github .ace_gutter-active-line {background-color : rgba(0, 0, 0, 0.07);}.ace-github .ace_marker-layer .ace_selected-word {background: rgb(250, 250, 255);border: 1px solid rgb(200, 200, 250);}.ace-github .ace_invisible {color: #BFBFBF}.ace-github .ace_print-margin {width: 1px;background: #e8e8e8;}.ace-github .ace_indent-guide {background: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAACCAYAAACZgbYnAAAAE0lEQVQImWP4////f4bLly//BwAmVgd1/w11/gAAAABJRU5ErkJggg==") right repeat-y;}
/*# sourceURL=ace/css/ace-github */</style><style>    .error_widget_wrapper {        background: inherit;        color: inherit;        border:none    }    .error_widget {        border-top: solid 2px;        border-bottom: solid 2px;        margin: 5px 0;        padding: 10px 40px;        white-space: pre-wrap;    }    .error_widget.ace_error, .error_widget_arrow.ace_error{        border-color: #ff5a5a    }    .error_widget.ace_warning, .error_widget_arrow.ace_warning{        border-color: #F1D817    }    .error_widget.ace_info, .error_widget_arrow.ace_info{        border-color: #5a5a5a    }    .error_widget.ace_ok, .error_widget_arrow.ace_ok{        border-color: #5aaa5a    }    .error_widget_arrow {        position: absolute;        border: solid 5px;        border-top-color: transparent!important;        border-right-color: transparent!important;        border-left-color: transparent!important;        top: -5px;    }</style><style id="ace-tm">.ace-tm .ace_gutter {background: #f0f0f0;color: #333;}.ace-tm .ace_print-margin {width: 1px;background: #e8e8e8;}.ace-tm .ace_fold {background-color: #6B72E6;}.ace-tm {background-color: #FFFFFF;color: black;}.ace-tm .ace_cursor {color: black;}.ace-tm .ace_invisible {color: rgb(191, 191, 191);}.ace-tm .ace_storage,.ace-tm .ace_keyword {color: blue;}.ace-tm .ace_constant {color: rgb(197, 6, 11);}.ace-tm .ace_constant.ace_buildin {color: rgb(88, 72, 246);}.ace-tm .ace_constant.ace_language {color: rgb(88, 92, 246);}.ace-tm .ace_constant.ace_library {color: rgb(6, 150, 14);}.ace-tm .ace_invalid {background-color: rgba(255, 0, 0, 0.1);color: red;}.ace-tm .ace_support.ace_function {color: rgb(60, 76, 114);}.ace-tm .ace_support.ace_constant {color: rgb(6, 150, 14);}.ace-tm .ace_support.ace_type,.ace-tm .ace_support.ace_class {color: rgb(109, 121, 222);}.ace-tm .ace_keyword.ace_operator {color: rgb(104, 118, 135);}.ace-tm .ace_string {color: rgb(3, 106, 7);}.ace-tm .ace_comment {color: rgb(76, 136, 107);}.ace-tm .ace_comment.ace_doc {color: rgb(0, 102, 255);}.ace-tm .ace_comment.ace_doc.ace_tag {color: rgb(128, 159, 191);}.ace-tm .ace_constant.ace_numeric {color: rgb(0, 0, 205);}.ace-tm .ace_variable {color: rgb(49, 132, 149);}.ace-tm .ace_xml-pe {color: rgb(104, 104, 91);}.ace-tm .ace_entity.ace_name.ace_function {color: #0000A2;}.ace-tm .ace_heading {color: rgb(12, 7, 255);}.ace-tm .ace_list {color:rgb(185, 6, 144);}.ace-tm .ace_meta.ace_tag {color:rgb(0, 22, 142);}.ace-tm .ace_string.ace_regex {color: rgb(255, 0, 0)}.ace-tm .ace_marker-layer .ace_selection {background: rgb(181, 213, 255);}.ace-tm.ace_multiselect .ace_selection.ace_start {box-shadow: 0 0 3px 0px white;}.ace-tm .ace_marker-layer .ace_step {background: rgb(252, 255, 0);}.ace-tm .ace_marker-layer .ace_stack {background: rgb(164, 229, 101);}.ace-tm .ace_marker-layer .ace_bracket {margin: -1px 0 0 -1px;border: 1px solid rgb(192, 192, 192);}.ace-tm .ace_marker-layer .ace_active-line {background: rgba(0, 0, 0, 0.07);}.ace-tm .ace_gutter-active-line {background-color : #dcdcdc;}.ace-tm .ace_marker-layer .ace_selected-word {background: rgb(250, 250, 255);border: 1px solid rgb(200, 200, 250);}.ace-tm .ace_indent-guide {background: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAACCAYAAACZgbYnAAAAE0lEQVQImWP4////f4bLly//BwAmVgd1/w11/gAAAABJRU5ErkJggg==") right repeat-y;}
/*# sourceURL=ace/css/ace-tm */</style><style id="ace_editor.css">.ace_br1 {border-top-left-radius    : 3px;}.ace_br2 {border-top-right-radius   : 3px;}.ace_br3 {border-top-left-radius    : 3px; border-top-right-radius:    3px;}.ace_br4 {border-bottom-right-radius: 3px;}.ace_br5 {border-top-left-radius    : 3px; border-bottom-right-radius: 3px;}.ace_br6 {border-top-right-radius   : 3px; border-bottom-right-radius: 3px;}.ace_br7 {border-top-left-radius    : 3px; border-top-right-radius:    3px; border-bottom-right-radius: 3px;}.ace_br8 {border-bottom-left-radius : 3px;}.ace_br9 {border-top-left-radius    : 3px; border-bottom-left-radius:  3px;}.ace_br10{border-top-right-radius   : 3px; border-bottom-left-radius:  3px;}.ace_br11{border-top-left-radius    : 3px; border-top-right-radius:    3px; border-bottom-left-radius:  3px;}.ace_br12{border-bottom-right-radius: 3px; border-bottom-left-radius:  3px;}.ace_br13{border-top-left-radius    : 3px; border-bottom-right-radius: 3px; border-bottom-left-radius:  3px;}.ace_br14{border-top-right-radius   : 3px; border-bottom-right-radius: 3px; border-bottom-left-radius:  3px;}.ace_br15{border-top-left-radius    : 3px; border-top-right-radius:    3px; border-bottom-right-radius: 3px; border-bottom-left-radius: 3px;}.ace_editor {position: relative;overflow: hidden;font: 12px/normal 'Monaco', 'Menlo', 'Ubuntu Mono', 'Consolas', 'source-code-pro', monospace;direction: ltr;text-align: left;-webkit-tap-highlight-color: rgba(0, 0, 0, 0);}.ace_scroller {position: absolute;overflow: hidden;top: 0;bottom: 0;background-color: inherit;-ms-user-select: none;-moz-user-select: none;-webkit-user-select: none;user-select: none;cursor: text;}.ace_content {position: absolute;box-sizing: border-box;min-width: 100%;contain: style size layout;}.ace_dragging .ace_scroller:before{position: absolute;top: 0;left: 0;right: 0;bottom: 0;content: '';background: rgba(250, 250, 250, 0.01);z-index: 1000;}.ace_dragging.ace_dark .ace_scroller:before{background: rgba(0, 0, 0, 0.01);}.ace_selecting, .ace_selecting * {cursor: text !important;}.ace_gutter {position: absolute;overflow : hidden;width: auto;top: 0;bottom: 0;left: 0;cursor: default;z-index: 4;-ms-user-select: none;-moz-user-select: none;-webkit-user-select: none;user-select: none;contain: style size layout;}.ace_gutter-active-line {position: absolute;left: 0;right: 0;}.ace_scroller.ace_scroll-left {box-shadow: 17px 0 16px -16px rgba(0, 0, 0, 0.4) inset;}.ace_gutter-cell {position: absolute;top: 0;left: 0;right: 0;padding-left: 19px;padding-right: 6px;background-repeat: no-repeat;}.ace_gutter-cell.ace_error {background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAABOFBMVEX/////////QRswFAb/Ui4wFAYwFAYwFAaWGAfDRymzOSH/PxswFAb/SiUwFAYwFAbUPRvjQiDllog5HhHdRybsTi3/Tyv9Tir+Syj/UC3////XurebMBIwFAb/RSHbPx/gUzfdwL3kzMivKBAwFAbbvbnhPx66NhowFAYwFAaZJg8wFAaxKBDZurf/RB6mMxb/SCMwFAYwFAbxQB3+RB4wFAb/Qhy4Oh+4QifbNRcwFAYwFAYwFAb/QRzdNhgwFAYwFAbav7v/Uy7oaE68MBK5LxLewr/r2NXewLswFAaxJw4wFAbkPRy2PyYwFAaxKhLm1tMwFAazPiQwFAaUGAb/QBrfOx3bvrv/VC/maE4wFAbRPBq6MRO8Qynew8Dp2tjfwb0wFAbx6eju5+by6uns4uH9/f36+vr/GkHjAAAAYnRSTlMAGt+64rnWu/bo8eAA4InH3+DwoN7j4eLi4xP99Nfg4+b+/u9B/eDs1MD1mO7+4PHg2MXa347g7vDizMLN4eG+Pv7i5evs/v79yu7S3/DV7/498Yv24eH+4ufQ3Ozu/v7+y13sRqwAAADLSURBVHjaZc/XDsFgGIBhtDrshlitmk2IrbHFqL2pvXf/+78DPokj7+Fz9qpU/9UXJIlhmPaTaQ6QPaz0mm+5gwkgovcV6GZzd5JtCQwgsxoHOvJO15kleRLAnMgHFIESUEPmawB9ngmelTtipwwfASilxOLyiV5UVUyVAfbG0cCPHig+GBkzAENHS0AstVF6bacZIOzgLmxsHbt2OecNgJC83JERmePUYq8ARGkJx6XtFsdddBQgZE2nPR6CICZhawjA4Fb/chv+399kfR+MMMDGOQAAAABJRU5ErkJggg==");background-repeat: no-repeat;background-position: 2px center;}.ace_gutter-cell.ace_warning {background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAAAoLQ9TAAAAmVBMVEX///8AAAD///8AAAAAAABPSzb/5sAAAAB/blH/73z/ulkAAAAAAAD85pkAAAAAAAACAgP/vGz/rkDerGbGrV7/pkQICAf////e0IsAAAD/oED/qTvhrnUAAAD/yHD/njcAAADuv2r/nz//oTj/p064oGf/zHAAAAA9Nir/tFIAAAD/tlTiuWf/tkIAAACynXEAAAAAAAAtIRW7zBpBAAAAM3RSTlMAABR1m7RXO8Ln31Z36zT+neXe5OzooRDfn+TZ4p3h2hTf4t3k3ucyrN1K5+Xaks52Sfs9CXgrAAAAjklEQVR42o3PbQ+CIBQFYEwboPhSYgoYunIqqLn6/z8uYdH8Vmdnu9vz4WwXgN/xTPRD2+sgOcZjsge/whXZgUaYYvT8QnuJaUrjrHUQreGczuEafQCO/SJTufTbroWsPgsllVhq3wJEk2jUSzX3CUEDJC84707djRc5MTAQxoLgupWRwW6UB5fS++NV8AbOZgnsC7BpEAAAAABJRU5ErkJggg==");background-position: 2px center;}.ace_gutter-cell.ace_info {background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAAAAAA6mKC9AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAAJ0Uk5TAAB2k804AAAAPklEQVQY02NgIB68QuO3tiLznjAwpKTgNyDbMegwisCHZUETUZV0ZqOquBpXj2rtnpSJT1AEnnRmL2OgGgAAIKkRQap2htgAAAAASUVORK5CYII=");background-position: 2px center;}.ace_dark .ace_gutter-cell.ace_info {background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQBAMAAADt3eJSAAAAJFBMVEUAAAChoaGAgIAqKiq+vr6tra1ZWVmUlJSbm5s8PDxubm56enrdgzg3AAAAAXRSTlMAQObYZgAAAClJREFUeNpjYMAPdsMYHegyJZFQBlsUlMFVCWUYKkAZMxZAGdxlDMQBAG+TBP4B6RyJAAAAAElFTkSuQmCC");}.ace_scrollbar {contain: strict;position: absolute;right: 0;bottom: 0;z-index: 6;}.ace_scrollbar-inner {position: absolute;cursor: text;left: 0;top: 0;}.ace_scrollbar-v{overflow-x: hidden;overflow-y: scroll;top: 0;}.ace_scrollbar-h {overflow-x: scroll;overflow-y: hidden;left: 0;}.ace_print-margin {position: absolute;height: 100%;}.ace_text-input {position: absolute;z-index: 0;width: 0.5em;height: 1em;opacity: 0;background: transparent;-moz-appearance: none;appearance: none;border: none;resize: none;outline: none;overflow: hidden;font: inherit;padding: 0 1px;margin: 0 -1px;contain: strict;-ms-user-select: text;-moz-user-select: text;-webkit-user-select: text;user-select: text;white-space: pre!important;}.ace_text-input.ace_composition {background: transparent;color: inherit;z-index: 1000;opacity: 1;}.ace_composition_placeholder { color: transparent }.ace_composition_marker { border-bottom: 1px solid;position: absolute;border-radius: 0;margin-top: 1px;}[ace_nocontext=true] {transform: none!important;filter: none!important;perspective: none!important;clip-path: none!important;mask : none!important;contain: none!important;perspective: none!important;mix-blend-mode: initial!important;z-index: auto;}.ace_layer {z-index: 1;position: absolute;overflow: hidden;word-wrap: normal;white-space: pre;height: 100%;width: 100%;box-sizing: border-box;pointer-events: none;}.ace_gutter-layer {position: relative;width: auto;text-align: right;pointer-events: auto;height: 1000000px;contain: style size layout;}.ace_text-layer {font: inherit !important;position: absolute;height: 1000000px;width: 1000000px;contain: style size layout;}.ace_text-layer > .ace_line, .ace_text-layer > .ace_line_group {contain: style size layout;position: absolute;top: 0;left: 0;right: 0;}.ace_hidpi .ace_text-layer,.ace_hidpi .ace_gutter-layer,.ace_hidpi .ace_content,.ace_hidpi .ace_gutter {contain: strict;will-change: transform;}.ace_hidpi .ace_text-layer > .ace_line, .ace_hidpi .ace_text-layer > .ace_line_group {contain: strict;}.ace_cjk {display: inline-block;text-align: center;}.ace_cursor-layer {z-index: 4;}.ace_cursor {z-index: 4;position: absolute;box-sizing: border-box;border-left: 2px solid;transform: translatez(0);}.ace_multiselect .ace_cursor {border-left-width: 1px;}.ace_slim-cursors .ace_cursor {border-left-width: 1px;}.ace_overwrite-cursors .ace_cursor {border-left-width: 0;border-bottom: 1px solid;}.ace_hidden-cursors .ace_cursor {opacity: 0.2;}.ace_smooth-blinking .ace_cursor {transition: opacity 0.18s;}.ace_animate-blinking .ace_cursor {animation-duration: 1000ms;animation-timing-function: step-end;animation-name: blink-ace-animate;animation-iteration-count: infinite;}.ace_animate-blinking.ace_smooth-blinking .ace_cursor {animation-duration: 1000ms;animation-timing-function: ease-in-out;animation-name: blink-ace-animate-smooth;}@keyframes blink-ace-animate {from, to { opacity: 1; }60% { opacity: 0; }}@keyframes blink-ace-animate-smooth {from, to { opacity: 1; }45% { opacity: 1; }60% { opacity: 0; }85% { opacity: 0; }}.ace_marker-layer .ace_step, .ace_marker-layer .ace_stack {position: absolute;z-index: 3;}.ace_marker-layer .ace_selection {position: absolute;z-index: 5;}.ace_marker-layer .ace_bracket {position: absolute;z-index: 6;}.ace_marker-layer .ace_active-line {position: absolute;z-index: 2;}.ace_marker-layer .ace_selected-word {position: absolute;z-index: 4;box-sizing: border-box;}.ace_line .ace_fold {box-sizing: border-box;display: inline-block;height: 11px;margin-top: -2px;vertical-align: middle;background-image:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABEAAAAJCAYAAADU6McMAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAJpJREFUeNpi/P//PwOlgAXGYGRklAVSokD8GmjwY1wasKljQpYACtpCFeADcHVQfQyMQAwzwAZI3wJKvCLkfKBaMSClBlR7BOQikCFGQEErIH0VqkabiGCAqwUadAzZJRxQr/0gwiXIal8zQQPnNVTgJ1TdawL0T5gBIP1MUJNhBv2HKoQHHjqNrA4WO4zY0glyNKLT2KIfIMAAQsdgGiXvgnYAAAAASUVORK5CYII="),url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAA3CAYAAADNNiA5AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAACJJREFUeNpi+P//fxgTAwPDBxDxD078RSX+YeEyDFMCIMAAI3INmXiwf2YAAAAASUVORK5CYII=");background-repeat: no-repeat, repeat-x;background-position: center center, top left;color: transparent;border: 1px solid black;border-radius: 2px;cursor: pointer;pointer-events: auto;}.ace_dark .ace_fold {}.ace_fold:hover{background-image:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABEAAAAJCAYAAADU6McMAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAJpJREFUeNpi/P//PwOlgAXGYGRklAVSokD8GmjwY1wasKljQpYACtpCFeADcHVQfQyMQAwzwAZI3wJKvCLkfKBaMSClBlR7BOQikCFGQEErIH0VqkabiGCAqwUadAzZJRxQr/0gwiXIal8zQQPnNVTgJ1TdawL0T5gBIP1MUJNhBv2HKoQHHjqNrA4WO4zY0glyNKLT2KIfIMAAQsdgGiXvgnYAAAAASUVORK5CYII="),url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAA3CAYAAADNNiA5AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAACBJREFUeNpi+P//fz4TAwPDZxDxD5X4i5fLMEwJgAADAEPVDbjNw87ZAAAAAElFTkSuQmCC");}.ace_tooltip {background-color: #FFF;background-image: linear-gradient(to bottom, transparent, rgba(0, 0, 0, 0.1));border: 1px solid gray;border-radius: 1px;box-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);color: black;max-width: 100%;padding: 3px 4px;position: fixed;z-index: 999999;box-sizing: border-box;cursor: default;white-space: pre;word-wrap: break-word;line-height: normal;font-style: normal;font-weight: normal;letter-spacing: normal;pointer-events: none;}.ace_folding-enabled > .ace_gutter-cell {padding-right: 13px;}.ace_fold-widget {box-sizing: border-box;margin: 0 -12px 0 1px;display: none;width: 11px;vertical-align: top;background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAANElEQVR42mWKsQ0AMAzC8ixLlrzQjzmBiEjp0A6WwBCSPgKAXoLkqSot7nN3yMwR7pZ32NzpKkVoDBUxKAAAAABJRU5ErkJggg==");background-repeat: no-repeat;background-position: center;border-radius: 3px;border: 1px solid transparent;cursor: pointer;}.ace_folding-enabled .ace_fold-widget {display: inline-block;   }.ace_fold-widget.ace_end {background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAANElEQVR42m3HwQkAMAhD0YzsRchFKI7sAikeWkrxwScEB0nh5e7KTPWimZki4tYfVbX+MNl4pyZXejUO1QAAAABJRU5ErkJggg==");}.ace_fold-widget.ace_closed {background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAMAAAAGCAYAAAAG5SQMAAAAOUlEQVR42jXKwQkAMAgDwKwqKD4EwQ26sSOkVWjgIIHAzPiCgaqiqnJHZnKICBERHN194O5b9vbLuAVRL+l0YWnZAAAAAElFTkSuQmCCXA==");}.ace_fold-widget:hover {border: 1px solid rgba(0, 0, 0, 0.3);background-color: rgba(255, 255, 255, 0.2);box-shadow: 0 1px 1px rgba(255, 255, 255, 0.7);}.ace_fold-widget:active {border: 1px solid rgba(0, 0, 0, 0.4);background-color: rgba(0, 0, 0, 0.05);box-shadow: 0 1px 1px rgba(255, 255, 255, 0.8);}.ace_dark .ace_fold-widget {background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHklEQVQIW2P4//8/AzoGEQ7oGCaLLAhWiSwB146BAQCSTPYocqT0AAAAAElFTkSuQmCC");}.ace_dark .ace_fold-widget.ace_end {background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAH0lEQVQIW2P4//8/AxQ7wNjIAjDMgC4AxjCVKBirIAAF0kz2rlhxpAAAAABJRU5ErkJggg==");}.ace_dark .ace_fold-widget.ace_closed {background-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAMAAAAFCAYAAACAcVaiAAAAHElEQVQIW2P4//+/AxAzgDADlOOAznHAKgPWAwARji8UIDTfQQAAAABJRU5ErkJggg==");}.ace_dark .ace_fold-widget:hover {box-shadow: 0 1px 1px rgba(255, 255, 255, 0.2);background-color: rgba(255, 255, 255, 0.1);}.ace_dark .ace_fold-widget:active {box-shadow: 0 1px 1px rgba(255, 255, 255, 0.2);}.ace_inline_button {border: 1px solid lightgray;display: inline-block;margin: -1px 8px;padding: 0 5px;pointer-events: auto;cursor: pointer;}.ace_inline_button:hover {border-color: gray;background: rgba(200,200,200,0.2);display: inline-block;pointer-events: auto;}.ace_fold-widget.ace_invalid {background-color: #FFB4B4;border-color: #DE5555;}.ace_fade-fold-widgets .ace_fold-widget {transition: opacity 0.4s ease 0.05s;opacity: 0;}.ace_fade-fold-widgets:hover .ace_fold-widget {transition: opacity 0.05s ease 0.05s;opacity:1;}.ace_underline {text-decoration: underline;}.ace_bold {font-weight: bold;}.ace_nobold .ace_bold {font-weight: normal;}.ace_italic {font-style: italic;}.ace_error-marker {background-color: rgba(255, 0, 0,0.2);position: absolute;z-index: 9;}.ace_highlight-marker {background-color: rgba(255, 255, 0,0.2);position: absolute;z-index: 8;}
/*# sourceURL=ace/css/ace_editor.css */</style>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">
    <title>JSON to Dart</title>

    <!-- Bootstrap core CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
    <link rel="stylesheet" href="styles/github.css">

</head><body class="bg-light">
    <div class="container">
        <div class="py-5 text-center">
            <h2>JSON to Dart</h2>
            <p class="lead">Paste your JSON in the textarea below, click convert and get your Dart classes for free.</p>
        </div>
        <div class="row code-row">
            <div class="col-12 col-md-4">
                <form onsubmit="return false;">
                    <div class="form-group">
                        <label for="jsonEditor">JSON</label>
                        <div id="jsonEditor" class=" ace_editor ace_hidpi ace-github" draggable="false"><textarea class="ace_text-input" wrap="off" autocorrect="off" autocapitalize="off" spellcheck="false" style="opacity: 0; font-size: 1px; height: 1px; width: 1px; transform: translate(145px, 176px);"></textarea><div class="ace_gutter" aria-hidden="true" style="left: 0px; width: 48px;"><div class="ace_layer ace_gutter-layer ace_folding-enabled" style="height: 1e+06px; transform: translate(0px, 0px); width: 48px;"><div class="ace_gutter-cell " style="height: 16px; top: 0px;">1<span style="display: inline-block; height: 16px;" class="ace_fold-widget ace_start ace_open"></span></div><div class="ace_gutter-cell " style="height: 16px; top: 16px;">2<span style="display: none;"></span></div><div class="ace_gutter-cell " style="height: 16px; top: 32px;">3<span style="display: none;"></span></div><div class="ace_gutter-cell " style="height: 16px; top: 48px;">4<span style="display: none;"></span></div><div class="ace_gutter-cell " style="height: 16px; top: 64px;">5<span style="display: none;"></span></div><div class="ace_gutter-cell " style="height: 16px; top: 80px;">6<span style="display: none;"></span></div><div class="ace_gutter-cell " style="height: 16px; top: 96px;">7<span style="display: none;"></span></div><div class="ace_gutter-cell " style="height: 16px; top: 112px;">8<span style="display: none;"></span></div><div class="ace_gutter-cell " style="height: 16px; top: 128px;">9<span style="display: none;"></span></div><div class="ace_gutter-cell " style="height: 16px; top: 144px;">10<span style="display: none;"></span></div><div class="ace_gutter-active-line ace_gutter-cell " style="height: 16px; top: 160px;">11<span style="display: none;"></span></div><div class="ace_gutter-cell " style="height: 16px; top: 176px;">12<span style="display: none;"></span></div><div class="ace_gutter-cell " style="height: 16px; top: 192px;">13<span style="display: none;"></span></div></div></div><div class="ace_scroller" style="left: 47.4023px; right: 0px; bottom: 0px;"><div class="ace_content" style="transform: translate(0px, 0px); width: 577px; height: 361px;"><div class="ace_layer ace_print-margin-layer"><div class="ace_print-margin" style="left: 580px; visibility: visible;"></div></div><div class="ace_layer ace_marker-layer"><div class="ace_active-line" style="height: 16px; top: 160px; left: 0px; right: 0px;"></div></div><div class="ace_layer ace_text-layer" style="height: 1e+06px; margin: 0px 4px; transform: translate(0px, 0px);"><div class="ace_line" style="height: 16px; top: 0px;"><span class="ace_paren ace_lparen">{</span></div><div class="ace_line" style="height: 16px; top: 16px;">    <span class="ace_variable">"id"</span>: <span class="ace_string">"1"</span>,</div><div class="ace_line" style="height: 16px; top: 32px;">    <span class="ace_variable">"txn_id"</span>: <span class="ace_string">"KX9IP3K46U89RS5"</span>,</div><div class="ace_line" style="height: 16px; top: 48px;">    <span class="ace_variable">"type"</span>: <span class="ace_string">"2"</span>,</div><div class="ace_line" style="height: 16px; top: 64px;">    <span class="ace_variable">"user_id"</span>: <span class="ace_string">"BIZZ3800074"</span>,</div><div class="ace_line" style="height: 16px; top: 80px;">    <span class="ace_variable">"title"</span>: <span class="ace_string">"BIZZ3800074 TEST"</span>,</div><div class="ace_line" style="height: 16px; top: 96px;">    <span class="ace_variable">"message"</span>: <span class="ace_string">"&lt;p&gt;BIZZ3800074 TEST<span class="ace_invisible ace_invisible_space ace_invalid">·</span>BIZZ3800074 TEST<span class="ace_invisible ace_invisible_space ace_invalid">·</span>BIZZ3800074 TEST&lt;br&gt;&lt;/p&gt;"</span>,</div><div class="ace_line" style="height: 16px; top: 112px;">    <span class="ace_variable">"status"</span>: <span class="ace_string">"1"</span>,</div><div class="ace_line" style="height: 16px; top: 128px;">    <span class="ace_variable">"send"</span>: <span class="ace_string">"0"</span>,</div><div class="ace_line" style="height: 16px; top: 144px;">    <span class="ace_variable">"c_m_c"</span>: <span class="ace_string">"0"</span>,</div><div class="ace_line" style="height: 16px; top: 160px;">    <span class="ace_variable">"created_at"</span>: <span class="ace_string">"2023-06-15 08:50:34"</span>,</div><div class="ace_line" style="height: 16px; top: 176px;">    <span class="ace_variable">"updated_at"</span>: <span class="ace_string">"0000-00-00 00:00:00"</span></div><div class="ace_line" style="height: 16px; top: 192px;"><span class="ace_paren ace_rparen">}</span></div></div><div class="ace_layer ace_marker-layer"></div><div class="ace_layer ace_cursor-layer ace_hidden-cursors"><div class="ace_cursor" style="display: block; transform: translate(98px, 160px); width: 7px; height: 16px; animation-duration: 1000ms;"></div></div></div></div><div class="ace_scrollbar ace_scrollbar-v" style="display: none; width: 20px; bottom: 15px;"><div class="ace_scrollbar-inner" style="width: 20px; height: 208px;">&nbsp;</div></div><div class="ace_scrollbar ace_scrollbar-h" style="height: 20px; left: 47.4023px; right: 0px;"><div class="ace_scrollbar-inner" style="height: 20px; width: 577px;">&nbsp;</div></div><div style="height: auto; width: auto; top: 0px; left: 0px; visibility: hidden; position: absolute; white-space: pre; font: inherit; overflow: hidden;"><div style="height: auto; width: auto; top: 0px; left: 0px; visibility: hidden; position: absolute; white-space: pre; font: inherit; overflow: visible;">הההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההההה</div><div style="height: auto; width: auto; top: 0px; left: 0px; visibility: hidden; position: absolute; white-space: pre; font-style: inherit; font-variant: inherit; font-stretch: inherit; font-size: inherit; line-height: inherit; font-family: inherit; font-optical-sizing: inherit; font-kerning: inherit; font-feature-settings: inherit; font-variation-settings: inherit; overflow: visible;">XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</div></div></div>
                    </div>
                    <input class="form-control mb-2" id="dartClassName" placeholder="Your dart class name goes here">
                    <button type="submit" class="btn btn-primary">Generate Dart</button>
                    <label><input type="checkbox" id="private-fields"> Use private fields</label>
                    <button id="copy-clipboard" class="mt-2 btn btn-secondary">Copy Dart code to clipboard</button>
                </form>
            </div>
            <div class="col-12 col-md-8">
                <b id="invalid-dart" style="display: none">The Dart code generated is invalid</b>
                <pre><code class="dart hljs"><span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">InboxModel</span> </span>{
  <span class="hljs-built_in">String</span>? id;
  <span class="hljs-built_in">String</span>? txnId;
  <span class="hljs-built_in">String</span>? type;
  <span class="hljs-built_in">String</span>? userId;
  <span class="hljs-built_in">String</span>? title;
  <span class="hljs-built_in">String</span>? message;
  <span class="hljs-built_in">String</span>? status;
  <span class="hljs-built_in">String</span>? send;
  <span class="hljs-built_in">String</span>? cMC;
  <span class="hljs-built_in">String</span>? createdAt;
  <span class="hljs-built_in">String</span>? updatedAt;

  InboxModel(
      {<span class="hljs-keyword">this</span>.id,
      <span class="hljs-keyword">this</span>.txnId,
      <span class="hljs-keyword">this</span>.type,
      <span class="hljs-keyword">this</span>.userId,
      <span class="hljs-keyword">this</span>.title,
      <span class="hljs-keyword">this</span>.message,
      <span class="hljs-keyword">this</span>.status,
      <span class="hljs-keyword">this</span>.send,
      <span class="hljs-keyword">this</span>.cMC,
      <span class="hljs-keyword">this</span>.createdAt,
      <span class="hljs-keyword">this</span>.updatedAt});

  InboxModel.fromJson(<span class="hljs-built_in">Map</span>&lt;<span class="hljs-built_in">String</span>, <span class="hljs-keyword">dynamic</span>&gt; json) {
    id = json[<span class="hljs-string">'id'</span>];
    txnId = json[<span class="hljs-string">'txn_id'</span>];
    type = json[<span class="hljs-string">'type'</span>];
    userId = json[<span class="hljs-string">'user_id'</span>];
    title = json[<span class="hljs-string">'title'</span>];
    message = json[<span class="hljs-string">'message'</span>];
    status = json[<span class="hljs-string">'status'</span>];
    send = json[<span class="hljs-string">'send'</span>];
    cMC = json[<span class="hljs-string">'c_m_c'</span>];
    createdAt = json[<span class="hljs-string">'created_at'</span>];
    updatedAt = json[<span class="hljs-string">'updated_at'</span>];
  }

  <span class="hljs-built_in">Map</span>&lt;<span class="hljs-built_in">String</span>, <span class="hljs-keyword">dynamic</span>&gt; toJson() {
    <span class="hljs-keyword">final</span> <span class="hljs-built_in">Map</span>&lt;<span class="hljs-built_in">String</span>, <span class="hljs-keyword">dynamic</span>&gt; data = <span class="hljs-keyword">new</span> <span class="hljs-built_in">Map</span>&lt;<span class="hljs-built_in">String</span>, <span class="hljs-keyword">dynamic</span>&gt;();
    data[<span class="hljs-string">'id'</span>] = <span class="hljs-keyword">this</span>.id;
    data[<span class="hljs-string">'txn_id'</span>] = <span class="hljs-keyword">this</span>.txnId;
    data[<span class="hljs-string">'type'</span>] = <span class="hljs-keyword">this</span>.type;
    data[<span class="hljs-string">'user_id'</span>] = <span class="hljs-keyword">this</span>.userId;
    data[<span class="hljs-string">'title'</span>] = <span class="hljs-keyword">this</span>.title;
    data[<span class="hljs-string">'message'</span>] = <span class="hljs-keyword">this</span>.message;
    data[<span class="hljs-string">'status'</span>] = <span class="hljs-keyword">this</span>.status;
    data[<span class="hljs-string">'send'</span>] = <span class="hljs-keyword">this</span>.send;
    data[<span class="hljs-string">'c_m_c'</span>] = <span class="hljs-keyword">this</span>.cMC;
    data[<span class="hljs-string">'created_at'</span>] = <span class="hljs-keyword">this</span>.createdAt;
    data[<span class="hljs-string">'updated_at'</span>] = <span class="hljs-keyword">this</span>.updatedAt;
    <span class="hljs-keyword">return</span> data;
  }
}
</code></pre>
                <textarea style="position:fixed;opacity: 0;" id="hidden-dart"></textarea>
            </div>
        </div>
        <footer class="my-5 pt-5 text-muted text-center text-small">
            <p class="mb-1">Handcrafted by Javier Lecuona</p>
            <ul class="list-inline">
                <li class="list-inline-item">
                    <a href="https://github.com/javiercbk">Github</a>
                </li>
                <li class="list-inline-item">
                    <a href="https://github.com/javiercbk/json_to_dart">json_to_dart Code</a>
                </li>
                <li class="list-inline-item">
                    <a href="https://twitter.com/javiercbk">Twitter</a>
                </li>
            </ul>
        </footer>
    </div>
    <script src="js/highlight.min.js"></script>
    <script src="js/ace.js" type="text/javascript" charset="utf-8"></script>
    <script src="js/ace-mode-json.js" type="text/javascript" charset="utf-8"></script>
    <script src="js/ace-theme-github.js" type="text/javascript" charset="utf-8"></script>
    <script src="js/page.js"></script>


</body></html>""";

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});
  static const String routeName = 'InboxScreen';

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  var provider = sl.get<InboxProvider>();
  @override
  void initState() {
    provider.getMyInbox(true).then((value) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final args = ModalRoute.of(context)!.settings.arguments;
        print('arguments--> $args ${args.runtimeType}');
        try {
          if (args != null && args is String && args.isNotEmpty) {
            String? mailId = jsonDecode(args)['mail_id'];
            if (mailId != null) {
              if (provider.inbox.any((element) => element.id == mailId)) {
                InboxModel inbox = provider.inbox
                    .firstWhere((element) => element.id == mailId);
                Get.to(HtmlPreviewPage(
                  title: parseHtmlString(inbox.title ?? ''),
                  message: (inbox.message ?? ''),
                  file_url: (inbox.file_url ?? ''),
                ));
              }
            }
          }
        } catch (e) {
          errorLog('Error while routing notification mail $e',
              InboxScreen.routeName);
        }
      });
    });
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    provider.inboxPage = 0;
    await provider.getMyInbox(true);
    _refreshController.refreshCompleted();
  }

  late ScrollController _scrollController;
  void _scrollListener() async {
    if ((_scrollController.position.pixels -
                _scrollController.position.maxScrollExtent)
            .abs() <=
        200) {
      print('${(!provider.loadingMoreInbox && provider.hasMoreInbox)}');
      if (!provider.loadingMoreInbox && provider.hasMoreInbox) {
        provider.loadingMoreInbox = true;
        provider.getMyInbox(false, loadingMore: true);
      }
    }
  }

  @override
  void dispose() {
    provider.inboxPage = 0;
    provider.inbox.clear();
    provider.totalInbox = 0;
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color tColor = Colors.white;
    return Consumer<InboxProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: mainColor,
          appBar: AppBar(
              title: titleLargeText('Inbox', context, useGradient: true),
              elevation: 1,
              shadowColor: Colors.white),
          body: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: userAppBgImageProvider(context),
                    fit: BoxFit.cover,
                    opacity: 1)),
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              controller: _refreshController,
              header: const MaterialClassicHeader(),
              onRefresh: _onRefresh,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  (provider.loadingInbox || provider.inbox.isNotEmpty)
                      ? buildMessagesList(provider, tColor)
                      : buildEmptyMessages(context),
                  if (provider.loadingMoreInbox)
                    SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [appLoadingDots(height: 60)],
                      ),
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SliverToBoxAdapter buildEmptyMessages(BuildContext context) {
    return SliverToBoxAdapter(
        child: Container(
      height: Get.height * 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: 130,
              height: 130,
              child: assetLottie(Assets.mail, fit: BoxFit.cover)),
          height20(),
          Center(
            child: bodyLargeText(
              'You don\'t have any message yet.',
              context,
              color: Colors.white,
              useGradient: true,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ));
  }

  SliverList buildMessagesList(InboxProvider provider, Color tColor) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
            childCount: provider.loadingInbox ? 15 : provider.inbox.length,
            (context, i) {
      var request = InboxModel();
      if (!provider.loadingInbox) {
        request = provider.inbox[i];
      }
      return _InboxMessageTile(message: request);
    }));
  }
}

class _InboxMessageTile extends StatefulWidget {
  _InboxMessageTile({required this.message});
  final InboxModel message;

  @override
  State<_InboxMessageTile> createState() => _InboxMessageTileState();
}

class _InboxMessageTileState extends State<_InboxMessageTile> {
  bool showFull = false;
  @override
  Widget build(BuildContext context) {
    Color tColor = Colors.white;

    return Consumer<InboxProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: provider.loadingInbox
              ? null
              : () {
                  Get.to(HtmlPreviewPage(
                    title: parseHtmlString(widget.message.title ?? ''),
                    message: (widget.message.message ?? ''),
                    file_url: (widget.message.file_url ?? ''),
                  ));
                  setState(() {
                    showFull = !showFull;
                  });
                },
          child: Container(
            // duration: Duration(seconds: 2),
            // height: showFull ? 600 : 100,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            padding: const EdgeInsets.all(8),
            width: double.maxFinite,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black26,
                boxShadow: [
                  const BoxShadow(
                      color: Colors.white10,
                      blurRadius: 2,
                      spreadRadius: 2,
                      offset: Offset(0, 0))
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    provider.loadingInbox
                        ? Skeleton(
                            width: 70,
                            height: 15,
                            textColor: Colors.white30,
                            borderRadius: BorderRadius.circular(6))
                        : Expanded(
                            child: bodyLargeText(
                                parseHtmlString(widget.message.title ?? ''),
                                context,
                                color: tColor,
                                fontWeight: FontWeight.w500,
                                maxLines:
                                    // showFull ? double.maxFinite.toInt() :
                                    1),
                          ),
                    width5(),
                    provider.loadingInbox
                        ? Skeleton(
                            width: 100,
                            height: 15,
                            textColor: Colors.white30,
                            borderRadius: BorderRadius.circular(6))
                        : capText(
                            widget.message.createdAt != null &&
                                    widget.message.createdAt != ''
                                ? formatDateTime(
                                    DateTime.parse(widget.message.createdAt!))
                                : '',
                            context,
                            color: tColor.withOpacity(0.7),
                            fontWeight: FontWeight.w500)
                  ],
                ),
                height5(5),
                provider.loadingInbox
                    ? Skeleton(
                        width: 170,
                        height: 12,
                        textColor: Colors.white30,
                        borderRadius: BorderRadius.circular(6))
                    // : showFull
                    //     ? SizedBox(
                    //         height: 300,
                    //         child: HtmlPreviewPage(
                    //             title:
                    //                 parseHtmlString(widget.message.title ?? ''),
                    //             message: parseHtmlString(
                    //                 widget.message.message ?? '')))
                    : capText(
                        parseHtmlString(widget.message.message ?? ''), context,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        color: tColor.withOpacity(0.7)),
                width5(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HtmlPreviewPage extends StatefulWidget {
  const HtmlPreviewPage(
      {Key? key,
      required this.title,
      required this.message,
      required this.file_url})
      : super(key: key);

  final String title;
  final String message;
  final String file_url;

  @override
  HtmlPreviewPageState createState() => HtmlPreviewPageState();
}

final staticAnchorKey = GlobalKey();
String _parseHtmlString(String htmlString) {
  // var text = html.Element.span()..appendHtml(htmlString);
  var document = parse(htmlString
//       '''
// <body>
//   <h2>Header 1</h2>
//   <p>Text.</p>
//   <h2>Header 2</h2>
//   More text.
//   <br/>
// </body>'''
      );

  // outerHtml output
  print('outer html:');
  print(document.outerHtml);

  print('');

  // visitor output
  print('html visitor:');
  // _Visitor().visit(document);
  return document.outerHtml;
}

String removeTableTags(String htmlString) {
  RegExp tableRegExp = RegExp(r'<\/?table[^>]*>', multiLine: true);
  return htmlString.replaceAll(tableRegExp, '');
}

class HtmlPreviewPageState extends State<HtmlPreviewPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.bottom]);
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.message);
    return Scaffold(
      // backgroundColor: Color(0xFF082E8F),
      backgroundColor: const Color(0xFFEBEEF6),
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
        title: bodyMedText(widget.title, context,
            color: Colors.white, useGradient: true),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 10),
              child: Html(
                data: removeTableTags(widget.message),
                extensions: [
                  TagExtension(
                      tagsToExtend: {"flutter"}, child: const FlutterLogo()),
                ],
                style: {
                  "p.fancy": Style(
                      textAlign: TextAlign.center,
                      padding: HtmlPaddings.all(10),
                      backgroundColor: Colors.grey,
                      margin: Margins(
                          left: Margin(50, Unit.px), right: Margin.auto()),
                      width: Width(300, Unit.px),
                      fontWeight: FontWeight.bold),
                  "table": Style(
                    backgroundColor:
                        const Color.fromARGB(0x50, 0xe5, 0x15, 0x15),
                  ),
                  "tr": Style(
                    border:
                        const Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  "th": Style(
                      padding: HtmlPaddings.all(6),
                      backgroundColor: Colors.grey),
                  "td": Style(
                      padding: HtmlPaddings.all(6),
                      alignment: Alignment.topLeft),
                  'h2': Style(
                      maxLines: 2,
                      textOverflow: TextOverflow.ellipsis,
                      color: Colors.pink),
                  'h5': Style(
                      maxLines: 2,
                      textOverflow: TextOverflow.ellipsis,
                      color: Colors.pink),
                },
                onLinkTap: (str, map, ele) async {
                  print('link ${str},\n${map}, \n${ele}');
                  await launchTheLink(str ?? '');
                },
                onAnchorTap: (str, map, ele) async {
                  print('${str},\n${map}, \n${ele}');
                  await launchTheLink(str ?? '');
                },
                onCssParseError: (err, list) {
                  print('css err ${err}  ${list.map((e) => e.message)}');
                },
              ),
            ),
          ),
          if (widget.file_url != '')
            Container(
              // margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.link,
                      size: 13, color: Colors.black, weight: 2),
                  Expanded(
                      child: bodyLargeText('Attachment (1)', context,
                          color: Colors.black)),
                  TextButton(
                      onPressed: () => launchTheLink(widget.file_url),
                      child: bodyLargeText('View', context,
                          color: CupertinoColors.link))
                ],
              ),
            )
        ],
      ),
    );
  }
}
