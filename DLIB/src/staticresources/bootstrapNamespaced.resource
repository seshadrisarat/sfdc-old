/*!
 * Bootstrap v3.1.1 (http://getbootstrap.com)
 * Copyright 2011-2014 Twitter, Inc.
 * Licensed under MIT (https://github.com/twbs/bootstrap/blob/master/LICENSE)
 */


.sl-sb article,
.sl-sb aside,
.sl-sb details,
.sl-sb figcaption,
.sl-sb figure,
.sl-sb footer,
.sl-sb header,
.sl-sb hgroup,
.sl-sb main,
.sl-sb nav,
.sl-sb section,
.sl-sb summary {
  display: block;
}

.sl-sb html {
  font-family: sans-serif;
  -webkit-text-size-adjust: 100%;
      -ms-text-size-adjust: 100%;
}
.sl-sb body {
  margin: 0;
}
.sl-sb audio,
.sl-sb canvas,
.sl-sb progress,
.sl-sb video {
  display: inline-block;
  vertical-align: baseline;
}
.sl-sb audio:not([controls]) {
  display: none;
  height: 0;
}
.sl-sb [hidden],
.sl-sb template {
  display: none;
}
.sl-sb a {
  background: transparent;
}
.sl-sb a:active,
.sl-sb a:hover {
  outline: 0;
}
.sl-sb abbr[title] {
  border-bottom: 1px dotted;
}
.sl-sb b,
.sl-sb strong {
  font-weight: bold;
}
.sl-sb dfn {
  font-style: italic;
}
.sl-sb h1 {
  margin: .67em 0;
  font-size: 2em;
}
.sl-sb mark {
  color: #000;
  background: #ff0;
}
.sl-sb small {
  font-size: 80%;
}
.sl-sb sub,
.sl-sb sup {
  position: relative;
  font-size: 75%;
  line-height: 0;
  vertical-align: baseline;
}
.sl-sb sup {
  top: -.5em;
}
.sl-sb sub {
  bottom: -.25em;
}
.sl-sb img {
  border: 0;
}
.sl-sb svg:not(:root) {
  overflow: hidden;
}
.sl-sb figure {
  margin: 1em 40px;
}
.sl-sb hr {
  height: 0;
  -webkit-box-sizing: content-box;
     -moz-box-sizing: content-box;
          box-sizing: content-box;
}
.sl-sb pre {
  overflow: auto;
}
.sl-sb code,
.sl-sb kbd,
.sl-sb pre,
.sl-sb samp {
  font-family: monospace, monospace;
  font-size: 1em;
}
.sl-sb button,
.sl-sb input,
.sl-sb optgroup,
.sl-sb select,
.sl-sb textarea {
  margin: 0;
  font: inherit;
  color: inherit;
}
.sl-sb button {
  overflow: visible;
}
.sl-sb button,
.sl-sb select {
  text-transform: none;
}
.sl-sb button,
.sl-sb html input[type="button"],
.sl-sb input[type="reset"],
.sl-sb input[type="submit"] {
  -webkit-appearance: button;
  cursor: pointer;
}
.sl-sb button[disabled],
.sl-sb html input[disabled] {
  cursor: default;
}
.sl-sb button::-moz-focus-inner,
.sl-sb input::-moz-focus-inner {
  padding: 0;
  border: 0;
}
.sl-sb input {
  line-height: normal;
}
.sl-sb input[type="checkbox"],
.sl-sb input[type="radio"] {
  -webkit-box-sizing: border-box;
     -moz-box-sizing: border-box;
          box-sizing: border-box;
  padding: 0;
}
.sl-sb input[type="number"]::-webkit-inner-spin-button,
.sl-sb input[type="number"]::-webkit-outer-spin-button {
  height: auto;
}
.sl-sb input[type="search"] {
  -webkit-box-sizing: content-box;
     -moz-box-sizing: content-box;
          box-sizing: content-box;
  -webkit-appearance: textfield;
}
.sl-sb input[type="search"]::-webkit-search-cancel-button,
.sl-sb input[type="search"]::-webkit-search-decoration {
  -webkit-appearance: none;
}
.sl-sb fieldset {
  padding: .35em .625em .75em;
  margin: 0 2px;
  border: 1px solid #c0c0c0;
}
.sl-sb legend {
  padding: 0;
  border: 0;
}
.sl-sb textarea {
  overflow: auto;
}
.sl-sb optgroup {
  font-weight: bold;
}
.sl-sb table {
  border-spacing: 0;
  border-collapse: collapse;
}
.sl-sb td,
.sl-sb th {
  padding: 0;
}
@media print {
  .sl-sb * {
    color: #000 !important;
    text-shadow: none !important;
    background: transparent !important;
    -webkit-box-shadow: none !important;
            box-shadow: none !important;
  }
  .sl-sb a,
  .sl-sb a:visited {
    text-decoration: underline;
  }
  .sl-sb a[href]:after {
    content: " (" attr(href) ")";
  }
  .sl-sb abbr[title]:after {
    content: " (" attr(title) ")";
  }
  .sl-sb a[href^="javascript:"]:after,
  .sl-sb a[href^="#"]:after {
    content: "";
  }
  .sl-sb pre,
  .sl-sb blockquote {
    border: 1px solid #999;

    page-break-inside: avoid;
  }
  .sl-sb thead {
    display: table-header-group;
  }
  .sl-sb tr,
  .sl-sb img {
    page-break-inside: avoid;
  }
  .sl-sb img {
    max-width: 100% !important;
  }
  .sl-sb p,
  .sl-sb h2,
  .sl-sb h3 {
    orphans: 3;
    widows: 3;
  }
  .sl-sb h2,
  .sl-sb h3 {
    page-break-after: avoid;
  }
  .sl-sb select {
    background: #fff !important;
  }
  .sl-sb .navbar {
    display: none;
  }
  .sl-sb .table td,
  .sl-sb .table th {
    background-color: #fff !important;
  }
  .sl-sb .btn > .caret,
  .sl-sb .dropup > .btn > .caret {
    border-top-color: #000 !important;
  }
  .sl-sb .label {
    border: 1px solid #000;
  }
  .sl-sb .table {
    border-collapse: collapse !important;
  }
  .sl-sb .table-bordered th,
  .sl-sb .table-bordered td {
    border: 1px solid #ddd !important;
  }
}
@font-face {
  font-family: 'Glyphicons Halflings';

  src: url('../fonts/glyphicons-halflings-regular.eot');
  src: url('../fonts/glyphicons-halflings-regular.eot?#iefix') format('embedded-opentype'), url('../fonts/glyphicons-halflings-regular.woff') format('woff'), url('../fonts/glyphicons-halflings-regular.ttf') format('truetype'), url('../fonts/glyphicons-halflings-regular.svg#glyphicons_halflingsregular') format('svg');
}
.sl-sb .glyphicon {
  position: relative;
  top: 1px;
  display: inline-block;
  font-family: 'Glyphicons Halflings';
  font-style: normal;
  font-weight: normal;
  line-height: 1;

  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
.sl-sb .glyphicon-asterisk:before {
  content: "\2a";
}
.sl-sb .glyphicon-plus:before {
  content: "\2b";
}
.sl-sb .glyphicon-euro:before {
  content: "\20ac";
}
.sl-sb .glyphicon-minus:before {
  content: "\2212";
}
.sl-sb .glyphicon-cloud:before {
  content: "\2601";
}
.sl-sb .glyphicon-envelope:before {
  content: "\2709";
}
.sl-sb .glyphicon-pencil:before {
  content: "\270f";
}
.sl-sb .glyphicon-glass:before {
  content: "\e001";
}
.sl-sb .glyphicon-music:before {
  content: "\e002";
}
.sl-sb .glyphicon-search:before {
  content: "\e003";
}
.sl-sb .glyphicon-heart:before {
  content: "\e005";
}
.sl-sb .glyphicon-star:before {
  content: "\e006";
}
.sl-sb .glyphicon-star-empty:before {
  content: "\e007";
}
.sl-sb .glyphicon-user:before {
  content: "\e008";
}
.sl-sb .glyphicon-film:before {
  content: "\e009";
}
.sl-sb .glyphicon-th-large:before {
  content: "\e010";
}
.sl-sb .glyphicon-th:before {
  content: "\e011";
}
.sl-sb .glyphicon-th-list:before {
  content: "\e012";
}
.sl-sb .glyphicon-ok:before {
  content: "\e013";
}
.sl-sb .glyphicon-remove:before {
  content: "\e014";
}
.sl-sb .glyphicon-zoom-in:before {
  content: "\e015";
}
.sl-sb .glyphicon-zoom-out:before {
  content: "\e016";
}
.sl-sb .glyphicon-off:before {
  content: "\e017";
}
.sl-sb .glyphicon-signal:before {
  content: "\e018";
}
.sl-sb .glyphicon-cog:before {
  content: "\e019";
}
.sl-sb .glyphicon-trash:before {
  content: "\e020";
}
.sl-sb .glyphicon-home:before {
  content: "\e021";
}
.sl-sb .glyphicon-file:before {
  content: "\e022";
}
.sl-sb .glyphicon-time:before {
  content: "\e023";
}
.sl-sb .glyphicon-road:before {
  content: "\e024";
}
.sl-sb .glyphicon-download-alt:before {
  content: "\e025";
}
.sl-sb .glyphicon-download:before {
  content: "\e026";
}
.sl-sb .glyphicon-upload:before {
  content: "\e027";
}
.sl-sb .glyphicon-inbox:before {
  content: "\e028";
}
.sl-sb .glyphicon-play-circle:before {
  content: "\e029";
}
.sl-sb .glyphicon-repeat:before {
  content: "\e030";
}
.sl-sb .glyphicon-refresh:before {
  content: "\e031";
}
.sl-sb .glyphicon-list-alt:before {
  content: "\e032";
}
.sl-sb .glyphicon-lock:before {
  content: "\e033";
}
.sl-sb .glyphicon-flag:before {
  content: "\e034";
}
.sl-sb .glyphicon-headphones:before {
  content: "\e035";
}
.sl-sb .glyphicon-volume-off:before {
  content: "\e036";
}
.sl-sb .glyphicon-volume-down:before {
  content: "\e037";
}
.sl-sb .glyphicon-volume-up:before {
  content: "\e038";
}
.sl-sb .glyphicon-qrcode:before {
  content: "\e039";
}
.sl-sb .glyphicon-barcode:before {
  content: "\e040";
}
.sl-sb .glyphicon-tag:before {
  content: "\e041";
}
.sl-sb .glyphicon-tags:before {
  content: "\e042";
}
.sl-sb .glyphicon-book:before {
  content: "\e043";
}
.sl-sb .glyphicon-bookmark:before {
  content: "\e044";
}
.sl-sb .glyphicon-print:before {
  content: "\e045";
}
.sl-sb .glyphicon-camera:before {
  content: "\e046";
}
.sl-sb .glyphicon-font:before {
  content: "\e047";
}
.sl-sb .glyphicon-bold:before {
  content: "\e048";
}
.sl-sb .glyphicon-italic:before {
  content: "\e049";
}
.sl-sb .glyphicon-text-height:before {
  content: "\e050";
}
.sl-sb .glyphicon-text-width:before {
  content: "\e051";
}
.sl-sb .glyphicon-align-left:before {
  content: "\e052";
}
.sl-sb .glyphicon-align-center:before {
  content: "\e053";
}
.sl-sb .glyphicon-align-right:before {
  content: "\e054";
}
.sl-sb .glyphicon-align-justify:before {
  content: "\e055";
}
.sl-sb .glyphicon-list:before {
  content: "\e056";
}
.sl-sb .glyphicon-indent-left:before {
  content: "\e057";
}
.sl-sb .glyphicon-indent-right:before {
  content: "\e058";
}
.sl-sb .glyphicon-facetime-video:before {
  content: "\e059";
}
.sl-sb .glyphicon-picture:before {
  content: "\e060";
}
.sl-sb .glyphicon-map-marker:before {
  content: "\e062";
}
.sl-sb .glyphicon-adjust:before {
  content: "\e063";
}
.sl-sb .glyphicon-tint:before {
  content: "\e064";
}
.sl-sb .glyphicon-edit:before {
  content: "\e065";
}
.sl-sb .glyphicon-share:before {
  content: "\e066";
}
.sl-sb .glyphicon-check:before {
  content: "\e067";
}
.sl-sb .glyphicon-move:before {
  content: "\e068";
}
.sl-sb .glyphicon-step-backward:before {
  content: "\e069";
}
.sl-sb .glyphicon-fast-backward:before {
  content: "\e070";
}
.sl-sb .glyphicon-backward:before {
  content: "\e071";
}
.sl-sb .glyphicon-play:before {
  content: "\e072";
}
.sl-sb .glyphicon-pause:before {
  content: "\e073";
}
.sl-sb .glyphicon-stop:before {
  content: "\e074";
}
.sl-sb .glyphicon-forward:before {
  content: "\e075";
}
.sl-sb .glyphicon-fast-forward:before {
  content: "\e076";
}
.sl-sb .glyphicon-step-forward:before {
  content: "\e077";
}
.sl-sb .glyphicon-eject:before {
  content: "\e078";
}
.sl-sb .glyphicon-chevron-left:before {
  content: "\e079";
}
.sl-sb .glyphicon-chevron-right:before {
  content: "\e080";
}
.sl-sb .glyphicon-plus-sign:before {
  content: "\e081";
}
.sl-sb .glyphicon-minus-sign:before {
  content: "\e082";
}
.sl-sb .glyphicon-remove-sign:before {
  content: "\e083";
}
.sl-sb .glyphicon-ok-sign:before {
  content: "\e084";
}
.sl-sb .glyphicon-question-sign:before {
  content: "\e085";
}
.sl-sb .glyphicon-info-sign:before {
  content: "\e086";
}
.sl-sb .glyphicon-screenshot:before {
  content: "\e087";
}
.sl-sb .glyphicon-remove-circle:before {
  content: "\e088";
}
.sl-sb .glyphicon-ok-circle:before {
  content: "\e089";
}
.sl-sb .glyphicon-ban-circle:before {
  content: "\e090";
}
.sl-sb .glyphicon-arrow-left:before {
  content: "\e091";
}
.sl-sb .glyphicon-arrow-right:before {
  content: "\e092";
}
.sl-sb .glyphicon-arrow-up:before {
  content: "\e093";
}
.sl-sb .glyphicon-arrow-down:before {
  content: "\e094";
}
.sl-sb .glyphicon-share-alt:before {
  content: "\e095";
}
.sl-sb .glyphicon-resize-full:before {
  content: "\e096";
}
.sl-sb .glyphicon-resize-small:before {
  content: "\e097";
}
.sl-sb .glyphicon-exclamation-sign:before {
  content: "\e101";
}
.sl-sb .glyphicon-gift:before {
  content: "\e102";
}
.sl-sb .glyphicon-leaf:before {
  content: "\e103";
}
.sl-sb .glyphicon-fire:before {
  content: "\e104";
}
.sl-sb .glyphicon-eye-open:before {
  content: "\e105";
}
.sl-sb .glyphicon-eye-close:before {
  content: "\e106";
}
.sl-sb .glyphicon-warning-sign:before {
  content: "\e107";
}
.sl-sb .glyphicon-plane:before {
  content: "\e108";
}
.sl-sb .glyphicon-calendar:before {
  content: "\e109";
}
.sl-sb .glyphicon-random:before {
  content: "\e110";
}
.sl-sb .glyphicon-comment:before {
  content: "\e111";
}
.sl-sb .glyphicon-magnet:before {
  content: "\e112";
}
.sl-sb .glyphicon-chevron-up:before {
  content: "\e113";
}
.sl-sb .glyphicon-chevron-down:before {
  content: "\e114";
}
.sl-sb .glyphicon-retweet:before {
  content: "\e115";
}
.sl-sb .glyphicon-shopping-cart:before {
  content: "\e116";
}
.sl-sb .glyphicon-folder-close:before {
  content: "\e117";
}
.sl-sb .glyphicon-folder-open:before {
  content: "\e118";
}
.sl-sb .glyphicon-resize-vertical:before {
  content: "\e119";
}
.sl-sb .glyphicon-resize-horizontal:before {
  content: "\e120";
}
.sl-sb .glyphicon-hdd:before {
  content: "\e121";
}
.sl-sb .glyphicon-bullhorn:before {
  content: "\e122";
}
.sl-sb .glyphicon-bell:before {
  content: "\e123";
}
.sl-sb .glyphicon-certificate:before {
  content: "\e124";
}
.sl-sb .glyphicon-thumbs-up:before {
  content: "\e125";
}
.sl-sb .glyphicon-thumbs-down:before {
  content: "\e126";
}
.sl-sb .glyphicon-hand-right:before {
  content: "\e127";
}
.sl-sb .glyphicon-hand-left:before {
  content: "\e128";
}
.sl-sb .glyphicon-hand-up:before {
  content: "\e129";
}
.sl-sb .glyphicon-hand-down:before {
  content: "\e130";
}
.sl-sb .glyphicon-circle-arrow-right:before {
  content: "\e131";
}
.sl-sb .glyphicon-circle-arrow-left:before {
  content: "\e132";
}
.sl-sb .glyphicon-circle-arrow-up:before {
  content: "\e133";
}
.sl-sb .glyphicon-circle-arrow-down:before {
  content: "\e134";
}
.sl-sb .glyphicon-globe:before {
  content: "\e135";
}
.sl-sb .glyphicon-wrench:before {
  content: "\e136";
}
.sl-sb .glyphicon-tasks:before {
  content: "\e137";
}
.sl-sb .glyphicon-filter:before {
  content: "\e138";
}
.sl-sb .glyphicon-briefcase:before {
  content: "\e139";
}
.sl-sb .glyphicon-fullscreen:before {
  content: "\e140";
}
.sl-sb .glyphicon-dashboard:before {
  content: "\e141";
}
.sl-sb .glyphicon-paperclip:before {
  content: "\e142";
}
.sl-sb .glyphicon-heart-empty:before {
  content: "\e143";
}
.sl-sb .glyphicon-link:before {
  content: "\e144";
}
.sl-sb .glyphicon-phone:before {
  content: "\e145";
}
.sl-sb .glyphicon-pushpin:before {
  content: "\e146";
}
.sl-sb .glyphicon-usd:before {
  content: "\e148";
}
.sl-sb .glyphicon-gbp:before {
  content: "\e149";
}
.sl-sb .glyphicon-sort:before {
  content: "\e150";
}
.sl-sb .glyphicon-sort-by-alphabet:before {
  content: "\e151";
}
.sl-sb .glyphicon-sort-by-alphabet-alt:before {
  content: "\e152";
}
.sl-sb .glyphicon-sort-by-order:before {
  content: "\e153";
}
.sl-sb .glyphicon-sort-by-order-alt:before {
  content: "\e154";
}
.sl-sb .glyphicon-sort-by-attributes:before {
  content: "\e155";
}
.sl-sb .glyphicon-sort-by-attributes-alt:before {
  content: "\e156";
}
.sl-sb .glyphicon-unchecked:before {
  content: "\e157";
}
.sl-sb .glyphicon-expand:before {
  content: "\e158";
}
.sl-sb .glyphicon-collapse-down:before {
  content: "\e159";
}
.sl-sb .glyphicon-collapse-up:before {
  content: "\e160";
}
.sl-sb .glyphicon-log-in:before {
  content: "\e161";
}
.sl-sb .glyphicon-flash:before {
  content: "\e162";
}
.sl-sb .glyphicon-log-out:before {
  content: "\e163";
}
.sl-sb .glyphicon-new-window:before {
  content: "\e164";
}
.sl-sb .glyphicon-record:before {
  content: "\e165";
}
.sl-sb .glyphicon-save:before {
  content: "\e166";
}
.sl-sb .glyphicon-open:before {
  content: "\e167";
}
.sl-sb .glyphicon-saved:before {
  content: "\e168";
}
.sl-sb .glyphicon-import:before {
  content: "\e169";
}
.sl-sb .glyphicon-export:before {
  content: "\e170";
}
.sl-sb .glyphicon-send:before {
  content: "\e171";
}
.sl-sb .glyphicon-floppy-disk:before {
  content: "\e172";
}
.sl-sb .glyphicon-floppy-saved:before {
  content: "\e173";
}
.sl-sb .glyphicon-floppy-remove:before {
  content: "\e174";
}
.sl-sb .glyphicon-floppy-save:before {
  content: "\e175";
}
.sl-sb .glyphicon-floppy-open:before {
  content: "\e176";
}
.sl-sb .glyphicon-credit-card:before {
  content: "\e177";
}
.sl-sb .glyphicon-transfer:before {
  content: "\e178";
}
.sl-sb .glyphicon-cutlery:before {
  content: "\e179";
}
.sl-sb .glyphicon-header:before {
  content: "\e180";
}
.sl-sb .glyphicon-compressed:before {
  content: "\e181";
}
.sl-sb .glyphicon-earphone:before {
  content: "\e182";
}
.sl-sb .glyphicon-phone-alt:before {
  content: "\e183";
}
.sl-sb .glyphicon-tower:before {
  content: "\e184";
}
.sl-sb .glyphicon-stats:before {
  content: "\e185";
}
.sl-sb .glyphicon-sd-video:before {
  content: "\e186";
}
.sl-sb .glyphicon-hd-video:before {
  content: "\e187";
}
.sl-sb .glyphicon-subtitles:before {
  content: "\e188";
}
.sl-sb .glyphicon-sound-stereo:before {
  content: "\e189";
}
.sl-sb .glyphicon-sound-dolby:before {
  content: "\e190";
}
.sl-sb .glyphicon-sound-5-1:before {
  content: "\e191";
}
.sl-sb .glyphicon-sound-6-1:before {
  content: "\e192";
}
.sl-sb .glyphicon-sound-7-1:before {
  content: "\e193";
}
.sl-sb .glyphicon-copyright-mark:before {
  content: "\e194";
}
.sl-sb .glyphicon-registration-mark:before {
  content: "\e195";
}
.sl-sb .glyphicon-cloud-download:before {
  content: "\e197";
}
.sl-sb .glyphicon-cloud-upload:before {
  content: "\e198";
}
.sl-sb .glyphicon-tree-conifer:before {
  content: "\e199";
}
.sl-sb .glyphicon-tree-deciduous:before {
  content: "\e200";
}
.sl-sb * {
  -webkit-box-sizing: border-box;
     -moz-box-sizing: border-box;
          box-sizing: border-box;
}
.sl-sb *:before,
.sl-sb *:after {
  -webkit-box-sizing: border-box;
     -moz-box-sizing: border-box;
          box-sizing: border-box;
}
.sl-sb html {
  font-size: 62.5%;

  -webkit-tap-highlight-color: rgba(0, 0, 0, 0);
}
.sl-sb body {
  font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
  font-size: 14px;
  line-height: 1.42857143;
  color: #333;
  background-color: #fff;
}
.sl-sb input,
.sl-sb button,
.sl-sb select,
.sl-sb textarea {
  font-family: inherit;
  font-size: inherit;
  line-height: inherit;
}
.sl-sb a {
  color: #428bca;
  text-decoration: none;
}
.sl-sb a:hover,
.sl-sb a:focus {
  color: #2a6496;
  text-decoration: underline;
}
.sl-sb a:focus {
  outline: thin dotted;
  outline: 5px auto -webkit-focus-ring-color;
  outline-offset: -2px;
}
.sl-sb figure {
  margin: 0;
}
.sl-sb img {
  vertical-align: middle;
}
.sl-sb .img-responsive,
.sl-sb .thumbnail > img,
.sl-sb .thumbnail a > img,
.sl-sb .carousel-inner > .item > img,
.sl-sb .carousel-inner > .item > a > img {
  display: block;
  max-width: 100%;
  height: auto;
}
.sl-sb .img-rounded {
  border-radius: 6px;
}
.sl-sb .img-thumbnail {
  display: inline-block;
  max-width: 100%;
  height: auto;
  padding: 4px;
  line-height: 1.42857143;
  background-color: #fff;
  border: 1px solid #ddd;
  border-radius: 4px;
  -webkit-transition: all .2s ease-in-out;
       -o-transition: all .2s ease-in-out;
          transition: all .2s ease-in-out;
}
.sl-sb .img-circle {
  border-radius: 50%;
}
.sl-sb hr {
  margin-top: 20px;
  margin-bottom: 20px;
  border: 0;
  border-top: 1px solid #eee;
}
.sl-sb .sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  border: 0;
}
.sl-sb .sr-only-focusable:active,
.sl-sb .sr-only-focusable:focus {
  position: static;
  width: auto;
  height: auto;
  margin: 0;
  overflow: visible;
  clip: auto;
}
.sl-sb h1,
.sl-sb h2,
.sl-sb h3,
.sl-sb h4,
.sl-sb h5,
.sl-sb h6,
.sl-sb .h1,
.sl-sb .h2,
.sl-sb .h3,
.sl-sb .h4,
.sl-sb .h5,
.sl-sb .h6 {
  font-family: inherit;
  font-weight: 500;
  line-height: 1.1;
  color: inherit;
}
.sl-sb h1 small,
.sl-sb h2 small,
.sl-sb h3 small,
.sl-sb h4 small,
.sl-sb h5 small,
.sl-sb h6 small,
.sl-sb .h1 small,
.sl-sb .h2 small,
.sl-sb .h3 small,
.sl-sb .h4 small,
.sl-sb .h5 small,
.sl-sb .h6 small,
.sl-sb h1 .small,
.sl-sb h2 .small,
.sl-sb h3 .small,
.sl-sb h4 .small,
.sl-sb h5 .small,
.sl-sb h6 .small,
.sl-sb .h1 .small,
.sl-sb .h2 .small,
.sl-sb .h3 .small,
.sl-sb .h4 .small,
.sl-sb .h5 .small,
.sl-sb .h6 .small {
  font-weight: normal;
  line-height: 1;
  color: #999;
}
.sl-sb h1,
.sl-sb .h1,
.sl-sb h2,
.sl-sb .h2,
.sl-sb h3,
.sl-sb .h3 {
  margin-top: 20px;
  margin-bottom: 10px;
}
.sl-sb h1 small,
.sl-sb .h1 small,
.sl-sb h2 small,
.sl-sb .h2 small,
.sl-sb h3 small,
.sl-sb .h3 small,
.sl-sb h1 .small,
.sl-sb .h1 .small,
.sl-sb h2 .small,
.sl-sb .h2 .small,
.sl-sb h3 .small,
.sl-sb .h3 .small {
  font-size: 65%;
}
.sl-sb h4,
.sl-sb .h4,
.sl-sb h5,
.sl-sb .h5,
.sl-sb h6,
.sl-sb .h6 {
  margin-top: 10px;
  margin-bottom: 10px;
}
.sl-sb h4 small,
.sl-sb .h4 small,
.sl-sb h5 small,
.sl-sb .h5 small,
.sl-sb h6 small,
.sl-sb .h6 small,
.sl-sb h4 .small,
.sl-sb .h4 .small,
.sl-sb h5 .small,
.sl-sb .h5 .small,
.sl-sb h6 .small,
.sl-sb .h6 .small {
  font-size: 75%;
}
.sl-sb h1,
.sl-sb .h1 {
  font-size: 36px;
}
.sl-sb h2,
.sl-sb .h2 {
  font-size: 30px;
}
.sl-sb h3,
.sl-sb .h3 {
  font-size: 24px;
}
.sl-sb h4,
.sl-sb .h4 {
  font-size: 18px;
}
.sl-sb h5,
.sl-sb .h5 {
  font-size: 14px;
}
.sl-sb h6,
.sl-sb .h6 {
  font-size: 12px;
}
.sl-sb p {
  margin: 0 0 10px;
}
.sl-sb .lead {
  margin-bottom: 20px;
  font-size: 16px;
  font-weight: 200;
  line-height: 1.4;
}
@media (min-width: 768px) {
  .sl-sb .lead {
    font-size: 21px;
  }
}
.sl-sb small,
.sl-sb .small {
  font-size: 85%;
}
.sl-sb cite {
  font-style: normal;
}
.sl-sb mark,
.sl-sb .mark {
  padding: .2em;
  background-color: #fcf8e3;
}
.sl-sb .text-left {
  text-align: left;
}
.sl-sb .text-right {
  text-align: right;
}
.sl-sb .text-center {
  text-align: center;
}
.sl-sb .text-justify {
  text-align: justify;
}
.sl-sb .text-muted {
  color: #999;
}
.sl-sb .text-primary {
  color: #428bca;
}
.sl-sb a.text-primary:hover {
  color: #3071a9;
}
.sl-sb .text-success {
  color: #3c763d;
}
.sl-sb a.text-success:hover {
  color: #2b542c;
}
.sl-sb .text-info {
  color: #31708f;
}
.sl-sb a.text-info:hover {
  color: #245269;
}
.sl-sb .text-warning {
  color: #8a6d3b;
}
.sl-sb a.text-warning:hover {
  color: #66512c;
}
.sl-sb .text-danger {
  color: #a94442;
}
.sl-sb a.text-danger:hover {
  color: #843534;
}
.sl-sb .bg-primary {
  color: #fff;
  background-color: #428bca;
}
.sl-sb a.bg-primary:hover {
  background-color: #3071a9;
}
.sl-sb .bg-success {
  background-color: #dff0d8;
}
.sl-sb a.bg-success:hover {
  background-color: #c1e2b3;
}
.sl-sb .bg-info {
  background-color: #d9edf7;
}
.sl-sb a.bg-info:hover {
  background-color: #afd9ee;
}
.sl-sb .bg-warning {
  background-color: #fcf8e3;
}
.sl-sb a.bg-warning:hover {
  background-color: #f7ecb5;
}
.sl-sb .bg-danger {
  background-color: #f2dede;
}
.sl-sb a.bg-danger:hover {
  background-color: #e4b9b9;
}
.sl-sb .page-header {
  padding-bottom: 9px;
  margin: 40px 0 20px;
  border-bottom: 1px solid #eee;
}
.sl-sb ul,
.sl-sb ol {
  margin-top: 0;
  margin-bottom: 10px;
}
.sl-sb ul ul,
.sl-sb ol ul,
.sl-sb ul ol,
.sl-sb ol ol {
  margin-bottom: 0;
}
.sl-sb .list-unstyled {
  padding-left: 0;
  list-style: none;
}
.sl-sb .list-inline {
  padding-left: 0;
  margin-left: -5px;
  list-style: none;
}
.sl-sb .list-inline > li {
  display: inline-block;
  padding-right: 5px;
  padding-left: 5px;
}
.sl-sb dl {
  margin-top: 0;
  margin-bottom: 20px;
}
.sl-sb dt,
.sl-sb dd {
  line-height: 1.42857143;
}
.sl-sb dt {
  font-weight: bold;
}
.sl-sb dd {
  margin-left: 0;
}
@media (min-width: 768px) {
  .sl-sb .dl-horizontal dt {
    float: left;
    width: 160px;
    overflow: hidden;
    clear: left;
    text-align: right;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  .sl-sb .dl-horizontal dd {
    margin-left: 180px;
  }
}
.sl-sb abbr[title],
.sl-sb abbr[data-original-title] {
  cursor: help;
  border-bottom: 1px dotted #999;
}
.sl-sb .initialism {
  font-size: 90%;
  text-transform: uppercase;
}
.sl-sb blockquote {
  padding: 10px 20px;
  margin: 0 0 20px;
  font-size: 17.5px;
  border-left: 5px solid #eee;
}
.sl-sb blockquote p:last-child,
.sl-sb blockquote ul:last-child,
.sl-sb blockquote ol:last-child {
  margin-bottom: 0;
}
.sl-sb blockquote footer,
.sl-sb blockquote small,
.sl-sb blockquote .small {
  display: block;
  font-size: 80%;
  line-height: 1.42857143;
  color: #999;
}
.sl-sb blockquote footer:before,
.sl-sb blockquote small:before,
.sl-sb blockquote .small:before {
  content: '\2014 \00A0';
}
.sl-sb .blockquote-reverse,
.sl-sb blockquote.pull-right {
  padding-right: 15px;
  padding-left: 0;
  text-align: right;
  border-right: 5px solid #eee;
  border-left: 0;
}
.sl-sb .blockquote-reverse footer:before,
.sl-sb blockquote.pull-right footer:before,
.sl-sb .blockquote-reverse small:before,
.sl-sb blockquote.pull-right small:before,
.sl-sb .blockquote-reverse .small:before,
.sl-sb blockquote.pull-right .small:before {
  content: '';
}
.sl-sb .blockquote-reverse footer:after,
.sl-sb blockquote.pull-right footer:after,
.sl-sb .blockquote-reverse small:after,
.sl-sb blockquote.pull-right small:after,
.sl-sb .blockquote-reverse .small:after,
.sl-sb blockquote.pull-right .small:after {
  content: '\00A0 \2014';
}
.sl-sb blockquote:before,
.sl-sb blockquote:after {
  content: "";
}
.sl-sb address {
  margin-bottom: 20px;
  font-style: normal;
  line-height: 1.42857143;
}
.sl-sb code,
.sl-sb kbd,
.sl-sb pre,
.sl-sb samp {
  font-family: Menlo, Monaco, Consolas, "Courier New", monospace;
}
.sl-sb code {
  padding: 2px 4px;
  font-size: 90%;
  color: #c7254e;
  background-color: #f9f2f4;
  border-radius: 4px;
}
.sl-sb kbd {
  padding: 2px 4px;
  font-size: 90%;
  color: #fff;
  background-color: #333;
  border-radius: 3px;
  -webkit-box-shadow: inset 0 -1px 0 rgba(0, 0, 0, .25);
          box-shadow: inset 0 -1px 0 rgba(0, 0, 0, .25);
}
.sl-sb pre {
  display: block;
  padding: 9.5px;
  margin: 0 0 10px;
  font-size: 13px;
  line-height: 1.42857143;
  color: #333;
  word-break: break-all;
  word-wrap: break-word;
  background-color: #f5f5f5;
  border: 1px solid #ccc;
  border-radius: 4px;
}
.sl-sb pre code {
  padding: 0;
  font-size: inherit;
  color: inherit;
  white-space: pre-wrap;
  background-color: transparent;
  border-radius: 0;
}
.sl-sb .pre-scrollable {
  max-height: 340px;
  overflow-y: scroll;
}
.sl-sb .container {
  padding-right: 15px;
  padding-left: 15px;
  margin-right: auto;
  margin-left: auto;
}
@media (min-width: 768px) {
  .sl-sb .container {
    width: 750px;
  }
}
@media (min-width: 992px) {
  .sl-sb .container {
    width: 970px;
  }
}
@media (min-width: 1200px) {
  .sl-sb .container {
    width: 1170px;
  }
}
.sl-sb .container-fluid {
  padding-right: 15px;
  padding-left: 15px;
  margin-right: auto;
  margin-left: auto;
}
.sl-sb .row {
  margin-right: -15px;
  margin-left: -15px;
}
.sl-sb .col-xs-1,
.sl-sb .col-sm-1,
.sl-sb .col-md-1,
.sl-sb .col-lg-1,
.sl-sb .col-xs-2,
.sl-sb .col-sm-2,
.sl-sb .col-md-2,
.sl-sb .col-lg-2,
.sl-sb .col-xs-3,
.sl-sb .col-sm-3,
.sl-sb .col-md-3,
.sl-sb .col-lg-3,
.sl-sb .col-xs-4,
.sl-sb .col-sm-4,
.sl-sb .col-md-4,
.sl-sb .col-lg-4,
.sl-sb .col-xs-5,
.sl-sb .col-sm-5,
.sl-sb .col-md-5,
.sl-sb .col-lg-5,
.sl-sb .col-xs-6,
.sl-sb .col-sm-6,
.sl-sb .col-md-6,
.sl-sb .col-lg-6,
.sl-sb .col-xs-7,
.sl-sb .col-sm-7,
.sl-sb .col-md-7,
.sl-sb .col-lg-7,
.sl-sb .col-xs-8,
.sl-sb .col-sm-8,
.sl-sb .col-md-8,
.sl-sb .col-lg-8,
.sl-sb .col-xs-9,
.sl-sb .col-sm-9,
.sl-sb .col-md-9,
.sl-sb .col-lg-9,
.sl-sb .col-xs-10,
.sl-sb .col-sm-10,
.sl-sb .col-md-10,
.sl-sb .col-lg-10,
.sl-sb .col-xs-11,
.sl-sb .col-sm-11,
.sl-sb .col-md-11,
.sl-sb .col-lg-11,
.sl-sb .col-xs-12,
.sl-sb .col-sm-12,
.sl-sb .col-md-12,
.sl-sb .col-lg-12 {
  position: relative;
  min-height: 1px;
  padding-right: 15px;
  padding-left: 15px;
}
.sl-sb .col-xs-1,
.sl-sb .col-xs-2,
.sl-sb .col-xs-3,
.sl-sb .col-xs-4,
.sl-sb .col-xs-5,
.sl-sb .col-xs-6,
.sl-sb .col-xs-7,
.sl-sb .col-xs-8,
.sl-sb .col-xs-9,
.sl-sb .col-xs-10,
.sl-sb .col-xs-11,
.sl-sb .col-xs-12 {
  float: left;
}
.sl-sb .col-xs-12 {
  width: 100%;
}
.sl-sb .col-xs-11 {
  width: 91.66666667%;
}
.sl-sb .col-xs-10 {
  width: 83.33333333%;
}
.sl-sb .col-xs-9 {
  width: 75%;
}
.sl-sb .col-xs-8 {
  width: 66.66666667%;
}
.sl-sb .col-xs-7 {
  width: 58.33333333%;
}
.sl-sb .col-xs-6 {
  width: 50%;
}
.sl-sb .col-xs-5 {
  width: 41.66666667%;
}
.sl-sb .col-xs-4 {
  width: 33.33333333%;
}
.sl-sb .col-xs-3 {
  width: 25%;
}
.sl-sb .col-xs-2 {
  width: 16.66666667%;
}
.sl-sb .col-xs-1 {
  width: 8.33333333%;
}
.sl-sb .col-xs-pull-12 {
  right: 100%;
}
.sl-sb .col-xs-pull-11 {
  right: 91.66666667%;
}
.sl-sb .col-xs-pull-10 {
  right: 83.33333333%;
}
.sl-sb .col-xs-pull-9 {
  right: 75%;
}
.sl-sb .col-xs-pull-8 {
  right: 66.66666667%;
}
.sl-sb .col-xs-pull-7 {
  right: 58.33333333%;
}
.sl-sb .col-xs-pull-6 {
  right: 50%;
}
.sl-sb .col-xs-pull-5 {
  right: 41.66666667%;
}
.sl-sb .col-xs-pull-4 {
  right: 33.33333333%;
}
.sl-sb .col-xs-pull-3 {
  right: 25%;
}
.sl-sb .col-xs-pull-2 {
  right: 16.66666667%;
}
.sl-sb .col-xs-pull-1 {
  right: 8.33333333%;
}
.sl-sb .col-xs-pull-0 {
  right: auto;
}
.sl-sb .col-xs-push-12 {
  left: 100%;
}
.sl-sb .col-xs-push-11 {
  left: 91.66666667%;
}
.sl-sb .col-xs-push-10 {
  left: 83.33333333%;
}
.sl-sb .col-xs-push-9 {
  left: 75%;
}
.sl-sb .col-xs-push-8 {
  left: 66.66666667%;
}
.sl-sb .col-xs-push-7 {
  left: 58.33333333%;
}
.sl-sb .col-xs-push-6 {
  left: 50%;
}
.sl-sb .col-xs-push-5 {
  left: 41.66666667%;
}
.sl-sb .col-xs-push-4 {
  left: 33.33333333%;
}
.sl-sb .col-xs-push-3 {
  left: 25%;
}
.sl-sb .col-xs-push-2 {
  left: 16.66666667%;
}
.sl-sb .col-xs-push-1 {
  left: 8.33333333%;
}
.sl-sb .col-xs-push-0 {
  left: auto;
}
.sl-sb .col-xs-offset-12 {
  margin-left: 100%;
}
.sl-sb .col-xs-offset-11 {
  margin-left: 91.66666667%;
}
.sl-sb .col-xs-offset-10 {
  margin-left: 83.33333333%;
}
.sl-sb .col-xs-offset-9 {
  margin-left: 75%;
}
.sl-sb .col-xs-offset-8 {
  margin-left: 66.66666667%;
}
.sl-sb .col-xs-offset-7 {
  margin-left: 58.33333333%;
}
.sl-sb .col-xs-offset-6 {
  margin-left: 50%;
}
.sl-sb .col-xs-offset-5 {
  margin-left: 41.66666667%;
}
.sl-sb .col-xs-offset-4 {
  margin-left: 33.33333333%;
}
.sl-sb .col-xs-offset-3 {
  margin-left: 25%;
}
.sl-sb .col-xs-offset-2 {
  margin-left: 16.66666667%;
}
.sl-sb .col-xs-offset-1 {
  margin-left: 8.33333333%;
}
.sl-sb .col-xs-offset-0 {
  margin-left: 0;
}
@media (min-width: 768px) {
  .sl-sb .col-sm-1,
  .sl-sb .col-sm-2,
  .sl-sb .col-sm-3,
  .sl-sb .col-sm-4,
  .sl-sb .col-sm-5,
  .sl-sb .col-sm-6,
  .sl-sb .col-sm-7,
  .sl-sb .col-sm-8,
  .sl-sb .col-sm-9,
  .sl-sb .col-sm-10,
  .sl-sb .col-sm-11,
  .sl-sb .col-sm-12 {
    float: left;
  }
  .sl-sb .col-sm-12 {
    width: 100%;
  }
  .sl-sb .col-sm-11 {
    width: 91.66666667%;
  }
  .sl-sb .col-sm-10 {
    width: 83.33333333%;
  }
  .sl-sb .col-sm-9 {
    width: 75%;
  }
  .sl-sb .col-sm-8 {
    width: 66.66666667%;
  }
  .sl-sb .col-sm-7 {
    width: 58.33333333%;
  }
  .sl-sb .col-sm-6 {
    width: 50%;
  }
  .sl-sb .col-sm-5 {
    width: 41.66666667%;
  }
  .sl-sb .col-sm-4 {
    width: 33.33333333%;
  }
  .sl-sb .col-sm-3 {
    width: 25%;
  }
  .sl-sb .col-sm-2 {
    width: 16.66666667%;
  }
  .sl-sb .col-sm-1 {
    width: 8.33333333%;
  }
  .sl-sb .col-sm-pull-12 {
    right: 100%;
  }
  .sl-sb .col-sm-pull-11 {
    right: 91.66666667%;
  }
  .sl-sb .col-sm-pull-10 {
    right: 83.33333333%;
  }
  .sl-sb .col-sm-pull-9 {
    right: 75%;
  }
  .sl-sb .col-sm-pull-8 {
    right: 66.66666667%;
  }
  .sl-sb .col-sm-pull-7 {
    right: 58.33333333%;
  }
  .sl-sb .col-sm-pull-6 {
    right: 50%;
  }
  .sl-sb .col-sm-pull-5 {
    right: 41.66666667%;
  }
  .sl-sb .col-sm-pull-4 {
    right: 33.33333333%;
  }
  .sl-sb .col-sm-pull-3 {
    right: 25%;
  }
  .sl-sb .col-sm-pull-2 {
    right: 16.66666667%;
  }
  .sl-sb .col-sm-pull-1 {
    right: 8.33333333%;
  }
  .sl-sb .col-sm-pull-0 {
    right: auto;
  }
  .sl-sb .col-sm-push-12 {
    left: 100%;
  }
  .sl-sb .col-sm-push-11 {
    left: 91.66666667%;
  }
  .sl-sb .col-sm-push-10 {
    left: 83.33333333%;
  }
  .sl-sb .col-sm-push-9 {
    left: 75%;
  }
  .sl-sb .col-sm-push-8 {
    left: 66.66666667%;
  }
  .sl-sb .col-sm-push-7 {
    left: 58.33333333%;
  }
  .sl-sb .col-sm-push-6 {
    left: 50%;
  }
  .sl-sb .col-sm-push-5 {
    left: 41.66666667%;
  }
  .sl-sb .col-sm-push-4 {
    left: 33.33333333%;
  }
  .sl-sb .col-sm-push-3 {
    left: 25%;
  }
  .sl-sb .col-sm-push-2 {
    left: 16.66666667%;
  }
  .sl-sb .col-sm-push-1 {
    left: 8.33333333%;
  }
  .sl-sb .col-sm-push-0 {
    left: auto;
  }
  .sl-sb .col-sm-offset-12 {
    margin-left: 100%;
  }
  .sl-sb .col-sm-offset-11 {
    margin-left: 91.66666667%;
  }
  .sl-sb .col-sm-offset-10 {
    margin-left: 83.33333333%;
  }
  .sl-sb .col-sm-offset-9 {
    margin-left: 75%;
  }
  .sl-sb .col-sm-offset-8 {
    margin-left: 66.66666667%;
  }
  .sl-sb .col-sm-offset-7 {
    margin-left: 58.33333333%;
  }
  .sl-sb .col-sm-offset-6 {
    margin-left: 50%;
  }
  .sl-sb .col-sm-offset-5 {
    margin-left: 41.66666667%;
  }
  .sl-sb .col-sm-offset-4 {
    margin-left: 33.33333333%;
  }
  .sl-sb .col-sm-offset-3 {
    margin-left: 25%;
  }
  .sl-sb .col-sm-offset-2 {
    margin-left: 16.66666667%;
  }
  .sl-sb .col-sm-offset-1 {
    margin-left: 8.33333333%;
  }
  .sl-sb .col-sm-offset-0 {
    margin-left: 0;
  }
}
@media (min-width: 992px) {
  .sl-sb .col-md-1,
  .sl-sb .col-md-2,
  .sl-sb .col-md-3,
  .sl-sb .col-md-4,
  .sl-sb .col-md-5,
  .sl-sb .col-md-6,
  .sl-sb .col-md-7,
  .sl-sb .col-md-8,
  .sl-sb .col-md-9,
  .sl-sb .col-md-10,
  .sl-sb .col-md-11,
  .sl-sb .col-md-12 {
    float: left;
  }
  .sl-sb .col-md-12 {
    width: 100%;
  }
  .sl-sb .col-md-11 {
    width: 91.66666667%;
  }
  .sl-sb .col-md-10 {
    width: 83.33333333%;
  }
  .sl-sb .col-md-9 {
    width: 75%;
  }
  .sl-sb .col-md-8 {
    width: 66.66666667%;
  }
  .sl-sb .col-md-7 {
    width: 58.33333333%;
  }
  .sl-sb .col-md-6 {
    width: 50%;
  }
  .sl-sb .col-md-5 {
    width: 41.66666667%;
  }
  .sl-sb .col-md-4 {
    width: 33.33333333%;
  }
  .sl-sb .col-md-3 {
    width: 25%;
  }
  .sl-sb .col-md-2 {
    width: 16.66666667%;
  }
  .sl-sb .col-md-1 {
    width: 8.33333333%;
  }
  .sl-sb .col-md-pull-12 {
    right: 100%;
  }
  .sl-sb .col-md-pull-11 {
    right: 91.66666667%;
  }
  .sl-sb .col-md-pull-10 {
    right: 83.33333333%;
  }
  .sl-sb .col-md-pull-9 {
    right: 75%;
  }
  .sl-sb .col-md-pull-8 {
    right: 66.66666667%;
  }
  .sl-sb .col-md-pull-7 {
    right: 58.33333333%;
  }
  .sl-sb .col-md-pull-6 {
    right: 50%;
  }
  .sl-sb .col-md-pull-5 {
    right: 41.66666667%;
  }
  .sl-sb .col-md-pull-4 {
    right: 33.33333333%;
  }
  .sl-sb .col-md-pull-3 {
    right: 25%;
  }
  .sl-sb .col-md-pull-2 {
    right: 16.66666667%;
  }
  .sl-sb .col-md-pull-1 {
    right: 8.33333333%;
  }
  .sl-sb .col-md-pull-0 {
    right: auto;
  }
  .sl-sb .col-md-push-12 {
    left: 100%;
  }
  .sl-sb .col-md-push-11 {
    left: 91.66666667%;
  }
  .sl-sb .col-md-push-10 {
    left: 83.33333333%;
  }
  .sl-sb .col-md-push-9 {
    left: 75%;
  }
  .sl-sb .col-md-push-8 {
    left: 66.66666667%;
  }
  .sl-sb .col-md-push-7 {
    left: 58.33333333%;
  }
  .sl-sb .col-md-push-6 {
    left: 50%;
  }
  .sl-sb .col-md-push-5 {
    left: 41.66666667%;
  }
  .sl-sb .col-md-push-4 {
    left: 33.33333333%;
  }
  .sl-sb .col-md-push-3 {
    left: 25%;
  }
  .sl-sb .col-md-push-2 {
    left: 16.66666667%;
  }
  .sl-sb .col-md-push-1 {
    left: 8.33333333%;
  }
  .sl-sb .col-md-push-0 {
    left: auto;
  }
  .sl-sb .col-md-offset-12 {
    margin-left: 100%;
  }
  .sl-sb .col-md-offset-11 {
    margin-left: 91.66666667%;
  }
  .sl-sb .col-md-offset-10 {
    margin-left: 83.33333333%;
  }
  .sl-sb .col-md-offset-9 {
    margin-left: 75%;
  }
  .sl-sb .col-md-offset-8 {
    margin-left: 66.66666667%;
  }
  .sl-sb .col-md-offset-7 {
    margin-left: 58.33333333%;
  }
  .sl-sb .col-md-offset-6 {
    margin-left: 50%;
  }
  .sl-sb .col-md-offset-5 {
    margin-left: 41.66666667%;
  }
  .sl-sb .col-md-offset-4 {
    margin-left: 33.33333333%;
  }
  .sl-sb .col-md-offset-3 {
    margin-left: 25%;
  }
  .sl-sb .col-md-offset-2 {
    margin-left: 16.66666667%;
  }
  .sl-sb .col-md-offset-1 {
    margin-left: 8.33333333%;
  }
  .sl-sb .col-md-offset-0 {
    margin-left: 0;
  }
}
@media (min-width: 1200px) {
  .sl-sb .col-lg-1,
  .sl-sb .col-lg-2,
  .sl-sb .col-lg-3,
  .sl-sb .col-lg-4,
  .sl-sb .col-lg-5,
  .sl-sb .col-lg-6,
  .sl-sb .col-lg-7,
  .sl-sb .col-lg-8,
  .sl-sb .col-lg-9,
  .sl-sb .col-lg-10,
  .sl-sb .col-lg-11,
  .sl-sb .col-lg-12 {
    float: left;
  }
  .sl-sb .col-lg-12 {
    width: 100%;
  }
  .sl-sb .col-lg-11 {
    width: 91.66666667%;
  }
  .sl-sb .col-lg-10 {
    width: 83.33333333%;
  }
  .sl-sb .col-lg-9 {
    width: 75%;
  }
  .sl-sb .col-lg-8 {
    width: 66.66666667%;
  }
  .sl-sb .col-lg-7 {
    width: 58.33333333%;
  }
  .sl-sb .col-lg-6 {
    width: 50%;
  }
  .sl-sb .col-lg-5 {
    width: 41.66666667%;
  }
  .sl-sb .col-lg-4 {
    width: 33.33333333%;
  }
  .sl-sb .col-lg-3 {
    width: 25%;
  }
  .sl-sb .col-lg-2 {
    width: 16.66666667%;
  }
  .sl-sb .col-lg-1 {
    width: 8.33333333%;
  }
  .sl-sb .col-lg-pull-12 {
    right: 100%;
  }
  .sl-sb .col-lg-pull-11 {
    right: 91.66666667%;
  }
  .sl-sb .col-lg-pull-10 {
    right: 83.33333333%;
  }
  .sl-sb .col-lg-pull-9 {
    right: 75%;
  }
  .sl-sb .col-lg-pull-8 {
    right: 66.66666667%;
  }
  .sl-sb .col-lg-pull-7 {
    right: 58.33333333%;
  }
  .sl-sb .col-lg-pull-6 {
    right: 50%;
  }
  .sl-sb .col-lg-pull-5 {
    right: 41.66666667%;
  }
  .sl-sb .col-lg-pull-4 {
    right: 33.33333333%;
  }
  .sl-sb .col-lg-pull-3 {
    right: 25%;
  }
  .sl-sb .col-lg-pull-2 {
    right: 16.66666667%;
  }
  .sl-sb .col-lg-pull-1 {
    right: 8.33333333%;
  }
  .sl-sb .col-lg-pull-0 {
    right: auto;
  }
  .sl-sb .col-lg-push-12 {
    left: 100%;
  }
  .sl-sb .col-lg-push-11 {
    left: 91.66666667%;
  }
  .sl-sb .col-lg-push-10 {
    left: 83.33333333%;
  }
  .sl-sb .col-lg-push-9 {
    left: 75%;
  }
  .sl-sb .col-lg-push-8 {
    left: 66.66666667%;
  }
  .sl-sb .col-lg-push-7 {
    left: 58.33333333%;
  }
  .sl-sb .col-lg-push-6 {
    left: 50%;
  }
  .sl-sb .col-lg-push-5 {
    left: 41.66666667%;
  }
  .sl-sb .col-lg-push-4 {
    left: 33.33333333%;
  }
  .sl-sb .col-lg-push-3 {
    left: 25%;
  }
  .sl-sb .col-lg-push-2 {
    left: 16.66666667%;
  }
  .sl-sb .col-lg-push-1 {
    left: 8.33333333%;
  }
  .sl-sb .col-lg-push-0 {
    left: auto;
  }
  .sl-sb .col-lg-offset-12 {
    margin-left: 100%;
  }
  .sl-sb .col-lg-offset-11 {
    margin-left: 91.66666667%;
  }
  .sl-sb .col-lg-offset-10 {
    margin-left: 83.33333333%;
  }
  .sl-sb .col-lg-offset-9 {
    margin-left: 75%;
  }
  .sl-sb .col-lg-offset-8 {
    margin-left: 66.66666667%;
  }
  .sl-sb .col-lg-offset-7 {
    margin-left: 58.33333333%;
  }
  .sl-sb .col-lg-offset-6 {
    margin-left: 50%;
  }
  .sl-sb .col-lg-offset-5 {
    margin-left: 41.66666667%;
  }
  .sl-sb .col-lg-offset-4 {
    margin-left: 33.33333333%;
  }
  .sl-sb .col-lg-offset-3 {
    margin-left: 25%;
  }
  .sl-sb .col-lg-offset-2 {
    margin-left: 16.66666667%;
  }
  .sl-sb .col-lg-offset-1 {
    margin-left: 8.33333333%;
  }
  .sl-sb .col-lg-offset-0 {
    margin-left: 0;
  }
}
.sl-sb table {
  max-width: 100%;
  background-color: transparent;
}
.sl-sb th {
  text-align: left;
}
.sl-sb .table {
  width: 100%;
  margin-bottom: 20px;
}
.sl-sb .table > thead > tr > th,
.sl-sb .table > tbody > tr > th,
.sl-sb .table > tfoot > tr > th,
.sl-sb .table > thead > tr > td,
.sl-sb .table > tbody > tr > td,
.sl-sb .table > tfoot > tr > td {
  padding: 8px;
  line-height: 1.42857143;
  vertical-align: top;
  border-top: 1px solid #ddd;
}
.sl-sb .table > thead > tr > th {
  vertical-align: bottom;
  border-bottom: 2px solid #ddd;
}
.sl-sb .table > caption + thead > tr:first-child > th,
.sl-sb .table > colgroup + thead > tr:first-child > th,
.sl-sb .table > thead:first-child > tr:first-child > th,
.sl-sb .table > caption + thead > tr:first-child > td,
.sl-sb .table > colgroup + thead > tr:first-child > td,
.sl-sb .table > thead:first-child > tr:first-child > td {
  border-top: 0;
}
.sl-sb .table > tbody + tbody {
  border-top: 2px solid #ddd;
}
.sl-sb .table .table {
  background-color: #fff;
}
.sl-sb .table-condensed > thead > tr > th,
.sl-sb .table-condensed > tbody > tr > th,
.sl-sb .table-condensed > tfoot > tr > th,
.sl-sb .table-condensed > thead > tr > td,
.sl-sb .table-condensed > tbody > tr > td,
.sl-sb .table-condensed > tfoot > tr > td {
  padding: 5px;
}
.sl-sb .table-bordered {
  border: 1px solid #ddd;
}
.sl-sb .table-bordered > thead > tr > th,
.sl-sb .table-bordered > tbody > tr > th,
.sl-sb .table-bordered > tfoot > tr > th,
.sl-sb .table-bordered > thead > tr > td,
.sl-sb .table-bordered > tbody > tr > td,
.sl-sb .table-bordered > tfoot > tr > td {
  border: 1px solid #ddd;
}
.sl-sb .table-bordered > thead > tr > th,
.sl-sb .table-bordered > thead > tr > td {
  border-bottom-width: 2px;
}
.sl-sb .table-striped > tbody > tr:nth-child(odd) > td,
.sl-sb .table-striped > tbody > tr:nth-child(odd) > th {
  background-color: #f9f9f9;
}
.sl-sb .table-hover > tbody > tr:hover > td,
.sl-sb .table-hover > tbody > tr:hover > th {
  background-color: #f5f5f5;
}
.sl-sb table col[class*="col-"] {
  position: static;
  display: table-column;
  float: none;
}
.sl-sb table td[class*="col-"],
.sl-sb table th[class*="col-"] {
  position: static;
  display: table-cell;
  float: none;
}
.sl-sb .table > thead > tr > td.active,
.sl-sb .table > tbody > tr > td.active,
.sl-sb .table > tfoot > tr > td.active,
.sl-sb .table > thead > tr > th.active,
.sl-sb .table > tbody > tr > th.active,
.sl-sb .table > tfoot > tr > th.active,
.sl-sb .table > thead > tr.active > td,
.sl-sb .table > tbody > tr.active > td,
.sl-sb .table > tfoot > tr.active > td,
.sl-sb .table > thead > tr.active > th,
.sl-sb .table > tbody > tr.active > th,
.sl-sb .table > tfoot > tr.active > th {
  background-color: #f5f5f5;
}
.sl-sb .table-hover > tbody > tr > td.active:hover,
.sl-sb .table-hover > tbody > tr > th.active:hover,
.sl-sb .table-hover > tbody > tr.active:hover > td,
.sl-sb .table-hover > tbody > tr:hover > .active,
.sl-sb .table-hover > tbody > tr.active:hover > th {
  background-color: #e8e8e8;
}
.sl-sb .table > thead > tr > td.success,
.sl-sb .table > tbody > tr > td.success,
.sl-sb .table > tfoot > tr > td.success,
.sl-sb .table > thead > tr > th.success,
.sl-sb .table > tbody > tr > th.success,
.sl-sb .table > tfoot > tr > th.success,
.sl-sb .table > thead > tr.success > td,
.sl-sb .table > tbody > tr.success > td,
.sl-sb .table > tfoot > tr.success > td,
.sl-sb .table > thead > tr.success > th,
.sl-sb .table > tbody > tr.success > th,
.sl-sb .table > tfoot > tr.success > th {
  background-color: #dff0d8;
}
.sl-sb .table-hover > tbody > tr > td.success:hover,
.sl-sb .table-hover > tbody > tr > th.success:hover,
.sl-sb .table-hover > tbody > tr.success:hover > td,
.sl-sb .table-hover > tbody > tr:hover > .success,
.sl-sb .table-hover > tbody > tr.success:hover > th {
  background-color: #d0e9c6;
}
.sl-sb .table > thead > tr > td.info,
.sl-sb .table > tbody > tr > td.info,
.sl-sb .table > tfoot > tr > td.info,
.sl-sb .table > thead > tr > th.info,
.sl-sb .table > tbody > tr > th.info,
.sl-sb .table > tfoot > tr > th.info,
.sl-sb .table > thead > tr.info > td,
.sl-sb .table > tbody > tr.info > td,
.sl-sb .table > tfoot > tr.info > td,
.sl-sb .table > thead > tr.info > th,
.sl-sb .table > tbody > tr.info > th,
.sl-sb .table > tfoot > tr.info > th {
  background-color: #d9edf7;
}
.sl-sb .table-hover > tbody > tr > td.info:hover,
.sl-sb .table-hover > tbody > tr > th.info:hover,
.sl-sb .table-hover > tbody > tr.info:hover > td,
.sl-sb .table-hover > tbody > tr:hover > .info,
.sl-sb .table-hover > tbody > tr.info:hover > th {
  background-color: #c4e3f3;
}
.sl-sb .table > thead > tr > td.warning,
.sl-sb .table > tbody > tr > td.warning,
.sl-sb .table > tfoot > tr > td.warning,
.sl-sb .table > thead > tr > th.warning,
.sl-sb .table > tbody > tr > th.warning,
.sl-sb .table > tfoot > tr > th.warning,
.sl-sb .table > thead > tr.warning > td,
.sl-sb .table > tbody > tr.warning > td,
.sl-sb .table > tfoot > tr.warning > td,
.sl-sb .table > thead > tr.warning > th,
.sl-sb .table > tbody > tr.warning > th,
.sl-sb .table > tfoot > tr.warning > th {
  background-color: #fcf8e3;
}
.sl-sb .table-hover > tbody > tr > td.warning:hover,
.sl-sb .table-hover > tbody > tr > th.warning:hover,
.sl-sb .table-hover > tbody > tr.warning:hover > td,
.sl-sb .table-hover > tbody > tr:hover > .warning,
.sl-sb .table-hover > tbody > tr.warning:hover > th {
  background-color: #faf2cc;
}
.sl-sb .table > thead > tr > td.danger,
.sl-sb .table > tbody > tr > td.danger,
.sl-sb .table > tfoot > tr > td.danger,
.sl-sb .table > thead > tr > th.danger,
.sl-sb .table > tbody > tr > th.danger,
.sl-sb .table > tfoot > tr > th.danger,
.sl-sb .table > thead > tr.danger > td,
.sl-sb .table > tbody > tr.danger > td,
.sl-sb .table > tfoot > tr.danger > td,
.sl-sb .table > thead > tr.danger > th,
.sl-sb .table > tbody > tr.danger > th,
.sl-sb .table > tfoot > tr.danger > th {
  background-color: #f2dede;
}
.sl-sb .table-hover > tbody > tr > td.danger:hover,
.sl-sb .table-hover > tbody > tr > th.danger:hover,
.sl-sb .table-hover > tbody > tr.danger:hover > td,
.sl-sb .table-hover > tbody > tr:hover > .danger,
.sl-sb .table-hover > tbody > tr.danger:hover > th {
  background-color: #ebcccc;
}
@media screen and (max-width: 767px) {
  .sl-sb .table-responsive {
    width: 100%;
    margin-bottom: 15px;
    overflow-x: scroll;
    overflow-y: hidden;
    -webkit-overflow-scrolling: touch;
    -ms-overflow-style: -ms-autohiding-scrollbar;
    border: 1px solid #ddd;
  }
  .sl-sb .table-responsive > .table {
    margin-bottom: 0;
  }
  .sl-sb .table-responsive > .table > thead > tr > th,
  .sl-sb .table-responsive > .table > tbody > tr > th,
  .sl-sb .table-responsive > .table > tfoot > tr > th,
  .sl-sb .table-responsive > .table > thead > tr > td,
  .sl-sb .table-responsive > .table > tbody > tr > td,
  .sl-sb .table-responsive > .table > tfoot > tr > td {
    white-space: nowrap;
  }
  .sl-sb .table-responsive > .table-bordered {
    border: 0;
  }
  .sl-sb .table-responsive > .table-bordered > thead > tr > th:first-child,
  .sl-sb .table-responsive > .table-bordered > tbody > tr > th:first-child,
  .sl-sb .table-responsive > .table-bordered > tfoot > tr > th:first-child,
  .sl-sb .table-responsive > .table-bordered > thead > tr > td:first-child,
  .sl-sb .table-responsive > .table-bordered > tbody > tr > td:first-child,
  .sl-sb .table-responsive > .table-bordered > tfoot > tr > td:first-child {
    border-left: 0;
  }
  .sl-sb .table-responsive > .table-bordered > thead > tr > th:last-child,
  .sl-sb .table-responsive > .table-bordered > tbody > tr > th:last-child,
  .sl-sb .table-responsive > .table-bordered > tfoot > tr > th:last-child,
  .sl-sb .table-responsive > .table-bordered > thead > tr > td:last-child,
  .sl-sb .table-responsive > .table-bordered > tbody > tr > td:last-child,
  .sl-sb .table-responsive > .table-bordered > tfoot > tr > td:last-child {
    border-right: 0;
  }
  .sl-sb .table-responsive > .table-bordered > tbody > tr:last-child > th,
  .sl-sb .table-responsive > .table-bordered > tfoot > tr:last-child > th,
  .sl-sb .table-responsive > .table-bordered > tbody > tr:last-child > td,
  .sl-sb .table-responsive > .table-bordered > tfoot > tr:last-child > td {
    border-bottom: 0;
  }
}
.sl-sb fieldset {
  min-width: 0;
  padding: 0;
  margin: 0;
  border: 0;
}
.sl-sb legend {
  display: block;
  width: 100%;
  padding: 0;
  margin-bottom: 20px;
  font-size: 21px;
  line-height: inherit;
  color: #333;
  border: 0;
  border-bottom: 1px solid #e5e5e5;
}
.sl-sb label {
  display: inline-block;
  max-width: 100%;
  margin-bottom: 5px;
  font-weight: bold;
}
.sl-sb input[type="search"] {
  -webkit-box-sizing: border-box;
     -moz-box-sizing: border-box;
          box-sizing: border-box;
}
.sl-sb input[type="radio"],
.sl-sb input[type="checkbox"] {
  margin: 4px 0 0;
  margin-top: 1px \9;
  line-height: normal;
}
.sl-sb input[type="file"] {
  display: block;
}
.sl-sb input[type="range"] {
  display: block;
  width: 100%;
}
.sl-sb select[multiple],
.sl-sb select[size] {
  height: auto;
}
.sl-sb input[type="file"]:focus,
.sl-sb input[type="radio"]:focus,
.sl-sb input[type="checkbox"]:focus {
  outline: thin dotted;
  outline: 5px auto -webkit-focus-ring-color;
  outline-offset: -2px;
}
.sl-sb output {
  display: block;
  padding-top: 7px;
  font-size: 14px;
  line-height: 1.42857143;
  color: #555;
}
.sl-sb .form-control {
  display: block;
  width: 100%;
  height: 34px;
  padding: 6px 12px;
  font-size: 14px;
  line-height: 1.42857143;
  color: #555;
  background-color: #fff;
  background-image: none;
  border: 1px solid #ccc;
  border-radius: 4px;
  -webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
          box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
  -webkit-transition: border-color ease-in-out .15s, -webkit-box-shadow ease-in-out .15s;
       -o-transition: border-color ease-in-out .15s, box-shadow ease-in-out .15s;
          transition: border-color ease-in-out .15s, box-shadow ease-in-out .15s;
}
.sl-sb .form-control:focus {
  border-color: #66afe9;
  outline: 0;
  -webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075), 0 0 8px rgba(102, 175, 233, .6);
          box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075), 0 0 8px rgba(102, 175, 233, .6);
}
.sl-sb .form-control::-moz-placeholder {
  color: #999;
  opacity: 1;
}
.sl-sb .form-control:-ms-input-placeholder {
  color: #999;
}
.sl-sb .form-control::-webkit-input-placeholder {
  color: #999;
}
.sl-sb .form-control[disabled],
.sl-sb .form-control[readonly],
.sl-sb fieldset[disabled] .form-control {
  cursor: not-allowed;
  background-color: #eee;
  opacity: 1;
}
.sl-sb textarea.form-control {
  height: auto;
}
.sl-sb input[type="search"] {
  -webkit-appearance: none;
}
.sl-sb input[type="date"],
.sl-sb input[type="time"],
.sl-sb input[type="datetime-local"],
.sl-sb input[type="month"] {
  line-height: 34px;
  line-height: 1.42857143 \0;
}
.sl-sb input[type="date"].input-sm,
.sl-sb input[type="time"].input-sm,
.sl-sb input[type="datetime-local"].input-sm,
.sl-sb input[type="month"].input-sm {
  line-height: 30px;
}
.sl-sb input[type="date"].input-lg,
.sl-sb input[type="time"].input-lg,
.sl-sb input[type="datetime-local"].input-lg,
.sl-sb input[type="month"].input-lg {
  line-height: 46px;
}
.sl-sb .form-group {
  margin-bottom: 15px;
}
.sl-sb .radio,
.sl-sb .checkbox {
  display: block;
  min-height: 20px;
  margin-top: 10px;
  margin-bottom: 10px;
}
.sl-sb .radio label,
.sl-sb .checkbox label {
  padding-left: 20px;
  margin-bottom: 0;
  font-weight: normal;
  cursor: pointer;
}
.sl-sb .radio input[type="radio"],
.sl-sb .radio-inline input[type="radio"],
.sl-sb .checkbox input[type="checkbox"],
.sl-sb .checkbox-inline input[type="checkbox"] {
  float: left;
  margin-left: -20px;
}
.sl-sb .radio + .radio,
.sl-sb .checkbox + .checkbox {
  margin-top: -5px;
}
.sl-sb .radio-inline,
.sl-sb .checkbox-inline {
  display: inline-block;
  padding-left: 20px;
  margin-bottom: 0;
  font-weight: normal;
  vertical-align: middle;
  cursor: pointer;
}
.sl-sb .radio-inline + .radio-inline,
.sl-sb .checkbox-inline + .checkbox-inline {
  margin-top: 0;
  margin-left: 10px;
}
.sl-sb input[type="radio"][disabled],
.sl-sb input[type="checkbox"][disabled],
.sl-sb .radio[disabled],
.sl-sb .radio-inline[disabled],
.sl-sb .checkbox[disabled],
.sl-sb .checkbox-inline[disabled],
.sl-sb fieldset[disabled] input[type="radio"],
.sl-sb fieldset[disabled] input[type="checkbox"],
.sl-sb fieldset[disabled] .radio,
.sl-sb fieldset[disabled] .radio-inline,
.sl-sb fieldset[disabled] .checkbox,
.sl-sb fieldset[disabled] .checkbox-inline {
  cursor: not-allowed;
}
.sl-sb .input-sm {
  height: 30px;
  padding: 5px 10px;
  font-size: 12px;
  line-height: 1.5;
  border-radius: 3px;
}
.sl-sb select.input-sm {
  height: 30px;
  line-height: 30px;
}
.sl-sb textarea.input-sm,
.sl-sb select[multiple].input-sm {
  height: auto;
}
.sl-sb .input-lg {
  height: 46px;
  padding: 10px 16px;
  font-size: 18px;
  line-height: 1.33;
  border-radius: 6px;
}
.sl-sb select.input-lg {
  height: 46px;
  line-height: 46px;
}
.sl-sb textarea.input-lg,
.sl-sb select[multiple].input-lg {
  height: auto;
}
.sl-sb .has-feedback {
  position: relative;
}
.sl-sb .has-feedback .form-control {
  padding-right: 42.5px;
}
.sl-sb .form-control-feedback {
  position: absolute;
  top: 25px;
  right: 0;
  z-index: 2;
  display: block;
  width: 34px;
  height: 34px;
  line-height: 34px;
  text-align: center;
}
.sl-sb .input-lg + .form-control-feedback {
  width: 46px;
  height: 46px;
  line-height: 46px;
}
.sl-sb .input-sm + .form-control-feedback {
  width: 30px;
  height: 30px;
  line-height: 30px;
}
.sl-sb .has-success .help-block,
.sl-sb .has-success .control-label,
.sl-sb .has-success .radio,
.sl-sb .has-success .checkbox,
.sl-sb .has-success .radio-inline,
.sl-sb .has-success .checkbox-inline {
  color: #3c763d;
}
.sl-sb .has-success .form-control {
  border-color: #3c763d;
  -webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
          box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
}
.sl-sb .has-success .form-control:focus {
  border-color: #2b542c;
  -webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075), 0 0 6px #67b168;
          box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075), 0 0 6px #67b168;
}
.sl-sb .has-success .input-group-addon {
  color: #3c763d;
  background-color: #dff0d8;
  border-color: #3c763d;
}
.sl-sb .has-success .form-control-feedback {
  color: #3c763d;
}
.sl-sb .has-warning .help-block,
.sl-sb .has-warning .control-label,
.sl-sb .has-warning .radio,
.sl-sb .has-warning .checkbox,
.sl-sb .has-warning .radio-inline,
.sl-sb .has-warning .checkbox-inline {
  color: #8a6d3b;
}
.sl-sb .has-warning .form-control {
  border-color: #8a6d3b;
  -webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
          box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
}
.sl-sb .has-warning .form-control:focus {
  border-color: #66512c;
  -webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075), 0 0 6px #c0a16b;
          box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075), 0 0 6px #c0a16b;
}
.sl-sb .has-warning .input-group-addon {
  color: #8a6d3b;
  background-color: #fcf8e3;
  border-color: #8a6d3b;
}
.sl-sb .has-warning .form-control-feedback {
  color: #8a6d3b;
}
.sl-sb .has-error .help-block,
.sl-sb .has-error .control-label,
.sl-sb .has-error .radio,
.sl-sb .has-error .checkbox,
.sl-sb .has-error .radio-inline,
.sl-sb .has-error .checkbox-inline {
  color: #a94442;
}
.sl-sb .has-error .form-control {
  border-color: #a94442;
  -webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
          box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075);
}
.sl-sb .has-error .form-control:focus {
  border-color: #843534;
  -webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075), 0 0 6px #ce8483;
          box-shadow: inset 0 1px 1px rgba(0, 0, 0, .075), 0 0 6px #ce8483;
}
.sl-sb .has-error .input-group-addon {
  color: #a94442;
  background-color: #f2dede;
  border-color: #a94442;
}
.sl-sb .has-error .form-control-feedback {
  color: #a94442;
}
.sl-sb .form-control-static {
  margin-bottom: 0;
}
.sl-sb .help-block {
  display: block;
  margin-top: 5px;
  margin-bottom: 10px;
  color: #737373;
}
@media (min-width: 768px) {
  .sl-sb .form-inline .form-group {
    display: inline-block;
    margin-bottom: 0;
    vertical-align: middle;
  }
  .sl-sb .form-inline .form-control {
    display: inline-block;
    width: auto;
    vertical-align: middle;
  }
  .sl-sb .form-inline .input-group {
    display: inline-table;
    vertical-align: middle;
  }
  .sl-sb .form-inline .input-group .input-group-addon,
  .sl-sb .form-inline .input-group .input-group-btn,
  .sl-sb .form-inline .input-group .form-control {
    width: auto;
  }
  .sl-sb .form-inline .input-group > .form-control {
    width: 100%;
  }
  .sl-sb .form-inline .control-label {
    margin-bottom: 0;
    vertical-align: middle;
  }
  .sl-sb .form-inline .radio,
  .sl-sb .form-inline .checkbox {
    display: inline-block;
    padding-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    vertical-align: middle;
  }
  .sl-sb .form-inline .radio input[type="radio"],
  .sl-sb .form-inline .checkbox input[type="checkbox"] {
    float: none;
    margin-left: 0;
  }
  .sl-sb .form-inline .has-feedback .form-control-feedback {
    top: 0;
  }
}
.sl-sb .form-horizontal .radio,
.sl-sb .form-horizontal .checkbox,
.sl-sb .form-horizontal .radio-inline,
.sl-sb .form-horizontal .checkbox-inline {
  padding-top: 7px;
  margin-top: 0;
  margin-bottom: 0;
}
.sl-sb .form-horizontal .radio,
.sl-sb .form-horizontal .checkbox {
  min-height: 27px;
}
.sl-sb .form-horizontal .form-group {
  margin-right: -15px;
  margin-left: -15px;
}
.sl-sb .form-horizontal .form-control-static {
  padding-top: 7px;
  padding-bottom: 7px;
}
@media (min-width: 768px) {
  .sl-sb .form-horizontal .control-label {
    padding-top: 7px;
    margin-bottom: 0;
    text-align: right;
  }
}
.sl-sb .form-horizontal .has-feedback .form-control-feedback {
  top: 0;
  right: 15px;
}
.sl-sb .btn {
  display: inline-block;
  padding: 6px 12px;
  margin-bottom: 0;
  font-size: 14px;
  font-weight: normal;
  line-height: 1.42857143;
  text-align: center;
  white-space: nowrap;
  vertical-align: middle;
  cursor: pointer;
  -webkit-user-select: none;
     -moz-user-select: none;
      -ms-user-select: none;
          user-select: none;
  background-image: none;
  border: 1px solid transparent;
  border-radius: 4px;
}
.sl-sb .btn:focus,
.sl-sb .btn:active:focus,
.sl-sb .btn.active:focus {
  outline: thin dotted;
  outline: 5px auto -webkit-focus-ring-color;
  outline-offset: -2px;
}
.sl-sb .btn:hover,
.sl-sb .btn:focus {
  color: #333;
  text-decoration: none;
}
.sl-sb .btn:active,
.sl-sb .btn.active {
  background-image: none;
  outline: 0;
  -webkit-box-shadow: inset 0 3px 5px rgba(0, 0, 0, .125);
          box-shadow: inset 0 3px 5px rgba(0, 0, 0, .125);
}
.sl-sb .btn.disabled,
.sl-sb .btn[disabled],
.sl-sb fieldset[disabled] .btn {
  pointer-events: none;
  cursor: not-allowed;
  filter: alpha(opacity=65);
  -webkit-box-shadow: none;
          box-shadow: none;
  opacity: .65;
}
.sl-sb .btn-default {
  color: #333;
  background-color: #fff;
  border-color: #ccc;
}
.sl-sb .btn-default:hover,
.sl-sb .btn-default:focus,
.sl-sb .btn-default:active,
.sl-sb .btn-default.active,
.sl-sb .open > .dropdown-toggle.btn-default {
  color: #333;
  background-color: #e6e6e6;
  border-color: #adadad;
}
.sl-sb .btn-default:active,
.sl-sb .btn-default.active,
.sl-sb .open > .dropdown-toggle.btn-default {
  background-image: none;
}
.sl-sb .btn-default.disabled,
.sl-sb .btn-default[disabled],
.sl-sb fieldset[disabled] .btn-default,
.sl-sb .btn-default.disabled:hover,
.sl-sb .btn-default[disabled]:hover,
.sl-sb fieldset[disabled] .btn-default:hover,
.sl-sb .btn-default.disabled:focus,
.sl-sb .btn-default[disabled]:focus,
.sl-sb fieldset[disabled] .btn-default:focus,
.sl-sb .btn-default.disabled:active,
.sl-sb .btn-default[disabled]:active,
.sl-sb fieldset[disabled] .btn-default:active,
.sl-sb .btn-default.disabled.active,
.sl-sb .btn-default[disabled].active,
.sl-sb fieldset[disabled] .btn-default.active {
  background-color: #fff;
  border-color: #ccc;
}
.sl-sb .btn-default .badge {
  color: #fff;
  background-color: #333;
}
.sl-sb .btn-primary {
  color: #fff;
  background-color: #428bca;
  border-color: #357ebd;
}
.sl-sb .btn-primary:hover,
.sl-sb .btn-primary:focus,
.sl-sb .btn-primary:active,
.sl-sb .btn-primary.active,
.sl-sb .open > .dropdown-toggle.btn-primary {
  color: #fff;
  background-color: #3071a9;
  border-color: #285e8e;
}
.sl-sb .btn-primary:active,
.sl-sb .btn-primary.active,
.sl-sb .open > .dropdown-toggle.btn-primary {
  background-image: none;
}
.sl-sb .btn-primary.disabled,
.sl-sb .btn-primary[disabled],
.sl-sb fieldset[disabled] .btn-primary,
.sl-sb .btn-primary.disabled:hover,
.sl-sb .btn-primary[disabled]:hover,
.sl-sb fieldset[disabled] .btn-primary:hover,
.sl-sb .btn-primary.disabled:focus,
.sl-sb .btn-primary[disabled]:focus,
.sl-sb fieldset[disabled] .btn-primary:focus,
.sl-sb .btn-primary.disabled:active,
.sl-sb .btn-primary[disabled]:active,
.sl-sb fieldset[disabled] .btn-primary:active,
.sl-sb .btn-primary.disabled.active,
.sl-sb .btn-primary[disabled].active,
.sl-sb fieldset[disabled] .btn-primary.active {
  background-color: #428bca;
  border-color: #357ebd;
}
.sl-sb .btn-primary .badge {
  color: #428bca;
  background-color: #fff;
}
.sl-sb .btn-success {
  color: #fff;
  background-color: #5cb85c;
  border-color: #4cae4c;
}
.sl-sb .btn-success:hover,
.sl-sb .btn-success:focus,
.sl-sb .btn-success:active,
.sl-sb .btn-success.active,
.sl-sb .open > .dropdown-toggle.btn-success {
  color: #fff;
  background-color: #449d44;
  border-color: #398439;
}
.sl-sb .btn-success:active,
.sl-sb .btn-success.active,
.sl-sb .open > .dropdown-toggle.btn-success {
  background-image: none;
}
.sl-sb .btn-success.disabled,
.sl-sb .btn-success[disabled],
.sl-sb fieldset[disabled] .btn-success,
.sl-sb .btn-success.disabled:hover,
.sl-sb .btn-success[disabled]:hover,
.sl-sb fieldset[disabled] .btn-success:hover,
.sl-sb .btn-success.disabled:focus,
.sl-sb .btn-success[disabled]:focus,
.sl-sb fieldset[disabled] .btn-success:focus,
.sl-sb .btn-success.disabled:active,
.sl-sb .btn-success[disabled]:active,
.sl-sb fieldset[disabled] .btn-success:active,
.sl-sb .btn-success.disabled.active,
.sl-sb .btn-success[disabled].active,
.sl-sb fieldset[disabled] .btn-success.active {
  background-color: #5cb85c;
  border-color: #4cae4c;
}
.sl-sb .btn-success .badge {
  color: #5cb85c;
  background-color: #fff;
}
.sl-sb .btn-info {
  color: #fff;
  background-color: #5bc0de;
  border-color: #46b8da;
}
.sl-sb .btn-info:hover,
.sl-sb .btn-info:focus,
.sl-sb .btn-info:active,
.sl-sb .btn-info.active,
.sl-sb .open > .dropdown-toggle.btn-info {
  color: #fff;
  background-color: #31b0d5;
  border-color: #269abc;
}
.sl-sb .btn-info:active,
.sl-sb .btn-info.active,
.sl-sb .open > .dropdown-toggle.btn-info {
  background-image: none;
}
.sl-sb .btn-info.disabled,
.sl-sb .btn-info[disabled],
.sl-sb fieldset[disabled] .btn-info,
.sl-sb .btn-info.disabled:hover,
.sl-sb .btn-info[disabled]:hover,
.sl-sb fieldset[disabled] .btn-info:hover,
.sl-sb .btn-info.disabled:focus,
.sl-sb .btn-info[disabled]:focus,
.sl-sb fieldset[disabled] .btn-info:focus,
.sl-sb .btn-info.disabled:active,
.sl-sb .btn-info[disabled]:active,
.sl-sb fieldset[disabled] .btn-info:active,
.sl-sb .btn-info.disabled.active,
.sl-sb .btn-info[disabled].active,
.sl-sb fieldset[disabled] .btn-info.active {
  background-color: #5bc0de;
  border-color: #46b8da;
}
.sl-sb .btn-info .badge {
  color: #5bc0de;
  background-color: #fff;
}
.sl-sb .btn-warning {
  color: #fff;
  background-color: #f0ad4e;
  border-color: #eea236;
}
.sl-sb .btn-warning:hover,
.sl-sb .btn-warning:focus,
.sl-sb .btn-warning:active,
.sl-sb .btn-warning.active,
.sl-sb .open > .dropdown-toggle.btn-warning {
  color: #fff;
  background-color: #ec971f;
  border-color: #d58512;
}
.sl-sb .btn-warning:active,
.sl-sb .btn-warning.active,
.sl-sb .open > .dropdown-toggle.btn-warning {
  background-image: none;
}
.sl-sb .btn-warning.disabled,
.sl-sb .btn-warning[disabled],
.sl-sb fieldset[disabled] .btn-warning,
.sl-sb .btn-warning.disabled:hover,
.sl-sb .btn-warning[disabled]:hover,
.sl-sb fieldset[disabled] .btn-warning:hover,
.sl-sb .btn-warning.disabled:focus,
.sl-sb .btn-warning[disabled]:focus,
.sl-sb fieldset[disabled] .btn-warning:focus,
.sl-sb .btn-warning.disabled:active,
.sl-sb .btn-warning[disabled]:active,
.sl-sb fieldset[disabled] .btn-warning:active,
.sl-sb .btn-warning.disabled.active,
.sl-sb .btn-warning[disabled].active,
.sl-sb fieldset[disabled] .btn-warning.active {
  background-color: #f0ad4e;
  border-color: #eea236;
}
.sl-sb .btn-warning .badge {
  color: #f0ad4e;
  background-color: #fff;
}
.sl-sb .btn-danger {
  color: #fff;
  background-color: #d9534f;
  border-color: #d43f3a;
}
.sl-sb .btn-danger:hover,
.sl-sb .btn-danger:focus,
.sl-sb .btn-danger:active,
.sl-sb .btn-danger.active,
.sl-sb .open > .dropdown-toggle.btn-danger {
  color: #fff;
  background-color: #c9302c;
  border-color: #ac2925;
}
.sl-sb .btn-danger:active,
.sl-sb .btn-danger.active,
.sl-sb .open > .dropdown-toggle.btn-danger {
  background-image: none;
}
.sl-sb .btn-danger.disabled,
.sl-sb .btn-danger[disabled],
.sl-sb fieldset[disabled] .btn-danger,
.sl-sb .btn-danger.disabled:hover,
.sl-sb .btn-danger[disabled]:hover,
.sl-sb fieldset[disabled] .btn-danger:hover,
.sl-sb .btn-danger.disabled:focus,
.sl-sb .btn-danger[disabled]:focus,
.sl-sb fieldset[disabled] .btn-danger:focus,
.sl-sb .btn-danger.disabled:active,
.sl-sb .btn-danger[disabled]:active,
.sl-sb fieldset[disabled] .btn-danger:active,
.sl-sb .btn-danger.disabled.active,
.sl-sb .btn-danger[disabled].active,
.sl-sb fieldset[disabled] .btn-danger.active {
  background-color: #d9534f;
  border-color: #d43f3a;
}
.sl-sb .btn-danger .badge {
  color: #d9534f;
  background-color: #fff;
}
.sl-sb .btn-link {
  font-weight: normal;
  color: #428bca;
  cursor: pointer;
  border-radius: 0;
}
.sl-sb .btn-link,
.sl-sb .btn-link:active,
.sl-sb .btn-link[disabled],
.sl-sb fieldset[disabled] .btn-link {
  background-color: transparent;
  -webkit-box-shadow: none;
          box-shadow: none;
}
.sl-sb .btn-link,
.sl-sb .btn-link:hover,
.sl-sb .btn-link:focus,
.sl-sb .btn-link:active {
  border-color: transparent;
}
.sl-sb .btn-link:hover,
.sl-sb .btn-link:focus {
  color: #2a6496;
  text-decoration: underline;
  background-color: transparent;
}
.sl-sb .btn-link[disabled]:hover,
.sl-sb fieldset[disabled] .btn-link:hover,
.sl-sb .btn-link[disabled]:focus,
.sl-sb fieldset[disabled] .btn-link:focus {
  color: #999;
  text-decoration: none;
}
.sl-sb .btn-lg,
.sl-sb .btn-group-lg > .btn {
  padding: 10px 16px;
  font-size: 18px;
  line-height: 1.33;
  border-radius: 6px;
}
.sl-sb .btn-sm,
.sl-sb .btn-group-sm > .btn {
  padding: 5px 10px;
  font-size: 12px;
  line-height: 1.5;
  border-radius: 3px;
}
.sl-sb .btn-xs,
.sl-sb .btn-group-xs > .btn {
  padding: 1px 5px;
  font-size: 12px;
  line-height: 1.5;
  border-radius: 3px;
}
.sl-sb .btn-block {
  display: block;
  width: 100%;
  padding-right: 0;
  padding-left: 0;
}
.sl-sb .btn-block + .btn-block {
  margin-top: 5px;
}
.sl-sb input[type="submit"].btn-block,
.sl-sb input[type="reset"].btn-block,
.sl-sb input[type="button"].btn-block {
  width: 100%;
}
.sl-sb .fade {
  opacity: 0;
  -webkit-transition: opacity .15s linear;
       -o-transition: opacity .15s linear;
          transition: opacity .15s linear;
}
.sl-sb .fade.in {
  opacity: 1;
}
.sl-sb .collapse {
  display: none;
}
.sl-sb .collapse.in {
  display: block;
}
.sl-sb tr.collapse.in {
  display: table-row;
}
.sl-sb tbody.collapse.in {
  display: table-row-group;
}
.sl-sb .collapsing {
  position: relative;
  height: 0;
  overflow: hidden;
  -webkit-transition: height .35s ease;
       -o-transition: height .35s ease;
          transition: height .35s ease;
}
.sl-sb .caret {
  display: inline-block;
  width: 0;
  height: 0;
  margin-left: 2px;
  vertical-align: middle;
  border-top: 4px solid;
  border-right: 4px solid transparent;
  border-left: 4px solid transparent;
}
.sl-sb .dropdown {
  position: relative;
}
.sl-sb .dropdown-toggle:focus {
  outline: 0;
}
.sl-sb .dropdown-menu {
  position: absolute;
  top: 100%;
  left: 0;
  z-index: 1000;
  display: none;
  float: left;
  min-width: 160px;
  padding: 5px 0;
  margin: 2px 0 0;
  font-size: 14px;
  text-align: left;
  list-style: none;
  background-color: #fff;
  -webkit-background-clip: padding-box;
          background-clip: padding-box;
  border: 1px solid #ccc;
  border: 1px solid rgba(0, 0, 0, .15);
  border-radius: 4px;
  -webkit-box-shadow: 0 6px 12px rgba(0, 0, 0, .175);
          box-shadow: 0 6px 12px rgba(0, 0, 0, .175);
}
.sl-sb .dropdown-menu.pull-right {
  right: 0;
  left: auto;
}
.sl-sb .dropdown-menu .divider {
  height: 1px;
  margin: 9px 0;
  overflow: hidden;
  background-color: #e5e5e5;
}
.sl-sb .dropdown-menu > li > a {
  display: block;
  padding: 3px 20px;
  clear: both;
  font-weight: normal;
  line-height: 1.42857143;
  color: #333;
  white-space: nowrap;
}
.sl-sb .dropdown-menu > li > a:hover,
.sl-sb .dropdown-menu > li > a:focus {
  color: #262626;
  text-decoration: none;
  background-color: #f5f5f5;
}
.sl-sb .dropdown-menu > .active > a,
.sl-sb .dropdown-menu > .active > a:hover,
.sl-sb .dropdown-menu > .active > a:focus {
  color: #fff;
  text-decoration: none;
  background-color: #428bca;
  outline: 0;
}
.sl-sb .dropdown-menu > .disabled > a,
.sl-sb .dropdown-menu > .disabled > a:hover,
.sl-sb .dropdown-menu > .disabled > a:focus {
  color: #999;
}
.sl-sb .dropdown-menu > .disabled > a:hover,
.sl-sb .dropdown-menu > .disabled > a:focus {
  text-decoration: none;
  cursor: not-allowed;
  background-color: transparent;
  background-image: none;
  filter: progid:DXImageTransform.Microsoft.gradient(enabled=false);
}
.sl-sb .open > .dropdown-menu {
  display: block;
}
.sl-sb .open > a {
  outline: 0;
}
.sl-sb .dropdown-menu-right {
  right: 0;
  left: auto;
}
.sl-sb .dropdown-menu-left {
  right: auto;
  left: 0;
}
.sl-sb .dropdown-header {
  display: block;
  padding: 3px 20px;
  font-size: 12px;
  line-height: 1.42857143;
  color: #999;
}
.sl-sb .dropdown-backdrop {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: 990;
}
.sl-sb .pull-right > .dropdown-menu {
  right: 0;
  left: auto;
}
.sl-sb .dropup .caret,
.sl-sb .navbar-fixed-bottom .dropdown .caret {
  content: "";
  border-top: 0;
  border-bottom: 4px solid;
}
.sl-sb .dropup .dropdown-menu,
.sl-sb .navbar-fixed-bottom .dropdown .dropdown-menu {
  top: auto;
  bottom: 100%;
  margin-bottom: 1px;
}
@media (min-width: 768px) {
  .sl-sb .navbar-right .dropdown-menu {
    right: 0;
    left: auto;
  }
  .sl-sb .navbar-right .dropdown-menu-left {
    right: auto;
    left: 0;
  }
}
.sl-sb .btn-group,
.sl-sb .btn-group-vertical {
  position: relative;
  display: inline-block;
  vertical-align: middle;
}
.sl-sb .btn-group > .btn,
.sl-sb .btn-group-vertical > .btn {
  position: relative;
  float: left;
}
.sl-sb .btn-group > .btn:hover,
.sl-sb .btn-group-vertical > .btn:hover,
.sl-sb .btn-group > .btn:focus,
.sl-sb .btn-group-vertical > .btn:focus,
.sl-sb .btn-group > .btn:active,
.sl-sb .btn-group-vertical > .btn:active,
.sl-sb .btn-group > .btn.active,
.sl-sb .btn-group-vertical > .btn.active {
  z-index: 2;
}
.sl-sb .btn-group > .btn:focus,
.sl-sb .btn-group-vertical > .btn:focus {
  outline: 0;
}
.sl-sb .btn-group .btn + .btn,
.sl-sb .btn-group .btn + .btn-group,
.sl-sb .btn-group .btn-group + .btn,
.sl-sb .btn-group .btn-group + .btn-group {
  margin-left: -1px;
}
.sl-sb .btn-toolbar {
  margin-left: -5px;
}
.sl-sb .btn-toolbar .btn-group,
.sl-sb .btn-toolbar .input-group {
  float: left;
}
.sl-sb .btn-toolbar > .btn,
.sl-sb .btn-toolbar > .btn-group,
.sl-sb .btn-toolbar > .input-group {
  margin-left: 5px;
}
.sl-sb .btn-group > .btn:not(:first-child):not(:last-child):not(.dropdown-toggle) {
  border-radius: 0;
}
.sl-sb .btn-group > .btn:first-child {
  margin-left: 0;
}
.sl-sb .btn-group > .btn:first-child:not(:last-child):not(.dropdown-toggle) {
  border-top-right-radius: 0;
  border-bottom-right-radius: 0;
}
.sl-sb .btn-group > .btn:last-child:not(:first-child),
.sl-sb .btn-group > .dropdown-toggle:not(:first-child) {
  border-top-left-radius: 0;
  border-bottom-left-radius: 0;
}
.sl-sb .btn-group > .btn-group {
  float: left;
}
.sl-sb .btn-group > .btn-group:not(:first-child):not(:last-child) > .btn {
  border-radius: 0;
}
.sl-sb .btn-group > .btn-group:first-child > .btn:last-child,
.sl-sb .btn-group > .btn-group:first-child > .dropdown-toggle {
  border-top-right-radius: 0;
  border-bottom-right-radius: 0;
}
.sl-sb .btn-group > .btn-group:last-child > .btn:first-child {
  border-top-left-radius: 0;
  border-bottom-left-radius: 0;
}
.sl-sb .btn-group .dropdown-toggle:active,
.sl-sb .btn-group.open .dropdown-toggle {
  outline: 0;
}
.sl-sb .btn-group > .btn + .dropdown-toggle {
  padding-right: 8px;
  padding-left: 8px;
}
.sl-sb .btn-group > .btn-lg + .dropdown-toggle {
  padding-right: 12px;
  padding-left: 12px;
}
.sl-sb .btn-group.open .dropdown-toggle {
  -webkit-box-shadow: inset 0 3px 5px rgba(0, 0, 0, .125);
          box-shadow: inset 0 3px 5px rgba(0, 0, 0, .125);
}
.sl-sb .btn-group.open .dropdown-toggle.btn-link {
  -webkit-box-shadow: none;
          box-shadow: none;
}
.sl-sb .btn .caret {
  margin-left: 0;
}
.sl-sb .btn-lg .caret {
  border-width: 5px 5px 0;
  border-bottom-width: 0;
}
.sl-sb .dropup .btn-lg .caret {
  border-width: 0 5px 5px;
}
.sl-sb .btn-group-vertical > .btn,
.sl-sb .btn-group-vertical > .btn-group,
.sl-sb .btn-group-vertical > .btn-group > .btn {
  display: block;
  float: none;
  width: 100%;
  max-width: 100%;
}
.sl-sb .btn-group-vertical > .btn-group > .btn {
  float: none;
}
.sl-sb .btn-group-vertical > .btn + .btn,
.sl-sb .btn-group-vertical > .btn + .btn-group,
.sl-sb .btn-group-vertical > .btn-group + .btn,
.sl-sb .btn-group-vertical > .btn-group + .btn-group {
  margin-top: -1px;
  margin-left: 0;
}
.sl-sb .btn-group-vertical > .btn:not(:first-child):not(:last-child) {
  border-radius: 0;
}
.sl-sb .btn-group-vertical > .btn:first-child:not(:last-child) {
  border-top-right-radius: 4px;
  border-bottom-right-radius: 0;
  border-bottom-left-radius: 0;
}
.sl-sb .btn-group-vertical > .btn:last-child:not(:first-child) {
  border-top-left-radius: 0;
  border-top-right-radius: 0;
  border-bottom-left-radius: 4px;
}
.sl-sb .btn-group-vertical > .btn-group:not(:first-child):not(:last-child) > .btn {
  border-radius: 0;
}
.sl-sb .btn-group-vertical > .btn-group:first-child:not(:last-child) > .btn:last-child,
.sl-sb .btn-group-vertical > .btn-group:first-child:not(:last-child) > .dropdown-toggle {
  border-bottom-right-radius: 0;
  border-bottom-left-radius: 0;
}
.sl-sb .btn-group-vertical > .btn-group:last-child:not(:first-child) > .btn:first-child {
  border-top-left-radius: 0;
  border-top-right-radius: 0;
}
.sl-sb .btn-group-justified {
  display: table;
  width: 100%;
  table-layout: fixed;
  border-collapse: separate;
}
.sl-sb .btn-group-justified > .btn,
.sl-sb .btn-group-justified > .btn-group {
  display: table-cell;
  float: none;
  width: 1%;
}
.sl-sb .btn-group-justified > .btn-group .btn {
  width: 100%;
}
.sl-sb [data-toggle="buttons"] > .btn > input[type="radio"],
.sl-sb [data-toggle="buttons"] > .btn > input[type="checkbox"] {
  position: absolute;
  z-index: -1;
  opacity: 0;
}
.sl-sb .input-group {
  position: relative;
  display: table;
  border-collapse: separate;
}
.sl-sb .input-group[class*="col-"] {
  float: none;
  padding-right: 0;
  padding-left: 0;
}
.sl-sb .input-group .form-control {
  position: relative;
  z-index: 2;
  float: left;
  width: 100%;
  margin-bottom: 0;
}
.sl-sb .input-group-lg > .form-control,
.sl-sb .input-group-lg > .input-group-addon,
.sl-sb .input-group-lg > .input-group-btn > .btn {
  height: 46px;
  padding: 10px 16px;
  font-size: 18px;
  line-height: 1.33;
  border-radius: 6px;
}
.sl-sb select.input-group-lg > .form-control,
.sl-sb select.input-group-lg > .input-group-addon,
.sl-sb select.input-group-lg > .input-group-btn > .btn {
  height: 46px;
  line-height: 46px;
}
.sl-sb textarea.input-group-lg > .form-control,
.sl-sb textarea.input-group-lg > .input-group-addon,
.sl-sb textarea.input-group-lg > .input-group-btn > .btn,
.sl-sb select[multiple].input-group-lg > .form-control,
.sl-sb select[multiple].input-group-lg > .input-group-addon,
.sl-sb select[multiple].input-group-lg > .input-group-btn > .btn {
  height: auto;
}
.sl-sb .input-group-sm > .form-control,
.sl-sb .input-group-sm > .input-group-addon,
.sl-sb .input-group-sm > .input-group-btn > .btn {
  height: 30px;
  padding: 5px 10px;
  font-size: 12px;
  line-height: 1.5;
  border-radius: 3px;
}
.sl-sb select.input-group-sm > .form-control,
.sl-sb select.input-group-sm > .input-group-addon,
.sl-sb select.input-group-sm > .input-group-btn > .btn {
  height: 30px;
  line-height: 30px;
}
.sl-sb textarea.input-group-sm > .form-control,
.sl-sb textarea.input-group-sm > .input-group-addon,
.sl-sb textarea.input-group-sm > .input-group-btn > .btn,
.sl-sb select[multiple].input-group-sm > .form-control,
.sl-sb select[multiple].input-group-sm > .input-group-addon,
.sl-sb select[multiple].input-group-sm > .input-group-btn > .btn {
  height: auto;
}
.sl-sb .input-group-addon,
.sl-sb .input-group-btn,
.sl-sb .input-group .form-control {
  display: table-cell;
}
.sl-sb .input-group-addon:not(:first-child):not(:last-child),
.sl-sb .input-group-btn:not(:first-child):not(:last-child),
.sl-sb .input-group .form-control:not(:first-child):not(:last-child) {
  border-radius: 0;
}
.sl-sb .input-group-addon,
.sl-sb .input-group-btn {
  width: 1%;
  white-space: nowrap;
  vertical-align: middle;
}
.sl-sb .input-group-addon {
  padding: 6px 12px;
  font-size: 14px;
  font-weight: normal;
  line-height: 1;
  color: #555;
  text-align: center;
  background-color: #eee;
  border: 1px solid #ccc;
  border-radius: 4px;
}
.sl-sb .input-group-addon.input-sm {
  padding: 5px 10px;
  font-size: 12px;
  border-radius: 3px;
}
.sl-sb .input-group-addon.input-lg {
  padding: 10px 16px;
  font-size: 18px;
  border-radius: 6px;
}
.sl-sb .input-group-addon input[type="radio"],
.sl-sb .input-group-addon input[type="checkbox"] {
  margin-top: 0;
}
.sl-sb .input-group .form-control:first-child,
.sl-sb .input-group-addon:first-child,
.sl-sb .input-group-btn:first-child > .btn,
.sl-sb .input-group-btn:first-child > .btn-group > .btn,
.sl-sb .input-group-btn:first-child > .dropdown-toggle,
.sl-sb .input-group-btn:last-child > .btn:not(:last-child):not(.dropdown-toggle),
.sl-sb .input-group-btn:last-child > .btn-group:not(:last-child) > .btn {
  border-top-right-radius: 0;
  border-bottom-right-radius: 0;
}
.sl-sb .input-group-addon:first-child {
  border-right: 0;
}
.sl-sb .input-group .form-control:last-child,
.sl-sb .input-group-addon:last-child,
.sl-sb .input-group-btn:last-child > .btn,
.sl-sb .input-group-btn:last-child > .btn-group > .btn,
.sl-sb .input-group-btn:last-child > .dropdown-toggle,
.sl-sb .input-group-btn:first-child > .btn:not(:first-child),
.sl-sb .input-group-btn:first-child > .btn-group:not(:first-child) > .btn {
  border-top-left-radius: 0;
  border-bottom-left-radius: 0;
}
.sl-sb .input-group-addon:last-child {
  border-left: 0;
}
.sl-sb .input-group-btn {
  position: relative;
  font-size: 0;
  white-space: nowrap;
}
.sl-sb .input-group-btn > .btn {
  position: relative;
}
.sl-sb .input-group-btn > .btn + .btn {
  margin-left: -1px;
}
.sl-sb .input-group-btn > .btn:hover,
.sl-sb .input-group-btn > .btn:focus,
.sl-sb .input-group-btn > .btn:active {
  z-index: 2;
}
.sl-sb .input-group-btn:first-child > .btn,
.sl-sb .input-group-btn:first-child > .btn-group {
  margin-right: -1px;
}
.sl-sb .input-group-btn:last-child > .btn,
.sl-sb .input-group-btn:last-child > .btn-group {
  margin-left: -1px;
}
.sl-sb .nav {
  padding-left: 0;
  margin-bottom: 0;
  list-style: none;
}
.sl-sb .nav > li {
  position: relative;
  display: block;
}
.sl-sb .nav > li > a {
  position: relative;
  display: block;
  padding: 10px 15px;
}
.sl-sb .nav > li > a:hover,
.sl-sb .nav > li > a:focus {
  text-decoration: none;
  background-color: #eee;
}
.sl-sb .nav > li.disabled > a {
  color: #999;
}
.sl-sb .nav > li.disabled > a:hover,
.sl-sb .nav > li.disabled > a:focus {
  color: #999;
  text-decoration: none;
  cursor: not-allowed;
  background-color: transparent;
}
.sl-sb .nav .open > a,
.sl-sb .nav .open > a:hover,
.sl-sb .nav .open > a:focus {
  background-color: #eee;
  border-color: #428bca;
}
.sl-sb .nav .nav-divider {
  height: 1px;
  margin: 9px 0;
  overflow: hidden;
  background-color: #e5e5e5;
}
.sl-sb .nav > li > a > img {
  max-width: none;
}
.sl-sb .nav-tabs {
  border-bottom: 1px solid #ddd;
}
.sl-sb .nav-tabs > li {
  float: left;
  margin-bottom: -1px;
}
.sl-sb .nav-tabs > li > a {
  margin-right: 2px;
  line-height: 1.42857143;
  border: 1px solid transparent;
  border-radius: 4px 4px 0 0;
}
.sl-sb .nav-tabs > li > a:hover {
  border-color: #eee #eee #ddd;
}
.sl-sb .nav-tabs > li.active > a,
.sl-sb .nav-tabs > li.active > a:hover,
.sl-sb .nav-tabs > li.active > a:focus {
  color: #555;
  cursor: default;
  background-color: #fff;
  border: 1px solid #ddd;
  border-bottom-color: transparent;
}
.sl-sb .nav-tabs.nav-justified {
  width: 100%;
  border-bottom: 0;
}
.sl-sb .nav-tabs.nav-justified > li {
  float: none;
}
.sl-sb .nav-tabs.nav-justified > li > a {
  margin-bottom: 5px;
  text-align: center;
}
.sl-sb .nav-tabs.nav-justified > .dropdown .dropdown-menu {
  top: auto;
  left: auto;
}
@media (min-width: 768px) {
  .sl-sb .nav-tabs.nav-justified > li {
    display: table-cell;
    width: 1%;
  }
  .sl-sb .nav-tabs.nav-justified > li > a {
    margin-bottom: 0;
  }
}
.sl-sb .nav-tabs.nav-justified > li > a {
  margin-right: 0;
  border-radius: 4px;
}
.sl-sb .nav-tabs.nav-justified > .active > a,
.sl-sb .nav-tabs.nav-justified > .active > a:hover,
.sl-sb .nav-tabs.nav-justified > .active > a:focus {
  border: 1px solid #ddd;
}
@media (min-width: 768px) {
  .sl-sb .nav-tabs.nav-justified > li > a {
    border-bottom: 1px solid #ddd;
    border-radius: 4px 4px 0 0;
  }
  .sl-sb .nav-tabs.nav-justified > .active > a,
  .sl-sb .nav-tabs.nav-justified > .active > a:hover,
  .sl-sb .nav-tabs.nav-justified > .active > a:focus {
    border-bottom-color: #fff;
  }
}
.sl-sb .nav-pills > li {
  float: left;
}
.sl-sb .nav-pills > li > a {
  border-radius: 4px;
}
.sl-sb .nav-pills > li + li {
  margin-left: 2px;
}
.sl-sb .nav-pills > li.active > a,
.sl-sb .nav-pills > li.active > a:hover,
.sl-sb .nav-pills > li.active > a:focus {
  color: #fff;
  background-color: #428bca;
}
.sl-sb .nav-stacked > li {
  float: none;
}
.sl-sb .nav-stacked > li + li {
  margin-top: 2px;
  margin-left: 0;
}
.sl-sb .nav-justified {
  width: 100%;
}
.sl-sb .nav-justified > li {
  float: none;
}
.sl-sb .nav-justified > li > a {
  margin-bottom: 5px;
  text-align: center;
}
.sl-sb .nav-justified > .dropdown .dropdown-menu {
  top: auto;
  left: auto;
}
@media (min-width: 768px) {
  .sl-sb .nav-justified > li {
    display: table-cell;
    width: 1%;
  }
  .sl-sb .nav-justified > li > a {
    margin-bottom: 0;
  }
}
.sl-sb .nav-tabs-justified {
  border-bottom: 0;
}
.sl-sb .nav-tabs-justified > li > a {
  margin-right: 0;
  border-radius: 4px;
}
.sl-sb .nav-tabs-justified > .active > a,
.sl-sb .nav-tabs-justified > .active > a:hover,
.sl-sb .nav-tabs-justified > .active > a:focus {
  border: 1px solid #ddd;
}
@media (min-width: 768px) {
  .sl-sb .nav-tabs-justified > li > a {
    border-bottom: 1px solid #ddd;
    border-radius: 4px 4px 0 0;
  }
  .sl-sb .nav-tabs-justified > .active > a,
  .sl-sb .nav-tabs-justified > .active > a:hover,
  .sl-sb .nav-tabs-justified > .active > a:focus {
    border-bottom-color: #fff;
  }
}
.sl-sb .tab-content > .tab-pane {
  display: none;
}
.sl-sb .tab-content > .active {
  display: block;
}
.sl-sb .nav-tabs .dropdown-menu {
  margin-top: -1px;
  border-top-left-radius: 0;
  border-top-right-radius: 0;
}
.sl-sb .navbar {
  position: relative;
  min-height: 50px;
  margin-bottom: 20px;
  border: 1px solid transparent;
}
@media (min-width: 768px) {
  .sl-sb .navbar {
    border-radius: 4px;
  }
}
@media (min-width: 768px) {
  .sl-sb .navbar-header {
    float: left;
  }
}
.sl-sb .navbar-collapse {
  padding-right: 15px;
  padding-left: 15px;
  overflow-x: visible;
  -webkit-overflow-scrolling: touch;
  border-top: 1px solid transparent;
  -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, .1);
          box-shadow: inset 0 1px 0 rgba(255, 255, 255, .1);
}
.sl-sb .navbar-collapse.in {
  overflow-y: auto;
}
@media (min-width: 768px) {
  .sl-sb .navbar-collapse {
    width: auto;
    border-top: 0;
    -webkit-box-shadow: none;
            box-shadow: none;
  }
  .sl-sb .navbar-collapse.collapse {
    display: block !important;
    height: auto !important;
    padding-bottom: 0;
    overflow: visible !important;
  }
  .sl-sb .navbar-collapse.in {
    overflow-y: visible;
  }
  .sl-sb .navbar-fixed-top .navbar-collapse,
  .sl-sb .navbar-static-top .navbar-collapse,
  .sl-sb .navbar-fixed-bottom .navbar-collapse {
    padding-right: 0;
    padding-left: 0;
  }
}
.sl-sb .navbar-fixed-top .navbar-collapse,
.sl-sb .navbar-fixed-bottom .navbar-collapse {
  max-height: 340px;
}
@media (max-width: 480px) and (orientation: landscape) {
  .sl-sb .navbar-fixed-top .navbar-collapse,
  .sl-sb .navbar-fixed-bottom .navbar-collapse {
    max-height: 200px;
  }
}
.sl-sb .container > .navbar-header,
.sl-sb .container-fluid > .navbar-header,
.sl-sb .container > .navbar-collapse,
.sl-sb .container-fluid > .navbar-collapse {
  margin-right: -15px;
  margin-left: -15px;
}
@media (min-width: 768px) {
  .sl-sb .container > .navbar-header,
  .sl-sb .container-fluid > .navbar-header,
  .sl-sb .container > .navbar-collapse,
  .sl-sb .container-fluid > .navbar-collapse {
    margin-right: 0;
    margin-left: 0;
  }
}
.sl-sb .navbar-static-top {
  z-index: 1000;
  border-width: 0 0 1px;
}
@media (min-width: 768px) {
  .sl-sb .navbar-static-top {
    border-radius: 0;
  }
}
.sl-sb .navbar-fixed-top,
.sl-sb .navbar-fixed-bottom {
  position: fixed;
  right: 0;
  left: 0;
  z-index: 1030;
}
@media (min-width: 768px) {
  .sl-sb .navbar-fixed-top,
  .sl-sb .navbar-fixed-bottom {
    border-radius: 0;
  }
}
.sl-sb .navbar-fixed-top {
  top: 0;
  border-width: 0 0 1px;
}
.sl-sb .navbar-fixed-bottom {
  bottom: 0;
  margin-bottom: 0;
  border-width: 1px 0 0;
}
.sl-sb .navbar-brand {
  float: left;
  height: 50px;
  padding: 15px 15px;
  font-size: 18px;
  line-height: 20px;
}
.sl-sb .navbar-brand:hover,
.sl-sb .navbar-brand:focus {
  text-decoration: none;
}
@media (min-width: 768px) {
  .sl-sb .navbar > .container .navbar-brand,
  .sl-sb .navbar > .container-fluid .navbar-brand {
    margin-left: -15px;
  }
}
.sl-sb .navbar-toggle {
  position: relative;
  float: right;
  padding: 9px 10px;
  margin-top: 8px;
  margin-right: 15px;
  margin-bottom: 8px;
  background-color: transparent;
  background-image: none;
  border: 1px solid transparent;
  border-radius: 4px;
}
.sl-sb .navbar-toggle:focus {
  outline: 0;
}
.sl-sb .navbar-toggle .icon-bar {
  display: block;
  width: 22px;
  height: 2px;
  border-radius: 1px;
}
.sl-sb .navbar-toggle .icon-bar + .icon-bar {
  margin-top: 4px;
}
@media (min-width: 768px) {
  .sl-sb .navbar-toggle {
    display: none;
  }
}
.sl-sb .navbar-nav {
  margin: 7.5px -15px;
}
.sl-sb .navbar-nav > li > a {
  padding-top: 10px;
  padding-bottom: 10px;
  line-height: 20px;
}
@media (max-width: 767px) {
  .sl-sb .navbar-nav .open .dropdown-menu {
    position: static;
    float: none;
    width: auto;
    margin-top: 0;
    background-color: transparent;
    border: 0;
    -webkit-box-shadow: none;
            box-shadow: none;
  }
  .sl-sb .navbar-nav .open .dropdown-menu > li > a,
  .sl-sb .navbar-nav .open .dropdown-menu .dropdown-header {
    padding: 5px 15px 5px 25px;
  }
  .sl-sb .navbar-nav .open .dropdown-menu > li > a {
    line-height: 20px;
  }
  .sl-sb .navbar-nav .open .dropdown-menu > li > a:hover,
  .sl-sb .navbar-nav .open .dropdown-menu > li > a:focus {
    background-image: none;
  }
}
@media (min-width: 768px) {
  .sl-sb .navbar-nav {
    float: left;
    margin: 0;
  }
  .sl-sb .navbar-nav > li {
    float: left;
  }
  .sl-sb .navbar-nav > li > a {
    padding-top: 15px;
    padding-bottom: 15px;
  }
  .sl-sb .navbar-nav.navbar-right:last-child {
    margin-right: -15px;
  }
}
@media (min-width: 768px) {
  .sl-sb .navbar-left {
    float: left !important;
  }
  .sl-sb .navbar-right {
    float: right !important;
  }
}
.sl-sb .navbar-form {
  padding: 10px 15px;
  margin-top: 8px;
  margin-right: -15px;
  margin-bottom: 8px;
  margin-left: -15px;
  border-top: 1px solid transparent;
  border-bottom: 1px solid transparent;
  -webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, .1), 0 1px 0 rgba(255, 255, 255, .1);
          box-shadow: inset 0 1px 0 rgba(255, 255, 255, .1), 0 1px 0 rgba(255, 255, 255, .1);
}
@media (min-width: 768px) {
  .sl-sb .navbar-form .form-group {
    display: inline-block;
    margin-bottom: 0;
    vertical-align: middle;
  }
  .sl-sb .navbar-form .form-control {
    display: inline-block;
    width: auto;
    vertical-align: middle;
  }
  .sl-sb .navbar-form .input-group {
    display: inline-table;
    vertical-align: middle;
  }
  .sl-sb .navbar-form .input-group .input-group-addon,
  .sl-sb .navbar-form .input-group .input-group-btn,
  .sl-sb .navbar-form .input-group .form-control {
    width: auto;
  }
  .sl-sb .navbar-form .input-group > .form-control {
    width: 100%;
  }
  .sl-sb .navbar-form .control-label {
    margin-bottom: 0;
    vertical-align: middle;
  }
  .sl-sb .navbar-form .radio,
  .sl-sb .navbar-form .checkbox {
    display: inline-block;
    padding-left: 0;
    margin-top: 0;
    margin-bottom: 0;
    vertical-align: middle;
  }
  .sl-sb .navbar-form .radio input[type="radio"],
  .sl-sb .navbar-form .checkbox input[type="checkbox"] {
    float: none;
    margin-left: 0;
  }
  .sl-sb .navbar-form .has-feedback .form-control-feedback {
    top: 0;
  }
}
@media (max-width: 767px) {
  .sl-sb .navbar-form .form-group {
    margin-bottom: 5px;
  }
}
@media (min-width: 768px) {
  .sl-sb .navbar-form {
    width: auto;
    padding-top: 0;
    padding-bottom: 0;
    margin-right: 0;
    margin-left: 0;
    border: 0;
    -webkit-box-shadow: none;
            box-shadow: none;
  }
  .sl-sb .navbar-form.navbar-right:last-child {
    margin-right: -15px;
  }
}
.sl-sb .navbar-nav > li > .dropdown-menu {
  margin-top: 0;
  border-top-left-radius: 0;
  border-top-right-radius: 0;
}
.sl-sb .navbar-fixed-bottom .navbar-nav > li > .dropdown-menu {
  border-bottom-right-radius: 0;
  border-bottom-left-radius: 0;
}
.sl-sb .navbar-btn {
  margin-top: 8px;
  margin-bottom: 8px;
}
.sl-sb .navbar-btn.btn-sm {
  margin-top: 10px;
  margin-bottom: 10px;
}
.sl-sb .navbar-btn.btn-xs {
  margin-top: 14px;
  margin-bottom: 14px;
}
.sl-sb .navbar-text {
  margin-top: 15px;
  margin-bottom: 15px;
}
@media (min-width: 768px) {
  .sl-sb .navbar-text {
    float: left;
    margin-right: 15px;
    margin-left: 15px;
  }
  .sl-sb .navbar-text.navbar-right:last-child {
    margin-right: 0;
  }
}
.sl-sb .navbar-default {
  background-color: #f8f8f8;
  border-color: #e7e7e7;
}
.sl-sb .navbar-default .navbar-brand {
  color: #777;
}
.sl-sb .navbar-default .navbar-brand:hover,
.sl-sb .navbar-default .navbar-brand:focus {
  color: #5e5e5e;
  background-color: transparent;
}
.sl-sb .navbar-default .navbar-text {
  color: #777;
}
.sl-sb .navbar-default .navbar-nav > li > a {
  color: #777;
}
.sl-sb .navbar-default .navbar-nav > li > a:hover,
.sl-sb .navbar-default .navbar-nav > li > a:focus {
  color: #333;
  background-color: transparent;
}
.sl-sb .navbar-default .navbar-nav > .active > a,
.sl-sb .navbar-default .navbar-nav > .active > a:hover,
.sl-sb .navbar-default .navbar-nav > .active > a:focus {
  color: #555;
  background-color: #e7e7e7;
}
.sl-sb .navbar-default .navbar-nav > .disabled > a,
.sl-sb .navbar-default .navbar-nav > .disabled > a:hover,
.sl-sb .navbar-default .navbar-nav > .disabled > a:focus {
  color: #ccc;
  background-color: transparent;
}
.sl-sb .navbar-default .navbar-toggle {
  border-color: #ddd;
}
.sl-sb .navbar-default .navbar-toggle:hover,
.sl-sb .navbar-default .navbar-toggle:focus {
  background-color: #ddd;
}
.sl-sb .navbar-default .navbar-toggle .icon-bar {
  background-color: #888;
}
.sl-sb .navbar-default .navbar-collapse,
.sl-sb .navbar-default .navbar-form {
  border-color: #e7e7e7;
}
.sl-sb .navbar-default .navbar-nav > .open > a,
.sl-sb .navbar-default .navbar-nav > .open > a:hover,
.sl-sb .navbar-default .navbar-nav > .open > a:focus {
  color: #555;
  background-color: #e7e7e7;
}
@media (max-width: 767px) {
  .sl-sb .navbar-default .navbar-nav .open .dropdown-menu > li > a {
    color: #777;
  }
  .sl-sb .navbar-default .navbar-nav .open .dropdown-menu > li > a:hover,
  .sl-sb .navbar-default .navbar-nav .open .dropdown-menu > li > a:focus {
    color: #333;
    background-color: transparent;
  }
  .sl-sb .navbar-default .navbar-nav .open .dropdown-menu > .active > a,
  .sl-sb .navbar-default .navbar-nav .open .dropdown-menu > .active > a:hover,
  .sl-sb .navbar-default .navbar-nav .open .dropdown-menu > .active > a:focus {
    color: #555;
    background-color: #e7e7e7;
  }
  .sl-sb .navbar-default .navbar-nav .open .dropdown-menu > .disabled > a,
  .sl-sb .navbar-default .navbar-nav .open .dropdown-menu > .disabled > a:hover,
  .sl-sb .navbar-default .navbar-nav .open .dropdown-menu > .disabled > a:focus {
    color: #ccc;
    background-color: transparent;
  }
}
.sl-sb .navbar-default .navbar-link {
  color: #777;
}
.sl-sb .navbar-default .navbar-link:hover {
  color: #333;
}
.sl-sb .navbar-default .btn-link {
  color: #777;
}
.sl-sb .navbar-default .btn-link:hover,
.sl-sb .navbar-default .btn-link:focus {
  color: #333;
}
.sl-sb .navbar-default .btn-link[disabled]:hover,
.sl-sb fieldset[disabled] .navbar-default .btn-link:hover,
.sl-sb .navbar-default .btn-link[disabled]:focus,
.sl-sb fieldset[disabled] .navbar-default .btn-link:focus {
  color: #ccc;
}
.sl-sb .navbar-inverse {
  background-color: #222;
  border-color: #080808;
}
.sl-sb .navbar-inverse .navbar-brand {
  color: #999;
}
.sl-sb .navbar-inverse .navbar-brand:hover,
.sl-sb .navbar-inverse .navbar-brand:focus {
  color: #fff;
  background-color: transparent;
}
.sl-sb .navbar-inverse .navbar-text {
  color: #999;
}
.sl-sb .navbar-inverse .navbar-nav > li > a {
  color: #999;
}
.sl-sb .navbar-inverse .navbar-nav > li > a:hover,
.sl-sb .navbar-inverse .navbar-nav > li > a:focus {
  color: #fff;
  background-color: transparent;
}
.sl-sb .navbar-inverse .navbar-nav > .active > a,
.sl-sb .navbar-inverse .navbar-nav > .active > a:hover,
.sl-sb .navbar-inverse .navbar-nav > .active > a:focus {
  color: #fff;
  background-color: #080808;
}
.sl-sb .navbar-inverse .navbar-nav > .disabled > a,
.sl-sb .navbar-inverse .navbar-nav > .disabled > a:hover,
.sl-sb .navbar-inverse .navbar-nav > .disabled > a:focus {
  color: #444;
  background-color: transparent;
}
.sl-sb .navbar-inverse .navbar-toggle {
  border-color: #333;
}
.sl-sb .navbar-inverse .navbar-toggle:hover,
.sl-sb .navbar-inverse .navbar-toggle:focus {
  background-color: #333;
}
.sl-sb .navbar-inverse .navbar-toggle .icon-bar {
  background-color: #fff;
}
.sl-sb .navbar-inverse .navbar-collapse,
.sl-sb .navbar-inverse .navbar-form {
  border-color: #101010;
}
.sl-sb .navbar-inverse .navbar-nav > .open > a,
.sl-sb .navbar-inverse .navbar-nav > .open > a:hover,
.sl-sb .navbar-inverse .navbar-nav > .open > a:focus {
  color: #fff;
  background-color: #080808;
}
@media (max-width: 767px) {
  .sl-sb .navbar-inverse .navbar-nav .open .dropdown-menu > .dropdown-header {
    border-color: #080808;
  }
  .sl-sb .navbar-inverse .navbar-nav .open .dropdown-menu .divider {
    background-color: #080808;
  }
  .sl-sb .navbar-inverse .navbar-nav .open .dropdown-menu > li > a {
    color: #999;
  }
  .sl-sb .navbar-inverse .navbar-nav .open .dropdown-menu > li > a:hover,
  .sl-sb .navbar-inverse .navbar-nav .open .dropdown-menu > li > a:focus {
    color: #fff;
    background-color: transparent;
  }
  .sl-sb .navbar-inverse .navbar-nav .open .dropdown-menu > .active > a,
  .sl-sb .navbar-inverse .navbar-nav .open .dropdown-menu > .active > a:hover,
  .sl-sb .navbar-inverse .navbar-nav .open .dropdown-menu > .active > a:focus {
    color: #fff;
    background-color: #080808;
  }
  .sl-sb .navbar-inverse .navbar-nav .open .dropdown-menu > .disabled > a,
  .sl-sb .navbar-inverse .navbar-nav .open .dropdown-menu > .disabled > a:hover,
  .sl-sb .navbar-inverse .navbar-nav .open .dropdown-menu > .disabled > a:focus {
    color: #444;
    background-color: transparent;
  }
}
.sl-sb .navbar-inverse .navbar-link {
  color: #999;
}
.sl-sb .navbar-inverse .navbar-link:hover {
  color: #fff;
}
.sl-sb .navbar-inverse .btn-link {
  color: #999;
}
.sl-sb .navbar-inverse .btn-link:hover,
.sl-sb .navbar-inverse .btn-link:focus {
  color: #fff;
}
.sl-sb .navbar-inverse .btn-link[disabled]:hover,
.sl-sb fieldset[disabled] .navbar-inverse .btn-link:hover,
.sl-sb .navbar-inverse .btn-link[disabled]:focus,
.sl-sb fieldset[disabled] .navbar-inverse .btn-link:focus {
  color: #444;
}
.sl-sb .breadcrumb {
  padding: 8px 15px;
  margin-bottom: 20px;
  list-style: none;
  background-color: #f5f5f5;
  border-radius: 4px;
}
.sl-sb .breadcrumb > li {
  display: inline-block;
}
.sl-sb .breadcrumb > li + li:before {
  padding: 0 5px;
  color: #ccc;
  content: "/\00a0";
}
.sl-sb .breadcrumb > .active {
  color: #999;
}
.sl-sb .pagination {
  display: inline-block;
  padding-left: 0;
  margin: 20px 0;
  border-radius: 4px;
}
.sl-sb .pagination > li {
  display: inline;
}
.sl-sb .pagination > li > a,
.sl-sb .pagination > li > span {
  position: relative;
  float: left;
  padding: 6px 12px;
  margin-left: -1px;
  line-height: 1.42857143;
  color: #428bca;
  text-decoration: none;
  background-color: #fff;
  border: 1px solid #ddd;
}
.sl-sb .pagination > li:first-child > a,
.sl-sb .pagination > li:first-child > span {
  margin-left: 0;
  border-top-left-radius: 4px;
  border-bottom-left-radius: 4px;
}
.sl-sb .pagination > li:last-child > a,
.sl-sb .pagination > li:last-child > span {
  border-top-right-radius: 4px;
  border-bottom-right-radius: 4px;
}
.sl-sb .pagination > li > a:hover,
.sl-sb .pagination > li > span:hover,
.sl-sb .pagination > li > a:focus,
.sl-sb .pagination > li > span:focus {
  color: #2a6496;
  background-color: #eee;
  border-color: #ddd;
}
.sl-sb .pagination > .active > a,
.sl-sb .pagination > .active > span,
.sl-sb .pagination > .active > a:hover,
.sl-sb .pagination > .active > span:hover,
.sl-sb .pagination > .active > a:focus,
.sl-sb .pagination > .active > span:focus {
  z-index: 2;
  color: #fff;
  cursor: default;
  background-color: #428bca;
  border-color: #428bca;
}
.sl-sb .pagination > .disabled > span,
.sl-sb .pagination > .disabled > span:hover,
.sl-sb .pagination > .disabled > span:focus,
.sl-sb .pagination > .disabled > a,
.sl-sb .pagination > .disabled > a:hover,
.sl-sb .pagination > .disabled > a:focus {
  color: #999;
  cursor: not-allowed;
  background-color: #fff;
  border-color: #ddd;
}
.sl-sb .pagination-lg > li > a,
.sl-sb .pagination-lg > li > span {
  padding: 10px 16px;
  font-size: 18px;
}
.sl-sb .pagination-lg > li:first-child > a,
.sl-sb .pagination-lg > li:first-child > span {
  border-top-left-radius: 6px;
  border-bottom-left-radius: 6px;
}
.sl-sb .pagination-lg > li:last-child > a,
.sl-sb .pagination-lg > li:last-child > span {
  border-top-right-radius: 6px;
  border-bottom-right-radius: 6px;
}
.sl-sb .pagination-sm > li > a,
.sl-sb .pagination-sm > li > span {
  padding: 5px 10px;
  font-size: 12px;
}
.sl-sb .pagination-sm > li:first-child > a,
.sl-sb .pagination-sm > li:first-child > span {
  border-top-left-radius: 3px;
  border-bottom-left-radius: 3px;
}
.sl-sb .pagination-sm > li:last-child > a,
.sl-sb .pagination-sm > li:last-child > span {
  border-top-right-radius: 3px;
  border-bottom-right-radius: 3px;
}
.sl-sb .pager {
  padding-left: 0;
  margin: 20px 0;
  text-align: center;
  list-style: none;
}
.sl-sb .pager li {
  display: inline;
}
.sl-sb .pager li > a,
.sl-sb .pager li > span {
  display: inline-block;
  padding: 5px 14px;
  background-color: #fff;
  border: 1px solid #ddd;
  border-radius: 15px;
}
.sl-sb .pager li > a:hover,
.sl-sb .pager li > a:focus {
  text-decoration: none;
  background-color: #eee;
}
.sl-sb .pager .next > a,
.sl-sb .pager .next > span {
  float: right;
}
.sl-sb .pager .previous > a,
.sl-sb .pager .previous > span {
  float: left;
}
.sl-sb .pager .disabled > a,
.sl-sb .pager .disabled > a:hover,
.sl-sb .pager .disabled > a:focus,
.sl-sb .pager .disabled > span {
  color: #999;
  cursor: not-allowed;
  background-color: #fff;
}
.sl-sb .label {
  display: inline;
  padding: .2em .6em .3em;
  font-size: 75%;
  font-weight: bold;
  line-height: 1;
  color: #fff;
  text-align: center;
  white-space: nowrap;
  vertical-align: baseline;
  border-radius: .25em;
}
.sl-sb a.label:hover,
.sl-sb a.label:focus {
  color: #fff;
  text-decoration: none;
  cursor: pointer;
}
.sl-sb .label:empty {
  display: none;
}
.sl-sb .btn .label {
  position: relative;
  top: -1px;
}
.sl-sb .label-default {
  background-color: #999;
}
.sl-sb .label-default[href]:hover,
.sl-sb .label-default[href]:focus {
  background-color: #808080;
}
.sl-sb .label-primary {
  background-color: #428bca;
}
.sl-sb .label-primary[href]:hover,
.sl-sb .label-primary[href]:focus {
  background-color: #3071a9;
}
.sl-sb .label-success {
  background-color: #5cb85c;
}
.sl-sb .label-success[href]:hover,
.sl-sb .label-success[href]:focus {
  background-color: #449d44;
}
.sl-sb .label-info {
  background-color: #5bc0de;
}
.sl-sb .label-info[href]:hover,
.sl-sb .label-info[href]:focus {
  background-color: #31b0d5;
}
.sl-sb .label-warning {
  background-color: #f0ad4e;
}
.sl-sb .label-warning[href]:hover,
.sl-sb .label-warning[href]:focus {
  background-color: #ec971f;
}
.sl-sb .label-danger {
  background-color: #d9534f;
}
.sl-sb .label-danger[href]:hover,
.sl-sb .label-danger[href]:focus {
  background-color: #c9302c;
}
.sl-sb .badge {
  display: inline-block;
  min-width: 10px;
  padding: 3px 7px;
  font-size: 12px;
  font-weight: bold;
  line-height: 1;
  color: #fff;
  text-align: center;
  white-space: nowrap;
  vertical-align: baseline;
  background-color: #999;
  border-radius: 10px;
}
.sl-sb .badge:empty {
  display: none;
}
.sl-sb .btn .badge {
  position: relative;
  top: -1px;
}
.sl-sb .btn-xs .badge {
  top: 0;
  padding: 1px 5px;
}
.sl-sb a.badge:hover,
.sl-sb a.badge:focus {
  color: #fff;
  text-decoration: none;
  cursor: pointer;
}
.sl-sb a.list-group-item.active > .badge,
.sl-sb .nav-pills > .active > a > .badge {
  color: #428bca;
  background-color: #fff;
}
.sl-sb .nav-pills > li > a > .badge {
  margin-left: 3px;
}
.sl-sb .jumbotron {
  padding: 30px;
  margin-bottom: 30px;
  color: inherit;
  background-color: #eee;
}
.sl-sb .jumbotron h1,
.sl-sb .jumbotron .h1 {
  color: inherit;
}
.sl-sb .jumbotron p {
  margin-bottom: 15px;
  font-size: 21px;
  font-weight: 200;
}
.sl-sb .jumbotron > hr {
  border-top-color: #d5d5d5;
}
.sl-sb .container .jumbotron {
  border-radius: 6px;
}
.sl-sb .jumbotron .container {
  max-width: 100%;
}
@media screen and (min-width: 768px) {
  .sl-sb .jumbotron {
    padding-top: 48px;
    padding-bottom: 48px;
  }
  .sl-sb .container .jumbotron {
    padding-right: 60px;
    padding-left: 60px;
  }
  .sl-sb .jumbotron h1,
  .sl-sb .jumbotron .h1 {
    font-size: 63px;
  }
}
.sl-sb .thumbnail {
  display: block;
  padding: 4px;
  margin-bottom: 20px;
  line-height: 1.42857143;
  background-color: #fff;
  border: 1px solid #ddd;
  border-radius: 4px;
  -webkit-transition: all .2s ease-in-out;
       -o-transition: all .2s ease-in-out;
          transition: all .2s ease-in-out;
}
.sl-sb .thumbnail > img,
.sl-sb .thumbnail a > img {
  margin-right: auto;
  margin-left: auto;
}
.sl-sb a.thumbnail:hover,
.sl-sb a.thumbnail:focus,
.sl-sb a.thumbnail.active {
  border-color: #428bca;
}
.sl-sb .thumbnail .caption {
  padding: 9px;
  color: #333;
}
.sl-sb .alert {
  padding: 15px;
  margin-bottom: 20px;
  border: 1px solid transparent;
  border-radius: 4px;
}
.sl-sb .alert h4 {
  margin-top: 0;
  color: inherit;
}
.sl-sb .alert .alert-link {
  font-weight: bold;
}
.sl-sb .alert > p,
.sl-sb .alert > ul {
  margin-bottom: 0;
}
.sl-sb .alert > p + p {
  margin-top: 5px;
}
.sl-sb .alert-dismissable {
  padding-right: 35px;
}
.sl-sb .alert-dismissable .close {
  position: relative;
  top: -2px;
  right: -21px;
  color: inherit;
}
.sl-sb .alert-success {
  color: #3c763d;
  background-color: #dff0d8;
  border-color: #d6e9c6;
}
.sl-sb .alert-success hr {
  border-top-color: #c9e2b3;
}
.sl-sb .alert-success .alert-link {
  color: #2b542c;
}
.sl-sb .alert-info {
  color: #31708f;
  background-color: #d9edf7;
  border-color: #bce8f1;
}
.sl-sb .alert-info hr {
  border-top-color: #a6e1ec;
}
.sl-sb .alert-info .alert-link {
  color: #245269;
}
.sl-sb .alert-warning {
  color: #8a6d3b;
  background-color: #fcf8e3;
  border-color: #faebcc;
}
.sl-sb .alert-warning hr {
  border-top-color: #f7e1b5;
}
.sl-sb .alert-warning .alert-link {
  color: #66512c;
}
.sl-sb .alert-danger {
  color: #a94442;
  background-color: #f2dede;
  border-color: #ebccd1;
}
.sl-sb .alert-danger hr {
  border-top-color: #e4b9c0;
}
.sl-sb .alert-danger .alert-link {
  color: #843534;
}
@-webkit-keyframes progress-bar-stripes {
  from {
    background-position: 40px 0;
  }
  to {
    background-position: 0 0;
  }
}
@-o-keyframes progress-bar-stripes {
  from {
    background-position: 40px 0;
  }
  to {
    background-position: 0 0;
  }
}
@keyframes progress-bar-stripes {
  from {
    background-position: 40px 0;
  }
  to {
    background-position: 0 0;
  }
}
.sl-sb .progress {
  height: 20px;
  margin-bottom: 20px;
  overflow: hidden;
  background-color: #f5f5f5;
  border-radius: 4px;
  -webkit-box-shadow: inset 0 1px 2px rgba(0, 0, 0, .1);
          box-shadow: inset 0 1px 2px rgba(0, 0, 0, .1);
}
.sl-sb .progress-bar {
  float: left;
  width: 0;
  height: 100%;
  font-size: 12px;
  line-height: 20px;
  color: #fff;
  text-align: center;
  background-color: #428bca;
  -webkit-box-shadow: inset 0 -1px 0 rgba(0, 0, 0, .15);
          box-shadow: inset 0 -1px 0 rgba(0, 0, 0, .15);
  -webkit-transition: width .6s ease;
       -o-transition: width .6s ease;
          transition: width .6s ease;
}
.sl-sb .progress-striped .progress-bar {
  background-image: -webkit-linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
  background-image:      -o-linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
  background-image:         linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
  -webkit-background-size: 40px 40px;
          background-size: 40px 40px;
}
.sl-sb .progress.active .progress-bar {
  -webkit-animation: progress-bar-stripes 2s linear infinite;
       -o-animation: progress-bar-stripes 2s linear infinite;
          animation: progress-bar-stripes 2s linear infinite;
}
.sl-sb .progress-bar[aria-valuenow="1"],
.sl-sb .progress-bar[aria-valuenow="2"] {
  min-width: 30px;
}
.sl-sb .progress-bar[aria-valuenow="0"] {
  min-width: 30px;
  color: #999;
  background-color: transparent;
  background-image: none;
  -webkit-box-shadow: none;
          box-shadow: none;
}
.sl-sb .progress-bar-success {
  background-color: #5cb85c;
}
.sl-sb .progress-striped .progress-bar-success {
  background-image: -webkit-linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
  background-image:      -o-linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
  background-image:         linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
}
.sl-sb .progress-bar-info {
  background-color: #5bc0de;
}
.sl-sb .progress-striped .progress-bar-info {
  background-image: -webkit-linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
  background-image:      -o-linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
  background-image:         linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
}
.sl-sb .progress-bar-warning {
  background-color: #f0ad4e;
}
.sl-sb .progress-striped .progress-bar-warning {
  background-image: -webkit-linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
  background-image:      -o-linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
  background-image:         linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
}
.sl-sb .progress-bar-danger {
  background-color: #d9534f;
}
.sl-sb .progress-striped .progress-bar-danger {
  background-image: -webkit-linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
  background-image:      -o-linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
  background-image:         linear-gradient(45deg, rgba(255, 255, 255, .15) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%, transparent 75%, transparent);
}
.sl-sb .media,
.sl-sb .media-body {
  overflow: hidden;
  zoom: 1;
}
.sl-sb .media,
.sl-sb .media .media {
  margin-top: 15px;
}
.sl-sb .media:first-child {
  margin-top: 0;
}
.sl-sb .media-object {
  display: block;
}
.sl-sb .media-heading {
  margin: 0 0 5px;
}
.sl-sb .media > .pull-left {
  margin-right: 10px;
}
.sl-sb .media > .pull-right {
  margin-left: 10px;
}
.sl-sb .media-list {
  padding-left: 0;
  list-style: none;
}
.sl-sb .list-group {
  padding-left: 0;
  margin-bottom: 20px;
}
.sl-sb .list-group-item {
  position: relative;
  display: block;
  padding: 10px 15px;
  margin-bottom: -1px;
  background-color: #fff;
  border: 1px solid #ddd;
}
.sl-sb .list-group-item:first-child {
  border-top-left-radius: 4px;
  border-top-right-radius: 4px;
}
.sl-sb .list-group-item:last-child {
  margin-bottom: 0;
  border-bottom-right-radius: 4px;
  border-bottom-left-radius: 4px;
}
.sl-sb .list-group-item > .badge {
  float: right;
}
.sl-sb .list-group-item > .badge + .badge {
  margin-right: 5px;
}
.sl-sb a.list-group-item {
  color: #555;
}
.sl-sb a.list-group-item .list-group-item-heading {
  color: #333;
}
.sl-sb a.list-group-item:hover,
.sl-sb a.list-group-item:focus {
  color: #555;
  text-decoration: none;
  background-color: #f5f5f5;
}
.sl-sb .list-group-item.disabled,
.sl-sb .list-group-item.disabled:hover,
.sl-sb .list-group-item.disabled:focus {
  color: #999;
  background-color: #eee;
}
.sl-sb .list-group-item.disabled .list-group-item-heading,
.sl-sb .list-group-item.disabled:hover .list-group-item-heading,
.sl-sb .list-group-item.disabled:focus .list-group-item-heading {
  color: inherit;
}
.sl-sb .list-group-item.disabled .list-group-item-text,
.sl-sb .list-group-item.disabled:hover .list-group-item-text,
.sl-sb .list-group-item.disabled:focus .list-group-item-text {
  color: #999;
}
.sl-sb .list-group-item.active,
.sl-sb .list-group-item.active:hover,
.sl-sb .list-group-item.active:focus {
  z-index: 2;
  color: #fff;
  background-color: #428bca;
  border-color: #428bca;
}
.sl-sb .list-group-item.active .list-group-item-heading,
.sl-sb .list-group-item.active:hover .list-group-item-heading,
.sl-sb .list-group-item.active:focus .list-group-item-heading {
  color: inherit;
}
.sl-sb .list-group-item.active .list-group-item-text,
.sl-sb .list-group-item.active:hover .list-group-item-text,
.sl-sb .list-group-item.active:focus .list-group-item-text {
  color: #e1edf7;
}
.sl-sb .list-group-item-success {
  color: #3c763d;
  background-color: #dff0d8;
}
.sl-sb a.list-group-item-success {
  color: #3c763d;
}
.sl-sb a.list-group-item-success .list-group-item-heading {
  color: inherit;
}
.sl-sb a.list-group-item-success:hover,
.sl-sb a.list-group-item-success:focus {
  color: #3c763d;
  background-color: #d0e9c6;
}
.sl-sb a.list-group-item-success.active,
.sl-sb a.list-group-item-success.active:hover,
.sl-sb a.list-group-item-success.active:focus {
  color: #fff;
  background-color: #3c763d;
  border-color: #3c763d;
}
.sl-sb .list-group-item-info {
  color: #31708f;
  background-color: #d9edf7;
}
.sl-sb a.list-group-item-info {
  color: #31708f;
}
.sl-sb a.list-group-item-info .list-group-item-heading {
  color: inherit;
}
.sl-sb a.list-group-item-info:hover,
.sl-sb a.list-group-item-info:focus {
  color: #31708f;
  background-color: #c4e3f3;
}
.sl-sb a.list-group-item-info.active,
.sl-sb a.list-group-item-info.active:hover,
.sl-sb a.list-group-item-info.active:focus {
  color: #fff;
  background-color: #31708f;
  border-color: #31708f;
}
.sl-sb .list-group-item-warning {
  color: #8a6d3b;
  background-color: #fcf8e3;
}
.sl-sb a.list-group-item-warning {
  color: #8a6d3b;
}
.sl-sb a.list-group-item-warning .list-group-item-heading {
  color: inherit;
}
.sl-sb a.list-group-item-warning:hover,
.sl-sb a.list-group-item-warning:focus {
  color: #8a6d3b;
  background-color: #faf2cc;
}
.sl-sb a.list-group-item-warning.active,
.sl-sb a.list-group-item-warning.active:hover,
.sl-sb a.list-group-item-warning.active:focus {
  color: #fff;
  background-color: #8a6d3b;
  border-color: #8a6d3b;
}
.sl-sb .list-group-item-danger {
  color: #a94442;
  background-color: #f2dede;
}
.sl-sb a.list-group-item-danger {
  color: #a94442;
}
.sl-sb a.list-group-item-danger .list-group-item-heading {
  color: inherit;
}
.sl-sb a.list-group-item-danger:hover,
.sl-sb a.list-group-item-danger:focus {
  color: #a94442;
  background-color: #ebcccc;
}
.sl-sb a.list-group-item-danger.active,
.sl-sb a.list-group-item-danger.active:hover,
.sl-sb a.list-group-item-danger.active:focus {
  color: #fff;
  background-color: #a94442;
  border-color: #a94442;
}
.sl-sb .list-group-item-heading {
  margin-top: 0;
  margin-bottom: 5px;
}
.sl-sb .list-group-item-text {
  margin-bottom: 0;
  line-height: 1.3;
}
.sl-sb .panel {
  margin-bottom: 20px;
  background-color: #fff;
  border: 1px solid transparent;
  border-radius: 4px;
  -webkit-box-shadow: 0 1px 1px rgba(0, 0, 0, .05);
          box-shadow: 0 1px 1px rgba(0, 0, 0, .05);
}
.sl-sb .panel-body {
  padding: 15px;
}
.sl-sb .panel-heading {
  padding: 10px 15px;
  border-bottom: 1px solid transparent;
  border-top-left-radius: 3px;
  border-top-right-radius: 3px;
}
.sl-sb .panel-heading > .dropdown .dropdown-toggle {
  color: inherit;
}
.sl-sb .panel-title {
  margin-top: 0;
  margin-bottom: 0;
  font-size: 16px;
  color: inherit;
}
.sl-sb .panel-title > a {
  color: inherit;
}
.sl-sb .panel-footer {
  padding: 10px 15px;
  background-color: #f5f5f5;
  border-top: 1px solid #ddd;
  border-bottom-right-radius: 3px;
  border-bottom-left-radius: 3px;
}
.sl-sb .panel > .list-group {
  margin-bottom: 0;
}
.sl-sb .panel > .list-group .list-group-item {
  border-width: 1px 0;
  border-radius: 0;
}
.sl-sb .panel > .list-group:first-child .list-group-item:first-child {
  border-top: 0;
  border-top-left-radius: 3px;
  border-top-right-radius: 3px;
}
.sl-sb .panel > .list-group:last-child .list-group-item:last-child {
  border-bottom: 0;
  border-bottom-right-radius: 3px;
  border-bottom-left-radius: 3px;
}
.sl-sb .panel-heading + .list-group .list-group-item:first-child {
  border-top-width: 0;
}
.sl-sb .panel > .table,
.sl-sb .panel > .table-responsive > .table {
  margin-bottom: 0;
}
.sl-sb .panel > .table:first-child,
.sl-sb .panel > .table-responsive:first-child > .table:first-child {
  border-top-left-radius: 3px;
  border-top-right-radius: 3px;
}
.sl-sb .panel > .table:first-child > thead:first-child > tr:first-child td:first-child,
.sl-sb .panel > .table-responsive:first-child > .table:first-child > thead:first-child > tr:first-child td:first-child,
.sl-sb .panel > .table:first-child > tbody:first-child > tr:first-child td:first-child,
.sl-sb .panel > .table-responsive:first-child > .table:first-child > tbody:first-child > tr:first-child td:first-child,
.sl-sb .panel > .table:first-child > thead:first-child > tr:first-child th:first-child,
.sl-sb .panel > .table-responsive:first-child > .table:first-child > thead:first-child > tr:first-child th:first-child,
.sl-sb .panel > .table:first-child > tbody:first-child > tr:first-child th:first-child,
.sl-sb .panel > .table-responsive:first-child > .table:first-child > tbody:first-child > tr:first-child th:first-child {
  border-top-left-radius: 3px;
}
.sl-sb .panel > .table:first-child > thead:first-child > tr:first-child td:last-child,
.sl-sb .panel > .table-responsive:first-child > .table:first-child > thead:first-child > tr:first-child td:last-child,
.sl-sb .panel > .table:first-child > tbody:first-child > tr:first-child td:last-child,
.sl-sb .panel > .table-responsive:first-child > .table:first-child > tbody:first-child > tr:first-child td:last-child,
.sl-sb .panel > .table:first-child > thead:first-child > tr:first-child th:last-child,
.sl-sb .panel > .table-responsive:first-child > .table:first-child > thead:first-child > tr:first-child th:last-child,
.sl-sb .panel > .table:first-child > tbody:first-child > tr:first-child th:last-child,
.sl-sb .panel > .table-responsive:first-child > .table:first-child > tbody:first-child > tr:first-child th:last-child {
  border-top-right-radius: 3px;
}
.sl-sb .panel > .table:last-child,
.sl-sb .panel > .table-responsive:last-child > .table:last-child {
  border-bottom-right-radius: 3px;
  border-bottom-left-radius: 3px;
}
.sl-sb .panel > .table:last-child > tbody:last-child > tr:last-child td:first-child,
.sl-sb .panel > .table-responsive:last-child > .table:last-child > tbody:last-child > tr:last-child td:first-child,
.sl-sb .panel > .table:last-child > tfoot:last-child > tr:last-child td:first-child,
.sl-sb .panel > .table-responsive:last-child > .table:last-child > tfoot:last-child > tr:last-child td:first-child,
.sl-sb .panel > .table:last-child > tbody:last-child > tr:last-child th:first-child,
.sl-sb .panel > .table-responsive:last-child > .table:last-child > tbody:last-child > tr:last-child th:first-child,
.sl-sb .panel > .table:last-child > tfoot:last-child > tr:last-child th:first-child,
.sl-sb .panel > .table-responsive:last-child > .table:last-child > tfoot:last-child > tr:last-child th:first-child {
  border-bottom-left-radius: 3px;
}
.sl-sb .panel > .table:last-child > tbody:last-child > tr:last-child td:last-child,
.sl-sb .panel > .table-responsive:last-child > .table:last-child > tbody:last-child > tr:last-child td:last-child,
.sl-sb .panel > .table:last-child > tfoot:last-child > tr:last-child td:last-child,
.sl-sb .panel > .table-responsive:last-child > .table:last-child > tfoot:last-child > tr:last-child td:last-child,
.sl-sb .panel > .table:last-child > tbody:last-child > tr:last-child th:last-child,
.sl-sb .panel > .table-responsive:last-child > .table:last-child > tbody:last-child > tr:last-child th:last-child,
.sl-sb .panel > .table:last-child > tfoot:last-child > tr:last-child th:last-child,
.sl-sb .panel > .table-responsive:last-child > .table:last-child > tfoot:last-child > tr:last-child th:last-child {
  border-bottom-right-radius: 3px;
}
.sl-sb .panel > .panel-body + .table,
.sl-sb .panel > .panel-body + .table-responsive {
  border-top: 1px solid #ddd;
}
.sl-sb .panel > .table > tbody:first-child > tr:first-child th,
.sl-sb .panel > .table > tbody:first-child > tr:first-child td {
  border-top: 0;
}
.sl-sb .panel > .table-bordered,
.sl-sb .panel > .table-responsive > .table-bordered {
  border: 0;
}
.sl-sb .panel > .table-bordered > thead > tr > th:first-child,
.sl-sb .panel > .table-responsive > .table-bordered > thead > tr > th:first-child,
.sl-sb .panel > .table-bordered > tbody > tr > th:first-child,
.sl-sb .panel > .table-responsive > .table-bordered > tbody > tr > th:first-child,
.sl-sb .panel > .table-bordered > tfoot > tr > th:first-child,
.sl-sb .panel > .table-responsive > .table-bordered > tfoot > tr > th:first-child,
.sl-sb .panel > .table-bordered > thead > tr > td:first-child,
.sl-sb .panel > .table-responsive > .table-bordered > thead > tr > td:first-child,
.sl-sb .panel > .table-bordered > tbody > tr > td:first-child,
.sl-sb .panel > .table-responsive > .table-bordered > tbody > tr > td:first-child,
.sl-sb .panel > .table-bordered > tfoot > tr > td:first-child,
.sl-sb .panel > .table-responsive > .table-bordered > tfoot > tr > td:first-child {
  border-left: 0;
}
.sl-sb .panel > .table-bordered > thead > tr > th:last-child,
.sl-sb .panel > .table-responsive > .table-bordered > thead > tr > th:last-child,
.sl-sb .panel > .table-bordered > tbody > tr > th:last-child,
.sl-sb .panel > .table-responsive > .table-bordered > tbody > tr > th:last-child,
.sl-sb .panel > .table-bordered > tfoot > tr > th:last-child,
.sl-sb .panel > .table-responsive > .table-bordered > tfoot > tr > th:last-child,
.sl-sb .panel > .table-bordered > thead > tr > td:last-child,
.sl-sb .panel > .table-responsive > .table-bordered > thead > tr > td:last-child,
.sl-sb .panel > .table-bordered > tbody > tr > td:last-child,
.sl-sb .panel > .table-responsive > .table-bordered > tbody > tr > td:last-child,
.sl-sb .panel > .table-bordered > tfoot > tr > td:last-child,
.sl-sb .panel > .table-responsive > .table-bordered > tfoot > tr > td:last-child {
  border-right: 0;
}
.sl-sb .panel > .table-bordered > thead > tr:first-child > td,
.sl-sb .panel > .table-responsive > .table-bordered > thead > tr:first-child > td,
.sl-sb .panel > .table-bordered > tbody > tr:first-child > td,
.sl-sb .panel > .table-responsive > .table-bordered > tbody > tr:first-child > td,
.sl-sb .panel > .table-bordered > thead > tr:first-child > th,
.sl-sb .panel > .table-responsive > .table-bordered > thead > tr:first-child > th,
.sl-sb .panel > .table-bordered > tbody > tr:first-child > th,
.sl-sb .panel > .table-responsive > .table-bordered > tbody > tr:first-child > th {
  border-bottom: 0;
}
.sl-sb .panel > .table-bordered > tbody > tr:last-child > td,
.sl-sb .panel > .table-responsive > .table-bordered > tbody > tr:last-child > td,
.sl-sb .panel > .table-bordered > tfoot > tr:last-child > td,
.sl-sb .panel > .table-responsive > .table-bordered > tfoot > tr:last-child > td,
.sl-sb .panel > .table-bordered > tbody > tr:last-child > th,
.sl-sb .panel > .table-responsive > .table-bordered > tbody > tr:last-child > th,
.sl-sb .panel > .table-bordered > tfoot > tr:last-child > th,
.sl-sb .panel > .table-responsive > .table-bordered > tfoot > tr:last-child > th {
  border-bottom: 0;
}
.sl-sb .panel > .table-responsive {
  margin-bottom: 0;
  border: 0;
}
.sl-sb .panel-group {
  margin-bottom: 20px;
}
.sl-sb .panel-group .panel {
  margin-bottom: 0;
  border-radius: 4px;
}
.sl-sb .panel-group .panel + .panel {
  margin-top: 5px;
}
.sl-sb .panel-group .panel-heading {
  border-bottom: 0;
}
.sl-sb .panel-group .panel-heading + .panel-collapse .panel-body {
  border-top: 1px solid #ddd;
}
.sl-sb .panel-group .panel-footer {
  border-top: 0;
}
.sl-sb .panel-group .panel-footer + .panel-collapse .panel-body {
  border-bottom: 1px solid #ddd;
}
.sl-sb .panel-default {
  border-color: #ddd;
}
.sl-sb .panel-default > .panel-heading {
  color: #333;
  background-color: #f5f5f5;
  border-color: #ddd;
}
.sl-sb .panel-default > .panel-heading + .panel-collapse > .panel-body {
  border-top-color: #ddd;
}
.sl-sb .panel-default > .panel-footer + .panel-collapse > .panel-body {
  border-bottom-color: #ddd;
}
.sl-sb .panel-primary {
  border-color: #428bca;
}
.sl-sb .panel-primary > .panel-heading {
  color: #fff;
  background-color: #428bca;
  border-color: #428bca;
}
.sl-sb .panel-primary > .panel-heading + .panel-collapse > .panel-body {
  border-top-color: #428bca;
}
.sl-sb .panel-primary > .panel-footer + .panel-collapse > .panel-body {
  border-bottom-color: #428bca;
}
.sl-sb .panel-success {
  border-color: #d6e9c6;
}
.sl-sb .panel-success > .panel-heading {
  color: #3c763d;
  background-color: #dff0d8;
  border-color: #d6e9c6;
}
.sl-sb .panel-success > .panel-heading + .panel-collapse > .panel-body {
  border-top-color: #d6e9c6;
}
.sl-sb .panel-success > .panel-footer + .panel-collapse > .panel-body {
  border-bottom-color: #d6e9c6;
}
.sl-sb .panel-info {
  border-color: #bce8f1;
}
.sl-sb .panel-info > .panel-heading {
  color: #31708f;
  background-color: #d9edf7;
  border-color: #bce8f1;
}
.sl-sb .panel-info > .panel-heading + .panel-collapse > .panel-body {
  border-top-color: #bce8f1;
}
.sl-sb .panel-info > .panel-footer + .panel-collapse > .panel-body {
  border-bottom-color: #bce8f1;
}
.sl-sb .panel-warning {
  border-color: #faebcc;
}
.sl-sb .panel-warning > .panel-heading {
  color: #8a6d3b;
  background-color: #fcf8e3;
  border-color: #faebcc;
}
.sl-sb .panel-warning > .panel-heading + .panel-collapse > .panel-body {
  border-top-color: #faebcc;
}
.sl-sb .panel-warning > .panel-footer + .panel-collapse > .panel-body {
  border-bottom-color: #faebcc;
}
.sl-sb .panel-danger {
  border-color: #ebccd1;
}
.sl-sb .panel-danger > .panel-heading {
  color: #a94442;
  background-color: #f2dede;
  border-color: #ebccd1;
}
.sl-sb .panel-danger > .panel-heading + .panel-collapse > .panel-body {
  border-top-color: #ebccd1;
}
.sl-sb .panel-danger > .panel-footer + .panel-collapse > .panel-body {
  border-bottom-color: #ebccd1;
}
.sl-sb .embed-responsive {
  position: relative;
  display: block;
  height: 0;
  padding: 0;
  overflow: hidden;
}
.sl-sb .embed-responsive .embed-responsive-item,
.sl-sb .embed-responsive iframe,
.sl-sb .embed-responsive embed,
.sl-sb .embed-responsive object {
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border: 0;
}
.sl-sb .embed-responsive.embed-responsive-16by9 {
  padding-bottom: 56.25%;
}
.sl-sb .embed-responsive.embed-responsive-4by3 {
  padding-bottom: 75%;
}
.sl-sb .well {
  min-height: 20px;
  padding: 19px;
  margin-bottom: 20px;
  background-color: #f5f5f5;
  border: 1px solid #e3e3e3;
  border-radius: 4px;
  -webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, .05);
          box-shadow: inset 0 1px 1px rgba(0, 0, 0, .05);
}
.sl-sb .well blockquote {
  border-color: #ddd;
  border-color: rgba(0, 0, 0, .15);
}
.sl-sb .well-lg {
  padding: 24px;
  border-radius: 6px;
}
.sl-sb .well-sm {
  padding: 9px;
  border-radius: 3px;
}
.sl-sb .close {
  float: right;
  font-size: 21px;
  font-weight: bold;
  line-height: 1;
  color: #000;
  text-shadow: 0 1px 0 #fff;
  filter: alpha(opacity=20);
  opacity: .2;
}
.sl-sb .close:hover,
.sl-sb .close:focus {
  color: #000;
  text-decoration: none;
  cursor: pointer;
  filter: alpha(opacity=50);
  opacity: .5;
}
.sl-sb button.close {
  -webkit-appearance: none;
  padding: 0;
  cursor: pointer;
  background: transparent;
  border: 0;
}
.sl-sb .modal-open {
  overflow: hidden;
}
.sl-sb .modal {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: 1050;
  display: none;
  overflow: auto;
  overflow-y: scroll;
  -webkit-overflow-scrolling: touch;
  outline: 0;
}
.sl-sb .modal.fade .modal-dialog {
  -webkit-transition: -webkit-transform .3s ease-out;
       -o-transition:      -o-transform .3s ease-out;
          transition:         transform .3s ease-out;
  -webkit-transform: translate(0, -25%);
      -ms-transform: translate(0, -25%);
       -o-transform: translate(0, -25%);
          transform: translate(0, -25%);
}
.sl-sb .modal.in .modal-dialog {
  -webkit-transform: translate(0, 0);
      -ms-transform: translate(0, 0);
       -o-transform: translate(0, 0);
          transform: translate(0, 0);
}
.sl-sb .modal-dialog {
  position: relative;
  width: auto;
  margin: 10px;
}
.sl-sb .modal-content {
  position: relative;
  background-color: #fff;
  -webkit-background-clip: padding-box;
          background-clip: padding-box;
  border: 1px solid #999;
  border: 1px solid rgba(0, 0, 0, .2);
  border-radius: 6px;
  outline: 0;
  -webkit-box-shadow: 0 3px 9px rgba(0, 0, 0, .5);
          box-shadow: 0 3px 9px rgba(0, 0, 0, .5);
}
.sl-sb .modal-backdrop {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: 1040;
  background-color: #000;
}
.sl-sb .modal-backdrop.fade {
  filter: alpha(opacity=0);
  opacity: 0;
}
.sl-sb .modal-backdrop.in {
  filter: alpha(opacity=50);
  opacity: .5;
}
.sl-sb .modal-header {
  min-height: 16.42857143px;
  padding: 15px;
  border-bottom: 1px solid #e5e5e5;
}
.sl-sb .modal-header .close {
  margin-top: -2px;
}
.sl-sb .modal-title {
  margin: 0;
  line-height: 1.42857143;
}
.sl-sb .modal-body {
  position: relative;
  padding: 15px;
}
.sl-sb .modal-footer {
  padding: 15px;
  text-align: right;
  border-top: 1px solid #e5e5e5;
}
.sl-sb .modal-footer .btn + .btn {
  margin-bottom: 0;
  margin-left: 5px;
}
.sl-sb .modal-footer .btn-group .btn + .btn {
  margin-left: -1px;
}
.sl-sb .modal-footer .btn-block + .btn-block {
  margin-left: 0;
}
.sl-sb .modal-scrollbar-measure {
  position: absolute;
  top: -9999px;
  width: 50px;
  height: 50px;
  overflow: scroll;
}
@media (min-width: 768px) {
  .sl-sb .modal-dialog {
    width: 600px;
    margin: 30px auto;
  }
  .sl-sb .modal-content {
    -webkit-box-shadow: 0 5px 15px rgba(0, 0, 0, .5);
            box-shadow: 0 5px 15px rgba(0, 0, 0, .5);
  }
  .sl-sb .modal-sm {
    width: 300px;
  }
}
@media (min-width: 992px) {
  .sl-sb .modal-lg {
    width: 900px;
  }
}
.sl-sb .tooltip {
  position: absolute;
  z-index: 1070;
  display: block;
  font-size: 12px;
  line-height: 1.4;
  visibility: visible;
  filter: alpha(opacity=0);
  opacity: 0;
}
.sl-sb .tooltip.in {
  filter: alpha(opacity=90);
  opacity: .9;
}
.sl-sb .tooltip.top {
  padding: 5px 0;
  margin-top: -3px;
}
.sl-sb .tooltip.right {
  padding: 0 5px;
  margin-left: 3px;
}
.sl-sb .tooltip.bottom {
  padding: 5px 0;
  margin-top: 3px;
}
.sl-sb .tooltip.left {
  padding: 0 5px;
  margin-left: -3px;
}
.sl-sb .tooltip-inner {
  max-width: 200px;
  padding: 3px 8px;
  color: #fff;
  text-align: center;
  text-decoration: none;
  background-color: #000;
  border-radius: 4px;
}
.sl-sb .tooltip-arrow {
  position: absolute;
  width: 0;
  height: 0;
  border-color: transparent;
  border-style: solid;
}
.sl-sb .tooltip.top .tooltip-arrow {
  bottom: 0;
  left: 50%;
  margin-left: -5px;
  border-width: 5px 5px 0;
  border-top-color: #000;
}
.sl-sb .tooltip.top-left .tooltip-arrow {
  bottom: 0;
  left: 5px;
  border-width: 5px 5px 0;
  border-top-color: #000;
}
.sl-sb .tooltip.top-right .tooltip-arrow {
  right: 5px;
  bottom: 0;
  border-width: 5px 5px 0;
  border-top-color: #000;
}
.sl-sb .tooltip.right .tooltip-arrow {
  top: 50%;
  left: 0;
  margin-top: -5px;
  border-width: 5px 5px 5px 0;
  border-right-color: #000;
}
.sl-sb .tooltip.left .tooltip-arrow {
  top: 50%;
  right: 0;
  margin-top: -5px;
  border-width: 5px 0 5px 5px;
  border-left-color: #000;
}
.sl-sb .tooltip.bottom .tooltip-arrow {
  top: 0;
  left: 50%;
  margin-left: -5px;
  border-width: 0 5px 5px;
  border-bottom-color: #000;
}
.sl-sb .tooltip.bottom-left .tooltip-arrow {
  top: 0;
  left: 5px;
  border-width: 0 5px 5px;
  border-bottom-color: #000;
}
.sl-sb .tooltip.bottom-right .tooltip-arrow {
  top: 0;
  right: 5px;
  border-width: 0 5px 5px;
  border-bottom-color: #000;
}
.sl-sb .popover {
  position: absolute;
  top: 0;
  left: 0;
  z-index: 1060;
  display: none;
  max-width: 276px;
  padding: 1px;
  text-align: left;
  white-space: normal;
  background-color: #fff;
  -webkit-background-clip: padding-box;
          background-clip: padding-box;
  border: 1px solid #ccc;
  border: 1px solid rgba(0, 0, 0, .2);
  border-radius: 6px;
  -webkit-box-shadow: 0 5px 10px rgba(0, 0, 0, .2);
          box-shadow: 0 5px 10px rgba(0, 0, 0, .2);
}
.sl-sb .popover.top {
  margin-top: -10px;
}
.sl-sb .popover.right {
  margin-left: 10px;
}
.sl-sb .popover.bottom {
  margin-top: 10px;
}
.sl-sb .popover.left {
  margin-left: -10px;
}
.sl-sb .popover-title {
  padding: 8px 14px;
  margin: 0;
  font-size: 14px;
  font-weight: normal;
  line-height: 18px;
  background-color: #f7f7f7;
  border-bottom: 1px solid #ebebeb;
  border-radius: 5px 5px 0 0;
}
.sl-sb .popover-content {
  padding: 9px 14px;
}
.sl-sb .popover > .arrow,
.sl-sb .popover > .arrow:after {
  position: absolute;
  display: block;
  width: 0;
  height: 0;
  border-color: transparent;
  border-style: solid;
}
.sl-sb .popover > .arrow {
  border-width: 11px;
}
.sl-sb .popover > .arrow:after {
  content: "";
  border-width: 10px;
}
.sl-sb .popover.top > .arrow {
  bottom: -11px;
  left: 50%;
  margin-left: -11px;
  border-top-color: #999;
  border-top-color: rgba(0, 0, 0, .25);
  border-bottom-width: 0;
}
.sl-sb .popover.top > .arrow:after {
  bottom: 1px;
  margin-left: -10px;
  content: " ";
  border-top-color: #fff;
  border-bottom-width: 0;
}
.sl-sb .popover.right > .arrow {
  top: 50%;
  left: -11px;
  margin-top: -11px;
  border-right-color: #999;
  border-right-color: rgba(0, 0, 0, .25);
  border-left-width: 0;
}
.sl-sb .popover.right > .arrow:after {
  bottom: -10px;
  left: 1px;
  content: " ";
  border-right-color: #fff;
  border-left-width: 0;
}
.sl-sb .popover.bottom > .arrow {
  top: -11px;
  left: 50%;
  margin-left: -11px;
  border-top-width: 0;
  border-bottom-color: #999;
  border-bottom-color: rgba(0, 0, 0, .25);
}
.sl-sb .popover.bottom > .arrow:after {
  top: 1px;
  margin-left: -10px;
  content: " ";
  border-top-width: 0;
  border-bottom-color: #fff;
}
.sl-sb .popover.left > .arrow {
  top: 50%;
  right: -11px;
  margin-top: -11px;
  border-right-width: 0;
  border-left-color: #999;
  border-left-color: rgba(0, 0, 0, .25);
}
.sl-sb .popover.left > .arrow:after {
  right: 1px;
  bottom: -10px;
  content: " ";
  border-right-width: 0;
  border-left-color: #fff;
}
.sl-sb .carousel {
  position: relative;
}
.sl-sb .carousel-inner {
  position: relative;
  width: 100%;
  overflow: hidden;
}
.sl-sb .carousel-inner > .item {
  position: relative;
  display: none;
  -webkit-transition: .6s ease-in-out left;
       -o-transition: .6s ease-in-out left;
          transition: .6s ease-in-out left;
}
.sl-sb .carousel-inner > .item > img,
.sl-sb .carousel-inner > .item > a > img {
  line-height: 1;
}
.sl-sb .carousel-inner > .active,
.sl-sb .carousel-inner > .next,
.sl-sb .carousel-inner > .prev {
  display: block;
}
.sl-sb .carousel-inner > .active {
  left: 0;
}
.sl-sb .carousel-inner > .next,
.sl-sb .carousel-inner > .prev {
  position: absolute;
  top: 0;
  width: 100%;
}
.sl-sb .carousel-inner > .next {
  left: 100%;
}
.sl-sb .carousel-inner > .prev {
  left: -100%;
}
.sl-sb .carousel-inner > .next.left,
.sl-sb .carousel-inner > .prev.right {
  left: 0;
}
.sl-sb .carousel-inner > .active.left {
  left: -100%;
}
.sl-sb .carousel-inner > .active.right {
  left: 100%;
}
.sl-sb .carousel-control {
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  width: 15%;
  font-size: 20px;
  color: #fff;
  text-align: center;
  text-shadow: 0 1px 2px rgba(0, 0, 0, .6);
  filter: alpha(opacity=50);
  opacity: .5;
}
.sl-sb .carousel-control.left {
  background-image: -webkit-linear-gradient(left, color-stop(rgba(0, 0, 0, .5) 0%), color-stop(rgba(0, 0, 0, .0001) 100%));
  background-image:      -o-linear-gradient(left, rgba(0, 0, 0, .5) 0%, rgba(0, 0, 0, .0001) 100%);
  background-image: -webkit-gradient(linear, left top, right top, from(rgba(0, 0, 0, .5)), to(rgba(0, 0, 0, .0001)));
  background-image: -webkit-linear-gradient(left, rgba(0, 0, 0, .5) 0%, rgba(0, 0, 0, .0001) 100%);
  background-image:         linear-gradient(to right, rgba(0, 0, 0, .5) 0%, rgba(0, 0, 0, .0001) 100%);
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#80000000', endColorstr='#00000000', GradientType=1);
  background-repeat: repeat-x;
}
.sl-sb .carousel-control.right {
  right: 0;
  left: auto;
  background-image: -webkit-linear-gradient(left, color-stop(rgba(0, 0, 0, .0001) 0%), color-stop(rgba(0, 0, 0, .5) 100%));
  background-image:      -o-linear-gradient(left, rgba(0, 0, 0, .0001) 0%, rgba(0, 0, 0, .5) 100%);
  background-image: -webkit-gradient(linear, left top, right top, from(rgba(0, 0, 0, .0001)), to(rgba(0, 0, 0, .5)));
  background-image: -webkit-linear-gradient(left, rgba(0, 0, 0, .0001) 0%, rgba(0, 0, 0, .5) 100%);
  background-image:         linear-gradient(to right, rgba(0, 0, 0, .0001) 0%, rgba(0, 0, 0, .5) 100%);
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#00000000', endColorstr='#80000000', GradientType=1);
  background-repeat: repeat-x;
}
.sl-sb .carousel-control:hover,
.sl-sb .carousel-control:focus {
  color: #fff;
  text-decoration: none;
  filter: alpha(opacity=90);
  outline: 0;
  opacity: .9;
}
.sl-sb .carousel-control .icon-prev,
.sl-sb .carousel-control .icon-next,
.sl-sb .carousel-control .glyphicon-chevron-left,
.sl-sb .carousel-control .glyphicon-chevron-right {
  position: absolute;
  top: 50%;
  z-index: 5;
  display: inline-block;
}
.sl-sb .carousel-control .icon-prev,
.sl-sb .carousel-control .glyphicon-chevron-left {
  left: 50%;
  margin-left: -10px;
}
.sl-sb .carousel-control .icon-next,
.sl-sb .carousel-control .glyphicon-chevron-right {
  right: 50%;
  margin-right: -10px;
}
.sl-sb .carousel-control .icon-prev,
.sl-sb .carousel-control .icon-next {
  width: 20px;
  height: 20px;
  margin-top: -10px;
  font-family: serif;
}
.sl-sb .carousel-control .icon-prev:before {
  content: '\2039';
}
.sl-sb .carousel-control .icon-next:before {
  content: '\203a';
}
.sl-sb .carousel-indicators {
  position: absolute;
  bottom: 10px;
  left: 50%;
  z-index: 15;
  width: 60%;
  padding-left: 0;
  margin-left: -30%;
  text-align: center;
  list-style: none;
}
.sl-sb .carousel-indicators li {
  display: inline-block;
  width: 10px;
  height: 10px;
  margin: 1px;
  text-indent: -999px;
  cursor: pointer;
  background-color: #000 \9;
  background-color: rgba(0, 0, 0, 0);
  border: 1px solid #fff;
  border-radius: 10px;
}
.sl-sb .carousel-indicators .active {
  width: 12px;
  height: 12px;
  margin: 0;
  background-color: #fff;
}
.sl-sb .carousel-caption {
  position: absolute;
  right: 15%;
  bottom: 20px;
  left: 15%;
  z-index: 10;
  padding-top: 20px;
  padding-bottom: 20px;
  color: #fff;
  text-align: center;
  text-shadow: 0 1px 2px rgba(0, 0, 0, .6);
}
.sl-sb .carousel-caption .btn {
  text-shadow: none;
}
@media screen and (min-width: 768px) {
  .sl-sb .carousel-control .glyphicon-chevron-left,
  .sl-sb .carousel-control .glyphicon-chevron-right,
  .sl-sb .carousel-control .icon-prev,
  .sl-sb .carousel-control .icon-next {
    width: 30px;
    height: 30px;
    margin-top: -15px;
    font-size: 30px;
  }
  .sl-sb .carousel-control .glyphicon-chevron-left,
  .sl-sb .carousel-control .icon-prev {
    margin-left: -15px;
  }
  .sl-sb .carousel-control .glyphicon-chevron-right,
  .sl-sb .carousel-control .icon-next {
    margin-right: -15px;
  }
  .sl-sb .carousel-caption {
    right: 20%;
    left: 20%;
    padding-bottom: 30px;
  }
  .sl-sb .carousel-indicators {
    bottom: 20px;
  }
}
.sl-sb .clearfix:before,
.sl-sb .clearfix:after,
.sl-sb .dl-horizontal dd:before,
.sl-sb .dl-horizontal dd:after,
.sl-sb .container:before,
.sl-sb .container:after,
.sl-sb .container-fluid:before,
.sl-sb .container-fluid:after,
.sl-sb .row:before,
.sl-sb .row:after,
.sl-sb .form-horizontal .form-group:before,
.sl-sb .form-horizontal .form-group:after,
.sl-sb .btn-toolbar:before,
.sl-sb .btn-toolbar:after,
.sl-sb .btn-group-vertical > .btn-group:before,
.sl-sb .btn-group-vertical > .btn-group:after,
.sl-sb .nav:before,
.sl-sb .nav:after,
.sl-sb .navbar:before,
.sl-sb .navbar:after,
.sl-sb .navbar-header:before,
.sl-sb .navbar-header:after,
.sl-sb .navbar-collapse:before,
.sl-sb .navbar-collapse:after,
.sl-sb .pager:before,
.sl-sb .pager:after,
.sl-sb .panel-body:before,
.sl-sb .panel-body:after,
.sl-sb .modal-footer:before,
.sl-sb .modal-footer:after {
  display: table;
  content: " ";
}
.sl-sb .clearfix:after,
.sl-sb .dl-horizontal dd:after,
.sl-sb .container:after,
.sl-sb .container-fluid:after,
.sl-sb .row:after,
.sl-sb .form-horizontal .form-group:after,
.sl-sb .btn-toolbar:after,
.sl-sb .btn-group-vertical > .btn-group:after,
.sl-sb .nav:after,
.sl-sb .navbar:after,
.sl-sb .navbar-header:after,
.sl-sb .navbar-collapse:after,
.sl-sb .pager:after,
.sl-sb .panel-body:after,
.sl-sb .modal-footer:after {
  clear: both;
}
.sl-sb .center-block {
  display: block;
  margin-right: auto;
  margin-left: auto;
}
.sl-sb .pull-right {
  float: right !important;
}
.sl-sb .pull-left {
  float: left !important;
}
.sl-sb .hide {
  display: none !important;
}
.sl-sb .show {
  display: block !important;
}
.sl-sb .invisible {
  visibility: hidden;
}
.sl-sb .text-hide {
  font: 0/0 a;
  color: transparent;
  text-shadow: none;
  background-color: transparent;
  border: 0;
}
.sl-sb .hidden {
  display: none !important;
  visibility: hidden !important;
}
.sl-sb .affix {
  position: fixed;
}
@-ms-viewport {
  width: device-width;
}
.sl-sb .visible-xs,
.sl-sb .visible-sm,
.sl-sb .visible-md,
.sl-sb .visible-lg {
  display: none !important;
}
.sl-sb .visible-xs-block,
.sl-sb .visible-xs-inline,
.sl-sb .visible-xs-inline-block,
.sl-sb .visible-sm-block,
.sl-sb .visible-sm-inline,
.sl-sb .visible-sm-inline-block,
.sl-sb .visible-md-block,
.sl-sb .visible-md-inline,
.sl-sb .visible-md-inline-block,
.sl-sb .visible-lg-block,
.sl-sb .visible-lg-inline,
.sl-sb .visible-lg-inline-block {
  display: none !important;
}
@media (max-width: 767px) {
  .sl-sb .visible-xs {
    display: block !important;
  }
  .sl-sb table.visible-xs {
    display: table;
  }
  .sl-sb tr.visible-xs {
    display: table-row !important;
  }
  .sl-sb th.visible-xs,
  .sl-sb td.visible-xs {
    display: table-cell !important;
  }
}
@media (max-width: 767px) {
  .sl-sb .visible-xs-block {
    display: block !important;
  }
}
@media (max-width: 767px) {
  .sl-sb .visible-xs-inline {
    display: inline !important;
  }
}
@media (max-width: 767px) {
  .sl-sb .visible-xs-inline-block {
    display: inline-block !important;
  }
}
@media (min-width: 768px) and (max-width: 991px) {
  .sl-sb .visible-sm {
    display: block !important;
  }
  .sl-sb table.visible-sm {
    display: table;
  }
  .sl-sb tr.visible-sm {
    display: table-row !important;
  }
  .sl-sb th.visible-sm,
  .sl-sb td.visible-sm {
    display: table-cell !important;
  }
}
@media (min-width: 768px) and (max-width: 991px) {
  .sl-sb .visible-sm-block {
    display: block !important;
  }
}
@media (min-width: 768px) and (max-width: 991px) {
  .sl-sb .visible-sm-inline {
    display: inline !important;
  }
}
@media (min-width: 768px) and (max-width: 991px) {
  .sl-sb .visible-sm-inline-block {
    display: inline-block !important;
  }
}
@media (min-width: 992px) and (max-width: 1199px) {
  .sl-sb .visible-md {
    display: block !important;
  }
  .sl-sb table.visible-md {
    display: table;
  }
  .sl-sb tr.visible-md {
    display: table-row !important;
  }
  .sl-sb th.visible-md,
  .sl-sb td.visible-md {
    display: table-cell !important;
  }
}
@media (min-width: 992px) and (max-width: 1199px) {
  .sl-sb .visible-md-block {
    display: block !important;
  }
}
@media (min-width: 992px) and (max-width: 1199px) {
  .sl-sb .visible-md-inline {
    display: inline !important;
  }
}
@media (min-width: 992px) and (max-width: 1199px) {
  .sl-sb .visible-md-inline-block {
    display: inline-block !important;
  }
}
@media (min-width: 1200px) {
  .sl-sb .visible-lg {
    display: block !important;
  }
  .sl-sb table.visible-lg {
    display: table;
  }
  .sl-sb tr.visible-lg {
    display: table-row !important;
  }
  .sl-sb th.visible-lg,
  .sl-sb td.visible-lg {
    display: table-cell !important;
  }
}
@media (min-width: 1200px) {
  .sl-sb .visible-lg-block {
    display: block !important;
  }
}
@media (min-width: 1200px) {
  .sl-sb .visible-lg-inline {
    display: inline !important;
  }
}
@media (min-width: 1200px) {
  .sl-sb .visible-lg-inline-block {
    display: inline-block !important;
  }
}
@media (max-width: 767px) {
  .sl-sb .hidden-xs {
    display: none !important;
  }
}
@media (min-width: 768px) and (max-width: 991px) {
  .sl-sb .hidden-sm {
    display: none !important;
  }
}
@media (min-width: 992px) and (max-width: 1199px) {
  .sl-sb .hidden-md {
    display: none !important;
  }
}
@media (min-width: 1200px) {
  .sl-sb .hidden-lg {
    display: none !important;
  }
}
.sl-sb .visible-print {
  display: none !important;
}
@media print {
  .sl-sb .visible-print {
    display: block !important;
  }
  .sl-sb table.visible-print {
    display: table;
  }
  .sl-sb tr.visible-print {
    display: table-row !important;
  }
  .sl-sb th.visible-print,
  .sl-sb td.visible-print {
    display: table-cell !important;
  }
}
.sl-sb .visible-print-block {
  display: none !important;
}
@media print {
  .sl-sb .visible-print-block {
    display: block !important;
  }
}
.sl-sb .visible-print-inline {
  display: none !important;
}
@media print {
  .sl-sb .visible-print-inline {
    display: inline !important;
  }
}
.sl-sb .visible-print-inline-block {
  display: none !important;
}
@media print {
  .sl-sb .visible-print-inline-block {
    display: inline-block !important;
  }
}
@media print {
  .sl-sb .hidden-print {
    display: none !important;
  }
}




