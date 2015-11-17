/**  
* \arg ClassName      : SL_GetScore
* \arg JIRATicket     : STARGAS-11
* \arg CreatedOn      : 22/JUL/2014
* \arg LastModifiedOn : 9/MAR/2015
* \arg CreatededBy    : SRUTI
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This is controller is used for making a callout to HART system when clicked on "Get Score" button
*/
global without sharing class SL_GetScore {
    
    // public and private Variables
    public static String testResponse; 
    
    /*
    * MethodName        : createCreditCheckRecord
    * param             : Opportunity fields, ie ID, First name, last name and SSN 
    * Description       : Will create Credit Check/History Object 
    */
    WebService static String createCreditCheckRecord(Id idOpportunity)
    {
        Opportunity objOpp = [Select Credit_First_Name__c, Credit_Last_Name__c, SSN__c, AccountId FROM Opportunity where Id =: idOpportunity];
                            
        String dryptData = getDecryptedValue( objOpp.SSN__c);
        System.debug('Printing dryptData '+dryptData);
         
        Credit_Check_History__c objCreditCheckHistory = new Credit_Check_History__c(Client_Prospect__c= objOpp.AccountId, Date__c = Datetime.now(),
                                                        SSN__c = dryptData, Requester__c = UserInfo.getUserId(),
                                                        Opportunity__c = idOpportunity, Last_Name__c = objOpp.Credit_Last_Name__c,
                                                        First_Name__c  = objOpp.Credit_First_Name__c, Name = objOpp.Credit_First_Name__c+' '+objOpp.Credit_Last_Name__c);
            
        try
        {
            insert objCreditCheckHistory;
            return objCreditCheckHistory.Id;
        }
        catch(Exception e)
        {
            system.debug(e.getMessage()+'===================');
            return 'ERROR# An error has occurred requesting the credit score.';  
        }
        return '';
    }
    
     /*
        * MethodName        : getDecryptedValue
        * param             : string to decrypt
        * Description       : Method to decrypted value of an encrypted SSN string
    */
    private static String getDecryptedValue(String stringSSN)
    {
        if(stringSSN != null)
        {
            Blob cryptoKey = Crypto.generateAesKey(128);
            //converting it into String
            String encodedKey = EncodingUtil.base64encode(cryptoKey);
            Blob encryptedValue = Crypto.encryptWithManagedIV('AES128', cryptoKey, Blob.valueOf(stringSSN));
            //Base64 string turns back into the key 
            Blob decodedKey = EncodingUtil.base64decode(encodedKey);
            Blob decryptedValue = Crypto.decryptWithmanagedIV('AES128', decodedKey, encryptedValue);
            return decryptedValue.toString();
        }
        
        
        else return '';
    }

    /*
        * MethodName        : CreditScoreCheck
        * param             : Opportunity  ID
        * Description       : Making a callout to HART system and updating Score value on Credit Check History object
    */
    webservice static string CreditScoreCheck( Id idCreditHistory, Id idOpportunity)
    {
        String strReturnResponse = '';
        if(idCreditHistory != Null)
        {
             Opportunity objOpp = [Select First_Name__c, Last_Name__c, SSN__c, Years__c, Previous_Street_2__c, Previous_Street_1__c, 
                                     Previous_State__c, Previous_Postal_Code__c, Previous_City__c, Current_Street_2__c, Current_Street_1__c, Current_State__c, 
                                     Current_Postal_Code__c, Current_City__c, AccountId, Territory__r.Division__r.HART_SID_Num__c
                                    FROM Opportunity where Id =: idOpportunity];
                                   
            //Credit_Check_History__c objCredit
            Credit_Check_History__c objCredit_Check = [SELECT Status__c, Score__c, SSN__c, Requester__c, Opportunity__c,
                                                        Opportunity__r.Current_Postal_Code__c, Opportunity__r.Current_Street_1__c, Opportunity__r.Current_State__c, 
                                                        Opportunity__r.Current_City__c , Opportunity__r.Current_Street_2__c,
                                                        Name, Last_Name__c, Id, First_Name__c, Date__c, Client_Prospect__c  
                                                        FROM Credit_Check_History__c 
                                                        WHERE Id =:idCreditHistory ];
               
            //Decrypting the encrypted SSN value                                             
            String dryptData = getDecryptedValue( objCredit_Check.SSN__c);
            
            //retrieving all the required inputs from custom settings l
            List<SL_HARTCalloutInputs__c> calloutInputs = SL_HARTCalloutInputs__c.getall().values();
             
            string strAddress = '';
            if(calloutInputs != null)
            {
                String strRequest = '';
                if(objOpp.Years__c >=1)
                {
                    String strStreet1 = objOpp.Current_Street_1__c != null ? objOpp.Current_Street_1__c : '';
                    String strStreet2 = objOpp.Current_Street_2__c != null ? objOpp.Current_Street_2__c : '';
                    
                    strRequest = 'ACCOUNT='+xmlEncoder(calloutInputs[0].Account__c)+''+'\r\n'+
                                    'PASSWD='+xmlEncoder(calloutInputs[0].Password__c)+'' + '\r\n'+
                                    'PROCESS='+xmlEncoder(calloutInputs[0].Process__c)+'' + '\r\n'+
                                    'BUREAU=' + ''+xmlEncoder(calloutInputs[0].Bureau__c)+'' + '\r\n'+
                                    'PRODUCT=' + ''+xmlEncoder(calloutInputs[0].Product__c)+'' + '\r\n'+
                                    'NAME=' + ''+xmlEncoder(objCredit_Check.First_Name__c+' ' + objCredit_Check.Last_Name__c) +'' + '\r\n'+
                                    'SSN=' + ''+xmlEncoder(dryptData)+'' + '\r\n' +
                                    'ADDRESS=' + ''+xmlEncoder(strStreet1 +' '+strStreet2)+'' + '\r\n'+   
                                    'CITY=' + ''+xmlEncoder(objOpp.Current_City__c)+'' + '\r\n'+
                                    'STATE=' + ''+xmlEncoder(objOpp.Current_State__c)+'' + '\r\n'+
                                    'ZIP=' + ''+xmlEncoder(objOpp.Current_Postal_Code__c)+'' + '\r\n'+
                                    'PASS=' + ''+xmlEncoder(calloutInputs[0].Pass__c)+'' + '\r\n'+
                                    'SELECTEDCODE=' + ''+xmlEncoder(objOpp.Territory__r.Division__r.HART_SID_Num__c)+''  ;
                                      
                    strAddress = strStreet1 +' '+strStreet2+ ', ' +objOpp.Current_City__c+ ', ' + objOpp.Current_State__c+ ', ' +objOpp.Current_Postal_Code__c;
                    
                }
                else
                {
                    String strStreet1 = objOpp.Previous_Street_1__c != null?
                                        objOpp.Previous_Street_1__c : '';
                    String strStreet2 = objOpp.Previous_Street_2__c != null? 
                                        objOpp.Previous_Street_2__c : '';
                    
                    strRequest = 'ACCOUNT='+xmlEncoder(calloutInputs[0].Account__c)+''+'\r\n'+
                                    'PASSWD='+xmlEncoder(calloutInputs[0].Password__c)+'' + '\r\n'+
                                    'PROCESS='+xmlEncoder(calloutInputs[0].Process__c)+'' + '\r\n'+
                                    'BUREAU=' + ''+xmlEncoder(calloutInputs[0].Bureau__c)+'' + '\r\n'+
                                    'PRODUCT=' + ''+xmlEncoder(calloutInputs[0].Product__c)+'' + '\r\n'+
                                    'NAME=' + ''+xmlEncoder(objCredit_Check.First_Name__c+' ' + objCredit_Check.Last_Name__c) +'' + '\r\n'+
                                    'SSN=' + ''+xmlEncoder(dryptData)+'' + '\r\n' +
                                    'ADDRESS=' + ''+xmlEncoder(strStreet1 +' '+strStreet2)+'' + '\r\n'+   
                                    'CITY=' + ''+xmlEncoder(objOpp.Previous_City__c)+'' + '\r\n'+
                                    'STATE=' + ''+xmlEncoder(objOpp.Previous_State__c)+'' + '\r\n'+
                                    'ZIP=' + ''+xmlEncoder(objOpp.Previous_Postal_Code__c)+'' + '\r\n'+
                                    'PASS=' + ''+xmlEncoder(calloutInputs[0].Pass__c)+'' + '\r\n'+
                                    'SELECTEDCODE=' + ''+xmlEncoder(objOpp.Territory__r.Division__r.HART_SID_Num__c)+''  ;
                    
                    strAddress = strStreet1 +' '+strStreet2+ ', ' +objOpp.Previous_City__c+ ', ' + objOpp.Previous_State__c+ ', ' +objOpp.Previous_Postal_Code__c;
                }
                //Send Request
                String response = sendHTTPRequest(strRequest, calloutInputs[0].Callout_URL__c); 
                //Parsing Response and Updating Credit_Check_History__c and Opportunity with required Values retreived from Callout 
                if(response != null)
                    return parseResponse(response, idCreditHistory, idOpportunity , strAddress);   
            }
        }
        return 'ERROR# An error has occurred requesting the credit score.';    
    }
    
    /*
        * MethodName        : parseResponse
        * param             : Response string, Credit History Id
        * Description       : Parsing Response string, getting info message and updating Score value on Credit Check History object
    */
    private static String parseResponse(String strResponse, Id idCreditHistory, Id idOpportunity, String straddress )
    {
        try
        {
            Dom.Document docx = new Dom.Document();        
            docx.load(strResponse);
            //variables to store values of hart customer name, his current address, his previous address, score, document content and RCD codes respectively.
            String strCustomerName, strCurrentAddress, strPreviousAddress, strScore, strDocumentContent, strRCDCodes, strCurrentAddress_ReportedDate, strPreviousAddress_ReportedDate;
            strCustomerName = strCurrentAddress = strPreviousAddress = strScore = strDocumentContent = strRCDCodes = strCurrentAddress_ReportedDate = strPreviousAddress_ReportedDate = '';//intializing all the variables
            Date dtDOB;
            Attachment objAttachment; //an Attachment to insert to this Credit History Check object

            // Identify the Score by parsing the response
            for(Dom.XMLNode child : docx.getrootelement().getchildelements())
            {
                
                if(child.getname() == 'bureau_xml_data')
                { 
                    dom.XmlNode advert = child.getChildElement('TU_Report', null);
                    if (advert != null) 
                    {
                        dom.XmlNode domChild = advert.getChildElement('subject_segments', null);
                        if (domChild != null)   
                        {                            
                            //xml node for name information to extract customer name
                            dom.Xmlnode domChildCustomerNameInfo = domChild.getChildElement('name_information', null);
                            if(domChildCustomerNameInfo!=null)
                            {
                                strCustomerName = domChildCustomerNameInfo.getChildElement('fname', null).getText()+' '+domChildCustomerNameInfo.getChildElement('lname', null).getText();
                            }
                            
                            //xml node for personal information to extract date of birth  
                            dom.Xmlnode domPersonalInfo = domChild.getChildElement('personal_information', null);
                            if(domPersonalInfo!=null)
                            {
                                Dom.Xmlnode domDOB = domPersonalInfo.getChildElement('dob', null);
                                if(String.isNotEmpty(domDOB.getText()))
                                {
                                    dtDOB = convertStringToDate(getExtractDate(domDOB.getText()));//calling method to convert string in date format
                                }
                            }
                            
                            //xml node for address information to extract current address
                            dom.Xmlnode domChildCurrentAddressInfo = domChild.getChildElement('address_information', null);
                            if(domChildCurrentAddressInfo!=null)
                            {
                                strCurrentAddress_ReportedDate = formAddress(domChildCurrentAddressInfo);
                                domChild.removeChild(domChildCurrentAddressInfo);//removing the node
                            }
                            //xml node for address information to extract previous address
                            dom.Xmlnode domChildPreviousAddressInfo = domChild.getChildElement('address_information', null);
                            if(domChildPreviousAddressInfo!=null)
                            {
                                strPreviousAddress_ReportedDate = formAddress(domChildPreviousAddressInfo);
                            }
                            String [] strCurrentAddress_ReportedDateArray = new String[]{};//array for holding current address and its reported date 
                            String [] strPreviousAddress_ReportedDateArray = new String[]{};//array for holding previous address and its reported date 
                            
                            //checking if current address is not null
                            if(String.isNotEmpty(strCurrentAddress_ReportedDate))
                            {
                                strCurrentAddress_ReportedDateArray = strCurrentAddress_ReportedDate.split('::');
                            }
                            
                            //checking if previous address is not null
                            if(String.isNotEmpty(strPreviousAddress_ReportedDate))
                            {
                                strPreviousAddress_ReportedDateArray = strPreviousAddress_ReportedDate.split('::');
                            }
                            
                            //checking if reported date is not null
                            if(strCurrentAddress_ReportedDateArray.size() == 2 && String.isNotEmpty(strCurrentAddress_ReportedDateArray[1]) && strPreviousAddress_ReportedDateArray.size() == 2 && String.isNotEmpty(strPreviousAddress_ReportedDateArray[1]))
                            {                               
                                Date dtCurrentReportDate = convertStringToDate(strCurrentAddress_ReportedDateArray[1]);//getting current report date
                                Date dtPreviousReportDate = convertStringToDate(strPreviousAddress_ReportedDateArray[1]);//getting previous report date
                                
                                //if current address reported date is greater than the previous address reported date
                                if(dtCurrentReportDate > dtPreviousReportDate)
                                {
                                    strCurrentAddress = strCurrentAddress_ReportedDateArray[0];
                                    strPreviousAddress = strPreviousAddress_ReportedDateArray[0];
                                }
                                else
                                {
                                    strPreviousAddress = strCurrentAddress_ReportedDateArray[0];
                                    strCurrentAddress = strPreviousAddress_ReportedDateArray[0];
                                }                           
                            }
                            
                            //if array contains current address
                            if(strCurrentAddress_ReportedDateArray.size() > 0 && String.isEmpty(strCurrentAddress))
                            {
                                strCurrentAddress = strCurrentAddress_ReportedDateArray[0];
                            }
                            
                            //if array contains previous address
                            if(strPreviousAddress_ReportedDateArray.size() > 0 && String.isEmpty(strPreviousAddress))
                            {
                                strPreviousAddress = strPreviousAddress_ReportedDateArray[0];
                            }
                                
                            //xml node for scoring segments to extract score and rcd codes
                            dom.XmlNode domChildSubject = domChild.getChildElement('scoring_segments', null);
                            
                            if(domChildSubject != null)
                            {               
                                if (domChildSubject.getname() == 'scoring_segments') 
                                {
                                    Dom.XMLNode xmlScore = domChildSubject.getChildElement('scoring', null);
                                    strScore =   xmlScore.getChildElement('score', null).getText();  
                                    //getting rcd codes
                                    strRCDCodes = String.join(new List<String>{getRCDCodes(xmlScore,'factor1'),
                                                                               getRCDCodes(xmlScore,'factor2'),
                                                                               getRCDCodes(xmlScore,'factor3'),
                                                                               getRCDCodes(xmlScore,'factor4')},'\r\n\r\n');
                                } 
                            }
                        }
                    }
                }
                //Retreiving the body of Attachment record
                else if(child.getname() == 'HTML_Reports')
                {
                    strDocumentContent = (strResponse.contains('<HTML_Reports>') &&  strResponse.contains('</HTML_Reports>')) ? 
                    strResponse.substring(strResponse.indexOf('<HTML_Reports>'), strResponse.indexOf('</HTML_Reports>')) : '';
                    
                    //Removing unwanted string from the HTML Reports 
                    strDocumentContent = strDocumentContent.contains('<HTML_Reports>') ? strDocumentContent.replace('<HTML_Reports>',''): strDocumentContent; 
                    strDocumentContent = strDocumentContent.contains(']]>') ? 
                    strDocumentContent.substring(0, strDocumentContent.lastindexOf(']]>')): strDocumentContent; 
                    
                }
            }
            
            //Inserting an Attachment to this Credit History Check object
            if(!String.isBlank(strDocumentContent))
            {
                objAttachment = new Attachment(Body = Blob.valueOf(strDocumentContent),
                                                Name = 'HTML-Report ' + System.now().format('yyyy-MM-dd-hh-mm-ss') +'.html',
                                                parentId = idCreditHistory, ContentType = 'text/plain');
                insert objAttachment;
                
            }

            //update score into Credit History object
            if(strScore != null && strScore != '')
            { 
                Integer intScore = Integer.valueOf(strScore);
                string strDecision = intScore< 600? 'Declined':  ( ( intScore >= 600 && intScore <= 619 )? 'Needs Review':  (intScore>= 600? '':  ('Approved' ) ));
                
                Opportunity objOpportunity = new Opportunity(Id= idOpportunity, Decision__c=strDecision , Credit_Score__c = intScore, Credit_Check_History_Lookup__c = idCreditHistory, HART_Current_Address__c = strCurrentAddress, HART_Previous_Address__c = strPreviousAddress , HART_Customer_Name__c = strCustomerName, HART_Date_of_Birth__c = dtDOB, HART_RCD_Codes__c = strRCDCodes);
                update objOpportunity;
                
                Credit_Check_History__c objCreditCheckHistory = new Credit_Check_History__c(Id= idCreditHistory, Score__c =  strScore, Status__c = strDecision, 
                                                                                            HART_Customer_Name__c = strCustomerName, HART_Current_Address__c = strCurrentAddress, 
                                                                                            HART_Previous_Address__c = strPreviousAddress, HART_RCD_Codes__c = strRCDCodes,
                                                                                            HART_Date_of_Birth__c = dtDOB,
                                                                                            Address__c= strAddress);
                update objCreditCheckHistory;
                
                return 'SUCCESS# Credit score received successfully';         
            }
            else
            {
                Credit_Check_History__c objCreditCheckHistory = new Credit_Check_History__c(Id= idCreditHistory, Score__c =  strScore, Status__c = 'Failed', 
                                                                                            HART_Customer_Name__c = strCustomerName, HART_Current_Address__c = strCurrentAddress, 
                                                                                            HART_Previous_Address__c = strPreviousAddress, HART_RCD_Codes__c = strRCDCodes,
                                                                                            HART_Date_of_Birth__c = dtDOB,
                                                                                            Address__c= strAddress);
                update objCreditCheckHistory;
            }
        }
        catch(Exception e)
        {
            system.debug(e.getMessage()+'========ERROR==========='+e.getLineNumber());
        }
        return 'ERROR# An error has occurred requesting the credit score. Requested information cannot be scored or returned because data is suppressed or cannot be evaluated. Please input valid data.';        
    }
    
     /*
        * MethodName        : sendHTTPRequest
        * param             : Request string
        * Description       : Method to send the HTTP Request and send back the response
    */
    private static String sendHTTPRequest(String strRequest, String calloutUrl)
    {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        
        //Setting required Parameters 
        req.setEndpoint(calloutUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/XML');
        req.setBody(strRequest); 
        
        if(!Test.isRunningTest())  
        {  
            // Send the request 
            res = http.send(req);
            String response = res.getBody();
            return response;
        }
        else
            return getResponseString();  
    }
    
    /*
        * MethodName  : xmlEncoder
        * param       : Request string
        * Description :  Method to handle special characters in XML
    */
    private static String xmlEncoder(String parameter)
    {
        if(String.isNotBlank(parameter))
            return parameter.replaceAll('\'' , '&apos;').replaceAll('"' , '&quot;').replaceAll('>' , '&gt;').replaceAll('<' , '&lt;').replaceAll('&' , '&amp;');
        return '';
    }
    
    /*
        * MethodName        : getResponseString
        * param             : None
        * Description       : A test response string  
    */
    private static String getResponseString()
    {
        return  '<?xmlversion="1.0"?> <HX5><bureau_xml_data> <TU_Report> <transaction_control id="TU4R"></transaction_control> <consumer_data id="CD01"> '+
                '</consumer_data> <bureau_product_header id="PH01" code="07000">Credit Report</bureau_product_header>'+
                '<subject_segments id="SH01" num="1"> <name_information id="NM01" type="1"> <source_indicator code="F">Name that appears in the returned file</source_indicator>'+
                '<name_indicator code="1">Primary name</name_indicator> <lname>BULLDOG</lname> <fname>UGA</fname> <mname></mname> <prefix></prefix> <suffix></suffix>'+
                '</name_information><personal_information id="PI01"><source_indicator code="F">Data that appears on the TransUnion database</source_indicator>'+
                '<ssn>666922211</ssn><dob></dob><age></age><gender code=""></gender></personal_information>'+
                '<address_information id="AD01"><source_indicator code="F">Address that appears on the database</source_indicator>'+
                '<addr_qualifier code="1">Personal</addr_qualifier><house_number>711</house_number>'+
                 '<predirectional>N</predirectional><street_name>SANFORD</street_name>'+
                '<postdirectional></postdirectional><street_type>AV</street_type>'+
                '<apt_unit_number></apt_unit_number><city>SAVANNAH</city>'+
                '<state>GA</state><zip>31401</zip><date_reported>20141001</date_reported></address_information>'+
                '<address_information id="AD01">'+
                '<source_indicator code="F">Address that appears on the database</source_indicator>'+
                '<addr_qualifier code="1">Personal</addr_qualifier>'+
                '<house_number>6886</house_number>'+
                '<predirectional>E</predirectional>'+
                '<street_name>VOLUNTEER</street_name>'+
                '<postdirectional></postdirectional>'+
                '<street_type>WY</street_type>'+
                '<apt_unit_number></apt_unit_number>'+
                '<city>KNOXVILLE</city>'+
                '<state>TN</state>'+
                '<zip>37901</zip>'+
                '<date_reported>20110904</date_reported>'+
                '</address_information>'+
                '<scoring_segments id="AO01" product="00P02"> <product_information id="AO01" product="00P02">'+
                '<product code="00P02"></product> <product_status code="04">Default product delivered</product_status> <search_status code=""></search_status>'+ 
                ' </product_information> <scoring id="SC01"> <product_code code="00P02">FICO CLASSIC 04</product_code> <sign>+</sign> <score>635</score> '+
                ' <indicator_flag code=""></indicator_flag> <derogatory_alert_flag code="I">Inquiries impacted the credit score</derogatory_alert_flag> '+
                ' <factor1 code="040">DEROGATORY PUBLIC RECORD OR COLLECTION FILED</factor1> <factor2 code="013">TIME SINCE DELINQUENCY IS TOO RECENT OR UNKNOWN</factor2> '+
                ' <factor3 code="010">PROPORTION OF BALANCES TO CREDIT LIMITS IS TOO HIGH ON BANK REVOLVING OR OTHER REVOLVING ACCOUNTS</factor3> '+
                '  <factor4 code="020">LENGTH OF TIME SINCE DEROGATORY PUBLIC RECORD OR COLLECTION IS TOO SHORT</factor4> <score_card_indicator></score_card_indicator>'+
                ' </scoring> </scoring_segments> </subject_segments>'+
                ' <transaction_ending id="ENDS"> <segments_returned>045</segments_returned> </transaction_ending> </TU_Report> </bureau_xml_data>  '+
                '<HTML_Reports> <HTML_Report fmt_type="1"> <table WIDTH="100%" ><tr><th>Inquiries</th></tr><tr><th><p>Date</p></th></tr></table></HTML_Report></HTML_Reports></HX5>';
            
    }
    
    /*
        * MethodName        : formAddress
        * param             : address node of type xml
        * Description       : This function is used to extract address and form it in a string 
    */
    private static String formAddress(Dom.XMLNode addressNode)
    {       
        
        return String.join(new List<String>{String.isNotEmpty(addressNode.getChildElement('house_number', null).getText()) ? addressNode.getChildElement('house_number', null).getText() : '###',
                                            String.isNotEmpty(addressNode.getChildElement('predirectional', null).getText()) ? addressNode.getChildElement('predirectional', null).getText() : '###',
                                            String.isNotEmpty(addressNode.getChildElement('street_name', null).getText()) ? addressNode.getChildElement('street_name', null).getText() : '###',
                                            String.isNotEmpty(addressNode.getChildElement('street_type', null).getText()) ? addressNode.getChildElement('street_type', null).getText() : '###',
                                            String.isNotEmpty(addressNode.getChildElement('city', null).getText()) ? addressNode.getChildElement('city', null).getText() : '###',
                                            String.isNotEmpty(addressNode.getChildElement('state', null).getText()) ? addressNode.getChildElement('state', null).getText() : '###',
                                            String.isNotEmpty(addressNode.getChildElement('zip', null).getText()) ? addressNode.getChildElement('zip', null).getText() : '###'},', ').remove('###, ') + 
                                            '::' 
                                            + (String.isNotEmpty(addressNode.getChildElement('date_reported', null).getText()) ? getExtractDate(addressNode.getChildElement('date_reported', null).getText()) : '');
    }
    
    /*
        * MethodName        : getRCDCodes
        * param             : scoring node of type xml node and factor name
        * Description       : This function is used to extract factor code and form it in a string 
    */
    private static String getRCDCodes(Dom.XMLNode scoringNode, String factorName)
    {
         Dom.XMLNode xmlFactor = scoringNode.getChildElement(factorName, null);
         return xmlFactor!=null ? String.format('Factor: {0} {1}',new List<String>{xmlFactor.getAttributeValue('code',null), xmlFactor.getText()}) : '';
    }
    
     /*
        * MethodName        : getExtractDate
        * param             : content of node
        * Description       : This function is used to extract date
    */
    private static String getExtractDate(String strNodeContent)
    {
        return String.isNotEmpty(strNodeContent) && strNodeContent.length() == 8 ? String.join(new List<String>{strNodeContent.substring(4,6), strNodeContent.substring(6,8), strNodeContent.substring(0,4)},'/') : '';
    }
    
    /*
        * MethodName        : convertStringToDate
        * param             : string that needs to be converted into date
        * Description       : This function is used to convert string to date
    */
    private static Date convertStringToDate(String strDate)
    {
        String[] strSplittedString = strDate.split('/');
        return Date.newInstance(Integer.valueOf(strSplittedString[2]), Integer.valueOf(strSplittedString[0]), Integer.valueOf(strSplittedString[1]));
    }
}