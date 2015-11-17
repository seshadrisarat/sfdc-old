/*
 *options = {
 *  "list" = "SELECTOR" or JQUERY object where selected list  displayed,
 *  "url" = server url to get data
 *  "data" = predefined list of data
 *  "params" = list of JSON params that must be send to server
 *  
 *  
 *}
 **/


(function($) {
    var apexSelector = function(el, options) {
        var self = {
            _dom : {},
            _nTimer : null,
            _name : '',
            _data : [],
            _result : []
        };
        
        self._init = function(options){
            self._options = options;
            if (options.data != undefined && options.data.length > 0) {
                self._data = options.data;
            }
            self._initDOM();
            self._initEvents();
        } 
        
        self._initDOM = function() {
            self._dom.el = el;
            self._dom.el.data('result', self._result);
            self._dom.parent = self._dom.el.parent();
            self._dom.parent.css('position', 'relative');
            self._name = el.attr('name');
            
            if (self._options.list != undefined) {
                if (typeof(self._options.list) == 'string') {
                    self._dom.list = jQuery(self._options.list);
                } else {
                    self._dom.list = self._options.list;
                }
            } else {
                //self._dom.list = jQuery('<div class="added_list"></div>').insertAfter(el);
                //self._dom.list = jQuery('<div class="added_list"></div>').insertBefore(el);
                self._dom.list = jQuery('').insertBefore(el);
            }
            self._dom.filter = jQuery('<div class=apex_filter>'
                + '<div class="title">'
                        + '<span data-action="prev_selector" class="simple_button" title="Previous">&lt;</span>'
                        + '<span data-action="next_selector" class="simple_button" title="Next">&gt;</span>'
                        + '<span data-action="close_filter" class="_close_filter" title="Close">X</span>'
                    + '</div>'
                    + '<div class=list></div>'
                + '</div>').insertAfter(el);
            var aParentOffset = self._dom.parent.offset(),
                aElOffset = self._dom.el.offset();
            
            self._dom.filter
                .css('position', 'absolute')
                .css('display', 'none')
                .width(self._dom.el.width())
                .css('top', parseInt(aElOffset.top - aParentOffset.top + self._dom.el.height()) + 'px' )
                .css('left', parseInt(aElOffset.left - aParentOffset.left) + 'px' );
        }
        
        self._initEvents = function() {
            self._dom.el.on('keydown.apexSelector', function(evt){
                if (evt.which === 13) {
                    evt.cancelBubble = true;
                    evt.stopPropagation();
                    return false;
                }
            });
            self._dom.el.on('keyup.apexSelector', function(evt){
                return self._startFilter(evt);
            });
            self._dom.filter.on('click.apexSelector', 'div.list > div', function(evt){
                self._appendFilterValue(evt);
            });
            self._dom.list.on('click.apexSelector', 'div', function(evt){
                self._removeFilterValue(evt);
            });
            
            self._dom.parent.on('click.apexSelector', '[data-action]', function(evt){
                var oEl = jQuery(evt.target);
                if (self['_' + oEl.data('action') + 'Action'] != 'undefined') {
                    self['_' + oEl.data('action') + 'Action'](evt);
                }
            });
        }
        

        self._startFilter = function(evt) {
            var sText = el.val();
            
            switch (evt.which ) {
                case 27 :
                    self._close_filterAction();
                    break;
                case 38 :
                case 40 :
                    self._filterSelectorChange(evt.which == 38 ? -1 : 1);
                    break;
                case 13 :
                    self._filterSelectorClick(evt);
                    return false;
                    

            }
            if ((evt.which <= 48 || evt.which >= 91) && evt.which != 8 && evt.which != 46) {
                return;
            }
            self._showFilter(sText);
        }
        
        self._showFilter = function(sText) {
            if (!self._dom.filter.is(':visible')){
                self._dom.filter.show();
            }
            self._dom.filter
                .show()
                .data('text', sText)
                .data('page', 0);
            self._refreshFilter(sText);
        }
        
        self._refreshFilter = function(sText) {
            if (self._nTimer != null) {
                clearTimeout(self._nTimer);
                self._nTimer = null;
            }
            sText = sText != undefined ? sText : self._dom.filter.data('text');
            var nPage = self._dom.filter.data('page') == undefined ? 0 : self._dom.filter.data('page'),
                aServerParams = jQuery.extend({}, self._options.params, {"field" : self._name, 'text' : sText, 'selel' : self._result.join(','), 'page' : nPage});
            
            if (self._options.url != undefined && self._options.url != '') {
                self._nTimer = setTimeout(function(){
                    jQuery.get(self._options.url, aServerParams, function(data){
                        self._data = data.list;
                        self._refreshFilterList(sText);
                        self._dom.filter.find('[data-action="next_selector"]').toggle(data.next === true);
                        self._dom.filter.find('[data-action="prev_selector"]').toggle(data.prev === true);
//                        self._checkSelectorPosition();
                    }, 'json');
                }
                , 200);
            } else {
                self._refreshFilterList(sText);
            }
        }
        
        self._refreshFilterList = function(sText) {
            
            self._data.sort(function(a, b){
                return a.name > b.name;
            });
            
            var sHTML = "";
            for (var nI = 0; nI <  self._data.length; nI++) {
                if (self._options.url != undefined || self._data[nI].name.indexOf(sText) >= 0) {
                    sHTML += '<div data-id="' + self._data[nI].id + '" '
                        + '>'
                        + self._data[nI].name
                        + '</div>';
                }
            }
            self._dom.filter.find('.list').html(sHTML);
        }
        
        
        self._appendFilterValue = function(evt) {
            var oEl = jQuery(evt.target);
            self._dom.list.append('<div data-id=' + oEl.data('id') + '>' + oEl.text() + '</div>');
            self._dom.el.focus().val('');
            self._dom.filter.hide();
            self._result.push(oEl.data('id'));
        }
        
        
        
        self._filterSelectorChange = function(nDir) {
            var aSelected = self._dom.filter.find('.list').find('.sel');
            if (aSelected.size() < 1) {
                self._dom.filter.find('.list').children(':first-child').addClass('sel');
            } else {
                var aNewSelected = (nDir > 0 ? aSelected.next() : aSelected.prev());
                if (aNewSelected.size() > 0) {
                    aSelected.removeClass('sel');
                    aNewSelected.addClass('sel');
                }
            }
        }
        
        self._filterSelectorClick = function(evt) {
            var aSelected = self._dom.filter.find('.list').find('.sel');
            if (aSelected.size() < 1) {
                aSelected = self._dom.filter.find('.list').children(':first-child');
            }
            if (aSelected.size() > 0) {
                aSelected.trigger('click');
            }
        }
        
        self._removeFilterValue = function(evt) {
            var oEl = jQuery(evt.target),
                nPos = self._result.indexOf(oEl.data('id'));
            if (nPos >= 0) {
                self._result.splice(nPos, 1);
            }
            
            oEl.remove();
        }
        
        
        self._close_filterAction = function(el, evt) {
            self._dom.filter.hide();
        }

        self._next_selectorAction = function(el, evt) {
            self._dom.filter.data('page', self._dom.filter.data('page') + 10);
            self._refreshFilter();
        }

        self._prev_selectorAction = function(el, evt) {
            self._dom.filter.data('page', self._dom.filter.data('page') - 10);
            self._refreshFilter();
        }
        
        
        self._init(options);
        
        
        
    }
    // convert to jquery plugin        
    $.fn.apexSelector = function(options) {
        return this.each(function() {
            return new apexSelector($(this), options);
        });
    }

}(jQuery));