/*
 * jQuery UI Multiselect
 *
 * Authors:
 *  Michael Aufreiter (quasipartikel.at)
 *  Yanick Rochon (yanick.rochon[at]gmail[dot]com)
 *
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * http://www.quasipartikel.at/multiselect/
 *
 *
 * Depends:
 *	ui.core.js
 *	ui.sortable.js
 *
 * Optional:
 * localization (http://plugins.jquery.com/project/localisation)
 * scrollTo (http://plugins.jquery.com/project/ScrollTo)
 *
 * Todo:
 *  Make batch actions faster
 *  Implement dynamic insertion through remote calls
 */


(function($) {

$.widget("ui.multiselect", {
  options: {
		sortable: true,
		searchable: true,
        doubleClickable: true,
		animated: 'fast',
		show: 'slideDown',
		hide: 'slideUp',
		dividerLocation: 0.6,
		pageSize: 100,
		nodeComparator: function(node1,node2) {
			var text1 = node1.text(),
			    text2 = node2.text();
			return text1 == text2 ? 0 : (text1 < text2 ? -1 : 1);
		}
	},
	_create: function() {
		this.element.hide();
		this.available = [];
        this.visible = [];
        this.selected = [];
        this.pages = [];
		this.currentPage = 0;
		this.id = this.element.attr("id");
		this.container = $('<div class="ui-multiselect ui-helper-clearfix ui-widget"></div>').insertAfter(this.element);
		this.count = 0; // number of currently selected options
		this.availableContainer = $('<div class="available"></div>').appendTo(this.container);
		this.selectedContainer = $('<div class="selected"></div>').appendTo(this.container);
		this.selectedActions = $('<div class="actions ui-widget-header ui-helper-clearfix"><span class="count">0 '+$.ui.multiselect.locale.itemsCount+'</span><a href="#" class="remove-all">'+$.ui.multiselect.locale.removeAll+'</a></div>').appendTo(this.selectedContainer);
		this.availableActions = $('<div class="actions ui-widget-header ui-helper-clearfix"><input type="text" class="search empty ui-widget-content ui-corner-all"/><a href="#" class="add-all">'+$.ui.multiselect.locale.addAll+'</a></div>').appendTo(this.availableContainer);
		this.selectedList = $('<ul class="selected connected-list"><li class="ui-helper-hidden-accessible"></li></ul>').bind('selectstart', function(){return false;}).appendTo(this.selectedContainer);
		this.availableList = $('<ul class="available connected-list"><li class="ui-helper-hidden-accessible"></li></ul>').bind('selectstart', function(){return false;}).appendTo(this.availableContainer);
		this.pageControls = $('<div class="ui-helper-clearfix"></div><div class="ui-helper-clearfix ui-tool-bar-container ui-widget-header"><ul class="ui-tool-bar"><li class="firstPage ui-tool-icon">&laquo;</li><li class="prevPage ui-tool-icon">&lsaquo;</li><li class="ui-tool-label"><span class="pagesLabel"></span></li><li class="nextPage ui-tool-icon">&rsaquo;</li><li class="lastPage ui-tool-icon">&raquo;</li></ul></div>').appendTo(this.container);

		var that = this;

		this.pageControls.find("li.nextPage").bind('click', function() { that._nextPage(); });
		this.pageControls.find("li.prevPage").bind('click', function() { that._prevPage(); });
		this.pageControls.find("li.firstPage").bind('click', function() { that._firstPage(); });
		this.pageControls.find("li.lastPage").bind('click', function() { that._lastPage(); });

		// set dimensions
		this.container.width(this.element.width()+1);
		this.pageControls.width(this.element.width()+1);
		this.selectedContainer.width(Math.floor(this.element.width()*this.options.dividerLocation));
		this.availableContainer.width(Math.floor(this.element.width()*(1-this.options.dividerLocation)));

		// fix list height to match <option> depending on their individual header's heights
		this.selectedList.height(Math.max(this.element.height()-this.selectedActions.height(),1));
		this.availableList.height(Math.max(this.element.height()-this.availableActions.height(),1));

		if ( !this.options.animated ) {
			this.options.show = 'show';
			this.options.hide = 'hide';
		}

		// init lists
        this._reset();

		// make selection sortable
		if (this.options.sortable) {
			this.selectedList.sortable({
				placeholder: 'ui-state-highlight',
				axis: 'y',
				update: function(event, ui) {
					// apply the new sort order to the original selectbox
					that.selectedList.find('li').each(function() {
						if ($(this).data('optionLink'))
							$(this).data('optionLink').remove().appendTo(that.element);
					});
				},
				receive: function(event, ui) {
					ui.item.data('optionLink').attr('selected', true);
					// increment count
					that.count += 1;
					that._updateCount();
					// workaround, because there's no way to reference
					// the new element, see http://dev.jqueryui.com/ticket/4303
					that.selectedList.children('.ui-draggable').each(function() {
						$(this).removeClass('ui-draggable');
						$(this).data('optionLink', ui.item.data('optionLink'));
						$(this).data('idx', ui.item.data('idx'));
						that._applyItemState($(this), true);
					});

					// workaround according to http://dev.jqueryui.com/ticket/4088
					setTimeout(function() { ui.item.remove(); }, 1);
				}
			});
		}

		// set up livesearch
		if (this.options.searchable) {
			this._registerSearchEvents(this.availableContainer.find('input.search'));
		} else {
			$('.search').hide();
		}

		// batch actions
		this.container.find(".remove-all").click(function() {
			that.element.find('option').removeAttr('selected');
            that._reset();
			return false;
		});

		this.container.find(".add-all").click(function() {
            $.each(that.pages[that.currentPage], function(idx, value) {
                $(value).attr('selected', 'selected');
            });
            that._reset();
			return false;
		});
	},
	destroy: function() {
		this.element.show();
		this.container.remove();

		$.Widget.prototype.destroy.apply(this, arguments);
	},
    _initLists: function() {
        var that = this;
        that.selected = [];
        that.available = [];
        this.element.find('option:selected').each(function(i, value) { that.selected.push(value); });
        this.element.find('option:not(:selected)').each(function(i, value) { that.available.push(value); });
        this.visible = this.available;
    },
    _reset : function() {
        this._initLists();
        this._populateSelected();
        if(this.options.searchable) {
            this._applyFilter(this.availableContainer.find('input.search'));
        }
        else {
            this._paginate();
            this._populateAvailable();
        }
    },
    _paginate: function() {
        this.currentPage = 0;
        var len = this._pageCount();
        this.pages = [];
        for(var idx = 0; idx < len; idx++) {
            var start = idx * this.options.pageSize;
            var end = start + this.options.pageSize;
            var page = this.visible.slice(start, end);
            this.pages.push(page);
        }
        
        if(this.pages.length == 0) {
           this.pages.push([]);
        }
        
    },
	_nextPage: function() {
	    if(this.currentPage == this._pageCount() - 1) return;
		this.currentPage++;
		this._populateAvailable();
	},
	_prevPage: function() {
	    if(this.currentPage == 0) return;
		this.currentPage--;
		this._populateAvailable();
	},
	_firstPage: function() {
		this.currentPage = 0;
		this._populateAvailable();
	},
    _lastPage: function() {
		this.currentPage = this._pageCount() - 1;
		this._populateAvailable();
	},
    _pageCount: function() {
    	var size = Math.floor(this.visible.length / this.options.pageSize);
    	var leftOver = Math.floor(this.visible.length % this.options.pageSize);
    	if(leftOver > 0) size++;

    	return size;
	},
    _populateAvailable: function() {
        this.availableList.children('.ui-element').remove();

        var that = this;
        var page = this.pages[this.currentPage];
        $.each(page, function(i, value) {
            var item = that._getOptionNode(value).appendTo(that.availableList).show();
            that._applyItemState(item, value.selected);
            item.data('idx', i);
        });
        this._updatePagination();
    },
	_populateSelected: function() {
		this.selectedList.children('.ui-element').remove();

		this.count = 0;

		var that = this;
		$.each(this.selected, function(i, value) {
			if (value.selected) {
			   that.count += 1;
	           var item = that._getOptionNode(value).appendTo(that.selectedList).show();
  			   that._applyItemState(item, value.selected);
   			   item.data('idx', i);
   			}
   		});

		// update count
		this._updateCount();
  },
	_updateCount: function() {
		this.selectedContainer.find('span.count').text(this.count+" "+$.ui.multiselect.locale.itemsCount);
	},
	_updatePagination: function() {
		this.pageControls.find('span.pagesLabel').text("Page " + (this.currentPage+1) +" of "+ this._pageCount());
	},
	_getOptionNode: function(option) {
		option = $(option);
		var node = $('<li class="ui-state-default ui-element" title="'+option.text()+'"><span class="ui-icon"/>'+option.text()+'<a href="#" class="action"><span class="ui-corner-all ui-icon"/></a></li>').hide();
		node.data('optionLink', option);
		return node;
	},
	// clones an item with associated data
	// didn't find a smarter away around this
	_cloneWithData: function(clonee) {
		var clone = clonee.clone();
		clone.data('optionLink', clonee.data('optionLink'));
		clone.data('idx', clonee.data('idx'));
		return clone;
	},
    _removeFromCurrentPage: function(option) {
        var o = option[0];
        var page = this.pages[this.currentPage];
        var idx = $.inArray(o, page);
        this.pages[this.currentPage] = page.slice(0, idx).concat(page.slice(idx+1));

        this.selected.push(o);
    },
    _removeFromSelected: function(option) {
        var o = option[0];
        var idx = $.inArray(o, this.selected);
        this.selected = this.selected.slice(0, idx).concat(this.selected.slice(idx+1));

        this.pages[this.currentPage].push(o);
    },
	_setSelected: function(item, selected) {
		item.data('optionLink').attr('selected', selected);

		if (selected) {
            this._removeFromCurrentPage(item.data('optionLink'));

			var selectedItem = this._cloneWithData(item);
			item[this.options.hide](this.options.animated, function() { $(this).remove(); });
			selectedItem.appendTo(this.selectedList).hide()[this.options.show](this.options.animated);

			this._applyItemState(selectedItem, true);
			return selectedItem;
		} else {
            this._removeFromSelected(item.data('optionLink'));

			// look for successor based on initial option index
			var items = this.availableList.find('li'), comparator = this.options.nodeComparator;
			var succ = null, i = item.data('idx'), direction = comparator(item, $(items[i]));

			// TODO: test needed for dynamic list populating
			if ( direction ) {
				while (i>=0 && i<items.length) {
					direction > 0 ? i++ : i--;
					if ( direction != comparator(item, $(items[i])) ) {
						// going up, go back one item down, otherwise leave as is
						succ = items[direction > 0 ? i : i+1];
						break;
					}
				}
			} else {
				succ = items[i];
			}

			var availableItem = this._cloneWithData(item);
			succ ? availableItem.insertBefore($(succ)) : availableItem.appendTo(this.availableList);
			item[this.options.hide](this.options.animated, function() { $(this).remove(); });
			availableItem.hide()[this.options.show](this.options.animated);

			this._applyItemState(availableItem, false);
			return availableItem;
		}
	},
	_applyItemState: function(item, selected) {
		if (selected) {
			if (this.options.sortable)
				item.children('span').addClass('ui-icon-arrowthick-2-n-s').removeClass('ui-helper-hidden').addClass('ui-icon');
			else
				item.children('span').removeClass('ui-icon-arrowthick-2-n-s').addClass('ui-helper-hidden').removeClass('ui-icon');
			item.find('a.action span').addClass('ui-icon-minus').removeClass('ui-icon-plus');
			this._registerRemoveEvents(item.find('a.action'));

		} else {
			item.children('span').removeClass('ui-icon-arrowthick-2-n-s').addClass('ui-helper-hidden').removeClass('ui-icon');
			item.find('a.action span').addClass('ui-icon-plus').removeClass('ui-icon-minus');
			this._registerAddEvents(item.find('a.action'));
		}
        this._registerDoubleClickEvents(item);
		this._registerHoverEvents(item);
	},
	_filter: function(that) {
		var input = $(this);
        that._applyFilter(input);
    },
    _applyFilter: function(input) {
		var term = $.trim(input.val().toLowerCase()), scores = [];

		if (!term) {
			this.visible = this.available;
		} else {
			this.visible = $.grep(this.available, function(value, idx) {
               return ($(value).text().toLowerCase().indexOf(term) > -1);
            });
		}
        this._paginate();
        this._populateAvailable();

	},
  _registerDoubleClickEvents: function(elements) {
    if (!this.options.doubleClickable) return;
    elements.dblclick(function(evt) {
      elements.find('a.action').click();
      evt.preventDefault();
      return false;
    });
  },
	_registerHoverEvents: function(elements) {
		elements.removeClass('ui-state-hover');
		elements.mouseover(function() {
			$(this).addClass('ui-state-hover');
		});
		elements.mouseout(function() {
			$(this).removeClass('ui-state-hover');
		});
	},
	_registerAddEvents: function(elements) {
		var that = this;
		elements.click(function(evt) {
			var item = that._setSelected($(this).parent(), true);
			that.count += 1;
			that._updateCount();
            if(that.pages[that.currentPage].length == 0) that._reset();
			evt.preventDefault();
			return false;
		});
		elements.dblclick(function(evt) {
			evt.preventDefault();
			return false;
		});

		// make draggable
		if (this.options.sortable) {
  		elements.each(function() {
  			$(this).parent().draggable({
  	      connectToSortable: that.selectedList,
  				helper: function() {
  					var selectedItem = that._cloneWithData($(this)).width($(this).width() - 50);
  					selectedItem.width($(this).width());
  					return selectedItem;
  				},
  				appendTo: that.container,
  				containment: that.container,
  				revert: 'invalid'
  	    });
  		});
		}
	},
	_registerRemoveEvents: function(elements) {
		var that = this;
		elements.click(function(evt) {
			that._setSelected($(this).parent(), false);
			that.count -= 1;
			that._updateCount();
			evt.preventDefault();
			return false;
		});
		elements.dblclick(function(evt) {
			evt.preventDefault();
			return false;
		});
		
 	},
	_registerSearchEvents: function(input) {
		var that = this;

		input.focus(function() {
			$(this).addClass('ui-state-active');
		})
		.blur(function() {
			$(this).removeClass('ui-state-active');
		})
		.keypress(function(e) {
			if (e.keyCode == 13)
				return false;
		})
		.keyup(function() {
			that._filter.apply(this, [that]);
		});
	}
});

$.extend($.ui.multiselect, {
	locale: {
		addAll:'Add all',
		removeAll:'Remove all',
		itemsCount:'items selected'
	}
});


})(jQuery);
