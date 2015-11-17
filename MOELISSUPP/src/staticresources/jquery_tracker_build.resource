(function ($) {
    $.extend({
        tablesorter: new(function () {
            var parsers = [],
                widgets = [];
            this.defaults = {
                cssHeader: "header",
                cssAsc: "headerSortUp",
                cssDesc: "headerSortDown",
                sortInitialOrder: "asc",
                sortMultiSortKey: null,
                sortForce: null,
                sortAppend: null,
                textExtraction: "simple",
                parsers: {},
                widgets: [],
                widgetZebra: {
                    css: ["even", "odd"]
                },
                headers: {},
                widthFixed: false,
                cancelSelection: true,
                sortList: [],
                headerList: [],
                dateFormat: "us",
                decimal: ".",
                debug: false
            };

            function benchmark(s, d) {
                log(s + "," + ((new Date).getTime() - d.getTime()) + "ms")
            }
            this.benchmark = benchmark;

            function log(s) {
                if (typeof console != "undefined" && typeof console.debug != "undefined") console.log(s);
                else alert(s)
            }
            function buildParserCache(table, $headers) {
                if (table.config.debug) var parsersDebug = "";
                var rows = table.tBodies[0].rows;
                if (table.tBodies[0].rows[0]) {
                    var list = [],
                        cells = rows[0].cells,
                        l = cells.length;
                    for (var i = 0; i < l; i++) {
                        var p = false;
                        if ($.metadata && $($headers[i]).metadata() && $($headers[i]).metadata().sorter) p = getParserById($($headers[i]).metadata().sorter);
                        else if (table.config.headers[i] && table.config.headers[i].sorter) p = getParserById(table.config.headers[i].sorter);
                        if (!p) p = detectParserForColumn(table, cells[i]);
                        if (table.config.debug) parsersDebug += "column:" + i + " parser:" + p.id + "\n";
                        list.push(p)
                    }
                }
                if (table.config.debug) log(parsersDebug);
                return list
            }
            function detectParserForColumn(table, node) {
                var l = parsers.length;
                for (var i = 1; i < l; i++) if (parsers[i].is($.trim(getElementText(table.config, node)), table, node)) return parsers[i];
                return parsers[0]
            }
            function getParserById(name) {
                var l = parsers.length;
                for (var i = 0; i < l; i++) if (parsers[i].id.toLowerCase() == name.toLowerCase()) return parsers[i];
                return false
            }
            function buildCache(table) {
                if (table.config.debug) var cacheTime = new Date;
                var totalRows = table.tBodies[0] && table.tBodies[0].rows.length || 0,
                    totalCells = table.tBodies[0].rows[0] && table.tBodies[0].rows[0].cells.length || 0,
                    parsers = table.config.parsers,
                    cache = {
                    row: [],
                    normalized: []
                };
                for (var i = 0; i < totalRows; ++i) {
                    var c = table.tBodies[0].rows[i],
                        cols = [];
                    cache.row.push($(c));
                    for (var j = 0; j < totalCells; ++j) cols.push(parsers[j].format(getElementText(table.config, c.cells[j]), table, c.cells[j]));
                    cols.push(i);
                    cache.normalized.push(cols);
                    cols = null
                }
                if (table.config.debug) benchmark("Building cache for " + totalRows + " rows:", cacheTime);
                return cache
            }
            function getElementText(config, node) {
                if (!node) return "";
                var t = "";
                if (config.textExtraction == "simple") if (node.childNodes[0] && node.childNodes[0].hasChildNodes()) t = node.childNodes[0].innerHTML;
                else t = node.innerHTML;
                else if (typeof config.textExtraction == "function") t = config.textExtraction(node);
                else t = $(node).text();
                return t
            }
            function appendToTable(table, cache) {
                if (table.config.debug) var appendTime = new Date;
                var c = cache,
                    r = c.row,
                    n = c.normalized,
                    totalRows = n.length,
                    checkCell = n[0].length - 1,
                    tableBody = $(table.tBodies[0]),
                    rows = [];
                for (var i = 0; i < totalRows; i++) {
                    rows.push(r[n[i][checkCell]]);
                    if (!table.config.appender) {
                        var o = r[n[i][checkCell]];
                        var l = o.length;
                        for (var j = 0; j < l; j++) tableBody[0].appendChild(o[j])
                    }
                }
                if (table.config.appender) table.config.appender(table, rows);
                rows = null;
                if (table.config.debug) benchmark("Rebuilt table:", appendTime);
                applyWidget(table);
                setTimeout(function () {
                    $(table).trigger("sortEnd")
                }, 0)
            }
            function buildHeaders(table) {
                if (table.config.debug) var time = new Date;
                var meta = $.metadata ? true : false,
                    tableHeadersRows = [];
                for (var i = 0; i < table.tHead.rows.length; i++) tableHeadersRows[i] = 0;
                $tableHeaders = $("thead th", table);
                $tableHeaders.each(function (index) {
                    this.count = 0;
                    this.column = index;
                    this.order = formatSortingOrder(table.config.sortInitialOrder);
                    if (checkHeaderMetadata(this) || checkHeaderOptions(table, index)) this.sortDisabled = true;
                    if (!this.sortDisabled) $(this).addClass(table.config.cssHeader);
                    table.config.headerList[index] =
                    this
                });
                if (table.config.debug) {
                    benchmark("Built headers:", time);
                    log($tableHeaders)
                }
                return $tableHeaders
            }
            function checkCellColSpan(table, rows, row) {
                var arr = [],
                    r = table.tHead.rows,
                    c = r[row].cells;
                for (var i = 0; i < c.length; i++) {
                    var cell = c[i];
                    if (cell.colSpan > 1) arr = arr.concat(checkCellColSpan(table, headerArr, row++));
                    else if (table.tHead.length == 1 || cell.rowSpan > 1 || !r[row + 1]) arr.push(cell)
                }
                return arr
            }
            function checkHeaderMetadata(cell) {
                if ($.metadata && $(cell).metadata().sorter === false) return true;
                return false
            }
            function checkHeaderOptions(table, i) {
                if (table.config.headers[i] && table.config.headers[i].sorter === false) return true;
                return false
            }
            function applyWidget(table) {
                var c = table.config.widgets;
                var l = c.length;
                for (var i = 0; i < l; i++) getWidgetById(c[i]).format(table)
            }
            function getWidgetById(name) {
                var l = widgets.length;
                for (var i = 0; i < l; i++) if (widgets[i].id.toLowerCase() == name.toLowerCase()) return widgets[i]
            }
            function formatSortingOrder(v) {
                if (typeof v != "Number") i = v.toLowerCase() == "desc" ? 1 : 0;
                else i = v == (0 || 1) ? v : 0;
                return i
            }
            function isValueInArray(v, a) {
                var l =
                a.length;
                for (var i = 0; i < l; i++) if (a[i][0] == v) return true;
                return false
            }
            function setHeadersCss(table, $headers, list, css) {
                $headers.removeClass(css[0]).removeClass(css[1]);
                var h = [];
                $headers.each(function (offset) {
                    if (!this.sortDisabled) h[this.column] = $(this)
                });
                var l = list.length;
                for (var i = 0; i < l; i++) h[list[i][0]].addClass(css[list[i][1]])
            }
            function fixColumnWidth(table, $headers) {
                var c = table.config;
                if (c.widthFixed) {
                    var colgroup = $("<colgroup>");
                    $("tr:first td", table.tBodies[0]).each(function () {
                        colgroup.append($("<col>").css("width", $(this).width()))
                    });
                    $(table).prepend(colgroup)
                }
            }
            function updateHeaderSortCount(table, sortList) {
                var c = table.config,
                    l = sortList.length;
                for (var i = 0; i < l; i++) {
                    var s = sortList[i],
                        o = c.headerList[s[0]];
                    o.count = s[1];
                    o.count++
                }
            }
            function multisort(table, sortList, cache) {
                if (table.config.debug) var sortTime = new Date;
                var dynamicExp = "var sortWrapper = function(a,b) {",
                    l = sortList.length;
                for (var i = 0; i < l; i++) {
                    var c = sortList[i][0];
                    var order = sortList[i][1];
                    var s = getCachedSortType(table.config.parsers, c) == "text" ? order == 0 ? "sortText" : "sortTextDesc" : order == 0 ? "sortNumeric" : "sortNumericDesc";
                    var e = "e" + i;
                    dynamicExp += "var " + e + " = " + s + "(a[" + c + "],b[" + c + "]); ";
                    dynamicExp += "if(" + e + ") { return " + e + "; } ";
                    dynamicExp += "else { "
                }
                var orgOrderCol = cache.normalized[0].length - 1;
                dynamicExp += "return a[" + orgOrderCol + "]-b[" + orgOrderCol + "];";
                for (var i = 0; i < l; i++) dynamicExp += "}; ";
                dynamicExp += "return 0; ";
                dynamicExp += "}; ";
                eval(dynamicExp);
                cache.normalized.sort(sortWrapper);
                if (table.config.debug) benchmark("Sorting on " + sortList.toString() + " and dir " + order + " time:", sortTime);
                return cache
            }
            function sortText(a, b) {
                return a < b ? -1 : a > b ? 1 : 0
            }
            function sortTextDesc(a, b) {
                return b < a ? -1 : b > a ? 1 : 0
            }
            function sortNumeric(a, b) {
                return a - b
            }
            function sortNumericDesc(a, b) {
                return b - a
            }
            function getCachedSortType(parsers, i) {
                return parsers[i].type
            }
            this.construct = function (settings) {
                return this.each(function () {
                    if (!this.tHead || !this.tBodies) return;
                    var $this, $document, $headers, cache, config, shiftDown = 0,
                        sortOrder;
                    this.config = {};
                    config = $.extend(this.config, $.tablesorter.defaults, settings);
                    $this = $(this);
                    $headers = buildHeaders(this);
                    this.config.parsers = buildParserCache(this, $headers);
                    cache = buildCache(this);
                    var sortCSS = [config.cssDesc, config.cssAsc];
                    fixColumnWidth(this);
                    $headers.click(function (e) {
                        $this.trigger("sortStart");
                        var totalRows = $this[0].tBodies[0] && $this[0].tBodies[0].rows.length || 0;
                        if (!this.sortDisabled && totalRows > 0) {
                            var $cell = $(this);
                            var i = this.column;
                            this.order = this.count++ % 2;
                            if (!e[config.sortMultiSortKey]) {
                                config.sortList = [];
                                if (config.sortForce != null) {
                                    var a = config.sortForce;
                                    for (var j = 0; j < a.length; j++) if (a[j][0] != i) config.sortList.push(a[j])
                                }
                                config.sortList.push([i, this.order])
                            } else if (isValueInArray(i, config.sortList)) for (var j = 0; j < config.sortList.length; j++) {
                                var s = config.sortList[j],
                                    o = config.headerList[s[0]];
                                if (s[0] == i) {
                                    o.count = s[1];
                                    o.count++;
                                    s[1] = o.count % 2
                                }
                            } else config.sortList.push([i, this.order]);
                            setTimeout(function () {
                                setHeadersCss($this[0], $headers, config.sortList, sortCSS);
                                appendToTable($this[0], multisort($this[0], config.sortList, cache))
                            }, 1);
                            return false
                        }
                    }).mousedown(function () {
                        if (config.cancelSelection) {
                            this.onselectstart =

                            function () {
                                return false
                            };
                            return false
                        }
                    });
                    $this.bind("update", function () {
                        this.config.parsers = buildParserCache(this, $headers);
                        cache = buildCache(this)
                    }).bind("sorton", function (e, list) {
                        $(this).trigger("sortStart");
                        config.sortList = list;
                        var sortList = config.sortList;
                        updateHeaderSortCount(this, sortList);
                        setHeadersCss(this, $headers, sortList, sortCSS);
                        appendToTable(this, multisort(this, sortList, cache))
                    }).bind("appendCache", function () {
                        appendToTable(this, cache)
                    }).bind("applyWidgetId", function (e, id) {
                        getWidgetById(id).format(this)
                    }).bind("applyWidgets", function () {
                        applyWidget(this)
                    });
                    if ($.metadata && $(this).metadata() && $(this).metadata().sortlist) config.sortList = $(this).metadata().sortlist;
                    if (config.sortList.length > 0) $this.trigger("sorton", [config.sortList]);
                    applyWidget(this)
                })
            };
            this.addParser = function (parser) {
                var l = parsers.length,
                    a = true;
                for (var i = 0; i < l; i++) if (parsers[i].id.toLowerCase() == parser.id.toLowerCase()) a = false;
                if (a) parsers.push(parser)
            };
            this.addWidget = function (widget) {
                widgets.push(widget)
            };
            this.formatFloat = function (s) {
                var i = parseFloat(s);
                return isNaN(i) ? 0 : i
            };
            this.formatInt = function (s) {
                var i = parseInt(s);
                return isNaN(i) ? 0 : i
            };
            this.isDigit = function (s, config) {
                var DECIMAL = "\\" + config.decimal;
                var exp = "/(^[+]?0(" + DECIMAL + "0+)?$)|(^([-+]?[1-9][0-9]*)$)|(^([-+]?((0?|[1-9][0-9]*)" + DECIMAL + "(0*[1-9][0-9]*)))$)|(^[-+]?[1-9]+[0-9]*" + DECIMAL + "0+$)/";
                return RegExp(exp).test($.trim(s))
            };
            this.clearTableBody = function (table) {
                if ($.browser.msie) {
                    function empty() {
                        while (this.firstChild) this.removeChild(this.firstChild)
                    }
                    empty.apply(table.tBodies[0])
                } else table.tBodies[0].innerHTML = ""
            }
        })
    });
    $.fn.extend({
        tablesorter: $.tablesorter.construct
    });
    var ts = $.tablesorter;
    ts.addParser({
        id: "text",
        is: function (s) {
            return true
        },
        format: function (s) {
            return $.trim(s.toLowerCase())
        },
        type: "text"
    });
    ts.addParser({
        id: "digit",
        is: function (s, table) {
            var c = table.config;
            return $.tablesorter.isDigit(s, c)
        },
        format: function (s) {
            return $.tablesorter.formatFloat(s)
        },
        type: "numeric"
    });
    ts.addParser({
        id: "currency",
        is: function (s) {
            return /^[\u00a3$\u20ac?.]/.test(s)
        },
        format: function (s) {
            return $.tablesorter.formatFloat(s.replace(new RegExp(/[^0-9.]/g), ""))
        },
        type: "numeric"
    });
    ts.addParser({
        id: "ipAddress",
        is: function (s) {
            return /^\d{2,3}[\.]\d{2,3}[\.]\d{2,3}[\.]\d{2,3}$/.test(s)
        },
        format: function (s) {
            var a = s.split("."),
                r = "",
                l = a.length;
            for (var i = 0; i < l; i++) {
                var item = a[i];
                if (item.length == 2) r += "0" + item;
                else r += item
            }
            return $.tablesorter.formatFloat(r)
        },
        type: "numeric"
    });
    ts.addParser({
        id: "url",
        is: function (s) {
            return /^(https?|ftp|file):\/\/$/.test(s)
        },
        format: function (s) {
            return jQuery.trim(s.replace(new RegExp(/(https?|ftp|file):\/\//), ""))
        },
        type: "text"
    });
    ts.addParser({
        id: "isoDate",
        is: function (s) {
            return /^\d{4}[\/-]\d{1,2}[\/-]\d{1,2}$/.test(s)
        },
        format: function (s) {
            return $.tablesorter.formatFloat(s != "" ? (new Date(s.replace(new RegExp(/-/g), "/"))).getTime() : "0")
        },
        type: "numeric"
    });
    ts.addParser({
        id: "percent",
        is: function (s) {
            return /\%$/.test($.trim(s))
        },
        format: function (s) {
            return $.tablesorter.formatFloat(s.replace(new RegExp(/%/g), ""))
        },
        type: "numeric"
    });
    ts.addParser({
        id: "usLongDate",
        is: function (s) {
            return s.match(new RegExp(/^[A-Za-z]{3,10}\.? [0-9]{1,2}, ([0-9]{4}|'?[0-9]{2}) (([0-2]?[0-9]:[0-5][0-9])|([0-1]?[0-9]:[0-5][0-9]\s(AM|PM)))$/))
        },
        format: function (s) {
            return $.tablesorter.formatFloat((new Date(s)).getTime())
        },
        type: "numeric"
    });
    ts.addParser({
        id: "shortDate",
        is: function (s) {
            return /\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}/.test(s)
        },
        format: function (s, table) {
            var c = table.config;
            s = s.replace(/\-/g, "/");
            if (c.dateFormat == "us") s = s.replace(/(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})/, "$3/$1/$2");
            else if (c.dateFormat == "uk") s = s.replace(/(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})/, "$3/$2/$1");
            else if (c.dateFormat == "dd/mm/yy" || c.dateFormat == "dd-mm-yy") s = s.replace(/(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2})/, "$1/$2/$3");
            return $.tablesorter.formatFloat((new Date(s)).getTime())
        },
        type: "numeric"
    });
    ts.addParser({
        id: "time",
        is: function (s) {
            return /^(([0-2]?[0-9]:[0-5][0-9])|([0-1]?[0-9]:[0-5][0-9]\s(am|pm)))$/.test(s)
        },
        format: function (s) {
            return $.tablesorter.formatFloat((new Date("2000/01/01 " + s)).getTime())
        },
        type: "numeric"
    });
    ts.addParser({
        id: "metadata",
        is: function (s) {
            return false
        },
        format: function (s, table, cell) {
            var c = table.config,
                p = !c.parserMetadataName ? "sortValue" : c.parserMetadataName;
            return $(cell).metadata()[p]
        },
        type: "numeric"
    });
    ts.addWidget({
        id: "zebra",
        format: function (table) {
            if (table.config.debug) var time = new Date;
            $("tr:visible", table.tBodies[0]).filter(":even").removeClass(table.config.widgetZebra.css[1]).addClass(table.config.widgetZebra.css[0]).end().filter(":odd").removeClass(table.config.widgetZebra.css[0]).addClass(table.config.widgetZebra.css[1]);
            if (table.config.debug) $.tablesorter.benchmark("Applying Zebra widget", time)
        }
    })
})(jQuery);
(function ($) {
    $.fn.drag = function (fn1, fn2, fn3) {
        if (fn2) this.bind("dragstart", fn1);
        if (fn3) this.bind("dragend", fn3);
        return !fn1 ? this.trigger("drag") : this.bind("drag", fn2 ? fn2 : fn1)
    };
    var $event = $.event,
        $special = $event.special,
        drag = $special.drag = {
        not: ":input",
        distance: 0,
        which: 1,
        setup: function (data) {
            data = $.extend({
                distance: drag.distance,
                which: drag.which,
                not: drag.not
            }, data || {});
            data.distance = squared(data.distance);
            $event.add(this, "mousedown", handler, data)
        },
        teardown: function () {
            $event.remove(this, "mousedown", handler);
            if (this === drag.dragging) drag.dragging = drag.proxy = null;
            selectable(this, true)
        }
    };

    function handler(event) {
        var elem = this,
            returned, data = event.data || {};
        if (data.elem) {
            elem = event.dragTarget = data.elem;
            event.dragProxy = drag.proxy || elem;
            event.cursorOffsetX = data.pageX - data.left;
            event.cursorOffsetY = data.pageY - data.top;
            event.offsetX = event.pageX - event.cursorOffsetX;
            event.offsetY = event.pageY - event.cursorOffsetY
        } else if (drag.dragging || data.which > 0 && event.which != data.which || $(event.target).is(data.not)) return;
        switch (event.type) {
        case "mousedown":
            $.extend(data, $(elem).offset(), {
                elem: elem,
                target: event.target,
                pageX: event.pageX,
                pageY: event.pageY
            });
            $event.add(document, "mousemove mouseup", handler, data);
            selectable(elem, false);
            return false;
        case !drag.dragging && "mousemove":
            if (squared(event.pageX - data.pageX) + squared(event.pageY - data.pageY) < data.distance) break;
            event.target = data.target;
            returned = hijack(event, "dragstart", elem);
            if (returned !== false) {
                drag.dragging = elem;
                drag.proxy = event.dragProxy = $(returned || elem)[0]
            }
        case "mousemove":
            if (drag.dragging) {
                returned = hijack(event, "drag", elem);
                if ($special.drop) {
                    $special.drop.allowed = returned !== false;
                    $special.drop.handler(event)
                }
                if (returned !== false) break;
                event.type = "mouseup"
            }
        case "mouseup":
            $event.remove(document, "mousemove mouseup", handler);
            if (drag.dragging) {
                if ($special.drop) $special.drop.handler(event);
                hijack(event, "dragend", elem)
            }
            selectable(elem, true);
            drag.dragging = drag.proxy = data.elem = null;
            break
        }
    }
    function hijack(event, type, elem) {
        event.type = type;
        var result = $event.handle.call(elem, event);
        return result === false ? false : result || event.result
    }
    function squared(value) {
        return Math.pow(value, 2)
    }
    function selectable(elem, bool) {
        if (!elem) return;
        elem.unselectable = bool ? "off" : "on";
        elem.onselectstart = function () {
            return bool
        };
        if (document.selection && document.selection.empty) document.selection.empty();
        if (elem.style) elem.style.MozUserSelect = bool ? "" : "none"
    }
})(jQuery);
(function ($) {
    $.fn.kiketable_colsizable = function (o) {
        o = $.extend({}, $.fn.kiketable_colsizable.defaults, o);
        o.dragProxy = o.dragProxy === "line" ? false : true;
        this.filter("table:not(." + o.namespace + ")").addClass(o.namespace).each(function (index) {
            o.renderTime = (new Date).getTime();
            var oTable = this,
                $Table = $(this),
                _Cols = oTable.getElementsByTagName("col");
            _Cols.length && $(o.dragCells, this).each(function (index) {
                if (!$(this).hasClass("kiketable-th")) $(this).addClass("kiketable-th").wrapInner('<div class="kiketable-th-text"></div>');
                $('<div class="' + o.classHandler + '" title="' + o.title + '"></div>').prependTo(this).each(function () {
                    this.td = this.parentNode;
                    this.$td = $(this.td);
                    this.col = _Cols[this.td.cellIndex]
                }).dblclick(function () {
                    if (this.wtd == null) {
                        this.wtd = this.col.offsetWidth;
                        this.wtd0 = this.wtd
                    }
                    var minimized = this.wtd == o.minWidth;
                    this.wtd = minimized ? this.wtd0 : o.minWidth;
                    this.col.style.width = this.wtd + "px";
                    if (!o.fixWidth) {
                        var d = this.wtd0 - o.minWidth;
                        oTable.style.width = $Table.width() + (minimized ? d : -d) + "px"
                    }
                    $(this).trigger("minimized")
                }).bind("dragstart", function (e) {
                    this.cell_width = this.$td.width();
                    this.table_width = $Table.width();
                    this.left0 = e.offsetX;
                    this.d1 = this.cell_width - this.left0;
                    this.d2 = o.minWidth - this.d1;
                    return $(this).clone().appendTo(this.td).css("opacity", o.dragOpacity).css(o.dragProxy ? {
                        top: this.$td.offset().top,
                        left: this.$td.offset().left,
                        width: this.cell_width
                    } : {
                        top: this.$td.offset().top,
                        left: e.offsetX
                    }).removeClass(o.classHandler).addClass(o.dragProxy ? o.classDragArea : o.classDragLine).height($Table.height())
                }).bind("drag", o.dragMove || o.dragProxy ?
                function (e) {
                    var w = e.offsetX + this.d1;
                    if (w - this.d2 - this.d1 >= 0) {
                        e.dragProxy.style.width = w + "px";
                        if (o.dragMove) {
                            this.col.style.width = w + "px";
                            if (!o.fixWidth) oTable.style.width = this.table_width - this.cell_width + w + "px"
                        }
                    }
                } : function (e) {
                    var x = e.offsetX;
                    if (x - this.d2 >= 0) e.dragProxy.style.left = x + "px"
                }).bind("dragend", function (e) {
                    if (!o.dragMove) {
                        var delta = parseInt(e.dragProxy.style.left) - this.left0;
                        this.col.style.width = o.dragProxy ? e.dragProxy.style.width : this.cell_width + delta + "px";
                        if (!o.fixWidth) oTable.style.width = (o.dragProxy ? this.table_width - this.cell_width + parseInt(e.dragProxy.style.width) : this.table_width + delta) + "px"
                    }
                    $(e.dragProxy)[o.fxHide](o.fxSpeed, function () {
                        $(this).remove()
                    });
                    $(this).trigger("minimized")
                }).bind("minimized", function (e) {
                    $(this.col)[parseInt(this.col.style.width) <= o.minWidth ? "addClass" : "removeClass"](o.classMinimized)
                })
            });
            o.renderTime = (new Date).getTime() - o.renderTime;
            o.onLoad()
        });
        return this
    };
    $.fn.kiketable_colsizable.defaults = {
        dragCells: "tr:first > *",
        dragMove: true,
        dragProxy: "line",
        dragOpacity: 0.3,
        minWidth: 8,
        fixWidth: false,
        fxHide: "fadeOut",
        fxSpeed: 200,
        namespace: "kiketable-colsizable",
        classHandler: "kiketable-colsizable-handler",
        classDragLine: "kiketable-colsizable-dragLine",
        classDragArea: "kiketable-colsizable-dragArea",
        classMinimized: "kiketable-colsizable-minimized",
        title: "Expand/Collapse this column",
        renderTime: 0,
        onLoad: function () {}
    }
})(jQuery);
(function ($) {
    function toIntegersAtLease(n) {
        return n < 10 ? "0" + n : n
    }
    Date.prototype.toJSON = function (date) {
        return this.getUTCFullYear() + "-" + toIntegersAtLease(this.getUTCMonth()) + "-" + toIntegersAtLease(this.getUTCDate())
    };
    var escapeable = /["\\\x00-\x1f\x7f-\x9f]/g;
    var meta = {
        "\u0008": "\\b",
        "\t": "\\t",
        "\n": "\\n",
        "\u000c": "\\f",
        "\r": "\\r",
        '"': '\\"',
        "\\": "\\\\"
    };
    $.quoteString = function (string) {
        if (escapeable.test(string)) return '"' + string.replace(escapeable, function (a) {
            var c = meta[a];
            if (typeof c === "string") return c;
            c = a.charCodeAt();
            return "\\u00" + Math.floor(c / 16).toString(16) + (c % 16).toString(16)
        }) + '"';
        return '"' + string + '"'
    };
    $.toJSON = function (o, compact) {
        var type = typeof o;
        if (type == "undefined") return "undefined";
        else if (type == "number" || type == "boolean") return o + "";
        else if (o === null) return "null";
        if (type == "string") return $.quoteString(o);
        if (type == "object" && typeof o.toJSON == "function") return o.toJSON(compact);
        if (type != "function" && typeof o.length == "number") {
            var ret = [];
            for (var i = 0; i < o.length; i++) ret.push($.toJSON(o[i], compact));
            if (compact) return "[" + ret.join(",") + "]";
            else return "[" + ret.join(", ") + "]"
        }
        if (type == "function") throw new TypeError("Unable to convert object of type 'function' to json.");
        var ret = [];
        for (var k in o) {
            var name;
            type = typeof k;
            if (type == "number") name = '"' + k + '"';
            else if (type == "string") name = $.quoteString(k);
            else continue;
            var val = $.toJSON(o[k], compact);
            if (typeof val != "string") continue;
            if (compact) ret.push(name + ":" + val);
            else ret.push(name + ": " + val)
        }
        return "{" + ret.join(", ") + "}"
    };
    $.compactJSON = function (o) {
        return $.toJSON(o, true)
    };
    $.evalJSON = function (src) {
        return eval("(" + src + ")")
    };
    $.secureEvalJSON = function (src) {
        var filtered = src;
        filtered = filtered.replace(/\\["\\\/bfnrtu]/g, "@");
        filtered = filtered.replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, "]");
        filtered = filtered.replace(/(?:^|:|,)(?:\s*\[)+/g, "");
        if (/^[\],:{}\s]*$/.test(filtered)) return eval("(" + src + ")");
        else throw new SyntaxError("Error parsing JSON, source is not valid.");
    }
})(jQuery);
(function ($) {
    $.contr_text = function () {
        alert("here1")
    };
    $.fn.contr_text = function () {
        return $(this)
    };
    $.isReadonly2 = function (obj, columnIndex) {
        try {
            if (obj.model.fields[columnIndex].readonly) return true
        } catch (exept) {}
        return false
    };
    $.contr_text.drawCell = function (jsonObj, rowIndex, cellIndex) {
        return jsonObj.table[rowIndex][cellIndex].value
    };
    $.fn.contr_textMakeEditable = function (obj) {
        return $(this).each(function () {
            $(this).bind("click", function (e) {
                $this = $(this);
                $tr = $(this).parent();
                var tdIndex = $this.attr("cell_index");
                var trIndex = $tr.attr("row_index");
                if (!$("input", this).length) {
                    obj.hideLast();
                    var cellIndex = $(this).attr("cell_index");
                    if (!$.isReadonly2(obj, cellIndex)) obj.lastItem = $(this).html('<input class="inputClass" type="text" value="' + obj.model.table[trIndex][tdIndex].value + '" style="width:20px;"/>').find("input").animate({
                        width: "95%"
                    }, {
                        queue: true,
                        duration: 100,
                        complete: function () {
                            $(this).trigger("focus")
                        }
                    }).bind("blur", function (e) {
                        $this = $(this);
                        $td = $this.parent();
                        $tr = $td.parent();
                        var newValue = $this.val();
                        obj.model.table[$tr.attr("row_index")][$td.attr("cell_index")].value =
                        newValue;
                        $(this).animate({
                            width: "1px"
                        }, {
                            queue: true,
                            duration: 100,
                            complete: function () {
                                $(this).trigger("showNewValue")
                            }
                        })
                    }).bind("showNewValue", function (event) {
                        $this = $(this);
                        var newValue = $this.val();
                        $td.find("*").remove().end().html(newValue != "" ? newValue : "&nbsp;");
                        $(obj.params.divPath).find("table").trigger("update")
                    }).bind("keypress", function (event) {
                        var keynum;
                        if (jQuery.browser.msie) keynum = event.keyCode;
                        else keynum = event.which;
                        if (keynum == 13) {
                            $(this).triggerHandler("blur");
                            return false
                        }
                    })
                }
            })
        })
    }
})(jQuery);
(function ($) {
    $.contr_rtext = function () {
        alert("here1")
    };
    $.fn.contr_rtext = function () {
        return $(this)
    };
    $.isReadonly = function (obj, columnIndex) {
        try {
            if (obj.model.fields[columnIndex].options.readonly) return true
        } catch (exept) {}
        return false
    };
    $.contr_rtext.drawCell = function (jsonObj, rowIndex, cellIndex) {
        return jsonObj.table[rowIndex][cellIndex].value
    };
    $.fn.contr_rtextMakeEditable = function (obj) {
        return $(this).each(function () {
            $(this).bind("click", function (e) {
                $this = $(this);
                $tr = $(this).parent();
                var tdIndex = $this.attr("cell_index");
                var trIndex = $tr.attr("row_index");
                if (!$("input", this).length) {
                    obj.hideLast();
                    var cellIndex = $(this).attr("cell_index");
                    obj.lastItem = $(this).html('<input class="inputClass" ' + ($.isReadonly(obj, cellIndex) ? 'readonly="true" ' : "") + 'type="text" value="' + obj.model.table[trIndex][tdIndex].value + '" style="width:20px;"/>').find("input").animate({
                        width: "95%"
                    }, {
                        queue: true,
                        duration: 100,
                        complete: function () {
                            $(this).trigger("focus")
                        }
                    }).bind("blur", function (e) {
                        obj.lastItem = undefined;
                        $this = $(this);
                        $td = $this.parent();
                        $tr = $td.parent();
                        var newValue = $this.val();
                        obj.model.table[$tr.attr("row_index")][$td.attr("cell_index")].value = newValue;
                        $(this).animate({
                            width: "1px"
                        }, {
                            queue: true,
                            duration: 100,
                            complete: function () {
                                $(this).trigger("showNewValue")
                            }
                        })
                    }).bind("showNewValue", function (event) {
                        $this = $(this);
                        $td = $this.parent();
                        var newValue = $this.val();
                        $td.find("*").remove().end().html(newValue != "" ? newValue : "&nbsp;");
                        $(obj.params.divPath).find("table").trigger("update")
                    }).bind("keypress", function (event) {
                        var keynum;
                        if (jQuery.browser.msie) keynum = event.keyCode;
                        else keynum = event.which;
                        if (keynum == 13) {
                            $(this).triggerHandler("blur");
                            return false
                        }
                    })
                }
            })
        })
    }
})(jQuery);
(function ($) {
    $.contr_link = function () {
        alert("here1")
    };
    $.fn.contr_link = function () {
        return $(this)
    };
    $.contr_link.drawCell = function (jsonObj, rowIndex, cellIndex) {
        return '<a href="' + jsonObj.table[rowIndex][cellIndex].link + '">' + jsonObj.table[rowIndex][cellIndex].value + "</a>"
    };
    $.fn.contr_linkMakeEditable = function (obj) {
        return $(this)
    }
})(jQuery);
(function ($) {
    $.contr_sflink = function () {
        alert("here1")
    };
    $.fn.contr_sflink = function () {
        return $(this)
    };
    $.contr_sflink.drawCell = function (jsonObj, rowIndex, cellIndex) {
        return '<a href="/' + jsonObj.rows[rowIndex] + '">' + jsonObj.table[rowIndex][cellIndex].value + "</a>"
    };
    $.fn.contr_sflinkMakeEditable = function (obj) {
        return $(this)
    }
})(jQuery);
(function ($) {
    $.contr_date = function () {
        alert("here1")
    };
    $.fn.contr_date = function () {
        return $(this)
    };
    $.contr_date.drawCell = function (jsonObj, rowIndex, cellIndex) {
        return jsonObj.table[rowIndex][cellIndex].value
    };
    $.fn.contr_dateMakeEditable = function (obj) {
        return $(this).each(function () {
            $(this).bind("click", function (e) {
                $this = $(this);
                $tr = $(this).parent();
                var tdIndex = $this.attr("cell_index");
                var trIndex = $tr.attr("row_index");
                if (!$("input", this).length) {
                    obj.hideLast();
                    obj.lastItem = $(this).html('<input type="text" value="' + obj.model.table[trIndex][tdIndex].value + '" style="width:20px;"/>').find("input").datepicker({
                        debug: false,
                        changeYear: true,
                        changeMonth: true,
                        showButtonPanel: true,
                        beforeShow: function (input) {
                            obj.debug.log("beforeShow : " + input)
                        },
                        onClose: function (dateText, inst) {
                            obj.debug.log("before onClose");
                            obj.debug.log("before " + this);
                            $this = $(this);
                            $td = $this.parent();
                            $tr = $td.parent();
                            if ($tr.attr("row_index") == undefined || $td.attr("cell_index") == undefined) return;
                            var newValue = $this.val();
                            obj.model.table[$tr.attr("row_index")][$td.attr("cell_index")].value =
                            newValue;
                            obj.debug.log("b");
                            $(this).animate({
                                width: "1px"
                            }, {
                                queue: true,
                                duration: 100,
                                complete: function () {
                                    obj.debug.log("before Complete");
                                    $(this).trigger("showNewValue")
                                }
                            })
                        }
                    }).animate({
                        width: "70px"
                    }, {
                        queue: true,
                        duration: 100,
                        complete: function () {
                            $(this).trigger("focus")
                        }
                    }).bind("showNewValue", function (event) {
                        obj.lastItem = undefined;
                        $this = $(this);
                        obj.debug.log("datepicker showNewValue: " + $this.html());
                        $td = $this.parent();
                        obj.debug.log("showNewValue td: " + $td.parent().html());
                        var newValue = $this.val();
                        obj.debug.log("Deleting: ");
                        $td.find("*").remove().end().html(newValue != "" ? newValue : "&nbsp;");
                        $(obj.params.divPath).find("table").trigger("update")
                    }).bind("blur", function (e) {}).bind("keypress", function (event) {
                        var keynum;
                        if (jQuery.browser.msie) keynum = event.keyCode;
                        else keynum = event.which;
                        if (keynum == 13) {
                            $(this).triggerHandler("blur");
                            return false
                        }
                    })
                }
            })
        })
    }
})(jQuery);
(function ($) {
    $.contr_boolean = function () {
        alert("here1")
    };
    $.fn.contr_boolean = function () {
        return $(this)
    };
    $.contr_boolean.drawCell = function (jsonObj, rowIndex, cellIndex) {
        return '<input type="checkbox" ' + (jsonObj.table[rowIndex][cellIndex].value != "" ? 'checked="checked" ' : "") + ' value="' + jsonObj.table[rowIndex][cellIndex].value + '"/>'
    };
    $.fn.contr_booleanMakeEditable = function (obj) {
        return $(this).each(function () {
            $(this).bind("change", function (e) {
                $this = $(this);
                $tr = $this.parent();
                var newValue = $(this).find("input").attr("checked");
                obj.model.table[$tr.attr("row_index")][$this.attr("cell_index")].value = newValue
            })
        })
    }
})(jQuery);
(function ($) {
    $.contr_smplselect = function () {
        alert("here1")
    };
    $.fn.contr_smplselect = function () {
        return $(this)
    };
    $.getFieldLabel = function (fieldObj, value) {
        var label = "";
        $.each(fieldObj.values, function () {
            if (this.value == value) {
                label = this.label;
                return false
            }
        });
        return label
    };
    $.contr_smplselect.drawCell = function (jsonObj, rowIndex, cellIndex) {
        return $.getFieldLabel(jsonObj.fields[cellIndex], jsonObj.table[rowIndex][cellIndex].value)
    };
    $.fn.contr_smplselectMakeEditable = function (obj) {
        return $(this).each(function () {
            $(this).bind("click", function (e) {
                if ($(e.target).is("td")) if (!$("select", this).length) {
                    obj.hideLast();
                    $tr = $(this).parent();
                    var cellIndex = $(this).attr("cell_index");
                    var selectHtml = "";
                    var curVal = obj.model.table[$tr.attr("row_index")][cellIndex].value;
                    var selIndex = -1;
                    $.each(obj.model.fields[cellIndex].values, function (index) {
                        selectHtml += "<option " + (this.value == curVal ? 'selected="true"' : "") + ' value="' + this.value + '">' + this.label + "</option>"
                    });
                    obj.lastItem = $(this).html('<select class="selectClass"></select>').find("select").html(selectHtml).animate({
                        width: "95%"
                    }, {
                        queue: true,
                        duration: 100,
                        complete: function () {
                            $(this).trigger("focus")
                        }
                    }).bind("blur", function (e) {
                        obj.lastItem = undefined;
                        obj.debug.log("blur: " + this);
                        $this = $(this);
                        $td = $this.parent();
                        $tr = $td.parent();
                        var newValue = $this.val();
                        newValue = $.getFieldLabel(obj.model.fields[$td.attr("cell_index")], newValue);
                        obj.model.table[$tr.attr("row_index")][$td.attr("cell_index")].value = newValue;
                        $(this).animate({
                            width: "1px"
                        }, {
                            queue: true,
                            duration: 100,
                            complete: function () {
                                $(this).trigger("showNewValue")
                            }
                        })
                    }).bind("showNewValue", function (event) {
                        obj.debug.log("ggg");
                        $this = $(this);
                        $td = $this.parent();
                        var newValue = $this.val();
                        var newValue = $.getFieldLabel(obj.model.fields[$td.attr("cell_index")], newValue);
                        $td.find("*").remove().end().html(newValue != "" ? newValue : "&nbsp;");
                        $(obj.params.divPath).find("table").trigger("update");
                        $(obj.params.divPath).trigger("onupdate")
                    }).bind("keypress", function (event) {
                        var keynum;
                        if (jQuery.browser.msie) keynum = event.keyCode;
                        else keynum = event.which;
                        if (keynum == 13) {
                            $(this).triggerHandler("blur");
                            return false
                        }
                    })
                }
            })
        })
    }
})(jQuery);
(function ($) {
    var ix = 0;
	var addRowInd = 1;

    $.isDateCell = function (node) {
        return node.innerHTML[ix + 2] == "/" && node.innerHTML[ix + 5] == "/"
    };
    $.isLinkCell = function (node) {
        return $(node).find("a").size() ? true : false
    };
    $.extractSortableDate = function (node) {
        return node.innerHTML.substr(ix + 6, 4) + node.innerHTML.substr(ix + 0, 2) + node.innerHTML.substr(ix + 3, 2)
    };
    $.drawTable = function (initParams) {
 
        var obj = {
            params: $.extend({}, $.drawTable.defaults, initParams),
            hideLast: function () {
                if (this.lastItem !== undefined) this.lastItem.trigger("showNewValue")
            },
            addRow: function (rowData) {
                this.model.rows.push(rowData.rowId);
                this.model.table.push(rowData.rowData)
            },
            delRow: function (rowId) {
                if ((elIndex = getRowIndex(rowId)) != -1) {
                    obj.model.rows.splice(elIndex, 1);
                    obj.model.table.splice(elIndex, 1)
                }
            },
            refreshTable: function () {
                var $newTable = buildTable();
                assignEvents($newTable);
                $(this.params.divPath).html($newTable)
            },
            debug: {
                log: function (msg) {
                    if (obj.params.debug) if (typeof console != "undefined" && typeof console.debug != "undefined") console.log(msg);
                    else alert(msg)
                }
            }
        };
        obj.model = obj.params.json;
        obj.model.delList = new Array;
		
        var getRowIndex =  function (rowId) {
            for (var ix = 0; ix < obj.model.rows.length; ix++) if (obj.model.rows[ix] == rowId) return ix;
            return -1
        };
        var drawCell = function (rowIndex, cellIndex) {
            var str = eval("$.contr_" + obj.model.table[rowIndex][cellIndex].type + ".drawCell(obj.model, rowIndex, cellIndex);");
            return str
        };
        var buildTable = function () {
            var headersStr = "";
            $.each(obj.params.json.head, function (headIndex, headValue) {
                headersStr += '<th style="background-color: white;';
                if(obj.params.json.fields[headIndex].columnfixed != null)
                {
                	if(!$.browser.msie || $.browser.version>7) headersStr += ' position:absolute;left:2px;';
                }
                if(obj.params.json.fields[headIndex].headerstyle != null) headersStr += obj.params.json.fields[headIndex].headerstyle;
                headersStr+= ' " >' + headValue + "</th>"
            });
             var rows = "";
			var rows_columnfixed = "";
            $.each(obj.model.table, function (rowIndex, rowValue) {
                var innerStr = "";
                var innerStr_columnfixed = "";
                $.each(rowValue, function (cellIndex, cellValue) {
                    var cellHTML = drawCell(rowIndex, cellIndex);
                	innerStr += '<td style="';
                	if(obj.params.json.fields[cellIndex].columnfixed != null)
                	{
                		if(!$.browser.msie || $.browser.version>7) innerStr += ' position:absolute;left:1px;';
                	}
                	if(obj.params.json.fields[cellIndex].rowstyle != null) innerStr += obj.params.json.fields[cellIndex].rowstyle;
                	
                	innerStr += ' "'+(obj.params.classes.table[cellIndex] !== undefined ? ' class="' + obj.params.classes.table[cellIndex] + '"' : "") + ' cell_index="' + cellIndex + '">' + (cellHTML != "" ? cellHTML : "&nbsp") + "</td>";
                });
                rows += '<tr row_index="' + rowIndex + '" >' + innerStr + "</tr>";
            });
			
            var colWidth;
            var sizesNum = obj.params.styles.colsWidth.length;
            var colgroup = "";
            for (var i = 0; i < obj.params.json.fields.length; i++) {
                colWidth = $.isArray(obj.params.styles.colsWidth) ? obj.params.styles.colsWidth[sizesNum > i ? i : sizesNum - 1] : obj.params.styles.colsWidth;
                colgroup += '<col style="width:' + colWidth + 'px;"/>'
            }
            var footerDom = $("<TFOOT></TFOOT>");
            $.each(obj.model.footer, function () {
                footerDom.append(eval("$.drawTable." + this["footer-type"] + ".draw(obj, this.cells);"))
            });
            return $('<table class="kiketable-colsizable" cellspacing="0" style="background-color: white;"><colgroup>' + colgroup + "</colgroup><thead><tr>" + headersStr + "</tr></thead><tbody>" + rows + "</tbody></table>").append(footerDom)
        };
        var textExtrFunc = function (node) {
            if ($.isDateCell(node)) return $.extractSortableDate(node);
            if ($.isLinkCell(node)) return $(node).find("a").html();
            return node.innerHTML
        };
        var assignEvents = function ($tableVar) {
        /*
            $tableVar.tablesorter({
                textExtraction: textExtrFunc
            });
          */  	
          	try{
	        	var sortHeaders = {};
				if (obj.params.sortHeaders != null)sortHeaders = obj.params.sortHeaders;
	        	$tableVar.tablesorter({
	               	headers:sortHeaders,
	                 textExtraction: function(td) 
	                 {          
						var tdIndex = $(td).attr('cell_index');
						var trIndex = $(td).parent().attr('row_index');
						return obj.params.json.table[trIndex][tdIndex].value;
			        } 
	            });
            } catch (err) {}
            $tableVar.kiketable_colsizable({
                dragMove: false
            });
            $("tbody > tr", $tableVar).each(function (indexRow, valueRow) {
                $("td", this).each(function (indexCell, valueCell) {
                    eval("$(this).contr_" + obj.params.json.table[indexRow][indexCell].type + "MakeEditable(obj);")
                })
            })
        };
        
        
        
        $table = buildTable();
        assignEvents($table);
        $(obj.params.divPath).append($table);
         //$(obj.params.divPath).append(tmp);
        //alert('Draw Table Complite.');
        return obj
    };
    $.drawTableNew = function (initParams, tableNumber) {
        //alert(tableNumber);
        var obj = {
            params: $.extend({}, $.drawTable.defaults, initParams),
            hideLast: function () {
                if (this.lastItem !== undefined) this.lastItem.trigger("showNewValue")
            },
            addRow: function (rowData) {
                this.model.rows.push(rowData.rowId);
                this.model.table.push(rowData.rowData)
            },
            delRow: function (rowId) {
                if ((elIndex = getRowIndex(rowId)) != -1) {
                    obj.model.rows.splice(elIndex, 1);
                    obj.model.table.splice(elIndex, 1)
                }
            },
            refreshTable: function () {
                var $newTable = buildTable(tableNumber);
                assignEvents($newTable);
                $(this.params.divPath).html($newTable)
            },
            debug: {
                log: function (msg) {
                    if (obj.params.debug) if (typeof console != "undefined" && typeof console.debug != "undefined") console.log(msg);
                    else alert(msg)
                }
            }
        };
        obj.model = obj.params.json;
        obj.model.delList = new Array;

        var getRowIndex =  function (rowId) {
            for (var ix = 0; ix < obj.model.rows.length; ix++) if (obj.model.rows[ix] == rowId) return ix;
            return -1
        };
        var drawCell = function (rowIndex, cellIndex, tableNumber) {
            var str;
            try{
                str = eval("$.contr_" + obj.model.table[rowIndex][cellIndex].type + ".drawCell(obj.model, rowIndex, cellIndex, "+tableNumber+");");
            } catch (err) {
                txt = "Error description: " + err.description;
                alert (txt);
            }
            return str
        };
        var buildTable = function (tableNumber) {
            var headersStr = "";
            $.each(obj.params.json.head, function (headIndex, headValue) {
                headersStr += '<th style="background-color: white;';
                if(obj.params.json.fields[headIndex].columnfixed != null) headersStr += ' position:absolute;';
                if(obj.params.json.fields[headIndex].headerstyle != null) headersStr += obj.params.json.fields[headIndex].headerstyle;
                headersStr+= ' " >' + headValue + "</th>"
            });
             var rows = "";
			var rows_columnfixed = "";
            $.each(obj.model.table, function (rowIndex, rowValue) {
                var innerStr = "";
                var innerStr_columnfixed = "";
                $.each(rowValue, function (cellIndex, cellValue) {
                    var cellHTML = drawCell(rowIndex, cellIndex, tableNumber);
                    innerStr += '<td style="';
                    if(obj.params.json.fields[cellIndex].columnfixed != null) innerStr += ' position:absolute;';
                    if(obj.params.json.fields[cellIndex].rowstyle != null) innerStr += obj.params.json.fields[cellIndex].rowstyle;

                    innerStr += ' "'+(obj.params.classes.table[cellIndex] !== undefined ? ' class="' + obj.params.classes.table[cellIndex] + '"' : "") + ' cell_index="' + cellIndex + '">' + (cellHTML != "" ? cellHTML : "&nbsp") + "</td>";
                });
                rows += '<tr row_index="' + rowIndex + '" >' + innerStr + "</tr>";
            });

            var colWidth;
            var sizesNum = obj.params.styles.colsWidth.length;
            var colgroup = "";
            for (var i = 0; i < obj.params.json.fields.length; i++) {
                colWidth = $.isArray(obj.params.styles.colsWidth) ? obj.params.styles.colsWidth[sizesNum > i ? i : sizesNum - 1] : obj.params.styles.colsWidth;
                colgroup += '<col style="width:' + colWidth + 'px;"/>'
            }
            var footerDom = $("<TFOOT></TFOOT>");
            $.each(obj.model.footer, function () {
                footerDom.append(eval("$.drawTable." + this["footer-type"] + ".draw(obj, this.cells);"))
            });
            return $('<table class="kiketable-colsizable" cellspacing="0" style="background-color: white;"><colgroup>' + colgroup + "</colgroup><thead><tr>" + headersStr + "</tr></thead><tbody>" + rows + "</tbody></table>").append(footerDom)
        };
        var textExtrFunc = function (node) {
            if ($.isDateCell(node)) return $.extractSortableDate(node);
            if ($.isLinkCell(node)) return $(node).find("a").html();
            return node.innerHTML
        };
        var assignEvents = function ($tableVar, tableNumber) {
        	/*
            $tableVar.tablesorter({
                textExtraction: textExtrFunc 
            });
            */
            try{
	        	var sortHeaders = {};
				if (obj.params.sortHeaders != null)sortHeaders = obj.params.sortHeaders;
	        	$tableVar.tablesorter({
	               	headers:sortHeaders,
	                 textExtraction: function(td) 
	                 {          
						var tdIndex = $(td).attr('cell_index');
						var trIndex = $(td).parent().attr('row_index');
						return obj.params.json.table[trIndex][tdIndex].value;
			        } 
	            });
            } catch (err) {}
            $tableVar.kiketable_colsizable({
                dragMove: false
            });
            $("tbody > tr", $tableVar).each(function (indexRow, valueRow) {
                $("td", this).each(function (indexCell, valueCell) {
                    if (obj.params.json.table[indexRow][indexCell].type == "rtextOMultyTable")
                        eval("$(this).contr_" + obj.params.json.table[indexRow][indexCell].type + "MakeEditable(obj, " + tableNumber + ");")
                    else
                        eval("$(this).contr_" + obj.params.json.table[indexRow][indexCell].type + "MakeEditable(obj);")
                })
            })
        };
        $table = buildTable(tableNumber);
        assignEvents($table, tableNumber);
        $(obj.params.divPath).append($table);
        //alert('Draw Table Complite.');
        return obj
    };
    $.drawTable.tableCells = {
        draw: function (obj, cells) {
            this._afterList = new Array;
            var rowDom = $("<tr></tr>");
            var hasFooter = typeof obj.params.classes.footer == "object";
            $.each(cells, function (index) {
                $tdDom = $(eval("$.drawTable.tableCells.draw_" + this.type + "_cell(obj, this.data, index, obj.params.classes.footer[index]);"));
                if (hasFooter) if (typeof obj.params.classes.footer[index] == "string") $tdDom.addClass(obj.params.classes.footer[index]);
                rowDom.append($tdDom)
            });
            $.each(this._afterList, function (index) {
                this(rowDom)
            });
            return rowDom
        },
        draw_caption_cell: function (obj, data, index, footerClasses) {
            var hasFooter = typeof footerClasses == "object";
            var tdClass = hasFooter && typeof footerClasses["td"] == "string" ? ' class="' + footerClasses["td"] + '"' : "";
            return "<td>" + data.caption + "</td>"
        },
        draw_sum_cell: function (obj, data, index, footerClasses) {
            var hasFooter = typeof footerClasses == "object";
            var tdClass = hasFooter && typeof footerClasses["td"] == "string" ? ' class="' + footerClasses["td"] + '"' : "";
            var sum_func = function (index) {
                var sum = 0;
                $(obj.model.table).each(function () {
                    sum += parseFloat(this[index].value)
                });
                return hasFooter && typeof footerClasses.precission == "number" ? sum.toFixed(footerClasses.precission) : sum
            };
            var tdDom = $("<td" + tdClass + ">" + sum_func(index) + "</td>");
            $(obj.params.divPath).bind("update", function () {
                tdDom.html(sum_func(index))
            });
            return tdDom
        },
        draw_del_cell: function (obj, data, index, footerClasses) {
            var hasFooter = typeof footerClasses == "object";
            var tdClass = hasFooter && typeof footerClasses["td"] == "string" ? ' class="' + footerClasses["td"] + '"' : "";
            var btnClass = hasFooter && typeof footerClasses["del-button"] == "string" ? ' class="' + footerClasses["del-button"] + '"' : "";
            var tdDom = $("<td" + tdClass + "><button" + btnClass + ">Delete</button></td>");
            tdDom.find("button").bind("click", function () {
               list = new Array;
               $("table tbody tr", obj.divPath).each(function (tRix) {
                    if ($("td:eq(" + index + ") input", this).attr("checked") &&  typeof obj.model.rows[$(this).attr("row_index")] != "undefined" ) list.push(obj.model.rows[$(this).attr("row_index")])
                });
               $.each(list, function () { 
                    if ($.inArray(this, obj.model.delList >= 0)) 
					{
						if(this.substring(0,3) != "new") obj.model.delList.push(''+this);
						obj.delRow(this);
					}
                });
                obj.refreshTable();
            });
            return tdDom
        },
		draw_add_cell: function (obj, data, index, footerClasses) {
            var hasFooter = typeof footerClasses == "object";
            var tdClass = hasFooter && typeof footerClasses["td"] == "string" ? ' class="' + footerClasses["td"] + '"' : "";
            var btnClass = hasFooter && typeof footerClasses["add-button"] == "string" ? ' class="' + footerClasses["add-button"] + '"' : "";
            var tdDom = $("<td" + tdClass + "><button" + btnClass + ">"+obj.params.json.footer[0].cells[index].data.caption+"</button></td>");//
            tdDom.find("button").bind("click", function () {
				obj.model.rows.push('new_'+addRowInd);
				obj.model.table.push(clone(obj.params.json.newRow));
				addRowInd++;
				obj.refreshTable()
            });
            return tdDom
        },
        draw_dummy_cell: function (obj, data, index, footerClasses) {
            this._afterList.push(function (trDom) {
                if (index > 0) $("td:eq(" + (index - 1) + ")", trDom).addClass("no_bor_r");
                if ($("td:eq(" + index + ")", trDom).length > 0) $("td:eq(" + index + ")", trDom).addClass("no_bor_l_r");
                if ($("td:eq(" + (index + 1) + ")", trDom).length > 0) $("td:eq(" + (index + 1) + ")", trDom).addClass("no_bor_l")
            });
            return "<td>" + data.caption + "</td>"
        }
    };
    $.drawTable.defaults = {
        json: {},
        divPath: "#div-space",
        clone: true,
        styles: {
            colsWidth: [300, 170, 120]
        },
        classes: {
            header: [],
            table: [],
            footer: []
        },
        debug: false
    }
})(jQuery);

function clone(o) {
	if(!o || 'object' !== typeof o)  {
		return o;
	}
 
	var c = 'function' === typeof o.pop ? [] : {};
	var p, v;
	for(p in o) {
		if(o.hasOwnProperty(p)) {
			v = o[p];
			if(v && 'object' === typeof v) {
				c[p] = clone(v);
			} else {
			c[p] = v;
			}
		}
	}
  return c;
};

jQuery(function ($) {
	$.fn.quicksearch = function (target, opt) {
		
		var timeout, cache, rowcache, jq_results, val = '', e = this; 
		var options = $.extend({ 
			delay: 100,
			dropdown : '#qs_list',
			currentClass : 'ui-current',
			selector: null,
			stripeRows: null,
			loader: null,
			noResults: '',
			bind: 'keyup',
			onBefore: function () {
				return;
			},
			onAfter: function () { 
				return;
			},
			show: function () {
				this.style.display = "";
			},
			hide: function () {
				this.style.display = "none";
			}
		}, opt);
		
		var $dropdown = $(options.dropdown);
		var currrent_element = 0;
		
		
		this.go = function () {
			
			var i = 0, noresults = true, vals = val.toLowerCase().split(' ');
			
			var rowcache_length = rowcache.length;
			for (var i = 0; i < rowcache_length; i++)
			{
				if (this.test(vals, cache[i]) || val == "") {
					options.show.apply(rowcache[i]);
					noresults = false;
				} else {
					options.hide.apply(rowcache[i]);
				}
			}
			
			if (noresults) {
				this.results(false);
			} else {
				this.results(true);
				this.stripe();
			}
			
			this.loader(false);
			options.onAfter();
			
			return this;
		};
		
		this.stripe = function () {
			
			if (typeof options.stripeRows === "object" && options.stripeRows !== null)
			{
				var joined = options.stripeRows.join(' ');
				var stripeRows_length = options.stripeRows.length;
				
				jq_results.not(':hidden').each(function (i) {
					$(this).removeClass(joined).addClass(options.stripeRows[i % stripeRows_length]);
				});
			}
			
			return this;
		};
		
		this.strip_html = function (input) {
			var output = input.replace(new RegExp('<[^<]+\>', 'g'), "");
			output = $.trim(output.toLowerCase());
			return output;
		};
		
		this.results = function (bool) {
			if (typeof options.noResults === "string" && options.noResults !== "") {
				if (bool) {
					$(options.noResults).hide();
				} else {
					$(options.noResults).show();
				}
			}
			return this;
		};
		
		this.loader = function (bool) {
			if (typeof options.loader === "string" && options.loader !== "") {
				 (bool) ? $(options.loader).show() : $(options.loader).hide();
			}
			return this;
		};
		
		this.test = function (vals, t) {
			for (var i = 0; i < vals.length; i += 1) {
				if (t.indexOf(vals[i]) === -1) {
					return false;
				}
			}
			return true;
		};
		
		this.cache = function () {
			
			jq_results = $(target);
			
			if (typeof options.noResults === "string" && options.noResults !== "") {
				jq_results = jq_results.not(options.noResults);
			}
			
			var t = (typeof options.selector === "string") ? jq_results.find(options.selector) : $(target).not(options.noResults);
			cache = t.map(function () {
				return e.strip_html(this.innerHTML);
			});
			
			rowcache = jq_results.map(function () {
				return this;
			});
			
			return this.go();
		};
		
		this.trigger = function (event) {
			this.loader(true);
			options.onBefore(event);
			
			window.clearTimeout(timeout);
			timeout = window.setTimeout(function () {
				e.go();
			}, options.delay);
			
			return this;
		};
		
		this.getKeyCode = function(event) {
			var char_code;
			if(!event) if(window.event) event=window.event;
			if(typeof(event.keyCode)=='number') char_code=event.keyCode;
			else if(typeof(event.which)=='number') char_code=event.which;
			else if(typeof(event.charCode)=='number') char_code=event.charCode;
			return char_code;
		};
		
		this.Element = function(idx, enter) {
			var next = currrent_element + idx;
			var $elements = $(target + ":visible")
			var count = $elements.length;
			if( next > count-1) { next = count-1; }
			if( next < 0) { next = 0; }
			$elements.each(function(idx) {
							 	$(this).removeClass(options.currentClass);			
								if(idx == next) {
									e._log("Element::next= " + next);
									$(this).addClass(options.currentClass);	
									if(enter == true) {
										e._log("Element::enter");
										var elemet_value = $(this).find("a").text(); 	//???
										e.attr( "value", elemet_value);
										e.triggerHandler("click");
										e._log("Element::enter:TEXT= " + elemet_value);
										$dropdown.hide(); 
										currrent_element = 1;
									}
								}
								
								currrent_element = next;
							 });		
		}
		
		this.keys = function() {
			e.bind("keydown", function(event) { 
									$dropdown.show(); 
									var char_code  = e.getKeyCode(event);
									switch (char_code){
										case 13:
        									e.Element(0, true); 
											event.preventDefault();
									    break;
									    case 27:
									       $dropdown.hide(); 
									    break;
									    case 38: 
											e.Element(-1, false); 
										break;
									    case 40: 
											e.Element(1, false); 
										break;
								    }
								}); 
		};
		
		this._log = function _log(obj) {
			//if(console != "undefined") { console.log(obj)}
			//else { alert(obj); }
		}
		
		this.cache();
		this.results(true);
		this.stripe();
		this.loader(false);
		this.keys();
		
		return this.each(function () {
			$(this).bind(options.bind, function (event) {
				val = $(this).val();
				e.trigger(event);
			});
		});
		
	};
});
