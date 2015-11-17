global Class AddApiLog{
    global static string ContactID {get;set;}
    global static void InsertAPILog(string strReq,string strRes,Boolean blnResult,string strMethodName){
        try{
            API_Log__c objAPILog = new API_Log__c();
            objAPILog.Request_Param__c = strReq;
            objAPILog.Response_Data__c = strRes;
            objAPILog.Result_Flag__c = blnResult;
            objAPILog.Method_Name__c = strMethodName;
            if(ContactID != null)
                objAPILog.Contact__c = ContactID;
            insert objAPILog;
        }catch ( Exception ex ) {
            //return ex.getMessage();
        }
    }
}