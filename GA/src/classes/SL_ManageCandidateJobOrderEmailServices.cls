/**
* \arg ClassName        : SL_ManageCandidateJobOrderEmailServices
* \arg JIRATicket       : GA-23, GA-32
* \arg CreatedOn        : 19/May/2015
* \arg LastModifiedOn   : 12/June/2015
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : Pankaj Ganwani
* \arg Description      : This class will create Task record to maintain history of the Emails 
*                         sends regards Contact or Job Order to filled out the postitions in the company
*/
global class SL_ManageCandidateJobOrderEmailServices implements Messaging.InboundEmailHandler
{    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope envelope) 
    { 
        String strOwnerId = '';
        String strEmailSubject = email.subject.length() > 255 ? email.subject.subString(0, 254).trim() : email.subject.trim();
        String strEmailBody = (email.plainTextBody.length() > 32760) ? email.plainTextBody.subString(0, 32760) : email.plainTextBody;
        String strFirst = '';
        String strLast = '';
        Id ObjectId;
        Messaging.Inboundemail.Textattachment[] lstTextAttachments = email.textAttachments;
        Messaging.InboundEmail.BinaryAttachment[] lstBinaryAttachments = email.binaryAttachments;
        List<ts2__Job__c> lstJobOrder = new List<ts2__Job__c>();
        String strRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Candidate'].Id;
        String strPortfolioRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'ts2__Job__c' AND DeveloperName = 'Portfolio'].Id;
        String strGANetworkNoteId = [SELECT Id FROM RecordType WHERE SobjectType = 'Task' AND DeveloperName = 'GA_Network_Note'].Id;
        List<User> lstUser = [SELECT Id FROM User WHERE Email =: email.fromAddress];
        List<SL_NoteDefalultOwner__c> lstNoteDefaultOwner = SL_NoteDefalultOwner__c.getAll().values();
        List<Attachment> lstAttachment = new List<Attachment>();
        
        //checking whether the email body contains the disclaimer text or not
        if(strEmailBody.contains('This e-mail (including all attachments) is confidential') && strEmailBody.contains('help@generalatlantic.com. Thank You.'))
        {
        	String endText = 'help@generalatlantic.com. Thank You.';
			Integer startIndex = strEmailBody.lastIndexOf('This e-mail (including all attachments) is confidential');
			Integer endIndex = strEmailBody.lastIndexOf('help@generalatlantic.com. Thank You.') + endText.length();
			strEmailBody = strEmailBody.replace(strEmailBody.substring(startIndex, endIndex), '');	
        }
        
        //Check to remove the email signature from the bottom of the email body
    	if(strEmailBody.contains('--'))
    	{
    		strEmailBody = strEmailBody.replace(strEmailBody.substring(strEmailBody.lastIndexOf('--')).trim(),'').trim();
    	}
    	
    	//checking if email is sent from outlook
    	if(strEmailBody.contains('____')) 	 
		{
		 	Integer endIndex = strEmailBody.lastIndexOf('____');
		 	Integer startIndex = endIndex;
			Integer[] chars = strEmailBody.getChars();
			while(startIndex!=0 && chars[startIndex]!=10 && chars[startIndex]==95)
    				startIndex--;
		 	strEmailBody = strEmailBody.replace(strEmailBody.substring(startIndex),'').trim();
		}
        
        //Removing the last hyphen from the email body if email is sent from outlook
        if(strEmailBody.length()!=0 && strEmailBody.substring(strEmailBody.length() - 1) == '-')
        	strEmailBody = strEmailBody.replace('-','');
        
        //If sender user's detail is found in the salesforce then setting the ownerId of that user 
        if(!lstUser.isEmpty()) 
            strOwnerId = lstUser[0].Id;
        
        //If User details is not found is salesforce then taking owner id from custom setting     
        else if(strOwnerId == '')
        {
            for(SL_NoteDefalultOwner__c objNDO : lstNoteDefaultOwner)
            {
                if(objNDO.Name == 'Note Default Owner')
                    strOwnerId = objNDO.Owner_Id__c;     
            }
        }
        
        //In case the particulare custom setting record is not found then setting current user id as owner id of Note record
        if(strOwnerId == '')
            strOwnerId = Userinfo.getUserId();
        
        //Removing Fwd: and Re: string from Email subject
        if(strEmailSubject.contains('Fwd:') || strEmailSubject.contains('Re:') || strEmailSubject.contains('FW:'))
        {
            strEmailSubject = strEmailSubject.replace('Fwd:', '').trim();
            strEmailSubject = strEmailSubject.replace('Re:', '').trim();
            strEmailSubject = strEmailSubject.replace('FW:', '').trim();
        }    
        
        Set<String> setNameCombination = new Set<String>();
        
        //If user send a name with space seperated then we are considering first Name as a first string after splitting 
        if(strEmailSubject.contains(' '))
        {
            strFirst = strEmailSubject.split(' ')[0].trim();
            strLast = (strEmailSubject.split(' ').size() > 1) ? strEmailSubject.replaceFirst(strEmailSubject.split(' ')[0].trim(), '') : '';   
        }
        else
        {
        	strFirst = strEmailSubject;
        	setNameCombination.add(strEmailSubject);
        }        
        
        List<String> strFirstNameArray = strFirst.split(' ');        
        setNameCombination.addAll(splitArray(strFirstNameArray));
        
        setNameCombination.addAll(strFirst.split(','));
        List<String> strLastNameArray = strLast.trim().split(' ');
        
        setNameCombination.addAll(splitArray(strLastNameArray));
        setNameCombination.addAll(strLast.trim().split(','));
        
        strFirstNameArray.addAll(strLastNameArray);
        setNameCombination.addAll(splitArray(strFirstNameArray));
        
        strFirst = strFirst.replaceAll(',', '').trim();
        strLast = strLast.replaceAll(',', '').trim();
        
        for(Contact objContact : [SELECT Id, 
                                       Name, 
                                       LastName, 
                                       FirstName 
                                  FROM Contact 
                                 WHERE RecordTypeId =: strRecordTypeId
                                   AND (FirstName LIKE : strFirst+'%'
                                    OR FirstName LIKE : strLast+'%'
                                    OR LastName LIKE : strFirst+'%'
                                    OR LastName LIKE : strLast+'%') ORDER BY LastModifiedDate DESC])
        {
            if(setNameCombination.contains(objContact.LastName) && (objContact.FirstName==NULL || setNameCombination.contains(objContact.FirstName)))
            {
            	ObjectId = objContact.Id;
            	break;
            }
        }
       
        
        //If candidate contact record is not found then searching in the Job Order object  
        if(String.isEmpty(ObjectId))
        {            
            for(ts2__Job__c objJobOrder : [SELECT Id,
		                                  ts2__Account__r.Name,
		                                  Name,
		                                  ts2__Account__c
		                             FROM ts2__Job__c 
		                            WHERE (ts2__Account__r.Name LIKE : strFirst+'%' 
		                               OR ts2__Account__r.Name LIKE : strLast+'%'
		                               OR Name LIKE : strLast+'%'
		                               OR Name LIKE : strFirst+'%') AND ts2__Account__c!=NULL AND RecordTypeId =:strPortfolioRecordTypeId ORDER BY LastModifiedDate DESC])
            {
                if(setNameCombination.contains(objJobOrder.Name) && setNameCombination.contains(objJobOrder.ts2__Account__r.Name))
                {
	                  ObjectId = objJobOrder.Id;
	                  break;	    
                }                     
            }   
        }
        
        if(String.isNotEmpty(ObjectId))
        {
            Task objTask = new Task(RecordTypeId = strGANetworkNoteId, Description=strEmailBody, Subject = strEmailSubject, ActivityDate = Date.today());
        	if(Id.valueOf(ObjectId).getSObjectType() == Contact.SobjectType)
        	    objTask.WhoId = ObjectId;
        	else
        	    objTask.WhatId = ObjectId;
        	insert objTask;
        }
        else
        {
            Candidate_JobOrder__c objCandidateJob = new Candidate_JobOrder__c(Name = strEmailSubject);
            insert objCandidateJob;
            
            insert new Task(RecordTypeId = strGANetworkNoteId, Description=strEmailBody, Subject = strEmailSubject, WhatId = objCandidateJob.Id,ActivityDate = Date.today());
            
            ObjectId = objCandidateJob.Id;
        }
            
        if(lstTextAttachments!=null)
        {
        	for(Messaging.Inboundemail.Textattachment objTextAttachment : lstTextAttachments)
        	{
        		lstAttachment.add(new Attachment(Body = Blob.valueOf(objTextAttachment.body), Name = objTextAttachment.fileName, ParentId = ObjectId));
        	}
        }
        
        if(lstBinaryAttachments!=null)
        {
        	for(Messaging.InboundEmail.BinaryAttachment objBinaryAttachment : lstBinaryAttachments)
        	{
        		lstAttachment.add(new Attachment(Body = objBinaryAttachment.body, Name = objBinaryAttachment.fileName, ParentId = ObjectId));
        	}
        }
        insert lstAttachment;
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result.success = true;
        return result;
    }
    
    //Function to prepare combinations of words contained in Email subject statement
    private Set<String> splitArray(List<String> strNameArray)
    {
    	Set<String> setNameCombination = new Set<String>();
    	Integer arraySize = strNameArray.size();
    	for(Integer i = 0; i < arraySize; i++)
        {
        	String strName = '';
        	for(Integer j=i; j < arraySize; j++)
        	{
        		strName+= String.isBlank(strName) ?  strNameArray[j].trim() : ' '+ strNameArray[j].trim();
        		setNameCombination.add(strName.trim());
        	}
        }
        
        for(Integer i = arraySize - 1; i >= 0 ; i--)
        {
        	String strName = '';
        	for(Integer j = i; j >=0; j--)
        	{
        		strName+= String.isBlank(strName) ?  strNameArray[j].trim() : ' '+ strNameArray[j].trim();
        		setNameCombination.add(strName.trim());
        	}
        }        
        return setNameCombination;
    }
}
/* End */