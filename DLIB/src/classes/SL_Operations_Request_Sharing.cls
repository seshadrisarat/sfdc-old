/**
 * @Author      : Edward Rivera
 * @ClassName   : SL_Operations_Request_Sharing
 * @CreatedOn   : 3 Sep 2014
 * @Test        : SL_Test_OperationsRequest
 * @Description : This is a container class for a method that needs to be in a system context without sharing
 */
public without sharing class SL_Operations_Request_Sharing {
    /*
    @MethodName    : shareWithRequester
    @param      :requests - all affected OperationsRequest objects
    @Description  : To automatically share the record with the lookup in the Requester__c field
    */    
    public static void shareWithRequester(List<Operations_Request__c> requests){
        List<Operations_Request__Share> requestSharing = new List<Operations_Request__Share>();
        for(Operations_Request__c request:requests){
            if (request.Private__c){
                Operations_Request__Share privateRequester = new Operations_Request__Share();
                privateRequester.ParentId = request.Id;
                privateRequester.UserOrGroupId = request.Requester__c;
                privateRequester.AccessLevel = 'read';
                //privateRequester.RowCause = Schema.Operations_Request__Share.RowCause.Private_Requester_Access__c;
                requestSharing.add(privateRequester);
            }
        }
        if (!requestSharing.isEmpty()){        
            Database.SaveResult[] requestShareInsertResult = Database.insert(requestSharing,false);
        }
    }
}