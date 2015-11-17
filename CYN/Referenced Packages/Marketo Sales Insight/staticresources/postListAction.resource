//{!REQUIRESCRIPT("resource/1363282971000/mkto_si__postListAction")}
//Note! The url above will change every time this resource is revised. Check it every time!
function post_to_url(path, params, method) {
	method = method || "post";
	var form = document.createElement("form");
	form.setAttribute("method", method);
	form.setAttribute("action", path);

	for(var key in params) {
		if(params.hasOwnProperty(key)) {
			var hiddenField = document.createElement("input");
			hiddenField.setAttribute("type", "hidden");
			hiddenField.setAttribute("name", String(key));
			hiddenField.setAttribute("value", String(params[key]));
			form.appendChild(hiddenField);
		}
	}
	document.body.appendChild(form);
	form.submit();
}

function build_action_path(actionName) {
	var hostname = window.location.hostname;
	var server = 'na1';
	if (hostname.indexOf(".salesforce.com") != -1){
		server = hostname.substring(0,hostname.indexOf(".salesforce.com") );
	} else if (hostname.indexOf(".force.com") != -1){
		server = hostname.substring(0,hostname.indexOf(".force.com") );
	}
	return "https://mkto-si." + server + ".visual.force.com/apex/" + actionName;
}