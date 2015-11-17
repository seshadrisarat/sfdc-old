/*
    Author: Kyle Lawson
    Created Date: April 7, 2014
    Description: Extension for the SL_Requestinfo VF page. Enables users to reassign Credit Requests that are in the middle
                 of an approval process in order to get more info about the request. It creates a chatter post with an @ mention to the person who submitted the record or to the person who requested more information, whichever is relevant. It will set the status of the record to 'Awaiting Information' when a request goes out, and back to whatever the status was before when the response comes in. Allows the user to attach a file to their chatter request for more information.
*/

public without sharing class SL_RequestInfoExtension {

    public final Credit_Requests__c creditRequest {get; set;}
    public String message {get; set;}
    public String btnText {get; set;}
    public String titleText {get; set;}
    public Boolean awaitingInformation {get; set;}
    public Boolean addFile {get; set;}
    public Blob fileContents {get; set;}
    public String contentType {get; set;}
    public String fileName {get; set;}
    public Boolean refreshPage {get; set;}

     // The extension constructor initializes the private member
     // variable creditRequestId by using the getRecord method from the standard
     // controller, and creditRequest by a SOQL query filtered on creditRequestId so that we
     // can get custom fields.
    public SL_RequestInfoExtension(ApexPages.StandardController stdController) {
        creditRequest = (Credit_Requests__c)stdController.getRecord();
        awaitingInformation = creditRequest.Status__c == 'Awaiting Information' ? true : false;
        btnText = !awaitingInformation ? 'Request Info' : 'Submit Info';
        titleText = !awaitingInformation ? 'Request for More Information:' : 'More Information about Credit Request:';
        fileContents = null;
        contentType = '';
        fileName = '';
        addFile = false;
        refreshPage = false;
    }

    /* Sends a chatter post to the person who originally submitted the credit request if the
        status of the request is not currently Awaiting Information or if the Requester field is blank.
        Otherwise it sends a chatter post to the person who requested information. Also should reassign
        the record to whomever the chatter post recipient is. */
    public PageReference sendChatterPost(){

        // Do not allow someone to submit a blank form
        if(String.isBlank(message))
            return null;

        Map<Id, String> prevApprover = SL_Util_Approvals.retrievePreviousApprover(creditRequest.Id);
        Id recipientID, prevApproverId;
        String requesterName;

        Credit_Requests__c creditRequest_Full = [SELECT Requester__c, Previous_Status__c, Submitter_Id__c, Credit_Last_Out_Timestamp__c, Credit_Last_In_Timestamp__c, Total_Time_in_Credit__c
                                                      FROM Credit_Requests__c
                                                      WHERE id = :creditRequest.Id LIMIT 1];

        // Check whether this is the requester of information or the requestee based on the status
        if(creditRequest.Status__c != 'Awaiting Information' || String.isBlank(creditRequest_Full.Requester__c)){

            if(String.isBlank(creditRequest_Full.Submitter_Id__c))
                return null;
            else
                recipientId = creditRequest_Full.Submitter_Id__c;
            
            if(prevApprover == null){ // No previous approver, use current user
                prevApproverId = UserInfo.getUserId();
                requesterName = UserInfo.getUserName();
            }else{
                prevApproverId = (new List<Id>(prevApprover.keySet()))[0];
                requesterName = prevApprover.values()[0];

                if(prevApproverId.getSObjectType().getDescribe().getName() != 'User'){//Ensure we're using a UserId for prevApproverId
                    prevApproverId = UserInfo.getUserId();
                    requesterName = UserInfo.getUserName();
                }
            } 

            // Get record type for locked records from custom setting
            Approval_Record_Types__c csRecordType = Approval_Record_Types__c.getValues('Locked');

            creditRequest_Full.Previous_Status__c = creditRequest.Status__c;
            creditRequest_Full.Status__c = 'Awaiting Information';
            creditRequest_Full.Requester__c = prevApproverId;
            creditRequest_Full.Requester_Name__c = requesterName;
            creditRequest_Full.RecordTypeId = csRecordType.RecordTypeId__c;
            creditRequest_Full.Credit_Last_Out_Timestamp__c = Datetime.now();
            creditRequest_Full.Total_Time_In_Credit__c = calcTimeInCredit(creditRequest_Full);

        }else{
            // Get record type for unlocked records from custom setting
            Approval_Record_Types__c csRecordType = Approval_Record_Types__c.getValues('Unlocked');

            recipientID = creditRequest_Full.Requester__c;
            creditRequest_Full.Status__c = creditRequest_Full.Previous_Status__c;
            creditRequest_Full.Previous_Status__c = '';
            creditRequest_Full.Requester__c = '';
            creditRequest_Full.Requester_Name__c = '';
            creditRequest_Full.RecordTypeId = csRecordType.RecordTypeId__c; 
            creditRequest_Full.Credit_Last_In_Timestamp__c = Datetime.now();
        }

        try {
            SL_Util_Approvals.reassign(creditRequest.Id, recipientId);

        }catch(DmlException ex){
            System.debug(LoggingLevel.ERROR, 'Error reassigning record in sendChatterPost: ' + ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You can\'t reassign this record.'));
            return null;
        }

        try {
            update creditRequest_Full;

        }catch(DMLException ex){
            System.debug(LoggingLevel.ERROR, 'Error updating Credit Request in sendChatterPost: ' + ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating Credit Request'));
            return null;
        }

        // Create chatter post and post to the record's feed
        ConnectApi.FeedItem feedItemRep = postToChatter(recipientID, message, fileContents, contentType, fileName);

        // Clear the file fields so that we don't error out when we try to return to the page
        message = '';
        fileContents = null;
        contentType = '';
        fileName = '';

        // Triggers conditionally rendered javascript so the page refreshes
        refreshPage = true;

        return null;
    }

    // Calculates the time between the last out and last in timestamp and converts from milliseconds into minutes
    @TestVisible
    private Decimal calcTimeInCredit(Credit_Requests__c request){
        Decimal totalTimeInCredit = request.Total_Time_in_Credit__c == null ? 0 : request.Total_Time_in_Credit__c;

        totalTimeInCredit += (request.Credit_Last_Out_Timestamp__c.getTime() - request.Credit_Last_In_Timestamp__c.getTime()) / 60000;

        return totalTimeInCredit;
    }

    // Creates a chatter post prepended with an '@' mention of the intended recipient, and optionally attaches a file if
    // 'file' contains the binary of the file, 'fileType' contains a string of the file type, and 'fName' contains the file name
    @TestVisible
    private ConnectApi.FeedItem postToChatter(ID recipientId, String message, Blob file, String fileType, String fName){
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = recipientId;
        messageInput.messageSegments.add(mentionSegment);

        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = ' ' + message;
        messageInput.messageSegments.add(textSegment);

        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.body = messageInput;

        input.visibility = ConnectApi.FeedItemVisibilityType.InternalUsers;

        ConnectApi.FeedItem feedItemRep;

        // If the user chose a file to attach, add it to the chatter post
        if(file != null && file.size() > 0 && String.isNotBlank(fileType) && String.isNotBlank(fName)){
            ConnectApi.BinaryInput f = new ConnectApi.BinaryInput(file, fileType, fName);
            ConnectApi.NewFileAttachmentInput fileAttachment = new ConnectApi.NewFileAttachmentInput();
            fileAttachment.title = fName;
            input.attachment = fileAttachment;

            feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, creditRequest.Id, input, f);
        }else{ // No file to attach
            feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, creditRequest.Id, input, null);
        }

        return feedItemRep;
    }

    public void enableFileAttach(){
        addFile = true;
    }
}