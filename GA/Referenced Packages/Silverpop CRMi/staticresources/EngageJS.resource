//Javascript methods for the Engage SFDC application

function login(sfdcServerUrl, sfdcSessionId, redirectUrl){
	//Login
	//var sfdcServerUrl = '{!$Api.Enterprise_Server_URL_180}';
	var eSessionId = sforce.apex.execute("silverpop.EngageLoginController","LoginWS", {serverUrl:sfdcServerUrl, sessionId:sfdcSessionId});	
	setCookieRedirect('sp_esessionid',eSessionId,redirectUrl);
}


function confirmCancel() {
	var isCancel = confirm("You are about to cancel.  Are you sure you wish to continue?"); 
	if (isCancel){ 
		//remove the cookies
		deleteCookie('sp_esessionid');
		deleteCookie('sp_crmlistid');
		deleteCookie('sp_visibility');
		deleteCookie('sp_template');
		deleteCookie('sp_subject');
		deleteCookie('sp_personalmsg');			
		deleteCookie('sp_from');
		deleteCookie('sp_replyto')
		deleteCookie('sp_mailingname');
		deleteCookie('sp_personilzation');
		deleteCookie('sp_senddate');
		deleteCookie('sp_fromname');
		window.close();
		return true;
	}
	return false;
} 

function closeMe(){
	
	//remove the cookies
	deleteCookie('sp_esessionid');
	deleteCookie('sp_crmlistid');
	deleteCookie('sp_visibility');
	deleteCookie('sp_template');
	deleteCookie('sp_subject');
	deleteCookie('sp_personalmsg');			
	deleteCookie('sp_from');
	deleteCookie('sp_replyto')
	deleteCookie('sp_mailingname');
	deleteCookie('sp_personilzation');
	deleteCookie('sp_senddate');
	deleteCookie('sp_fromname');
	
	//close the window
	window.close();
	return true;
}
 		
function setCookie(name, value){
	// set expire time to expire 1 day from now
	var date = new Date();
	date.setTime(date.getTime()+(1*24*60*60*1000));
	
	document.cookie = name + '=' + escape(value) + ';secure;expires='+ date.toGMTString();
}

//Get if the cookie exists and returns the value otherwise return null
function getCookie(name){

	//Regular expression to match a cookie
	var value = document.cookie.match ( '(^|;) ?' + name + '=([^;]*)(;|$)' );
	
	if (value)
	    return ( unescape ( value[2] ) );
	else
		return '';
}


//Remove all the cookies that start with sp_ after message has been scheduled
function deleteCookie(name){

	if(getCookie(name)){
		document.cookie = name + '=; expires=Thu, 01-Jan-70 00:00:01 GMT;'
	}	
}

function setCookieRedirect(name, value, url){
	setCookie(name,value);
	document.location=url;
}