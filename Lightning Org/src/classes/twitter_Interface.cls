public with sharing class twitter_Interface 
{
    private static Map<String, Schema.SObjectType> mapSobjectNameToSobjectType = Schema.getGlobalDescribe();    
    
    @auraEnabled
    public static String fetchTweetsFromTwitter(String strTwitter_Handler)
    {
        String keyencoded; 
        String secretkeyencoded;        
        try
        {
            keyencoded = EncodingUtil.urlEncode(Twitter_Key__c.getall().values()[0].Consumer_Key__c, 'UTF-8');
            secretkeyencoded = EncodingUtil.urlEncode(Twitter_Key__c.getall().values()[0].Consumer_Secret_Key__c, 'UTF-8');
        }
        catch(Exception e)
        {
            system.debug('Error:' + 'No Custom Setting');
        }
        String stoken; 
        //Create Final Key String
        String sFinal = keyencoded + ':' + secretkeyencoded;
        //Convert to Blob
        Blob headerValue = Blob.valueOf(sFinal);
         
        //Build Request
        Http http = new Http();
        HTTPResponse res;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.twitter.com/oauth2/token');
        req.setMethod('POST');
         
        //Add Auth Header
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
         
        //You need to add this to the request - proved easy to miss in instructions...
        req.setBody('grant_type=client_credentials');
         
        //Make request
        if(Test.isRunningTest())
        {
            // Create a fake response
            res = new HttpResponse();
            res.setBody('{"token_type":"bearer","access_token":"AAAAAAAAAAAAAAAAAAAAAK3PfgAAAAAA%2B5S5pjfsgqsjcVAaS8nltu61n%2Fs%3DD7thoimZ3Cq7tlApu0NOuIAPcnlB5kKEez6YCaErrgkZaMjIFm"}');
        }
        else
            res = http.send(req);

        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) 
        {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'access_token')
            {
                parser.nextToken();
                stoken = parser.getText();
            }
        }
        HttpRequest req2 = new HttpRequest();
        Http http2 = new Http();
        HTTPResponse res2;
        
        req2.setEndpoint('https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=' + strTwitter_Handler);
   
        req2.setMethod('GET');
        //Call Bearer token Method
        String authorizationHeader2 = 'Bearer ' + stoken;
        req2.setHeader('Authorization', authorizationHeader2);
           
        if(Test.isRunningTest())
        {
            // Create a fake response
            res2 = new HttpResponse();
            res2.setBody('[{"created_at":"Fri May 22 16:05:50 +0000 2015","id":601781020598349824}]');
        }
        else
            res2 = http2.send(req2);
        return res2.getBody();
    }
    
    @auraEnabled
    public static String fetchObjectFields(String strObjectName)
    {
        if(String.isNotEmpty(strObjectName))
        {
	        try
	        {
		        Schema.SobjectType objSobjectType = mapSobjectNameToSobjectType.get(String.escapeSingleQuotes(strObjectName));	        
		        if(objSobjectType!= NULL && (objSobjectType == Account.SobjectType || objSobjectType == Contact.SobjectType || objSobjectType == Lead.SobjectType))
		        {
		        	Map<String,Schema.SobjectField> mapSobjectNameToSobjectField = objSobjectType.getDescribe().fields.getMap();
			        if(mapSobjectNameToSobjectField.get('id').getDescribe().isAccessible() && mapSobjectNameToSobjectField.get('twitterhandler__c').getDescribe().isAccessible() && mapSobjectNameToSobjectField.get('name').getDescribe().isAccessible())
			        {
				        String strDynamicQuery = 'Select Id , twitterHandler__c, Name, UserRecordAccess.HasReadAccess from ' + strObjectName+' ORDER BY Name';
				        List<Sobject> lstSobject = database.query(strDynamicQuery); 
				        if(!lstSobject.isEmpty())
				            return JSON.serialize(lstSobject);
			        }
		        }
	        }
	        catch(Exception ex)
	        {
	        	return 'No Records';
	        }
        }
        return 'No Records';
    }
    
    @auraEnabled
    public static String fetchUsersFromTwitter(Id idRecordId)
    {
        try
        {
	        Schema.SobjectType objSobjectType = idRecordId.getSObjectType();
	        if((objSobjectType == Account.SobjectType || objSobjectType == Contact.SobjectType || objSobjectType == Lead.SobjectType) && objSobjectType.getDescribe().fields.getMap().get('Name').getDescribe().isAccessible())
	        {
	            /*---Setting up Query Data---*/
	            String query = 'Select Name from ' + idRecordId.getSObjectType() + ' where Id =\'' + idRecordId + '\'';
	            Sobject objName = database.query(query);
	            String strUserName = ((String)objName.get('Name')).replaceAll(' ' , '%2520');
	            
	            strUserName = strUserName.replaceAll('&', '%2526');
	            strUserName = strUserName.replaceAll(',', '%252C');
	            
	            /*--Setting up OAuTH1.0 parameters--*/
	            String strDefaultSearchCount = '15';
	            HTTPResponse twitterResponse;
	            
	            String strouthConsumerKey;
	            String strConsumerSecretKey;
	            String strAccessToken;
	            String strAccessTokenSecret;
	            Integer int_searchCount ; 
	            try
	            {
	                strouthConsumerKey = Twitter_Key__c.getall().values()[0].TRKBTweetForce__Consumer_Key__c;
	                strConsumerSecretKey = Twitter_Key__c.getall().values()[0].TRKBTweetForce__Consumer_Secret_Key__c;
	                strAccessToken = Twitter_Key__c.getall().values()[0].TRKBTweetForce__Access_Token__c;
	                strAccessTokenSecret = Twitter_Key__c.getall().values()[0].TRKBTweetForce__Access_Token_Secret__c;
	                int_searchCount = Integer.valueOf(Twitter_Key__c.getall().values()[0].TRKBTweetForce__Search_Result__c);
	            }
	            catch(Exception e)
	            {
	                system.debug('Error:' + 'No Custom Settings' );    
	            }
	            String oauthsignaturemethod = 'HMAC-SHA1';
	            String oauthversion = '1.0';
	            String urlAcc = 'https://api.twitter.com/1.1/users/search.json';
	            String oauthTimeStamp = String.valueOf(datetime.now().getTime()).substring(0 , 10);
	            String aouth_nonce = EncodingUtil.base64Encode(blob.valueOf(String.valueof(datetime.now()))).split('=')[0] + 'ABCDEF';
	            String strCount = ( int_searchCount > 20) ? strDefaultSearchCount : String.valueOf(int_searchCount);
	        
	           
	            
	            /*--Prepare Signature Base String for HRA-SHA1 hashing Algorithm--*/
	            map<String , String> mapIdToValues = new map<String , String>();
	            mapIdToValues.put('oauth_consumer_key' , strouthConsumerKey);
	            mapIdToValues.put('oauth_nonce' , aouth_nonce);
	            mapIdToValues.put('oauth_signature_method' , oauthsignaturemethod);
	            mapIdToValues.put('oauth_timestamp' , oauthTimeStamp);
	            mapIdToValues.put('oauth_token' , strAccessToken);
	            mapIdToValues.put('oauth_version' , oauthversion);
	            mapIdToValues.put('q' , strUserName);
	            mapIdToValues.put('count',strCount);
	            
	            List<String> lstParam = new List<String>{'count','oauth_consumer_key', //For Ordered creation of Signature String since Oauth relies on Lexical parsing
	                                                    'oauth_nonce',
	                                                    'oauth_signature_method',
	                                                    'oauth_timestamp',
	                                                    'oauth_token',
	                                                    'oauth_version','q'};
	            String signatureString ='GET&'+ manualEncode(EncodingUtil.urlEncode(urlAcc , 'UTF-8')+ '&');
	            for(String objString : lstParam)
	            {
	                signatureString+=manualEncode(EncodingUtil.urlEncode(objString + '=' + mapIdToValues.get(objString) + '&' , 'UTF-8'));
	            }
	            signatureString = signatureString.subString(0 , signatureString.length()-3);
	            
	            String strURL = 'https://api.twitter.com/1.1/users/search.json?q=' + strUserName + '&count=' + strCount;//URL to be Queried
	    
	          
	        
	            /*--Prepare Composite Key String for HRA-SHA1 hashing Algorithm--*/
	            String compositeKey = manualEncode(EncodingUtil.urlEncode(strConsumerSecretKey , 'UTF-8')) + '&' + manualEncode(EncodingUtil.urlEncode(strAccessTokenSecret , 'UTF-8'));
	            
	            
	            /*--Prepare Authorization Header--*/
	            String strEncodedConsumerKey= EncodingUtil.urlEncode(strouthConsumerKey , 'UTF-8');
	            String strEncodedOauthOnce=EncodingUtil.urlEncode(aouth_nonce , 'UTF-8');
	            String strEncodedOauthSignature=EncodingUtil.urlEncode(EncodingUtil.base64Encode(Crypto.generateMac('hmacSHA1' , blob.valueOf(signatureString) , Blob.valueOf(compositeKey))), 'UTF-8');
	            String strEncodedOauthSignatureMethod=EncodingUtil.urlEncode(oauthsignaturemethod , 'UTF-8');
	            String strEncodedOauthTimestamp=EncodingUtil.urlEncode(oauthTimeStamp , 'UTF-8') ;
	            String strEncodedoauthToken=EncodingUtil.urlEncode(strAccessToken , 'UTF-8');
	            String strEncodedOauthVersion=EncodingUtil.urlEncode(oauthversion , 'UTF-8');
	            
	            String strOauthHeader = 'OAuth oauth_consumer_key="' + strEncodedConsumerKey + '",'+
	                                    'oauth_nonce="' + strEncodedOauthOnce + '",' + 
	                                    'oauth_signature="' + strEncodedOauthSignature +'"'+
	                                    ',oauth_signature_method="' + strEncodedOauthSignatureMethod + '"' + 
	                                    ',oauth_timestamp="' + strEncodedOauthTimestamp  + '"'+
	                                    ',oauth_token="' + strEncodedoauthToken + '"' + 
	                                    ',oauth_version="' + strEncodedOauthVersion + '"';
	            
	            HttpRequest twitterPacket = new HttpRequest();
	            twitterPacket.setEndpoint(strURL);
	            twitterPacket.setMethod('GET');
	            twitterPacket.setHeader('Authorization' , strOauthHeader);	            
	            Http twitterConnect = new Http();
	            
	            if(Test.isRunningTest())
	            {
	                // Create a fake response
	                twitterResponse = new HttpResponse();
	                twitterResponse.setBody('[{"id":2309250205,"id_str":"2309250205","name":"GenePoint","screen_name":"RTest42"]}');
	            }
	            else
	                twitterResponse = twitterConnect.send(twitterPacket);           
	           
	            	return twitterResponse.getBody();
	            }
	        return NULL;   
        } 
        catch(Exception ex)
        {
        	return NULL;
        }    
    }
    
    
    private static String manualEncode(String strURLendPoint)
    {
        return strURLendPoint.replace('!', '%21').replace('\'', '%27').replace('(', '%28').replace(')', '%29').replace('*', '%2A').replace(',', '%2C');
    }
    
    @auraEnabled
    public static String saveTwitterId( String strScreenName , Id recordId )
    {    
        try
        {
            String strObjectType = String.valueOf(recordId.getSObjectType());
            if(recordId.getSObjectType().getDescribe().isUpdateable())
            {
	            if(strObjectType == 'Lead')
	            {
	                update new Lead(Id = recordId , TRKBTweetForce__twitterHandler__c = strScreenName);
	                return 'Lead Saved';
	            }
	            else if(strObjectType == 'Contact')
	            {
	                update new Contact(Id = recordId , TRKBTweetForce__twitterHandler__c = strScreenName);
	                return 'Contact Saved';
	            }
	            else if(strObjectType == 'Account')
	            {
	                update new Account(Id = recordId , TRKBTweetForce__twitterHandler__c = strScreenName);
	                return 'Account Saved';
	            }
        	}
        }
        catch(Exception e)
        {
            system.debug('update Failed' + e.getMessage());
        }
        return 'Update Failed';
    }

}