@isTest(seeAlldata=false)

private class AddApiLogTest{

    static testmethod void AddApiLogTest(){
        
         List<recordtype> lstrecordtype= new List<recordtype>([select id,developername from 
                                                             recordtype where developername = 'Patient']);
        
         List<recordtype> lstAccrecordtype= new List<recordtype>([select id,developername from 
                                                 recordtype where developername = 'MIHIN_Organizations']);
                                                             
        account objAccount = new Account();
        objAccount.Name = 'TestAccountName';
        objAccount.Recordtypeid = lstAccrecordtype[0].id;
        insert objAccount;                                                             
        
        contact objcon = new contact();
        objcon.Firstname='TestFName';
        objcon.LastName='TestLName';
        objcon.Gender__c ='Male';
        objcon.Accountid = objAccount.id;
        objcon.recordtypeid = lstrecordtype[0].id;
        insert objcon;
        
        string strReq = 'testRequest';
        string strRes = 'TestResponse';
        Boolean blnResult = true;
        string strMethodName = 'Test method';
        
        API_Log__c objAPILog = new API_Log__c();
        objAPILog.Request_Param__c = strReq;
        objAPILog.Response_Data__c = strRes;
        objAPILog.Result_Flag__c = blnResult;
        objAPILog.Method_Name__c = strMethodName;
        objAPILog.Contact__c = objcon.id;
        insert objAPILog;
        
        AddApiLog.ContactID=objcon.id;
        AddApiLog.InsertAPILog(strReq,strRes,blnResult,strMethodName);
        
     }
}