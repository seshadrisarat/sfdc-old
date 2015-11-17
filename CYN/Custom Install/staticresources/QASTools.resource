var qas_url = '';
var qas_enclosingTabId = '';
var qas_openAddressValidationTabAttempts = 0;
var qas_enclosingTabFoundCalled = false;

function qas_openAddressValidationTabWithTimeout(){
	if(qas_enclosingTabFoundCalled === true) return;

	setTimeout(qas_openAddressValidationTab, 10);
	if(qas_openAddressValidationTabAttempts <= 5) {
		qas_openAddressValidationTabAttempts ++;
		setTimeout(qas_openAddressValidationTabWithTimeout, 1000);
	}
}

function qas_openAddressValidationTab() {
	sforce.console.getEnclosingTabId(qas_enclosingTabFound);
}

function qas_enclosingTabFound(result) {
	if(qas_enclosingTabFoundCalled === true) return;
	qas_enclosingTabFoundCalled = true;
	
	qas_enclosingTabId = result.id;
	qas_openSubtabOfEnclosingTab();
}

function qas_openSubtabOfEnclosingTab() {
	sforce.console.getEnclosingPrimaryTabId(qas_openSubtab);
}
       
var qas_openSubtab = function qas_openSubtab(result) {
	sforce.console.openSubtab(result.id, qas_url + "&IsInServiceCloudConsole=true&tabId=" + qas_enclosingTabId, true, 
      							'Address Verification', null, null, 'leadsACSubtab');
};

function qas_isConsoleView() {
	return window.top != window.parent;
}

//This is a copy of the isInConsole function in https://cs13.salesforce.com/support/console/24.0/integration.js 
//It was copied to remove the dependency of th eabove library.
function qas_isInConsole() {
	var qs = location.search;
    return (qs.length != 0 && ((qs.indexOf("?isdtp=") > -1) || (qs.indexOf("&isdtp=") > -1)));
}

function qas_invokeValidation(url) {
	if (qas_isInConsole() && qas_getViewTypeParamValue(window.location.href) == "vw") {
		qas_url = url;
		window.setTimeout(qas_openAddressValidationTabWithTimeout, 150);
	} else if (!qas_isConsoleView()) {
		window.parent.location = url;
	} else {   		
   		var nextUrl = encodeURIComponent(url+"&isdtp=mn" + "&IsInConsole=true");
   		var queryStringParams = "consoleExecute=" + nextUrl;
   		qas_showHomePageInHiddenIFrame(window.location.href, queryStringParams);
	}
}

function qas_showHomePageInHiddenIFrame(url,queryStringParams){
	var subdomain = qas_getPrimarySubdomainFromVisualForceUrl(url);
	if(subdomain.substring(0, 2) == 'eu' && !subdomain.indexOf('--') > 0) {
		subdomain = 'emea';
	}
	var homePageUrl = "https://" + subdomain + ".salesforce.com/home/home.jsp";

 	if(queryStringParams != 'undefined' && queryStringParams != ''){
 		homePageUrl += "?" + queryStringParams;
 	}
   	var iframe = "<iframe style='display: none;' src='" + homePageUrl + "'></iframe>";
   	document.write(iframe);
}

function qas_getPrimarySubdomainFromVisualForceUrl(url){
	var subdomain = url.substring(0, url.indexOf(".visual.force.com"));
	subdomain = subdomain.substring(subdomain.lastIndexOf("/") + 1, subdomain.length);
	subdomain = subdomain.toLowerCase();
	if (subdomain.indexOf("c.") == 0) {
		subdomain = subdomain.substring("c.".length, subdomain.length);
	} else if(subdomain.indexOf("qas-na-lt.") == 0) {
		subdomain = subdomain.substring("qas-na-lt.".length, subdomain.length);
	} else if(subdomain.indexOf("qas-na.") == 0) {
		subdomain = subdomain.substring("qas-na.".length, subdomain.length);
	} else if(subdomain.indexOf("--c.") > 0) {
		subdomain = subdomain.replace("--c.", ".") + ".my";
	} else if(subdomain.indexOf("--qas-na-lt.") > 0) {
		subdomain = subdomain.replace("--qas-na-lt.", ".") + ".my";
	} else if(subdomain.indexOf("--qas-na.") > 0) {
		subdomain = subdomain.replace("--qas-na.", ".") + ".my";
	}
	
	return subdomain;
}

function qas_getViewTypeParamValue(url) {
	var indexBeg = url.indexOf("isdtp=");
	if(indexBeg > 0){
		indexBeg += "isdtp=".length;
		if ((indexBeg + 2) >= url.length) {
			return url.substring(indexBeg, indexBeg + 2);
		}
	} 
	return "";
}
