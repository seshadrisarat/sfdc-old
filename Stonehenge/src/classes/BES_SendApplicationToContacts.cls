public class BES_SendApplicationToContacts
{
  
  public static testMethod void test()
  {
      Account objAcc = new Account();
      objAcc.Name = 'Test';
      insert objAcc;
      
      Contact con = new Contact();
      con.LastName = 'test';
      con.AccountId = objAcc.Id;
      con.Email = 'test@test.com';
      insert con;
      
      Opportunity objOpp = new Opportunity();
      objOpp.Name = 'Test';
      objOpp.StageName = 'Prospecting';
      Date dtCurr = Date.newInstance(2009, 1, 1);
      objOpp.CloseDate = dtCurr;
      objOpp.AccountId = objAcc.Id;
      insert objOpp;
      
      String opportunityId = objOpp.Id;
       
      Property__c oppProp = new Property__c();
      oppProp.Asking_Rent__c = 1.0;
      oppProp.Availability_Date__c = dtCurr;
      oppProp.Building_Name__c = 'XYZ';
      oppProp.Current_Rent__c = 1.0;
      oppProp.Move_Out_Date__c = dtCurr;
      oppProp.Name = 'ABC';
      oppProp.Number_Of_Days_Vacant__c = 1.0;
      oppProp.Sq_Feet__c = 1.0;
      oppProp.Unit_Description__c = 'ABC';
      oppProp.Unit_Number__c = '123';
      oppProp.Unit_Status__c = 'Value';
      oppProp.Unit_Type__c = 'ABC';
      insert oppProp;
      
      Property_to_Opportunity_Connector__c objpoc = new Property_to_Opportunity_Connector__c();
      objpoc.Property__c = oppProp.Id;
      objpoc.Opportunity__c = objOpp.Id;
      insert objpoc;
      
      OpportunityContactRole objOCR = new OpportunityContactRole();
      objOCR.Role = 'Tenant';
      objOCR.OpportunityId = objOpp.Id;
      objOCR.ContactId = con.Id;
      insert objOCR;
      
      //OpportunityContactRole objOCR = [Select Id,Role,Opportunity.Name,OpportunityId,Contact.Name,Contact.Email,ContactId From OpportunityContactRole limit 1 ];//new OpportunityContactRole();
            
      //String propOpp = objPOC.Id;
      
        ApexPages.CurrentPage().getParameters().put('id',objOpp.Id);
        ApexPages.CurrentPage().getParameters().put('propId',objpoc.Id);
        
        BES_SendApplicationToContacts objSendAppsToContacts = new BES_SendApplicationToContacts();
        searchObject objMySearchObject = new searchObject(objOCR,false);
        objMySearchObject.selected = true;
        objMySearchObject.recId = objOCR.Id;
        objMySearchObject.recName = 'test';
        objMySearchObject.recRole = 'test';
        objMySearchObject.RecEmail = 'test@test.com';
        objMySearchObject.CheckBoxVisible = true;
        
        objSendAppsToContacts.MysearchObject.add(objMySearchObject);
        objSendAppsToContacts.MySearchObject_Paging.add(objMySearchObject);
        objSendAppsToContacts.opportunityId = opportunityId;
        objSendAppsToContacts.getsearchResult();

        //objSendAppsToContacts.hidRecIds = '';
        //objSendAppsToContacts.opportunityId = '';
        //objSendAppsToContacts.whereClause = '';
        objSendAppsToContacts.OpportunityName = '';
        //objSendAppsToContacts.BES_Error = '';
        
        objSendAppsToContacts.GetIds();
        objSendAppsToContacts.opportunityId = opportunityId;
        objSendAppsToContacts.ResetPaging();
        objSendAppsToContacts.opportunityId = opportunityId;
        objSendAppsToContacts.getPageNumber();
        objSendAppsToContacts.opportunityId = opportunityId;
        objSendAppsToContacts.NextBtnClick();
        objSendAppsToContacts.opportunityId = opportunityId;
        objSendAppsToContacts.PreviousBtnClick();
        objSendAppsToContacts.opportunityId = opportunityId;
        objSendAppsToContacts.getPreviousButtonEnabled();
        objSendAppsToContacts.opportunityId = opportunityId;
        objSendAppsToContacts.getNextButtonDisabled();
        objSendAppsToContacts.opportunityId = opportunityId;
        objSendAppsToContacts.getTotalPageNumber();
        objSendAppsToContacts.opportunityId = opportunityId;
        objSendAppsToContacts.getPageSize();
        objSendAppsToContacts.opportunityId = opportunityId;
        objSendAppsToContacts.getSearchResults();
        objSendAppsToContacts.cancelAddProperty();
        objSendAppsToContacts.opportunityId = opportunityId;
        objSendAppsToContacts.hidRecIds = objOCR.Id;
        objSendAppsToContacts.SendApplicationsToRecipents();
        
        objSendAppsToContacts.PageNumber = 1;
    objSendAppsToContacts.PageSize = 1;
    objSendAppsToContacts.totalPageNumber = 1;
    objSendAppsToContacts.newPageIndex = 2;
    objSendAppsToContacts.renderNoRecords = false;
        //objSendAppsToContacts.BES_IsError = false;
        objSendAppsToContacts.renderTable = false;  
         
  }
  /* Variable Delcaration */
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
    
    
    //Srinivas code ..... begins
    public string propId
    {  get;set;  }
    
    public string propBuildingName
    {  get;set;  }
    
    public string propUnitNumber
    {  get;set;  }
    
    public string propOnsiteId
    {  get;set;  }
    public list<Property_to_Opportunity_Connector__c> lstPropList = new list<Property_to_Opportunity_Connector__c>();
    //ends
    boolean SearchClick = false;
        
    public BES_SendApplicationToContacts()
  {    
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
  public List<searchObject> MySelectedSearchObject = new list<searchObject>();
  public String printErrorMessage
  {  get;set;  }
  public Boolean isError
  {  get;set;  }
  public List<Task> lstCreateTask_Records
  {  get;set;  }
  /*Add Property To Opportunity Connector Records*/
  public PageReference SendApplicationsToRecipents()
  {
    /*Account objAcc = new Account();
    objAcc.Name = 'Test';
    insert objAcc;
    Contact c = new Contact(lastName='friend',AccountId = objAcc.Id,email='rajesh.sharma@in.v2solutions.com');
        insert c;
    List<Id> lstCon = new List<Id>();
    lstCon.add(c.Id);
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setTemplateId('00XS0000000LxM0');
    mail.setTargetObjectId(c.Id);
    Messaging.SendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
     */
     //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      
    
    String[] strIds;
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
                }
            }
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
        if(MySelectedSearchObject.size() > 0 )
        {
          //GetEmailsAndSendApplications();
          
          List<String> lstStrEmail = new List<String>();
          EmailTemplate objEmailTemplate = [select TemplateType, Subject, Name, Id, HtmlValue, Body, Description  from EmailTemplate Where DeveloperName = 'Send_Application'];
          
          /////////////////////////////////////////////////////////////
          
          System.debug('---------------------------mail' + objEmailTemplate.HtmlValue);
          //emailBody = body.replace('\\{\\!Contact\\.FirstName\\}', 'text');
                    
          
          ////////////////////////////////////////////////////////////
          
          /*if(TemplateId != null)
          {
            mail.setTemplateId(TemplateId);  
          }
      else
      {
        mail.setSubject('Hi');
        mail.setPlainTextBody('Hi');
      }*/
      Integer Count = 0;
      List<Id> lstContactIds = new List<Id>();
      LstContactTosend = [select Contact.FirstName, Opportunity.Owner.Name, Opportunity.Owner.Phone, ContactId,Id,Role from OpportunityContactRole where OpportunityId =: opportunityId Limit 1000];
      System.debug('&&&&&&&&&&&&&&&&&&&&&&&&& List Of Contacts To Send &&&&&&&&&&&&&&&&&&&&&&&&&&&&' + LstContactTosend);
      System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ My Selected Search Object$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$' + MySelectedSearchObject);
      Boolean IsSent = false;
      for(Integer i=0;i < MySelectedSearchObject.size();i++)
      {
        for(Integer j = 0;j < LstContactTosend.size();j++)
        {
          if(LstContactTosend[j].Id == MySelectedSearchObject[i].recId)
          {    
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject(objEmailTemplate.Subject);
                string emailBody = objEmailTemplate.HtmlValue;
            lstStrEmail = new List<String>();
            map<string, string> fieldsValues = new map<string, string>();
            string contFirstName = (LstContactTosend[j].Contact.FirstName != null) ? LstContactTosend[j].Contact.FirstName:'';
            string unitNumber = (propUnitNumber != null) ? propUnitNumber : '';
            string buildName = (propBuildingName != null) ? propBuildingName : '';
            string onsiteId = (propOnsiteId != null) ? propOnsiteId : '';
            string ownerName = (LstContactTosend[j].Opportunity.Owner.Name != null) ? LstContactTosend[j].Opportunity.Owner.Name : '';
            string ownerPhone = (LstContactTosend[j].Opportunity.Owner.Phone != null) ? LstContactTosend[j].Opportunity.Owner.Phone : '';
                fieldsValues.put('<![CDATA[', '' );
                fieldsValues.put(']]>', '');
                fieldsValues.put('{!Contact.FirstName}', contFirstName);
                fieldsValues.put('{!Property__c.Unit_Number__c}', unitNumber);
                fieldsValues.put('{!Property__c.OnsiteID__c}', onsiteId);
                fieldsValues.put('{!Property__c.Property_Name_Friendly__c}', buildName);
                fieldsValues.put('{!Opportunity.OwnerFullName}', ownerName);
                fieldsValues.put('{!Opportunity.OwnerPhone}', ownerPhone);
                for(String s : fieldsValues.keySet()) 
                {
                  emailBody = emailBody.replace(s, fieldsValues.get(s));
                }
                mail.setHtmlBody(emailBody);
            mail.setTargetObjectId(LstContactTosend[j].ContactId);
            lstStrEmail.add(MySelectedSearchObject[i].RecEmail);
            mail.setToAddresses(lstStrEmail);
            Messaging.SendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            lstContactIds.add(LstContactTosend[j].ContactId);
            Count++;
          }
        }
        
      }
      if(lstContactIds.size() > 0)
      {
        lstCreateTask_Records = new List<Task>();
        for(Integer u=0;u<lstContactIds.size();u++)
        {
            Task objTask = new Task();
            objTask.WhoId = lstContactIds[u];
            objTask.WhatId = opportunityId;//lstProperty_to_Opportunity_Connector[z].Id;
            objTask.Subject = 'Send Application';   
            objTask.Status = 'Completed';  
            objTask.Type = 'Sent Application';    
            objTask.OwnerId = Userinfo.getUserId();
            lstCreateTask_Records.add(objTask);
        }
        if(lstCreateTask_Records.size() > 0)
        {
          insert lstCreateTask_Records;
        }
        Pagereference pr = new PageReference('/' +opportunityId);                
          return pr;
        
       }
      else
      {
        return null;
      }
      
        }
        else
        {
          return null;
        }
            
  }
  /*public Pagereference GetEmailsAndSendApplications()
  {
    Messaging.SingleEmailMessage mail;
    mail = new Messaging.SingleEmailMessage();
    mail.setTemplateId('00XS0000000LxM0');
    LstContactTosend = [select ContactId,Id,Role from OpportunityContactRole where OpportunityId =: opportunityId];
    
    for(Integer i=0;i < MySelectedSearchObject.size();i++)
    {
      for(Integer j = 0;j < LstContactTosend.size();j++)
      {
        if(LstContactTosend[j].Id == MySelectedSearchObject[i].recId)
        {
          mail.setTargetObjectId(LstContactTosend[j].ContactId);
          Messaging.SendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
      }
      
    }
    
    return null;
  }*/
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
    public Boolean getPreviousButtonEnabled()
    {
        return !(PageNumber > 1);
    }
    public Boolean getNextButtonDisabled()
    {
        if (MySearchObject == null) 
            return true;    
        else
            return ((PageNumber * PageSize) >= MySearchObject.size());
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
    
    list<searchObject> MySearchObject_Paging;
    public list<searchObject> getSearchResultsByPaging(Integer newPageIndex)
    {  
      MySearchObject = new List<searchObject>();  
        MySearchObject_Paging = new List<searchObject>();
        List<OpportunityContactRole> lstOpprContactRole= [Select Id,Role,Opportunity.Name,OpportunityId,Contact.Name,Contact.Email,ContactId From OpportunityContactRole where OpportunityId =: opportunityId and  (Role ='Tenant' or Role ='Guarantor') limit 1000];                 
      for(Integer j = 0; j < lstOpprContactRole.size(); j++)
    {
            
      searchObject objSearch = new searchObject(lstOpprContactRole[j], false);
      MySearchObject.add(objSearch);                    
    }
    
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
  list<searchObject> MySearchObject;
  list<searchObject> MySearchObjectClone = new list<searchObject>();
  public class searchObject
    {
        public Boolean selected{get; set;}
        public string recId {get;set;}
        public string recName {get;set;}
        public string recRole {get;set;}
        public string RecEmail {get;set;}
        public Boolean CheckBoxVisible {get;set;}
        public Id recContactId {get;set;}
         public searchObject(OpportunityContactRole OpprConRole, Boolean s)
        {
          if(OpprConRole.ContactId != null)
          {
            recContactId = OpprConRole.ContactId;
          String FirstName = [select FirstName from Contact where Id=:OpprConRole.ContactId].FirstName;
          String LastName =  [select LastName from Contact where Id=:OpprConRole.ContactId].LastName;
          String Email = [select Email from Contact where Id=:OpprConRole.ContactId].Email;
          if((FirstName != null && FirstName != '') && (LastName != null && LastName != ''))
          {
            recName = FirstName + ' ' + LastName;  
          }
          else if(FirstName != null && FirstName != '')
          {
            recName = FirstName;
          }
          else if(LastName != null && LastName != '')
          {
            recName = LastName;
          }               
           
          RecEmail = Email;
          }
          else
          {
            recName  = '';
            RecEmail = '';  
          }
          recRole = OpprConRole.Role;
          if(RecEmail != null && RecEmail != '')
            CheckBoxVisible = true;
          else 
            CheckBoxVisible = false;   
          recId = OpprConRole.Id;
        selected = s;
           
        }
    }   
  /*Inner Class*/   
  
  public Pagereference cancelAddProperty()
    {
      Pagereference pr = new PageReference('/' +opportunityId);      
      return pr;
    }    

    /*Start Sorting Generic Function*/
  
  
}