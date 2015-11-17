/**
* \arg ClassName      : SL_WS_GenerateMergedPDF
* \arg JIRATicket     : OAKHILL-6
* \arg CreatedOn      : 24/DEC/2014
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class is used to merge all documents corresponding to current report generator
*/
global class SL_WS_GenerateMergedPDF 
{
    /** 
        * @Name         : mergeFiles
        * @parameter    : report generator Id
        * @Description  : This method will be called on click of detail page button of report generator page
    */ 
    webservice static String mergeFiles(Id reportGeneratorId, String reportGeneratorName)
    {
        Set<String> setTransDocId = new Set<String>();//set to hold transaction document records corresponding to the current report generator record
        List<Id> lstDocId = new List<Id>();//list to hold ids of documents that needs to be merged.
        List<Loop__Document_Request__c> lstDocumentQueue = new List<Loop__Document_Request__c>();
        //Fetching the transaction document ids corresponding to the current report generator
        for(Investor_Report_Document__c objTD : [SELECT Id FROM Investor_Report_Document__c WHERE Report_Generator__c=:reportGeneratorId])
        {
            setTransDocId.add(objTD.Id);
        }       
        if(!setTransDocId.isEmpty())
        {
            //Fetching document queue records corresponding to the report generator
            for(Loop__Document_Request__c objDR : [SELECT Id, Loop__Document_Id__c 
                                                   FROM Loop__Document_Request__c
                                                   WHERE Loop__Object_Id__c IN :setTransDocId AND Loop__Status__c=:'Complete'])
            {
                objDR.Loop__Status__c = 'Merged';
                lstDocumentQueue.add(objDR);
                lstDocId.add(objDR.Loop__Document_Id__c);
            }
            if(!lstDocId.isEmpty())
            {
                Date dtToday = Date.today();
                Loop.DocumentService.convertAndMerge(lstDocId, reportGeneratorId, 'AUDIT - '+String.join(new List<String>{String.valueOf(dtToday.month()),String.valueOf(dtToday.day()), String.valueOf(dtToday.year())},'-')+' - '+reportGeneratorName, new Map<String,String>{'trackActivity' => 'false','mergeType' => 'pdf'});
                update lstDocumentQueue;
                return Label.SL_ReportGeneratorJobProcessing;
            }
            else
                return Label.SL_EmptyDocumentQueue;
        }
        else
            return Label.SL_NoInvestorDocumentFound;
    }
}