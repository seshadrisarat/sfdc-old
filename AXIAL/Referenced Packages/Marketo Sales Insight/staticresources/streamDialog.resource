/**
 *  Stream Dialog
 *  Build the Email Alert subscription modal dialog
 */
Ext.namespace('Mkt', 'Mkt.stream');
// Initialize the alert modal dialog.

 Mkt.stream = {
   showAlertModal: function(contactName, accountName, momentType, momentNote, emailAddress) {
     document.getElementById("mktAlertModalLead").value = contactName;
     document.getElementById("mktAlertModalAccount").value = accountName;
     document.getElementById("mktAlertModalType").value = momentType;
     document.getElementById("mktAlertModalDesc").value = momentNote;
      
     var label = document.getElementById("mktAlertModalChoice1Label");
     label.innerHTML = "<b>Name:</b><div class=\"mktRadioLabel\">" + contactName + "</div>";
      
     label = document.getElementById("mktAlertModalChoice2Label");
     label.innerHTML = "<b>Account:</b><div class=\"mktRadioLabel\">" + accountName + "</div>";
      
     label = document.getElementById("mktAlertModalChoice3Label");
     label.innerHTML = "<b>Type:</b><div class=\"mktRadioLabel\">" + momentType + "</div>";
      
     label = document.getElementById("mktAlertModalChoice4Label");
     label.innerHTML = "<b>Description:</b><div class=\"mktRadioLabel\">" + momentNote + "</div>";
      
     document.getElementById("mktAlertModalEmail").value = emailAddress;
      
     document.getElementById("mktAlertModal").style.display = "block";

     // We do *not* want pressing the Enter key to submit the form
     // due to craziness with apex:commandButton not being able to 
     // be a submit button if it has an oncomplete function.
     //
     var inputField = Ext.get("mktAlertModalEmail");
     
     // This adds handler on the <input>
     inputField.addListener('keypress', function(evt, t, o) {
       if (evt.getKey() == Ext.EventObject.ENTER) {
         evt.stopEvent();
         return false;
       }
       return true;
     });
     
     // This adds handler on the <form>
     inputField.parent().addListener('keypress', function(evt, t) {
       if (evt.getKey() == Ext.EventObject.ENTER) {
         evt.stopEvent();
         return false;
       }
       return true;
     });

     Mkt.stream.alertModalDialog.show();
   },

	// Subscribe to Lead|Contact|Account from their detail pages, not from Lead Feed
   	showSubscribeModal: function(contactName, accountName, emailAddress) 
   	{
		document.getElementById("mktAlertModalLead").value = contactName;
		document.getElementById("mktAlertModalAccount").value = accountName;
      
		var label = document.getElementById("mktAlertModalChoice1Label");
		label.innerHTML = "<b>Name:</b><div class=\"mktRadioLabel\">" + contactName + "</div>";
      
		label = document.getElementById("mktAlertModalChoice2Label");
		label.innerHTML = "<b>Account:</b><div class=\"mktRadioLabel\">" + accountName + "</div>";
      
		document.getElementById("mktAlertModalEmail").value = emailAddress;
      
		document.getElementById("mktAlertModal").style.display = "block";

		// We do *not* want pressing the Enter key to submit the form
		// due to craziness with apex:commandButton not being able to 
		// be a submit button if it has an oncomplete function.
		//
     	var inputField = Ext.get("mktAlertModalEmail");
     
     	// This adds handler on the <input>
     	inputField.addListener('keypress', function(evt, t, o) 
     	{
       		if (evt.getKey() == Ext.EventObject.ENTER) 
       		{
         		evt.stopEvent();
         		return false;
       		}
       		return true;
     	});
     
     	// This adds handler on the <form>
     	inputField.parent().addListener('keypress', function(evt, t) 
     	{
       		if (evt.getKey() == Ext.EventObject.ENTER) 
       		{
         		evt.stopEvent();
         		return false;
       		}
       		return true;
     	});

     	Mkt.stream.alertModalDialog.show();
   },


   // Function called when we want to hide the dialog
   hideAlertModal: function() {
     var inputField = Ext.get("mktAlertModalEmail");

     inputField.removeAllListeners();
     inputField.parent().removeAllListeners();
		 
     Mkt.stream.alertModalDialog.hide();
   },
     
  // Function called when the DOM is ready to create the dialog,
  // render the dialog into the document body, add our dialog skin
  // css to the body tag, and wire up the buttons on our dialog    
  initAlertModal : function() {
    document.body.className = document.body.className + " yui-skin-sam";
    Mkt.stream.alertModalDialog = new YAHOO.widget.Panel(
      "mktAlertModal",  // The id of our dialog container
      { 
        width           :   "380px",
        visible         :   false,  // Should be invisible when rendered
        draggable       :   true,   // Make the dialog draggable
        close           :   false,  // Don't include a close title button
        modal           :   true,   // Make it modal
        fixedCenter     :   true,   // Keep centered if window is scrolled
        zindex          :   40      // Make sure it's on top of everything
      });
     // Render the dialog to the document.body level of the DOM
     Mkt.stream.alertModalDialog.render(document.body);
  },
    
  checkRequiredFields : function() {
    var email = YAHOO.lang.trim(document.getElementById('mktAlertModalEmail').value);
       
    if (email.length > 0) {
      return true;
    } 
    else {
      mySimpleDialog = new YAHOO.widget.SimpleDialog(
        "mktAlertModalError",
        { 
          width        : "200px", 
          modal        : true,
          visible      : false,
          fixedcenter  : true,
          draggable    : false, 
          close        : false,
          zindex       : 50
        });
    
      mySimpleDialog.setHeader("Error");
      mySimpleDialog.setBody("Email address is required");
      mySimpleDialog.cfg.setProperty("icon",YAHOO.widget.SimpleDialog.ICON_WARN);
    
      mySimpleDialog.cfg.queueProperty("buttons", [
                      { text: "OK", 
                      handler: function() { this.hide() },
                      isDefault: true }]);
    
      mySimpleDialog.render(document.body);
      mySimpleDialog.show();
    
      return false;
    }
  },
    
  ender: true
};
