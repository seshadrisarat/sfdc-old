//--------------------------------------------------------------------------------
// main.js
//--------------------------------------------------------------------------------

// Driver for the Social Graph page; provides an interface between
// the aaGraph page and the info JIT toolkit's "spacetree".

//--------------------------------------------------------------------------------
// globals
//--------------------------------------------------------------------------------

var pkg;

function get(id) {
  return document.getElementById(id);  
  }

function addEvent(obj, type, fn) {
	if (obj.addEventListener) obj.addEventListener(type, fn, false);
	else obj.attachEvent('on' + type, fn);
	}

	
// global nodeClicked function calls into pkg-exported version
function nodeClicked(node_id) {
	pkg.nodeClicked(node_id);
	}


//--------------------------------------------------------------------------------
// init() - sets (and returns) global "pkg" var as a closure with four functions:
//	 nodeClicked(node_id)
//	 setRoot(node, oncomplete)
//	 addChildren(node[], oncomplete)
//	 done()
//--------------------------------------------------------------------------------

function init(newRootCallback) {
	// XXX todo: fix me w/ dynamic resizing canvas!
	var L3MAX = 15;
	
	var infovis = get('infovis');
	var w = infovis.offsetWidth, h = infovis.offsetHeight;
	//init canvas
	//Create a new canvas instance.
	var canvas = new Canvas('mycanvas', {
		'injectInto': 'infovis',
		'width': w,
		'height': h,
		'backgroundColor': '#1a1a1a'
	});

	//Implement a node rendering function called 'nodeline' that plots a straight line
	//when contracting or expanding a subtree.
	ST.Plot.NodeTypes.implement({
		'nodeline': function(node, canvas, animating) {
			if(animating == 'expand' || animating == 'contract') {
				var pos = node.pos.getc(true), nconfig = this.node, data = node.data;
				var width  = nconfig.width, height = nconfig.height;
				var algnPos = this.getAlignedPos(pos, width, height);
				var ctx = canvas.getCtx(), ort = this.config.orientation;
				ctx.beginPath();
				if(ort == 'left' || ort == 'right') {
					ctx.moveTo(algnPos.x, algnPos.y + height / 2);
					ctx.lineTo(algnPos.x + width, algnPos.y + height / 2);
				} else {
					ctx.moveTo(algnPos.x + width / 2, algnPos.y);
					ctx.lineTo(algnPos.x + width / 2, algnPos.y + height);
				}
				ctx.stroke();
			} 
		}
	});

	//init st
  //Create a new ST instance
  var st= new ST(canvas, {
		duration: 300,
		transition: Trans.Quart.easeInOut,
		levelDistance: 80,
		levelsToShow: 2,
		// align: 'left', // in default (left-right) layout, this puts all children below the parent (instead of branching up/middle/down)

		Node: {
			height: 43,
			width: 150,
			//use a custom
			//node rendering function
			type: 'nodeline',
			color:'#1a1a1a',
			lineWidth: 2,
			align:"center",
			overridable: true
			},
		
		Edge: {
			type: 'bezier',
			lineWidth: 5,
			color:'#23A4FF',
			overridable: true
		},

		onCreateLabel: function(label, node) {
		  label.id = node.id;   
		  label.innerHTML = getNodeHTML(node);
   		},
		
		onBeforePlotLine: function(edge){
			edge.data.$lineWidth = getEdgeWidth(edge);
    	}

	 });


	function nodeClicked(node_id) {
		if (node_id != st.root) {
			var n = st.graph.getNode(node_id);
			setNodeSubscript(node_id, 'loading...');
			st.setRoot(n.id, 'animate', {
				onComplete: function() {
					cleanNodes();
					st.removeSubtree(n.id, false, 'replot'); // note 'animate' looks odd (flashes), and 'replot' ignores 'onComplete' (but appears to be synchronous)
					n.children = null;
					n.data.count = null;
					jPostTable(n.id).parents('div.popup').first().fadeOut('fast', function() { jPostTable(n.id).html(''); }); // clear the post table after fading out
					newRootCallback(n); // starts the data loading callouts too
					}
				});
			}
		}

	function cleanNodes() {
		jQuery('div.node').each(function() {
			jPostTable(this.id).html(''); 
			setNodeSubscript(this.id, '');
			}); // remove all existing posts
		}

	// nb: "escapeHTML" is a prototype method
	function getNodeHTML(n) {
		return '<div class="nodeIcon">' + getGravatar(n,32) + '</div>' +
			'<div class="name"><a href="#" onclick="nodeClicked(\'' + n.id + '\');return false;">' + n.name.escapeHTML() + '</a></div>' +
			'<div class="subscript"></div>' +
			'<div class="popup"><div class="wrap"><div class="header">' + getPopupHeader(n) + '</div><div class="body"><span style="font-size:110%;font-weight:bold;">Recent Emails</span><table class="postTable" cellspacing="8" cellspacing="0" width="100%"><tbody></tbody></table></div><div class="footer"></div></div></div>';
		}


	//-------------------------------------------------------------------------------
	// node subscript
	//-------------------------------------------------------------------------------
	function setNodeSubscript(n, txt) {
		if (! n instanceof Object ) n = st.graph.getNode(n); // can be called with node_id
		if (txt == null) txt = getSubscriptText(n);
		jQuery('#' + n.id + ' div.subscript').html(txt);
		}
		
	function getSubscriptText(n) {
		var ct = n.data.count;
		if (ct == null) { // root node
			ct = 0;
			n.children.each(function(i) { ct += i.data.count; });
			}
		return plural(ct, 'email');
		}
	function plural(ct, label) {
		return ct + ' ' + label + (ct == 1 ? '' : 's');
		}
	function getNodeParent(n) {
		return Graph.Util.getParents(n).shift(); // getParents() returns [] in no-parent case, so shift() returns null, which is what we want
		}

	//-------------------------------------------------------------------------------
	// node hover popup
	//-------------------------------------------------------------------------------
	function getPopupHeader(n) {
		return '<table cellspacing="0" cellpadding="0" border="0"><tbody><tr><td class="pbTitle ' + n.data.type.toLowerCase() + '">' + getGravatar(n,64) + '<h2 class="mainTitle">' + getViewLink(n) + '</h2></td></tr></tbody></table>';
		}
	function getGravatar(n, size) {
		return n.data.email == null
			? ''
			: '<img class="gravatar" src="https://secure.gravatar.com/avatar/' + md5(n.data.email) + '?size=' + size + '"/>';
		}
	function getViewLink(n) {
		var ret = n.data.type.capitalize() + ': ' + n.name.escapeHTML();
		return (n.data.type.toLowerCase() == 'user')
			? ret
			: '<a href="/' + n.id + '" target="_blank">' + ret + '</a>';
		}

	function addPostToPopups(n) {
		if (n.data.lastmsg == null) return;
		jPostTable(n.id).append(         getPopupPostRow(n.data.lastmsg, st.graph.getNode(n.data.fromId).name));
		jPostTable(n.data.fromId).append(getPopupPostRow(n.data.lastmsg, n.name                              ));
		}
	function getPopupPostRow(post, name) {
		return '<tr style="font-size:110%;"><td>' + name + '<span style="float:right;">' + fmtDate(post.sent) + '</span><br/><a href="/' + post.id + '" target="_blank"><i>' + (post.subject || '').escapeHTML() + '<i/></a></td></tr>';
		}
	function jPostTable(id) {
		return jQuery('#' + id + ' table.postTable tbody');
		}



	function fmtDate(dt) {
		var then = new Date(dt), now = new Date();
		if (then.getYear() == now.getYear()) {
			if (then.getMonth() == now.getMonth() && then.getDate() == now.getDate())
				return dateFormat(then, "'Today', mmm d h:MM TT");
			else return dateFormat(then, "mmm d h:MM TT");
			}
		else return dateFormat(then, "isoDate");
		}


	//--------------------------------------------------------------------------------
	// setRoot
	//--------------------------------------------------------------------------------
	var l3hash = blankL3Hash();

	function setRoot(n, onComplete) {
		if (!onComplete) onComplete = function() {};

		cleanNodes();
		if (st.root != null) st.removeSubtree(st.root, false, 'replot');
		canvas.clear();
		prepNode(n);
		st.loadJSON(n);
		st.compute();
		st.onClick(st.root, { onComplete: onComplete });
	  }
	function getRoot() {
		return st.graph.getNode(st.root);
		}
	 
	function addChildren(children, level, onComplete) {
		if (!onComplete) onComplete = function() {};
		
		children.each(function(n) { prepNode(n); });

		if (level == 2) {
	 		getRoot().children = children;
	 		setNodeSubscript(getRoot()); // do this now, while node still has children (they seem to go away later...)
		 	st.addSubtree(getRoot(), 'animate', { hideLabels: false, onComplete: function() { children.each(function(n) { addPostToPopups(n); }); onComplete(); } } );
	 		}
	 	else {
			l3hash = parseChildData(children);
			var nodes = getRoot().children;
			var addL3Children = function() {
				var n = nodes.shift();
				if (n) {				
					n.children = $A(l3hash.get(n.id) || []).sortBy(function(n) { return n.name; });
					st.addSubtree(n, 'animate', { hideLabels: false, onComplete: addL3Children });
					}
				else {
					addExtras(); // done adding & animating all subtrees
					children.each(function(n) { addPostToPopups(n); });
					onComplete();
					}
				};
			addL3Children();
			}
		}

	function prepNode(n) {
		if (!n.data) n.data = {};
		if (!n.children) n.children = [];
		n.data.dir = 'by'; // TODO: get rid of this!
		}

	//-------------------------------------------------------------------------------
	// extra-edge-adding functions
	//-------------------------------------------------------------------------------
	function addExtras() {
		l3hash.get('extra').each(addExtra);
		}
	function addExtra(n) {
		$A(st.graph.addAdjacence({'id': n.data.fromId}, {'id': n.id})).each(function(edge) { showEdge(edge); });
  	}


	//-------------------------------------------------------------------------------
	// edge (re)drawing functions
	//-------------------------------------------------------------------------------
	function getEdgeWidth(edge) {
		// note that edge.nodeTo is not necessarily the deeper node
		var f = edge.nodeFrom, t = edge.nodeTo;
		if (getDepth(edge.nodeFrom) > getDepth(edge.nodeTo)) { f = edge.nodeTo; t = edge.nodeFrom; }
		
		if (l3hash.get('counts').get(countsKey(f.id,t.id)))
			return l3hash.get('counts').get(countsKey(f.id,t.id));

		if (t.data && t.data.count) return t.data.count;
		return edge.data.$lineWidth;
		}

	function adjTo(edge, n) { return edge.nodeFrom.id == n.id || edge.nodeTo.id == n.id; }
	
	// redraws 2nd & 3rd level edges
	// if n is non-null, hides all edges except those connected to n
	// otherwise shows all edges
	function redrawEdges(n) {
		var all = l3Edges(), lose = [], keep = [];
		if (!n) keep = all;
		else { all.each(function(edge) { (adjTo(edge, n) ? keep : lose).push(edge); }); }
		lose.each(hideEdge);
		keep.each(showEdge);
		}
	
	function hideEdge(edge) {
		edge.data.$color = '#222';
		edge.data.$lineWidth = 2 + getEdgeWidth(edge);
		st.fx.plotLine(edge, canvas);
		}
	
	function showEdge(edge) {
		edge.data.$color = '#23A4FF';
		edge.data.$lineWidth = getEdgeWidth(edge);
		st.fx.plotLine(edge, canvas);
		}

	function l3Nodes() {
		return $A(l3hash.get('primary')).collect(function(n) { return st.graph.getNode(n.id); });
		}

	function l3Edges() {
		return l3Nodes().collect(function(n) { return getEdges(n); }).flatten();
		}

	//-------------------------------------------------------------------------------
	// XXXX UNSAFE calls that use JIT v1.1.3 private apis
	//-------------------------------------------------------------------------------
	function getDepth(n) { return n._depth; }
	function getEdges(n) {
		var ret = [];
		for (var p in n.adjacencies) { if (n.adjacencies[p] instanceof Object) ret.push(n.adjacencies[p]); }
		return ret;
		}
	

	//--------------------------------------------------------------------------------
	// l3 parsing
	//--------------------------------------------------------------------------------
	
	/*
	Normalizes l3 relations so each l3 node is the child of a single l2 parent
	
	Returns a hash keyed by parent ID ( parent1 : [children], parent2: [children] )
	
	These single-parent relations are the 'primary' relations, the multi-parent relations
	are the 'extra' relations.  Both 'primary' and 'extra' are also placed in the return
	hash.  (note 'extra' + 'primary' == input).
	
	Finally, we place all l2:l3 edge counts into a 'counts' hash.
	
	Once 'primary' has gotten to L3MAX nodes, we stop adding non-extra nodes to our hash.
	
	This input:
	
	{ id: "1", data: { fromId: "a", count: 1 }}
	{ id: "2", data: { fromId: "a", count: 2 }}
	{ id: "2", data: { fromId: "b", count: 3 }}
	{ id: "3", data: { fromId: "b", count: 4 }}
	
	returns this:
	
	{ a: [
			{ id: "1", data: { fromId: "a" }}
			{ id: "2", data: { fromId: "a" }}
			],
		
		b: [ { id: "3", data: { fromId: "b" }} ],
		
		extra: [ { id: "2", data: { fromId: "b" }} ],
		
		primary: [ 
			{ id: "1", data: { fromId: "a" }}
			{ id: "2", data: { fromId: "a" }}
			{ id: "3", data: { fromId: "b" }}
			],
		
		counts: $H({
			'1:a' : 1,
			'2:a' : 2,
			'2:b' : 3,
			'3:b' : 4
			})

		}

	*/
	function parseChildData(nodes) {
		var ret = blankL3Hash();

		var counts = $H();
		var primary = [];
		var extra = [];

		var seen = $H();
		$A(nodes).each(function(n) {
			if (seen.get(n.id)) {
				extra.push(n);
				counts.set(countsKey(n.data.fromId, n.id), n.data.count);
				}
			else if (primary.length < L3MAX) {
				var tmp = ret.get(n.data.fromId);
				if (!tmp) tmp = ret.set(n.data.fromId, []);
				tmp.push(n);

				counts.set(countsKey(n.data.fromId, n.id), n.data.count);
				primary.push(n);
				seen.set(n.id, 1);
				}
			});
		ret.set('primary', primary);
		ret.set('counts', counts);
		ret.set('extra', extra);
		return ret;
		}

	function blankL3Hash() {
		return $H({'primary': [], 'extra': [], 'counts': $H()});
		}

	function countsKey(id1, id2) {
		return id1 + ':' + id2;
		}



	//--------------------------------------------------------------------------------
	// done()
	//--------------------------------------------------------------------------------
	
	function done() { // add Hover effects to nodes
		var hoverTimer = null;
		var $j = jQuery;
		$j("div.node").hover(
			function() { 
				if (hoverTimer) clearTimeout(hoverTimer);
				if (this.id != st.root) redrawEdges(st.graph.getNode(this.id));
				$j(this).children('div.popup').first().stop(true, true).fadeIn('fast');
				},
			function() {
				if (hoverTimer) clearTimeout(hoverTimer);
				if (this.id != st.root) hoverTimer = setTimeout(function() { redrawEdges(); }, 200);
				$j(this).children('div.popup').first().fadeOut('fast');
				}
			);
		
		// apply custom positioning to popups; clear old custom positioning
		$j("div.popup").each(function() {
			var jdiv = $j(this);
			var n = st.graph.getNode(jdiv.parent().attr('id'));
			if (!n) return; // happens if an old node hasn't been cleared from the DOM yet, so $j("div.popup") catches it despite not wanting it
			
			if (n.id != st.root) setNodeSubscript(n); // root subscript set in loadChildren()
			
			// second level pop-ups on left, all others on right
			jdiv.toggleClass('left', getDepth(n) == 1);
			
			if (jdiv.css('background-position')) { // comes up null in IE8
				var offset = jdiv.height() / 2;
				var topOffset = offset + 20, arrowOffset = offset - 10;
				jdiv.css('top', '-' + topOffset + 'px');

				jdiv = jdiv.find('div.wrap').first();
				jdiv.removeAttr('style'); // remove old element style, so we're back to working off class values
				
				var arrowPos = jdiv.css('background-position').split(' ');
				arrowPos[1] = arrowPos[1].replace(/px/,'') - 0; // remove 'px' and coerce to number
				arrowPos[1] = arrowPos[1] = (arrowPos[1] + arrowOffset) + 'px';
				jdiv.css('background-position', arrowPos.join(' '));
				}
			});
		}

	return pkg = {
		nodeClicked: nodeClicked,
		setRoot: setRoot,
		addChildren: addChildren,
		done: done
		};

	} // end of 'init' function
