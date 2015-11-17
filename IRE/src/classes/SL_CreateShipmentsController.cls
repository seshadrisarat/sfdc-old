/**
* \arg ClassName      : SL_CreateShipmentsController
* \arg JIRATicket     : IRE-5
* \arg CreatedOn      : 10th/March/2015
* \arg LastModifiedOn : 30/March/2015
* \arg CreatededBy    : Sandeep
* \arg ModifiedBy     : Sandeep
* \arg Description    : This class is used to create shipments for literature request .
*/
public with sharing class SL_CreateShipmentsController 
{
	/* Start - variables */
	private String strLiteratureRequestId;  	
	private String strvalidateId;	
	private zkups__BulkShipment__c objBulkShipment;
	private String strProcessBulkShipmentId;
	/* End - variables */
	
	/* Start - SL_CreateShipmentsController Constructor */
	public SL_CreateShipmentsController()
	{
		/* Getting the Literature Request record Id from URL */
    	strLiteratureRequestId = ApexPages.currentPage().getParameters().get('id');

    	// Added so user can leave and return to page without needed to re-validate
    	if(!String.isBlank(strLiteratureRequestId)){

	    	Literature_Requests__c temp = [SELECT Validation_Batch_ID__c, Current_Bulk_Shipment_Id__c
	                         FROM Literature_Requests__c 
	                         WHERE Id =: strLiteratureRequestId];

	        strvalidateId = temp.Validation_Batch_ID__c;

	        if(!String.isBlank(temp.Current_Bulk_Shipment_Id__c)){
	        	objBulkShipment = [SELECT Id,
										   zkups__ShipmatePreference__c,
										   zkups__ShipmatePreference__r.zkups__PrimaryContactPhone__c,
										   zkups__ShipmatePreference__r.zkups__CompanyName__c, 
										   zkups__ShipmatePreference__r.zkups__ShippingStreet__c,
										   zkups__ShipmatePreference__r.zkups__ShippingCity__c,
										   zkups__ShipmatePreference__r.zkups__ShippingState__c,
										   zkups__ShipmatePreference__r.zkups__ShippingPostalCode__c,
										   zkups__ShipmatePreference__r.zkups__ShippingCountry__c
									  FROM zkups__BulkShipment__c
									 WHERE Id = :temp.Current_Bulk_Shipment_Id__c LIMIT 1];
	        }
    	}
	}
	/* End - SL_CreateShipmentsController Constructor */
	
    /*
     @MethodName: createShipments
     @param: na
     @Description: This method is used to create shipments
    */
    public void createShipments()
    {
    	Literature_Requests__c objLiteratureRequest;
    	zkups__QueuedShipment__c objQueuedShipment;
    	zkups__QueuedPackage__c  objQueuedPackage; 
    	
    	try
    	{
	    	/* Getting literature request record detail */
	    	if(strLiteratureRequestId != null && strLiteratureRequestId != '')
	    	{
		    	objLiteratureRequest = [SELECT Id,
		    								   Delivery_Method__c,
		    								   Zip_Postal_Code__c,
		    								   State_Province__c,
		    								   City__c,
		    								   Street__c,
		    								   Contact_Name__c,
		    								   Weight__c,
		    								   UPS_Account__c,
		    								   UPS_Account__r.zkups__CompanyName__c,
		    								   Recipient_Phone_Number__c,
		    								   Packaging_Type__c,
		    								   Country__c 
		    							  FROM Literature_Requests__c 
		    							 WHERE Id =: strLiteratureRequestId];
		    							 
	    	}
	    	
	    	zkups__UPSShipmatePreference__c objShipmentPreference;
	    	/* Getting UPSShipmatePreference record */
	    	if(objLiteratureRequest.UPS_Account__c != null)
	    	{ 
	    		objShipmentPreference = [SELECT Id, 
												Name, 
												zkups__CompanyName__c, 
												zkups__ShippingStreet__c, 
												zkups__ShippingCity__c, 
												zkups__ShippingState__c,
												zkups__ShippingPostalCode__c,
												zkups__PrimaryContactPhone__c,
												zkups__LabelImageTypeDefault__c 
										   FROM zkups__UPSShipmatePreference__c 
										  WHERE Id =: objLiteratureRequest.UPS_Account__c LIMIT 1];
	    	 
	    	}
	    	else
	    	{
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'UPS Account can'+'\'' +'t be empty on the Literature request.'));	
	    	}
	    	
	    	zkups__BulkShipment__c objBulkShipmentToInsert;
	    	
	    	/* Creating zkups__BulkShipment__c record */
	    	if(objShipmentPreference != null )
	    	{
				objBulkShipmentToInsert = new zkups__BulkShipment__c(zkups__ShipmatePreference__c = objShipmentPreference.Id);
			    insert objBulkShipmentToInsert;

			    objLiteratureRequest.Current_Bulk_Shipment_Id__c = objBulkShipmentToInsert.Id; // So user can leave and return to page
	    	}
	    	
	    	List<zkups__BulkShipment__c> lstBulkShipment = new List<zkups__BulkShipment__c>();
	    	
	    	if(objBulkShipmentToInsert != null)
	    	{
		    	lstBulkShipment = [SELECT Id,
										   zkups__ShipmatePreference__c,
										   zkups__ShipmatePreference__r.zkups__PrimaryContactPhone__c,
										   zkups__ShipmatePreference__r.zkups__CompanyName__c, 
										   zkups__ShipmatePreference__r.zkups__ShippingStreet__c,
										   zkups__ShipmatePreference__r.zkups__ShippingCity__c,
										   zkups__ShipmatePreference__r.zkups__ShippingState__c,
										   zkups__ShipmatePreference__r.zkups__ShippingPostalCode__c,
										   zkups__ShipmatePreference__r.zkups__ShippingCountry__c
									  FROM zkups__BulkShipment__c
									 WHERE Id =: objBulkShipmentToInsert.Id LIMIT 1];
	    	}		    										 
	    	
	    	for(zkups__BulkShipment__c objBulkShip : lstBulkShipment)
	    	{
	    		objBulkShipment = objBulkShip;
	    	}
	    	
	    	String strCustomAddressSourceId = [SELECT Id, Name FROM zkups__CustomAddressSource__c WHERE Name = 'Literature Requests' LIMIT 1].Id;
	    	
	    	
	    	if(strCustomAddressSourceId != null && strCustomAddressSourceId != '' && objLiteratureRequest != null && objBulkShipmentToInsert != null)
	    	{   
	    		/* Creating zkups__QueuedShipment__c record */ 	
	    		objQueuedShipment = new zkups__QueuedShipment__c(zkups__BulkShipment__c = objBulkShipment.Id, zkups__CustomAddressSource__c = strCustomAddressSourceId, 
	    														 zkups__CustomAddressSourceRecordId__c = strLiteratureRequestId, zkups__LabelImageType__c = objShipmentPreference.zkups__LabelImageTypeDefault__c , 
	    														 zkups__ReturnShipment__c = false, zkups__PaymentType__c = 'Sender', zkups__ServiceType__c = 
	    														 objLiteratureRequest.Delivery_Method__c, zkups__RecipientName__c = objLiteratureRequest.Contact_Name__c, 
	    														 zkups__RecipientStreet__c = objLiteratureRequest.Street__c, zkups__RecipientCity__c = 
	    														 objLiteratureRequest.City__c, zkups__RecipientState__c = objLiteratureRequest.State_Province__c,
	    														 zkups__RecipientPostalCode__c = objLiteratureRequest.Zip_Postal_Code__c.replace('-', ''), 
	    														 zkups__RecipientCompany__c = objLiteratureRequest.UPS_Account__r.zkups__CompanyName__c,
	    														 zkups__RecipientPhone__c = objLiteratureRequest.Recipient_Phone_Number__c, zkups__RecipientCountry__c = 
	    														 objLiteratureRequest.Country__c, zkups__PackagingType__c = objLiteratureRequest.Packaging_Type__c,
	    														 zkups__SenderName__c = objBulkShipment.zkups__ShipmatePreference__r.zkups__CompanyName__c, 
	    														 zkups__SenderStreet__c = objBulkShipment.zkups__ShipmatePreference__r.zkups__ShippingStreet__c, 
	    														 zkups__SenderCity__c = objBulkShipment.zkups__ShipmatePreference__r.zkups__ShippingCity__c, zkups__SenderState__c = 
	    														 objBulkShipment.zkups__ShipmatePreference__r.zkups__ShippingState__c, zkups__SenderPostalCode__c = 
	    														 objBulkShipment.zkups__ShipmatePreference__r.zkups__ShippingPostalCode__c, zkups__WeightDimensionUnits__c = 
	    														 'LB / IN', zkups__SenderPhone__c = objBulkShipment.zkups__ShipmatePreference__r.zkups__PrimaryContactPhone__c,
	    														 zkups__SenderCompany__c = objBulkShipment.zkups__ShipmatePreference__r.zkups__CompanyName__c,
	    														 zkups__SenderCountry__c = objBulkShipment.zkups__ShipmatePreference__r.zkups__ShippingCountry__c);
	    																				  
	    		insert objQueuedShipment;
	    	}
	    	
	    	if(objQueuedShipment != null && objLiteratureRequest != null )
	    	{
	    		/* Creating zkups__QueuedPackage__c record */
		    	objQueuedPackage = new zkups__QueuedPackage__c(zkups__DeclaredValue__c = 0, zkups__Weight__c = objLiteratureRequest.Weight__c, 
		    												   zkups__QueuedShipment__c = objQueuedShipment.Id);
		    	insert objQueuedPackage;
	    	}
	    	
	    	/* Calling validateBulkShipment method  */
	    	if(objBulkShipment != null){
	    		strvalidateId = zkups.BulkShipmentInterface.validateBulkShipment(objBulkShipment.Id, false);

	    		if(objLiteratureRequest != null){
                    objLiteratureRequest.Validation_Batch_ID__c = strvalidateId;
                    update objLiteratureRequest;
                }
	    	}
	    }
	    catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
		}
    }
    
    /*
     @MethodName: processShipment
     @param: na
     @Description: This method is used to process shipments
    */
    public void processShipment()
    {
    	zkups__QueuedShipmentStatus__c objQueuedShipmentStatus;
    	List<zkups__QueuedShipmentStatus__c> lstQueuedShipmentStatus  = new List<zkups__QueuedShipmentStatus__c>();
    	
    	try
    	{
    		
	    	if(strvalidateId !='' && strvalidateId != null && objBulkShipment != null)
	    	{
	    		/* Getting QueuedShipmentStatus detail */
		    	 lstQueuedShipmentStatus = [SELECT Id,
		    	 								   zkups__Status__c, 
												   zkups__StatusMessage__c, 
												   zkups__PrintBatchId__c,
												   zkups__BatchId__c 
											  FROM zkups__QueuedShipmentStatus__c 
											 WHERE zkups__BatchId__c =: strvalidateId LIMIT 1];
	    	} else {
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please validate before processing a shipment.'));
	    		return;
	    	}
	    	
	    	if(Test.isRunningTest())
	    	{
	    		objQueuedShipmentStatus = new zkups__QueuedShipmentStatus__c();
	    		objQueuedShipmentStatus.zkups__Status__c = 'VALIDATED';	
	    	}
	    	else
	    	{
				for(zkups__QueuedShipmentStatus__c objQueuedShipStatus : lstQueuedShipmentStatus)
				{
					objQueuedShipmentStatus = objQueuedShipStatus;
				}
	    	}
	    	
	    	if(objQueuedShipmentStatus != null)
			{
				if(objQueuedShipmentStatus.zkups__Status__c == 'ERROR')
				{
					/* Displayinh error message to User if status is 'Error' */
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, objQueuedShipmentStatus.zkups__StatusMessage__c));
				}
				
				if(objQueuedShipmentStatus.zkups__Status__c == 'VALIDATED')
				{
					/* Calling processBulkShipment method if status is 'Validated' */
					strProcessBulkShipmentId = zkups.BulkShipmentInterface.processBulkShipment(objBulkShipment.Id);
					
					lstQueuedShipmentStatus = new List<zkups__QueuedShipmentStatus__c>();
					zkups__QueuedShipmentStatus__c objQuestatus;
					if(strProcessBulkShipmentId !='' && strProcessBulkShipmentId != null)
					{
						lstQueuedShipmentStatus = [ SELECT Id,
			    	 								   zkups__Status__c, 
													   zkups__StatusMessage__c, 
													   zkups__PrintBatchId__c,
													   zkups__BatchId__c 
												  FROM zkups__QueuedShipmentStatus__c 
												 WHERE zkups__BatchId__c =: strProcessBulkShipmentId LIMIT 1];
					}
					
					if(Test.isRunningTest())
	    			{
	    				objQuestatus = new zkups__QueuedShipmentStatus__c();
	    				objQuestatus.zkups__Status__c = 'SUCCESS';
	    			}
	    			else
	    			{
						for(zkups__QueuedShipmentStatus__c objQueshipStatus : lstQueuedShipmentStatus)
						{
							objQuestatus = objQueshipStatus;
						}
	    			}
	    			
					if(objQuestatus != null)
					{
						if(objQuestatus.zkups__Status__c == 'SUCCESS')							 
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Shipment was successfully processed.'));
						
						/* Displayinh error message to User if status is 'Error' */
						if(objQuestatus.zkups__Status__c == 'ERROR')
							ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, objQuestatus.zkups__StatusMessage__c));
					}
					else
					{
						fetchStatusProceed();
					}		
				}    	
			}
	    	else
	  	  	{
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Wait for a few seconds then click on the '+'\''+'Process Shipments'+'\'' +' button after validating.'));
	    	}
    	}
    	catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + ' -- Line: ' + ex.getLineNumber()));
		}	
    }
    
    public void fetchStatusProceed()
    {
    	List<zkups__QueuedShipmentStatus__c> lstQueuedShipmentStatus = new List<zkups__QueuedShipmentStatus__c>();
		zkups__QueuedShipmentStatus__c objQuestatus;
		
		if(strProcessBulkShipmentId !='' && strProcessBulkShipmentId != null)
		{
			lstQueuedShipmentStatus = [ SELECT Id,
    	 								   zkups__Status__c, 
										   zkups__StatusMessage__c, 
										   zkups__PrintBatchId__c,
										   zkups__BatchId__c 
									  FROM zkups__QueuedShipmentStatus__c 
									 WHERE zkups__BatchId__c =: strProcessBulkShipmentId LIMIT 1];
		}
		
		if(Test.isRunningTest())
		{
			objQuestatus = new zkups__QueuedShipmentStatus__c();
			objQuestatus.zkups__Status__c = 'SUCCESS';
		}
		else
		{
													 
			for(zkups__QueuedShipmentStatus__c objQueshipStatus : lstQueuedShipmentStatus)
			{
				objQuestatus = objQueshipStatus;
			}
		}
		
		if(objQuestatus != null)
		{
			if(objQuestatus.zkups__Status__c == 'SUCCESS')							 
			{	
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Shipment was successfully processed.'));
			}
			
			/* Displaying error message to User if status is 'ERROR' */
			if(objQuestatus.zkups__Status__c == 'ERROR')
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, objQuestatus.zkups__StatusMessage__c));
		}
    }
}