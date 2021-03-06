public with sharing class SL_E3AddUpdateController {

    private ApexPages.StandardController controller;
    private final Opportunity selectedOpportunity;
    public string selOpportunity {get; set;}
    public string response {get; set;}
    public string syncLog {get; set;}

	public boolean refreshPage {get; set;}
    //private String username = 'myname';
    //private String password = 'mypwd';

    String username = 'E3SyncUser';
    String password = 'naBLOFF6';
      
    public SL_E3AddUpdateController(ApexPages.StandardController stdController) {
        this.controller = stdController;
        this.selectedOpportunity = (Opportunity)stdController.getRecord();
        this.selOpportunity = this.selectedOpportunity.Id;
        
        this.refreshPage = false;
        
    }
    
    public void AddUpdateE3(){
        
        //Validation
        
        boolean okToSync = true; //default
        
        
        //if Opp's record type is "Service Only" it must have at least one related prospect service contract
        //UPDATE: this validation rule has been removed by Kerry W.
        
        Opportunity opp = [select Id, recordType.Name, AccountId, sale_status__c from Opportunity where id=:selOpportunity];
        /*
        
        if (opp.recordType.Name.equals('Service Only')) {

            List<Prospect_Service_Contract__c> contracts = [select id from Prospect_Service_Contract__c where Opportunity__c =:selOpportunity];
            if (contracts.size() < 1) {
                okToSync = false;
                response = 'Opportunities of record type \'Service Only\' must have at least one related Prosect Service Contract';
    
            }  
        }
        */
		if (opp.sale_status__c != 'Sold') {
			okToSync = false;
			response = 'Sale Status must be set to \'Sold\' before this record may be pushed to E3.';
		}


		
		//Do not sync if Account.HHAU__c is blank
		Account acc = [select id, 
		Energy_AccountNumLong__c, 
		HHAU__c, 
		IsTerminated__c,
		PersonHomePhone,
		PersonMobilePhone,
		Phone
		from account where id=:opp.AccountId];
		
		
		//Only if creating a new E3 Account. Otherwise, this validation logic does not apply.
		
		
		if (acc.Energy_AccountNumLong__c == null || acc.Energy_AccountNumLong__c == '') 
		{

			//If none of home, work, cell/mobile have values, then don't sync
			if ((acc.PersonHomePhone == null || acc.PersonHomePhone == '') &&
				(acc.Phone == null || acc.Phone == '') &&
				(acc.PersonMobilePhone == null || acc.PersonMobilePhone == '')
			) {
				okToSync = false;
				response = 'The parent Account must have at least one of the following phone numbers set: Home, Work or Mobile.';
			}			
			
			//New accounts need value for HHAU
			if (acc.HHAU__c == null || acc.HHAU__c == '') {
				okToSync = false;
				response = 'The HHAU value for the parent Account must not be blank.';
			}
		
		}
		
		if (acc.IsTerminated__c) {
			okToSync = false;
			response = 'This Account is terminated and cannot be sold.';
		} 
		
		
        

        if (okToSync){

                    
            Http h = new http();
            HttpRequest req = new HttpRequest();

            //Set auth header
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);  
    
            req.setEndpoint('http://ec2-54-68-184-10.us-west-2.compute.amazonaws.com/Services/E3Sync.svc/AddUpdateE3?i=' + selOpportunity);
            req.setMethod('GET');
            req.setTimeout(90000); //90 seconds
            HttpResponse res = h.send(req);
            string JSONResponse = res.getBody();
            
    
         // Parse entire JSON response into E3AddUpdateResponse
            try {
                JSONParser parser = JSON.createParser(JSONResponse);
                E3AddUpdateResponse e3r = (E3AddUpdateResponse)parser.readValueAs(E3AddUpdateResponse.class);       
                //response = res.getBody();
                //response = 'EnergyAcctID: ' + e3r.EnergyAcctID + ', SyncResult: ' + e3r.SyncResult + ', LongErrorMessage: ' + e3r.LongErrorMessage;
                response = e3r.SyncMessages;
                //More detailed excpetion messages are found in response.LongErrorMessage;
                //response += e3r.LongErrorMessage;
                system.debug('e3r.SyncResult: ' + e3r.SyncResult);
                if (e3r.SyncResult == 'Success') {
                	//If successful, update the stage to "Sold" and update the sold date to today's date
                	opp.StageName = 'Sold';
                	opp.Sold_Date__c = system.today();
                	update opp;
                }
                
                } catch(Exception e)
            {
                response = 'An error occurred: ' + e + 'Raw server response: ' + JSONResponse;
                
            }
    		//Not needed if inline VF page will be causing full page refresh
            //updateOppValues();
        }
        
        
        //Needed only if inline VF page will be causing full page refresh
        if (okToSync) refreshPage = true;
    }

    void updateOppValues() {
        
        controller.reset();
        
    }
    

    
    public void ClearAllSyncData() {
        
        /*
        set Account.Energy_AccountNumLong__c = ""
        set Account.E3_sync_log__c = "Sync data deleted in SFDC only.  E3 records remain.\r\n" + E3_sync_log__c;
        
        set Opportunity.Synced_with_E3__c = false
        set Opportunity.E3_sync_log__c "Sync data deleted in SFDC only.  E3 records remain.\r\n" + E3_sync_log__c 
        
        set Prospect_Service_Contract__c.Energy_Service_ID__c = ""
        
        */
        
        Opportunity opp = [select E3_sync_log__c, Synced_with_E3__c, Account.Id from Opportunity where id=:selOpportunity];
        Account acc = [select id, Energy_AccountNumLong__c, E3_Sync_Log__c from account where id=:opp.Account.Id];
        //List<Prospect_Service_Contract__c> contracts = [select id, name, Energy_Service_ID__c from Prospect_Service_Contract__c where Opportunity__c =:opp.Id];
        //Update Account
        acc.Energy_AccountNumLong__c = '';
        acc.E3_sync_log__c = DateTime.now().format('yyyy-MM-dd HH:mm:sszzz') + ' Account sync data deleted in SFDC only.  E3 records remain.\r\n' +acc.E3_sync_log__c; 
        update acc;
        
        //Update Opportunity
        opp.Synced_with_E3__c = false;
        opp.E3_sync_log__c = DateTime.now().format('yyyy-MM-dd HH:mm:sszzz') + ' Parent Account sync data deleted in SFDC only.  E3 records remain.\r\n' +opp.E3_sync_log__c; 
        opp.E3_sync_log__c = DateTime.now().format('yyyy-MM-dd HH:mm:sszzz') + ' Opportunity sync data deleted in SFDC only.  E3 records remain.\r\n' + opp.E3_sync_log__c;
        update opp;
        
        /* No longer needed. We will not be updating contract records in SFDC
        //Update each Prospect Service Contract
        for (Prospect_Service_Contract__c c : contracts) {
            c.Energy_Service_ID__c = '';
            opp.E3_sync_log__c = DateTime.now().format('yyyy-MM-dd HH:mm:sszzz') + ' Prospect Service Contract sync data deleted in SFDC only (E3 Service ID: '+ c.Energy_Service_ID__c +').  E3 records remain.\r\n' + opp.E3_sync_log__c;
            //no sync log data in prospect service contract records
        }       

        if (contracts.size() > 0) update contracts;
         */        
        //Update UI
        response = 'E3 sync data cleared';

        //reload any fields in VF page that need to be updated
        updateOppValues();
        
    }


    
     
    public class E3AddUpdateResponse
    {
        public string EnergyAcctID { get; set; }
        public string SyncResult{ get; set; }
        public string LongErrorMessage { get; set; }  //This can be displayed on UI for further debugging.  For now, it is hidden from the user. 
        public string SyncMessages { get; set; }
     }
}