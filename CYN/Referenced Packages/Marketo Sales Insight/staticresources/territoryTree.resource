/**
 *  Territory Tree
 *  Build the territory tree from geoFilterJson
 */
Ext.namespace('Mkt', 'Mkt.territory');

Mkt.territory.buildTerritoryTree = function (renderTo, geoFilterArray) {  
  //Marketo.clockCursor();
  
  if (Mkt.territory.territoryTreePanel) { return; } 
  
  Mkt.territory.geoFilterArray = geoFilterArray;
  
  Mkt.territory.territoryTreeJson = Mkt.territory.buildTreeFromGeoFilter(geoFilterArray);
  //console.debug('Mkt.territory.territoryTreeJson=', Mkt.territory.territoryTreeJson);
  
  //console.debug('Building the tree');
  
  Mkt.territory.territoryTreePanel = new Ext.tree.TreePanel({
    renderTo:renderTo,
    autoWidth: true,
    autoHeight: true,
    useArrows:true,
    baseCls: 'x-plain',
    autoScroll:true,
    border: '1px solid #ccc',
    loadMask: true,
    animate:true,
    enableDD:false,
    containerScroll: true,
    rootVisible: false,
    frame: false,
    root: { children: Mkt.territory.territoryTreeJson },
    listeners: {
        'checkchange': function(node, checked){
            if (Mkt.territory.updateGeoFilterJsonNodeId == null) {
              Mkt.territory.updateGeoFilterJsonNodeId = node.id;
            }
                        
            if(checked){
              node.getUI().addClass('use');
            }
            else {
              node.getUI().removeClass('use');
            }
            
            Mkt.territory.toggleCheckChildren(node);
            Mkt.territory.toggleCheckParentNode(node, checked);
            
            if (node.id == Mkt.territory.updateGeoFilterJsonNodeId) {
              Mkt.territory.updateGeoFilterJson(node);
              Mkt.territory.updateGeoFilterJsonNodeId = null;
            }
        },
        'beforeexpandnode': function (node, deep, anim) {
            //console.debug('beforeexpandnode', node, node.attributes.checked);
            if (node.attributes.checked) {
              Mkt.territory.toggleCheckChildren(node);
            }
        },
        'click': function (node) {
           node.ui.toggleCheck();
        }
    },
   ender: true
  });  // end of tree constructor
  
} 

Mkt.territory.updateGeoFilterJsonNodeId = null;

/**
 *  Utility methods
 */
Mkt.territory.buildTreeFromGeoFilter = function (geoArray, depth, expandToDepth) {
  if (depth === undefined) depth = 0;
  if (expandToDepth === undefined) expandToDepth = 1;
  
  var treeArray = [];
  for (var i=0; i<geoArray.length; i++) {
    var geoNode = geoArray[i];
    
    if(depth < expandToDepth) {
      //console.debug('geoNode', geoNode.name, depth, geoNode);
    }
    
    var treeNode = {
      text: geoNode.name,
      cls: depth == 0 ? 'earth_location' : 'plain',
      checked: geoNode.use == '1',
      expanded: geoNode.use == '2' || depth < expandToDepth,
      geoNode: geoNode
    };
    
    // Build children, if any
    if (geoNode.subDiv) {
      treeNode.children = Mkt.territory.buildTreeFromGeoFilter(geoNode.subDiv, depth+1, expandToDepth);
    }
    else {
      treeNode.leaf = true;
    }
    
    treeArray.push(treeNode);
    
  }
  
  return treeArray;
}


// Returns Boolean "used" if any item in the array is in use
Mkt.territory.updateGeoFilterFromTree = function (geoArray, checkedTreeNodes) {
  var used = false;
  
  for (var i=0; i<geoArray.length; i++) {
    var geoNode = geoArray[i];
    geoNode.use = '0';
    
    // Set use='1' if this geoNode is in the array of "checked" tree nodes
    for (var j=0; j<checkedTreeNodes.length; j++) {
      var treeGeo = checkedTreeNodes[j].attributes.geoNode;
      if (geoNode.code == treeGeo.code && geoNode.name == treeGeo.name) {
        geoNode.use = '1';
        used = true;
        //console.debug('geoNode is used', geoNode, treeGeo);
        break;
      }
    }
    
    // Update children, if any
    if (geoNode.subDiv) {
      var childrenUsed = Mkt.territory.updateGeoFilterFromTree(geoNode.subDiv, checkedTreeNodes);
      if (childrenUsed) {
        used = true;
        if (geoNode.use == '0') {
          geoNode.use = '2';
        }
      }
    }
    
  }
  
  return used;
}

Mkt.territory.toggleCheckChildren = function (node) {
  if (!node.childNodes || !node.attributes.children) { return; }
  
  var checked = node.attributes.checked;
  
  var cs = node.childNodes;
  if (cs) {
    for(var i = 0, len = cs.length; i < len; i++){
      var n = cs[i];
      Mkt.territory.toggleCheckNode(n, checked);
      Mkt.territory.toggleCheckChildren(n);
    }
  }
  
  var cs = node.attributes.children;
  if (cs) {
    for(var i = 0, len = cs.length; i < len; i++){
      var n = cs[i];
      n.checked = checked;
      Mkt.territory.toggleCheckChildren(n);
    }
  }
}

Mkt.territory.toggleCheckParentNode = function (node, checked) {
  if (node.parentNode) {
    if (checked) {
      // only check the parent node if all child nodes are checked
      var cs = node.parentNode.childNodes;
      for(var i = 0, len = cs.length; i < len; i++){
        if (!cs[i].attributes.checked) return;
      }
    }
    Mkt.territory.toggleCheckNode(node.parentNode, checked);
    Mkt.territory.toggleCheckParentNode(node.parentNode, checked);
  }
}

Mkt.territory.toggleCheckNode = function (node, checked) {
  var cb = node.ui.checkbox;
  if (cb) {
    cb.checked = checked;
    cb.defaultChecked = checked; // fix for IE6
    node.attributes.checked = checked;
  }
}

Mkt.territory.updateGeoFilterJson = function (node) {
  var checkedTreeNodes = Mkt.territory.territoryTreePanel.getChecked();
  //console.debug('checkedTreeNodes', checkedTreeNodes);
  Mkt.territory.updateGeoFilterFromTree(Mkt.territory.geoFilterArray, checkedTreeNodes);
  var geoFilterJson = Ext.util.JSON.encode(Mkt.territory.geoFilterArray);
  
  var field = Mkt.territory.getTerritoryField();
  field.value = geoFilterJson;
};

Mkt.territory.territoryField = null;
Mkt.territory.getTerritoryField = function() {
  if (Mkt.territory.territoryField == null) {
    var forms = document.forms;
    var territoryForm = null;
    for (var i=0; i<forms.length; i++) {
      if (forms[i].id.indexOf('territoryForm') != -1) {
        territoryForm = forms[i];
        break;
      }
    }
    var field = null;
    for (var i=0; i<territoryForm.elements.length; i++) {
       if (territoryForm.elements[i].id.indexOf('geoFilterJsonHidden') != -1) {
         field = territoryForm.elements[i];
         break;
       }
    }
    Mkt.territory.territoryField = field;
  }
  
  return Mkt.territory.territoryField;
};

