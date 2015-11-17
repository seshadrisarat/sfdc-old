public class BES_SendApplicationToContacts_New
{
  /*  Test Coverage Method  */
  static testMethod void BES_SendApplicationToContacts()
    {

        // TO DO: implement unit test
         Test.startTest();

       BES_SendApplicationToContacts_New obj = new BES_SendApplicationToContacts_New();
       obj.getsearchResult();

       Account acc1 = new Account();
       acc1.LastName = 'test';
       acc1.PersonEmail = 'test@test1.com';
       insert acc1;

       Account acc2 = new Account();
       acc2.NAme = 'test1';
       insert acc2;

       Contact con1 = new Contact();
       con1.LastName = 'test';
       con1.AccountId = acc2.Id;
       insert con1;

       Account objPersonAccount = new Account();
       objPersonAccount.RecordTypeId = [Select Id from RecordType where Name = 'Client/Tenant Account'].Id;
       objPersonAccount.PersonEmail = 'test@testgmail.com';
       objPersonAccount.LastName = 'Test1';
       insert objPersonAccount;

       Opportunity opp1 = new Opportunity();
       opp1.AccountId = objPersonAccount.Id;
       opp1.Name = 'testOpp1';
       opp1.StageNAme = 'Open';
       opp1.CloseDate = date.today();
       insert opp1;

       Property__c objProp = new Property__c();
       objProp.NAme = 'test';
       insert objProp;

       Property_to_Opportunity_Connector__c objPC1 = new Property_to_Opportunity_Connector__c();
       objPC1.Account__c = objPersonAccount.Id;
       objPC1.Opportunity__c = opp1.Id;
       objPC1.Property__c = objProp.Id;
       insert objPC1;

       Contact_Role__c objCR1 = new Contact_Role__c();
       objCR1.Contact__c = objPersonAccount.Id;
       objCR1.Opportunity__c = opp1.Id;
       objCR1.Role__c = 'Tenant';
       objCR1.Status__c = 'Application Sent';
       insert objCR1;

       Apexpages.currentPage().getParameters().put('id', opp1.Id);
       Apexpages.currentPage().getParameters().put('propId', objPC1.Id);
       obj = new BES_SendApplicationToContacts_New();
       obj.PreviousBtnClick();
       obj.NextBtnClick();
       obj.cancelAddProperty();

       obj.PageSize = 1;
       obj.getPageSize();
       obj.getTotalPageNumber();
       obj.getsearchResult();
       obj.getPageNumber();

       obj.hidRecIds = [Select Id from Contact_Role__c where Opportunity__c =: opp1.Id limit 1].Id;
       obj.MySearchObject_Paging[0].selected = true;
       obj.SendApplicationsToRecipents();

        Test.stopTest();
    }
  /*  End of Test Coverage Method  */

  /* Variable Delcaration */
  public boolean isApexTest = false;

  public Map<Id, Contact_Role__c> mapContactRole
  {get;set;}
  public Integer PageNumber;
    public Integer PageSize;
    public Integer totalPageNumber;
    public Integer newPageIndex = 1;
    public Boolean renderTable
  {  get;set;  }
    public Boolean renderSearch
    {  get;set;  }
    public Boolean renderNoRecords
    {  get;set;  }
    public string hidRecIds
    {  get; set;  }
    public string hidSelectedIds
    {  get; set;  }
    public string opportunityId
    {  get; set;  }
    public string opportunityName
    {  get; set;  }
    public string oppContactId
    {  get;set;  }
    public string propId
    {  get;set;  }
    public string propBuildingName
    {  get;set;  }
    public string propUnitNumber
    {  get;set;  }
    public string propOnsiteId
    {  get;set;  }

    public list<Property_to_Opportunity_Connector__c> lstPropList = new list<Property_to_Opportunity_Connector__c>();
    boolean SearchClick = false;

    /*    Constructor    */
    public BES_SendApplicationToContacts_New()
  {
    mapContactRole = new Map<Id, Contact_Role__c>();
    PageNumber = 0;
    totalPageNumber = 0;
        PageSize = 6;
        opportunityId = System.currentPageReference().getParameters().get('Id');
        propid = System.currentPageReference().getParameters().get('propId');
        lstPropList = [select Property__r.Unit_Number__c, Property__r.Property_Name_Friendly__c, Property__r.OnsiteID__c from Property_to_Opportunity_Connector__c where Id =: propId];
        if(lstPropList != null && lstPropList.size() > 0)
        {
          propBuildingName = lstPropList[0].Property__r.Property_Name_Friendly__c;
          propUnitNumber = lstPropList[0].Property__r.Unit_Number__c;
          propOnsiteId = lstPropList[0].Property__r.OnsiteID__c;
        }
        else
        {
          propBuildingName = '';
          propUnitNumber = '';
          propOnsiteId = '';
        }
        getRecords();
        getSearchResults();
  }

  public void GetIds()
    {
      for(searchObject s: MySearchObject_Paging)
      {
        for(searchObject objSearchObject : MySelectedSearchObject)
          {
            if(objSearchObject.recid != s.recid)
            {
            if(s.selected == true)
            {
              MySearchObjectClone.add(s);
            }
            }
        }
        if(MySelectedSearchObject.size() == 0)
        {
          if(s.selected)
        {
            MySearchObjectClone.add(s);
        }
         }
      }
    }

    public Set<Id> setSelectedCR = new Set<Id>();
  public List<searchObject> MySelectedSearchObject = new list<searchObject>();
  public Boolean isWebServiceError
  {  get;set;  }
  public String printErrorMessage
  {  get;set;  }
  public Boolean isError
  {  get;set;  }
  public List<Task> lstCreateTask_Records
  {  get;set;  }
  List<searchObject> SelectedValues
  {  get;set;  }


  /*  Get All the Contact Roles and Contacts related to Current Opportunity  */
  public void getRecords()
  {
    MySearchObject = new List<searchObject>();
    set<String> setStatus = new set<String>{'Application Received','Application Approved','Application Rejected','Application Canceled', 'Submitted Application'};
    Set<Id> setPAccountIds = new Set<Id>();
    for(Contact_Role__c objCR: [Select Contact__c, Role__c From Contact_Role__c  where Opportunity__c =: opportunityId and
                  (Role__c ='Tenant' or Role__c ='Guarantor' or Role__c = 'Occupant')
                                AND Status__c NOT IN :setStatus ])
        {
          mapContactRole.put(objCR.Id, objCR);
          setPAccountIds.add(objCR.Contact__c);
        }
    if(!mapContactRole.isEmpty())
    {
      Map<Id, Contact> mapCon = new Map<Id, Contact>();
      for(Contact objCon: [Select Name, Id, Email, AccountId from Contact where AccountId In: setPAccountIds])
        mapCon.put(objCon.AccountId, objCon);
      for(Contact_Role__c objCR: mapContactRole.values())
      {
        searchObject objSearch = new searchObject(mapCon.get(objCR.Contact__c), false, objCR.Role__c, objCR.Id);
        MySearchObject.add(objSearch);
      }

    }
  }


  /**

  * \Last changed by Rahul Sharma
  * \date 27/06/2011
  * \see http://silverline.jira.com/browse/STONEPII-1
  * \brief Function CreateOnSiteRecord: 1) Create a task against selected records.
  * \                   2) Create a on-site record depending upon selected Contact records.
  * \returntype : PageReference
  */
  public PageReference SendApplicationsToRecipents()
  {

    system.debug('************************ enters page reference ****************');
    isWebServiceError = false;
    Integer countSelectedValues = 0;
    String[] strIds;
    List<Contact_Role__c> lstUpdateSelectedRoles = new List<Contact_Role__c>();
    List<Id> lstContactId = new List<Id>();
    Set<Id> setContactRoleIds = new Set<Id>();

    if(hidRecIds != null && hidRecIds != '')
    {
      strIds = hidRecIds.split(',');
    }
        if(MySearchObject_Paging != null && MySearchObject_Paging.size() > 0)
        {
            for(searchObject objSearchObject : MySearchObject_Paging)
            {
                if (objSearchObject.selected == true)
                {
                    Boolean isExist = false;
                    for(searchObject objISSearchObject : MySelectedSearchObject)
                    {
                        if(objSearchObject.recId == objISSearchObject.recId)
                        {
                            isExist = true;
                        }
                    }
                    if(!isExist)
                    {
                        MySelectedSearchObject.add(objSearchObject);
                    }
                    countSelectedValues += 1;
                }

            }
        }
        If(countSelectedValues == 0)
        {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please Select a Recipient'));
        }
        for(searchObject objSearchObject : MySearchObjectClone)
      {
        Boolean isTrue = false;
          for(searchObject objISSearchObject : MySelectedSearchObject)
          {
              if(objSearchObject.recId == objISSearchObject.recId)
              {
                  isTrue = true;
              }
          }
        if(!isTrue)
        {
              MySelectedSearchObject.add(objSearchObject);
        }
    }
        for(Integer i = 0; strIds != null && i < strIds.size(); i++)
        {
          for(searchObject SO : MySearchObject)
          {
            Boolean isTrue = false;
            for(searchObject objISSearchObject : MySelectedSearchObject)
            {
                if(SO.recId == objISSearchObject.recId)
                {
                    isTrue = true;
                }
            }
            if(!isTrue)
            {
                if(SO.recId == strIds[i])
                {
                  So.selected = true;
                  MySelectedSearchObject.add(SO);
                }
            }
          }
        }
        if(MySelectedSearchObject.size() > 0)
        {

        for(searchObject objSelectedSO: MySelectedSearchObject)
      {
        system.debug('================================= inside selected =======================');
        //setSelectedCR.add(objSelectedSO.recId);
        Contact_Role__c cr = new Contact_Role__c(id = objSelectedSO.recId);
        cr.Status__c = 'Application Sent';
        lstUpdateSelectedRoles.add(cr);
        setContactRoleIds.add(cr.Id);
      }

      if(lstUpdateSelectedRoles.size() > 0)
        update lstUpdateSelectedRoles;

        }
        else
        {
          return null;
        }
        if(MySelectedSearchObject.size() > 0 && !isWebServiceError)
        {
      lstCreateTask_Records = new List<Task>();
      for(searchObject objSelectedSO: MySelectedSearchObject)
      {
        lstCreateTask_Records.add(new Task (
                          WhoId = objSelectedSO.recContactId,
                          WhatId = opportunityId,
                          Subject = 'Send Application',
                          Status = 'Completed',
                          Type = 'Sent Application',
                          OwnerId = Userinfo.getUserId()
                          )
                    );
        lstContactId.add(objSelectedSO.recContactId);
      }

      if(lstCreateTask_Records.size() > 0)
      {
           insert lstCreateTask_Records;

           /*Start------To Send the email */

       	   List<Messaging.SingleEmailMessage> lstMail = new List<Messaging.SingleEmailMessage>();
           EmailTemplate objEmailTemplate = [SELECT Id FROM EmailTemplate WHERE  DeveloperName = 'Send_Application_New_Primary_applicants'];
           Opportunity objOpportunity = [SELECT Id, OwnerId FROM Opportunity WHERE Id =: opportunityId];
           User objUser = [SELECT Id, Name, Email FROM User WHERE Id =:objOpportunity.OwnerId];
           List<Contact_Role__c> lstContactRole = [Select c.Opportunity__r.AccountId, c.Opportunity__c, c.Contact__r.ContactID__pc,
                               c.Contact__c, c.Contact_Email__c
                               From Contact_Role__c c
                               where Id IN: setContactRoleIds];

           for(Contact_Role__c objContactRole : lstContactRole)
           {
				Messaging.SingleEmailMessage objEmail = new Messaging.SingleEmailMessage();
				objEmail.setSaveAsActivity(false);
				objEmail.setWhatId(objContactRole.Id);
				objEmail.setTemplateId(objEmailTemplate.Id);
				objEmail.setTargetObjectId(objContactRole.Contact__r.ContactId__pc);
				objEmail.setSenderDisplayName(objUser.Name);
				objEmail.setReplyTo(objUser.Email);
				lstMail.add(objEmail);
           }

           if(lstMail.size() > 0)
           {
           		Messaging.sendEmail(lstMail);
           }

        /*End------To Send the email */


      }


      Pagereference pr = new PageReference('/' +opportunityId);
      return pr;
    }
    else
    {
        return null;
    }
  }

  /*Add Property To Opportunity Connector Records*/
  public List<OpportunityContactRole> LstContactTosend
  {  get;set;  }
  public List<Contact> lstExistingContacts
  {  get;set;  }


  /*Paging functions*/
  public PageReference ResetPaging()
    {
        PageNumber = 0;
        totalPageNumber = 0;
        PageSize = 6;
        MySearchObject_Paging = new List<searchObject>();
        renderTable = false;
      renderNoRecords = true;
        return null;
    }
  public Integer getPageNumber()
    {
        return PageNumber;
    }
  public PageReference NextBtnClick()
    {
      GetIds();
      getSearchResultsByPaging(PageNumber + 1);
        return null;
    }
    public PageReference PreviousBtnClick()
    {
      GetIds();
      getSearchResultsByPaging(PageNumber - 1);
        return null;
    }
    public Integer getPageSize()
    {
        return PageSize;
    }

    public Integer getTotalPageNumber()
    {
        if (totalPageNumber == 0 && MySearchObject !=null)
        {
            totalPageNumber = MySearchObject.size() / PageSize;
            Integer mod = MySearchObject.size() - (totalPageNumber * PageSize);
            if (mod > 0)
            totalPageNumber++;
        }
        return totalPageNumber;
    }
    public list<searchObject> getsearchResult()
    {
    if(MySearchObject_Paging != null && MySearchObject_Paging.size() > 0)
        {
          return MySearchObject_Paging;
        }
        else
        {
            ResetPaging();
            return null;
        }
    }

    public PageReference getSearchResults()
    {
      PageNumber = 0;
      isError = false;
        getSearchResultsByPaging(1);
        return null;
    }

    public list<searchObject> MySearchObject_Paging;
    //  Paging logic
    public list<searchObject> getSearchResultsByPaging(Integer newPageIndex)
    {

    MySearchObject_Paging = new List<searchObject>();
        if(MySearchObject != null && MySearchObject.size() > 0)
        {
            Transient Integer counter = 0;
            Transient Integer min = 0;
            Transient Integer max = 0;
            Integer PNum;
            Integer PSize;
            totalPageNumber = 0;
            PNum = PageNumber;
            PSize = PageSize;
      if (newPageIndex > PNum)
            {
                min = PNum * PSize;
                max = newPageIndex * PSize;
            }
            else
            {
                max = ( PNum -1 ) * PSize;
                min = max - PSize;
            }
            for(searchObject c : MySearchObject)
            {
                counter++;
                if (counter > min && counter <= max)
                {
                    MySearchObject_Paging.add(c);
                }
            }

            PageNumber = newPageIndex;
            if (MySearchObject_Paging == null || MySearchObject_Paging.size() <= 0)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Data not available for this view.'));
            }
        }
        else
        {
            if (MySearchObject_Paging == null || MySearchObject_Paging.size() <= 0)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Data not available for this view.'));
            }
        }
        if(MySearchObject_Paging.size() > 0)
        {
          renderTable = true;
          renderNoRecords = false;
        }
        else
        {
          MySearchObject_Paging = new List<searchObject>();
          renderTable = false;
          renderNoRecords = true;
        }
        return MySearchObject_Paging;
    }
  /*Paging Functions*/
  /*Inner Class*/
  public list<searchObject> MySearchObject;
  public list<searchObject> MySearchObjectClone = new list<searchObject>();
  public class searchObject
    {
        public Boolean selected{get; set;}
        public string recId {get;set;}
        public string recName {get;set;}
        public string recRole {get;set;}
        public string RecEmail {get;set;}
        public Boolean CheckBoxVisible {get;set;}
        public Id recContactId {get;set;}

         //   Changed by Rahul
    public searchObject(Contact objContact, Boolean s, String strRole, String strCR)
        {
          recContactId = objContact.Id;
      		recName = objContact.Name;
          RecEmail = objContact.Email;
          recRole = strRole;
          if(RecEmail != null && RecEmail != '')
            CheckBoxVisible = true;
          else
            CheckBoxVisible = false;
          recId = strCR;
        selected = s;
        }
    }
  /*Inner Class*/

  public Pagereference cancelAddProperty()
    {
      Pagereference pr = new PageReference('/' +opportunityId);
      return pr;
    }
}