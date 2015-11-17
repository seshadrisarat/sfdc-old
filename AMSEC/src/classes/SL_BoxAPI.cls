public with sharing class SL_BoxAPI {
    Id purchaseRecTypeId = Schema.SObjectType.Deal__c.RecordTypeInfosByName.get('Purchase').RecordTypeId;
    Id ideaRecTypeId = Schema.SObjectType.Deal__c.RecordTypeInfosByName.get('Idea').RecordTypeId;
    Id portFolioRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Portfolio Company').RecordTypeId;
    Id portFolioFormerRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Former Portfolio').RecordTypeId;
    
    Map<String, Box_Template_Structure__c> boxStructureFolders = Box_Template_Structure__c.getAll();
    
    // Map to keep the box folder Name to Id...
    public Map<String, String> mapOfFolderNameToFolderId = new Map<String, String>();
    Map<String, String> mapOfStatusToBoxFolderName;
    Map<String, Box_Groups_Access_Levels__c> mapOfNameToGroupName;                                                   

    public SL_BoxAPI() {
        mapOfStatusToBoxFolderName =  new Map<String,String>();
        mapOfNameToGroupName = new Map<String,Box_Groups_Access_Levels__c>();

        // Collecting all the values from the custom setting....Status_Buckets__c
        for(Status_Buckets__c objStatus : Status_Buckets__c.getAll().values()) {
            mapOfStatusToBoxFolderName.put(objStatus.Am_Sec_Status__c, objStatus.Box_Folder_Name__c);
        }

        for(Box_Groups_Access_Levels__c objgroupAccess : Box_Groups_Access_Levels__c.getAll().values()) {
            if(objgroupAccess.Folder_Name__c != NULL)
                mapOfNameToGroupName.put(objgroupAccess.Name, objgroupAccess);
        }
    }

    /*
    Developer: Gordon Arnold
    Description: creates a new folder in box.com
    Parameters: recordID:The ID of the salesforce record that you want to create the folder for
                parentId: The ID of the parent record the box folder is going to go under
                foldername: The name that the the folder will be when the folder is created
    Return: The ID of the box folder in box.com
    Note: Uses box built in toolkit so this does not need authentication
    */
    public String boxCreateFolder(Map<Id, Deal__c> mapOfDealRecs, Map<Id, String> mapOfDealTofolderName,box.toolKit boxToolKit)
    {
        String boxID = null;
        Map<Id, String> mapOfDealIdToFolderId = new Map<Id, String>();
        Map<String, String> mapOfSubFolderIdToName = new Map<String, String>();
        Id dealIdHold;
        /*if(checkAuthentication() || Test.isRunningTest())
        {*/
            Box_OAuth__c boxAuthSetting = Box_OAuth__c.getValues(UserInfo.getUserId());
            mapOfSubFolderIdToName = getSubFolders(mapOfFolderNameToFolderId.get('New Deal Template'));  // Getting the subFolder's Info by hard-coding the ID....
            List<ID> lstCompany = new List<Id>();
            // Iterating over all the Records to create Folders..
            for(Id dealId : mapOfDealRecs.keySet()) 
            {

                //Batch will only process 1 at a time so hold onto the ID for later
                dealIdHold = dealId;
                Deal__c objDealRec = mapOfDealRecs.get(dealId);
                String folderName = mapOfDealTofolderName.get(dealId);
                Id parentId = objDealRec.Salesforce_Company__c;
                lstCompany.add(parentID);
                /***** Added as per AMSEC-435 ***********/
                String parentIDfolder= '';//boxToolKit.getFolderIdByRecordId(parentID);
                parentIDfolder = collectparentFolderId(objDealRec);

                if(parentIDfolder != '') {
                    // boxID = boxToolkit.createFolder(folderName,parentIDfolder,boxAuthSetting.Auth_Token__c);
                    boxID = boxToolkit.createFolder(folderName,parentIDfolder, null);
                    if(boxID == null) {
                        system.debug('most recent error: ' + boxToolkit.mostRecentError);
                    }
                    // copying the "New Deal Template", if the Deal record is betweend the recordTypes..
                    else if(objDealRec.RecordTypeId == purchaseRecTypeId || objDealRec.RecordTypeId == ideaRecTypeId) 
                    {
                        for(String strCopyFolderId : mapOfSubFolderIdToName.keySet()) 
                        {
                            BoxObject2.FolderFile objBoxObject2 = new BoxObject2.FolderFile();
                            if(mapOfSubFolderIdToName.get(strCopyFolderId)!='General Documents')
                            {
                                objBoxObject2 = BoxAPIv2.copyFolder(strCopyFolderId, boxID, mapOfSubFolderIdToName.get(strCopyFolderId) +' - '+folderName);
                            }
                            else
                            {
                                objBoxObject2 = BoxAPIv2.copyFolder(strCopyFolderId, boxID, mapOfSubFolderIdToName.get(strCopyFolderId));
                            }
                            // Adding Colloboration record for the newly created folders....
                            if(objBoxObject2.id != NULL)
                            {
                                String newFolderName = mapOfSubFolderIdToName.get(strCopyFolderId);
                                for(String strName : mapOfNameToGroupName.keySet()) {
                                    String strGroupId = mapOfNameToGroupName.get(strName).Box_Group_ID__c;  //'571370';
                                    String strRole = mapOfNameToGroupName.get(strName).Access_Level__c;
                                    if(newFolderName == mapOfNameToGroupName.get(strName).Folder_Name__c)
                                    {
                                        // Creting Colloboration record..
                                        if(strGroupId != NULL && strRole != NULL)
                                            BoxAPIv2.addCollaborationForGroup(objBoxObject2.id, strGroupId, strRole);
                                    }
                                }
                            }
                        }    
                    }
                    mapOfDealIdToFolderId.put(dealId, boxID);
                }
            }
            Map<ID,Account> mapCompanies = new Map<Id,Account>([SELECT ID, Box_ID__c from Account where ID in:lstCompany]);
            // Updating the Box_Id field on the Deal objects..
            if(!mapOfDealIdToFolderId.isEmpty()) 
            {
                List<Deal__c> lstDealToUpdate = new List<Deal__c>();
                for(Id dealId : mapOfDealIdToFolderId.keySet())
                {
                    if(mapOfDealIdToFolderId.get(dealId) != NULL) 
                    {
                        Deal__c objDeal = new Deal__c(Id = dealId);
                        if(mapCompanies.get(mapOfDealRecs.get(dealID).Salesforce_company__c)!=null)
                        {
                            mapCompanies.get(mapOfDealRecs.get(dealID).Salesforce_company__c).Box_ID__c=mapOfDealIdToFolderId.get(dealId);
                        }
                        objDeal.Box_ID__c = mapOfDealIdToFolderId.get(dealId);
                        lstDealToUpdate.add(objDeal);
                    }
                }
                update lstDealToUpdate;
                update mapCompanies.values();
            }
            //Need to create FRUP object because it seems to not work with custom objects 
            if(boxId!=null)
            {
                createFRUPObj('Deal__c',dealIdHold,boxID); 
            }
            if (!Test.isRunningTest())
                boxToolkit.commitChanges();
        //}
        return boxID;
    }




    /*this is the object that makes the assocations between box and salesforce records. For some reason the Box system is not working for custom objects
    so we must create the associations ourselves*/
    public void createFRUPObj(String objectname,ID recordID,String boxID)
    {
            box__FRUP__c fr = new box__FRUP__c();
            fr.box__Object_Name__c=objectname;
            fr.box__Record_ID__c = recordID;
            fr.box__Folder_ID__c= boxID;
            insert fr;
    }



    /*
    Developer: Harsh Chandra
    Description: Moving the folders to the required parent folders with respective Names.
    Parameters: Map<Id, Deal__c> mapOfDealRecs, Map<Id, String> mapOfDealTofolderName,box.toolKit boxToolKit
    Return: 
    */
    public void boxMoveFolder(Map<Id, Deal__c> mapOfDealRecs, Map<Id, String> mapOfDealTofolderName, Map<Id, Boolean> mapOfDealIdToStatusChanged,  box.toolKit boxToolKit)
    {
        List<External_Working_Group_Member__c> allWGMembers = [SELECT ID,Deal__c,WG_Type__c,Contact__c FROM External_Working_Group_Member__c WHERE Deal__c IN:mapOfDealRecs.keyset()];
        Map<ID,List<External_Working_Group_Member__c>> dealToWGMembersMap = new Map<ID,List<External_Working_Group_Member__c>>();
        Set<String> setOfActiveAmsecStatuses = new Set<String>();
        for(External_Working_Group_Member__c wg:allWGMembers)
        {
            if(dealToWGMembersMap.get(wg.Deal__c)==null)
            {
                List<External_Working_Group_Member__c> newList = new List<External_Working_Group_Member__c>();
                newList.add(wg);
                dealToWGMembersMap.put(wg.Deal__c,newList);
            }
            else
            {
                List<External_Working_Group_Member__c> newList = dealToWGMembersMap.get(wg.Deal__c);
                newList.add(wg);
                dealToWGMembersMap.put(wg.Deal__c,newList);
            }
        }
        for(Status_Buckets__c objStatus : Status_Buckets__c.getAll().values()) {
            if(objStatus.Name.startsWith('Active') && objStatus.Am_Sec_Status__c != NULL)
                setOfActiveAmsecStatuses.add(objStatus.Am_Sec_Status__c);
        }
        Map<String, String> mapOfSubFolderIdToName = new Map<String, String>();
        for(Deal__c objdeal : mapOfDealRecs.values()) 
        {
            // Updating the subFolder Names as well....
            // Getting the subFodlerIds
            String strDealFolderId = objdeal.Box_ID__c;
            String parentIDfolder= '';//boxToolKit.getFolderIdByRecordId(parentID);
            parentIDfolder = collectparentFolderId(objdeal);

            if(parentIDfolder != '') {
                String strDealFolderName = mapOfDealTofolderName.get(objdeal.Id);
                mapOfSubFolderIdToName = getSubFolders(strDealFolderId);      // Collecting the subFolder Information...

                // Iterating the Map to update the FolderName
                for(String subFolderId : mapOfSubFolderIdToName.keySet()) {
                    String folderName = mapOfSubFolderIdToName.get(subFolderId);
                    if(folderName.indexOf(' - ') != -1) {
                        folderName = folderName.subString(0, folderName.indexOf(' - '));
                        folderName += ' - ' +strDealFolderName;
                        
                        // Renaming this if required only..If the Name needs to change then only calling..else not required to call
                        if(mapOfSubFolderIdToName.get(subFolderId) != folderName)
                        {
                            //if(mapOfDealIdToStatusChanged == NULL || mapOfDealIdToStatusChanged.containsKey(objdeal.Id))
                            //{
                            //    System.debug('movefolder');
                            //    BoxAPIv2.moveFolder('', subFolderId, folderName, true);
                            //}
                            //else
                            //{
                                System.debug('movefolder');
                                BoxAPIv2.moveFolder('', subFolderId, folderName);
                            //}
                        }    
                    }
                }


                // if really need to move the fodler by changing the parent Id, or Name changed, then only calling...else not required.
                // Getting the existing details, then checking if the name or Parent is going to change...then doing callout, else nothing to do......
                //BoxObject2.FolderFile objExistingValsinBoxForDeal = BoxAPIv2.getFolder(strDealFolderId);

                //if(mapOfDealIdToStatusChanged == NULL || mapOfDealIdToStatusChanged.containsKey(objdeal.Id))
                //{
                //    System.debug('movefolder');
                //    BoxAPIv2.moveFolder(parentIDfolder, strDealFolderId, strDealFolderName, True);
                //}
                //else
                //{
                    System.debug('movefolder');
                    BoxAPIv2.moveFolder(parentIDfolder, strDealFolderId, strDealFolderName);
                //}
            }

            //if(setOfActiveAmsecStatuses.contains(objDeal.Deal_Status__c))
            //{
            //    if(dealToWGMembersMap.get(objDeal.ID)!=null)
            //    {
            //        System.debug('going to sync folder');
            //        Map<Id,Deal__c> deals = new Map<Id,Deal__c>();
            //        deals.put(objDeal.Id,objDeal);
            //        boxSyncFolder(deals,boxToolkit,dealToWGMembersMap.get(objDeal.ID));
            //    }
            //}
        }
        if (!Test.isRunningTest())
            boxToolkit.commitChanges();
    }
    
    public void getSyncingInfo()
    {
        
    }

    public Map<String,String> getBoxUserIds()
    {
        BoxObject2.UserCollection allBoxUser = BoxAPIv2.getUsers();
        List<BoxObject2.User> lstBoxUsers = allBoxUser.entries;

        Map<String,String> emailToBoxID = new Map<String,String>();
        for(BoxObject2.User users:lstBoxUsers)
        { 
            emailToBoxID.put(users.login.toLowerCase(),users.id);

        }
        System.debug(emailToBoxId);
        return emailToBoxID;
    }

    public void boxSyncFolder(Map<Id, Deal__c> mapOfDealRecs, box.toolKit boxToolKit, List<External_Working_Group_Member__c> wgMembers)
    {
        System.debug('syncing folders');
        Set<ID> contactIDs = new Set<ID>();
         //for(ID dealID: mapOfDealRecs.keyset())
         //{
             for(External_Working_Group_Member__c wg: wgMembers)
             {
             //   if(wg.WG_Type__c=='Project')
             //    {
             //       if(dealId==wg.Project_Deal_ID__c)
             //           contactIDs.add(wg.Contact__c);
             //    }
             //    else if(wg.WG_Type__c=='Deal')
             //    {
             //        if(dealId==wg.Deal__c)
                            contactIDs.add(wg.Contact__c);
                 //}
                 //else if()
             }
         //}
        
         List<Contact> contactList = [SELECT ID, Salesforce_User__r.Box_User_ID__c from Contact where ID in:contactIDs];
         Map<ID,String> contactToBoxId = new Map<ID,String>();
         for(Contact c: contactList)
         {
            contactToBoxId.put(c.ID,c.Salesforce_User__r.Box_User_ID__c);
         }
         for(External_Working_Group_Member__c wg: wgMembers)
         {
             System.debug('going through wg membs'+wg.AS_project__r.Box_Sync_Folder_ID__c);
             System.debug('projdeal'+wg.Project_Deal_ID__c);
            String boxfolderID='';
           if(wg.WG_Type__c=='Project')
           {
            if(wg.Project_Deal_ID__c!=null)
                boxfolderID=mapOfDealRecs.get(wg.Project_Deal_ID__c).Box_ID__c;
            else
                boxFolderID=wg.AS_project__r.Box_Sync_Folder_ID__c;
           }
            else if(wg.WG_Type__c=='Deal')
                boxfolderID=mapOfDealRecs.get(wg.Deal__c).Box_ID__c;
            else if(wg.WG_Type__c=='Company')
            {
                if(wg.Original_Deal_ID__c!=null)
                {
                    boxfolderId=mapOfDealRecs.get(wg.Original_Deal_ID__c).Box_ID__c;
                }
                else
                {
                    boxfolderId=wg.Company__r.Box_ID__c;
                }
            }
            String boxUserId = contactToBoxId.get(wg.Contact__c);
            if(boxUserId!=''&&boxUserID!=null&&boxfolderId!=''&&boxfolderID!=null)
                BoxAPIv2.syncFolder(boxFolderID,boxUserId);
         }
    }
    public void boxUnSyncFolder(Map<Id, Deal__c> mapOfDealRecs, box.toolKit boxToolKit, List<External_Working_Group_Member__c> wgMembers)
    {
        system.debug('unsyncing folder sl api');
         Set<ID> contactIDs = new Set<ID>();
         //for(ID dealID: mapOfDealRecs.keyset())
         //{
             for(External_Working_Group_Member__c wg: wgMembers)
             {
                 //if(wg.WG_Type__c=='Project')
                 //{
                 //   if(dealId==wg.Project_Deal_ID__c)
                        contactIDs.add(wg.Contact__c);
                // }
                // else if(wg.WG_Type__c=='Deal')
                // {
                //     if(dealId==wg.Deal__c)
                //            contactIDs.add(wg.Contact__c);
                // }
                //if(wg.WG_Type__c=='Company')
                //{
                //        contactIDs.add(wg.Contact__c);
                //}
             }
         //}
         List<Contact> contactList = [SELECT ID, Salesforce_User__r.Box_User_ID__c from Contact where ID in:contactIDs];
         Map<ID,String> contactToBoxId = new Map<ID,String>();
         for(Contact c: contactList)
         {
            contactToBoxId.put(c.ID,c.Salesforce_User__r.Box_User_ID__c);
         }
         for(External_Working_Group_Member__c wg: wgMembers)
         {
            String boxfolderID='';
            if(wg.WG_Type__c=='Project')
                if(wg.Project_Deal_ID__c!=null)
                    boxfolderID=mapOfDealRecs.get(wg.Project_Deal_ID__c).Box_ID__c;
                else
                    boxFolderID=wg.AS_project__r.Box_Sync_Folder_ID__c;
            else if(wg.WG_Type__c=='Deal')
                boxfolderID=mapOfDealRecs.get(wg.Deal__c).Box_ID__c;
            else if(wg.WG_Type__c=='Company')
            {
                if(wg.Original_Deal_ID__c!=null)
                {
                    boxfolderId=mapOfDealRecs.get(wg.Original_Deal_ID__c).Box_ID__c;
                }
                else
                {
                    boxfolderId=wg.Company__r.Box_ID__c;
                }
            }
            String boxUserId = contactToBoxId.get(wg.Contact__c);
            if(boxUserId!=''&&boxUserID!=null)
                BoxAPIv2.unSyncFolder(boxFolderID,boxUserId);
         }
    }
    /*Retriving the parent Folder Id */
    public String collectparentFolderId(Deal__c objDealRec)
    {
        String parentIDfolder = '';
        Boolean priorityNamingSet = false;
        if(objDealRec.Salesforce_Company__c != NULL) {
            // checking if the recordType is Portfolio - current 
            if(objDealRec.Salesforce_Company__r.RecordTypeId == portFolioRecTypeId)
            { 
                parentIDfolder = mapOfFolderNameToFolderId.get('Portfolio - Current');
                priorityNamingSet=true;
            }
            // checking if the recordType is Portfolio - Former
            else if(objDealRec.Salesforce_Company__r.RecordTypeId == portFolioFormerRecTypeId)
            {
                parentIDfolder = mapOfFolderNameToFolderId.get('Portfolio - Former');
                priorityNamingSet=true;
            }
        }
        // checkin if the custom setting record contains the current deal's statuses...
        if(!priorityNamingSet && (objDealRec.Deal_Status__c != NULL && mapOfStatusToBoxFolderName.containsKey(objDealRec.Deal_Status__c))) {
            String strParentBoxFolderName = mapOfStatusToBoxFolderName.get(objDealRec.Deal_Status__c);

            // Checking if the ParentFolderName Id is there in the Map...
            if(mapOfFolderNameToFolderId.containsKey(strParentBoxFolderName))
                parentIDfolder = mapOfFolderNameToFolderId.get(strParentBoxFolderName);
        }
        System.debug(parentIDfolder);
        return parentIDfolder;
    }

    /*
    Developer: Gordon Arnold
    Description: Collecting the subFodler Id and Names 
    Parameters: folderID:The ID of the Fodler from whihc we will colect the subFolders...i.e the structured template folder
    Return: Map of subFolderId to subFolderName. 
    */
    public Map<String, String> getSubFolders(String folderID)
    {
        Map<String, String> mapOfSubFolderIds = new Map<String, String>();
        // Getting the subFodlerIds.. by hardcoding the "New Deal Template" Id here... 4150386261................
        BoxObject2.FolderFile objBoxFile = BoxAPIv2.getFolder(folderID);
        for(BoxObject2.MiniFolderFile objMiniFolderFile : objBoxFile.item_collection.entries) {
            mapOfSubFolderIds.put(objMiniFolderFile.Id, objMiniFolderFile.name);
        }
        return mapOfSubFolderIds;
    }


    /*
    Developer: Gordon Arnold
    Description: moves a box folder from one location to another in box.com
    Parameters: recordID:The ID of the salesforce record that you want to move the folder for
                newParentFolderID: The ID of the parent folder you are moving the folder to
    Return: True if the folder was moved successfully. False if unsuccessfully 
    Note: Uses box built in toolkit so this does not need authentication
    */
    public Boolean boxMoveFolder(String recordID, String newParentFolderID)
    {
         box.Toolkit boxToolkit = new box.Toolkit();
         String folderID = boxToolKit.getFolderIdByRecordId(recordID);
         Boolean check =boxToolkit.moveFolder(folderId,newParentFolderID,null);
         boxToolkit.commitChanges();
         return check;
    }
    
    /*
    Developer: Gordon Arnold
    Description: associate a folder in box with a record ID in salesforce
    Parameters: recordID: The ID of the salesforce record that you want to associate with the box folder
                boxFolderID: The ID of the folder in box that the record is being associated with
    Note: Uses box built in toolkit so this does not need authentication
    */
    public void associateBoxFolderToRecord(String recordID, String boxFolderID,box.Toolkit boxToolkit)
    {
         box__FRUP__c ret =boxToolkit.createFolderAssociation(recordID,boxFolderID);
          if(ret == null) {
                system.debug('most recent error: ' + boxToolkit.mostRecentError);
            }
    }

    /*
    Developer: Gordon Arnold
    Description: get all of the folder ID's from box by giving in the names of the folders
    Parameters: boxFolderNames: The List of all the folder names in which the ID's are needed
    */
    public Set<String> getBoxFolderIDs(Set<String> boxFolderNames)
    {
        //ID zero is the root folder of the box structure
        List<BoxObject2.FolderFile> folderfiles = new List<BoxObject2.FolderFile>();
        //If folder ID's under the root folder have been found, iterate over those folders
        if(mapOfFolderNameToFolderId.keyset().size()!=0)
        {
            for(String name:mapOfFolderNameToFolderID.keyset())
            {
                //Only query new folders from the recursion so there is no duplicate work. 
                if(boxFolderNames.contains(name)&&boxStructureFolders.keyset().contains(name))
                {
                     folderfiles.add(BoxAPIv2.getFolder(mapOfFolderNameToFolderID.get(name)));
                }
            }
        }
        else
        {
            //If no folder ID's have been found yet, start at the root folder of ID=0
            folderfiles.add(BoxAPIv2.getFolder('0'));
        }
        //All of the folders that are going to be sent back through recursion
        Set<String> newFolders = new Set<String>();
        for(BoxObject2.FolderFile folderfi:folderfiles)
        {
            for(Integer i = 0; i < folderfi.item_collection.total_count; i++)
            {
                if(boxStructureFolders.get(folderfi.item_collection.entries[i].name)==null)
                {
                    break;
                }
                mapOfFolderNameToFolderId.put(folderfi.item_collection.entries[i].name,folderfi.item_collection.entries[i].ID);
                newFolders.add(folderfi.item_collection.entries[i].name);
            }
        }
            if(newFolders.size()!=0)
            {
                //Send back through recursion
                return getBoxFolderIDs(newFolders);
            }
            else
            //Break recursion
                return null;
    }
    
    /*
    Developer: Gordon Arnold
    Description: checks to see if a user is authenticated in box. If not it takes the appropriate actions to reauthnticate the user
    Parameters: 
    Return: True if the user was authenticated successfully. False if the user was not authenticated succesfully and needs new authorization 
    */
    public boolean checkAuthentication()
    {
        Boolean isAuthenticated = false;
        //User has not been authenticated
        User adminUser = [SELECT ID FROM USER where Name = 'Silverline CRM' limit 1];
        Box_OAuth__c boxAuthSetting = Box_OAuth__c.getValues(adminUser.ID);
        oAuthSettings__c boxOAuthSetting = oAuthSettings__c.getInstance('AMSEC Box');
        //User has an authentication custom setting
        if(boxAuthSetting!=null)
        {
            //Check to see if authtoken has expired
            //Auth Token has not expired
            if(boxAuthSetting.Auth_Token__c!=null&&boxAuthSetting.AuthTokenExpires__c>DateTime.now())
            {
                isAuthenticated = true;
            }
            //Has expired. check to see if refresh token has expired
            else
            {
                //Refresh token has not expired
                if(boxAuthSetting.Refresh_Token__c!=null&&boxAuthSetting.RefreshTokenExpires__c>DateTime.now())
                {
                    isAuthenticated = true;
                    //Need to refresh Auth token
                    BoxAuth.refreshToken(boxAuthSetting,boxOAuthSetting);
                }
                //Refresh Token has expired
                else
                {
                    //TODO dont know how I am going to accomplish this right now
                    //Need to reauthorize the user completely 

                }
            }
        }
        return isAuthenticated;
    }
}