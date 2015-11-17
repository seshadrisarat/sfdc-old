//This will only work on update operations
public class SL_ErrorLogger 
{
    public static void invokeErrorLogger(List<Database.SaveResult> DMLOperationResults , List<Sobject> lstDMLObject)
    {
        List<Error_Log__c> lstErrorLogDebug = new List<Error_Log__c>();
        if(!Error_Logging__c.getall().values().isEmpty() && Error_Logging__c.getall().values()[0].isErrorLog__c)
        {
            for(Integer i=0;i<DMLOperationResults.size();i++)
            {
                if (!DMLOperationResults.get(i).isSuccess())
                {
                    // DML operation failed
                    Database.Error error = DMLOperationResults.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    String recordId = lstDMLObject.get(i).Id;
                    lstErrorLogDebug.add(new Error_Log__c(Id__c = recordId , Debug_Log__c = failedDML));
                }
            }
            if(!lstErrorLogDebug.isEmpty())
                database.insert(lstErrorLogDebug , false);
        }    
    }
}