/* table sortable */



table.sortable span.sign {
    display: block;
    position: absolute;
    top: 50%;
    right: 5px;
    font-size: 12px;
    margin-top: -10px;
    color: #bfbfc1;
}

table.sortable span.arrow, span.reversed {
    border-style: solid;
    border-width: 5px;
    font-size: 0;
    border-color: #ccc transparent transparent transparent;
    line-height: 0;
    height: 0;
    width: 0;
    margin-top: -2px;
}

    table.sortable span.arrow.up {
        border-color: transparent transparent #ccc transparent;
        margin-top: -7px;
    }

table.sortable span.reversed {
    border-color: transparent transparent #ccc transparent;
    margin-top: -7px;
}

    table.sortable span.reversed.up {
        border-color: #ccc transparent transparent transparent;
        margin-top: -2px;
    }



table.sortable span.az:before {
    content: "a .. z";
}

table.sortable span.az.up:before {
    content: "z .. a";
}

table.sortable span.AZ:before {
    content: "A .. Z";
}

table.sortable span.AZ.up:before {
    content: "Z .. A";
}

table.sortable span._19:before {
    content: "1 .. 9";
}

table.sortable span._19.up:before {
    content: "9 .. 1";
}

table.sortable span.month:before {
    content: "jan .. dec";
}

table.sortable span.month.up:before {
    content: "dec .. jan";
}

table.sortable thead th:not([data-defaultsort=disabled]) {
    cursor: pointer;
    position: relative;
    top: 0;
    left: 0;
}

table.sortable thead th:hover:not([data-defaultsort=disabled]) {
    background: #efefef;
}

table.sortable thead th div.mozilla {
    position: relative;
}

/* END table sortable */
