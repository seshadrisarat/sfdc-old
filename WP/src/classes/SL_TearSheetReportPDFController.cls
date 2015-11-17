/**
* \arg ClassName      : SL_TearSheetReportPDFController
* \arg JIRATicket     : WP-131
* \arg CreatedOn      : 20/APR/2015
* \arg LastModifiedOn : 3/JUNE/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as controller for Tear sheet report pdf and is used to show the related Account information.
*/
public with sharing class SL_TearSheetReportPDFController 
{
	/* Start - Page Variables */
	public Event objEvent 											{get; private set;}// This variable is used to keep the record of current event record
	public Account objAccount										{get; private set;}// This variable is used to keep the record of Account record corresponding to Event's what id value.
	public Decimal decAggregateSum									{get; private set;}// This variable is used to keep the summation of commitment amount of all related associated commitment records. 
	public String strWhatId											{get; private set;}// This variable is used to keep the value of what id only if the it belongs to Account
	public String currencySymbol									{get; private set;}// This varibale is used to keep the value of currency symbol corresponding to the currently loggedin user or user which has been passed via url 
	public String strIntenalContacts								{get; private set;}// This variable is used to store the internal contacts correponding to main event
	public List<Contact> lstContact									{get; private set;}// This list is used to store the external contacts correponding to main event
	public Decimal decAggregateFundraisingAmount					{get; private set;}// This variable is used to store the total amount of fundraising opportunities belongs to current Event's what id and its child events
	/* End - Page Variables */
	
	/* Start - Class Variables */
	private User objUser;// This variable is used to hold the value of currently loggedin user or the user which has been passed via url
	private String strFundRaisingOpportunityId;	//This variable is used to keep the value of fund raising Opportunity corresponding to child event of current event
	private Decimal currencyConversionRate; //This variable is used to hold the conversion rate corresponding to the user's currency
	private Set<Id> setWhatId;//This set to hold the what Id of current event and its child events
	private static final String ASC_COMMITMENT_FIELDSET = 'AssociatedCommitmentFieldSet';// This variable is used to store the field set API name which has been created on Associated Commitment for showing fields dynamically on pdf report
	private static final String ASC_COMMITMENT_OBJECTNAME = 'Associated_Commitment__c';// This variable is used to store the API name of Associated Commitment object.
	private static final String ASC_ENTITY_FIELDSET = 'AssociatedEntityFieldSet';// This variable is used to store the field set API name which has been created on Associated Entity for showing fields dynamically on pdf report
	private static final String ASC_ENTITY_OBJECTNAME = 'Associated_Entity__c';// This variable is used to store the API name of Associated Entity object.
	private static Map<String,String> mapCurrencyIsoCodeToSymbol;// This map is used to hold the values mappings of currency iso code and its symbol
	private static Map<Id,RecordType> mapIdToRecordType = new Map<Id,RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN ('Contact','Employee') AND SobjectType=:'Contact']);//map to contain the Contact record types belongs to internal and external contacts
	private static String strIntermediaryRecordType = [SELECT Id FROM RecordType WHERE DeveloperName =:'Intermediary' LIMIT 1].Id;
	/* End - Class Variables */
	
	static
	{
		mapCurrencyIsoCodeToSymbol = new Map<String,String>();
		for(CurrecyIsoCodeToSymbolMapping__c objCurrenctObject : CurrecyIsoCodeToSymbolMapping__c.getAll().values())
		{
			mapCurrencyIsoCodeToSymbol.put(objCurrenctObject.Name, objCurrenctObject.Currency_Symbol__c);
		}
	}
	
	/* Start - Constructor */
	public SL_TearSheetReportPDFController()
	{
		initialize();
	}
	/* End - Constructor */
	
	//wrapper class to hold the fund raising Opportunity record and its corresponding converted amount value(as per the currently logged in user).
	public class FundRaisingOppWrapper
	{
		public Associated_Entity__c objAssociatedEntity		{get;set;}
		public Decimal targetAmount							{get;set;}		
		public FundRaisingOppWrapper(Associated_Entity__c objAssociatedEntity, Decimal targetAmount)
		{
			this.objAssociatedEntity = objAssociatedEntity;
			this.targetAmount = targetAmount;
		}
	}
	
	/*
    * MethodName        : initialize
    * param             : NA
    * Description       : This function will initialize the page variables.
    */
	private void initialize()
	{
		decAggregateSum = decAggregateFundraisingAmount = 0.0;
		currencySymbol = '$';
		currencyConversionRate = 1.0;
		strIntenalContacts = '';
		lstContact = new List<Contact>();
		setWhatId = new Set<Id>();
		Map<String,String> mapPageParameters = Apexpages.currentPage().getParameters();
		if(!mapPageParameters.containskey('id') && String.isEmpty(mapPageParameters.get('id')))
			return;
		String userId = mapPageParameters.containskey('userId') && mapPageParameters.get('userId')!=null ? mapPageParameters.get('userId') : Userinfo.getUserId();
		objUser = [SELECT CurrencyIsoCode, TimeZoneSidKey FROM User WHERE Id =:userId  LIMIT 1];
		if(mapCurrencyIsoCodeToSymbol.containskey(objUser.CurrencyIsoCode))
			currencySymbol = mapCurrencyIsoCodeToSymbol.get(objUser.CurrencyIsoCode);
		currencyConversionRate = [SELECT ConversionRate FROM CurrencyType WHERE IsoCode =: objUser.CurrencyIsoCode AND IsActive =: true LIMIT 1].ConversionRate;
					
		List<Event> lstEvent = [SELECT Id, StartDateTime, WhatId, Subject, Location, EndDateTime, (SELECT RelationId, Relation.RecordTypeId FROM EventRelations WHERE Relation.RecordTypeId IN :mapIdToRecordType.keyset() AND Relation.Type='Contact') FROM Event WHERE Id=:mapPageParameters.get('id') AND IsDeleted = FALSE ALL ROWS];
		if(!lstEvent.isEmpty())
		{
			objEvent = lstEvent[0];
			
			if(!objEvent.EventRelations.isEmpty())
			{
				Map<Id, EventRelation> mapIdToEventRelation = new Map<Id, EventRelation>();
				for(EventRelation objER : objEvent.EventRelations)
					mapIdToEventRelation.put(objER.RelationId, objER);
					
				for(Contact objContact : [SELECT Name, Title, RecordTypeId FROM Contact WHERE Id IN : mapIdToEventRelation.keyset()])
				{
					if(mapIdToRecordType.get(objContact.RecordTypeId).DeveloperName == 'Contact')
						lstContact.add(objContact);
					else if(mapIdToRecordType.get(objContact.RecordTypeId).DeveloperName == 'Employee')
						strIntenalContacts+=String.isBlank(strIntenalContacts) ? objContact.Name : ', ' + objContact.Name;
				}
			}
			
			if(objEvent.WhatId!=null && objEvent.WhatId.getSobjectType() == Account.SobjectType)
			{
				if([SELECT RecordTypeId FROM Account WHERE Id=:objEvent.WhatId].RecordTypeId == strIntermediaryRecordType)
					setWhatId.add(objEvent.WhatId);
				strWhatId = objEvent.WhatId;
			}
			
			for(Event objChildEvent : [SELECT WhatId, What.RecordTypeId FROM Event WHERE ParentId__c =: objEvent.Id AND WhatId!=NULL AND What.Type IN ('Account','Fundraising_Opportunity__c') AND IsDeleted = FALSE ALL ROWS])
			{
				if(objChildEvent.WhatId.getSobjectType() == Fundraising_Opportunity__c.getSobjectType())
				{
					strFundRaisingOpportunityId = objChildEvent.WhatId;
				}
				else if(String.isEmpty(objChildEvent.WhatId) && objChildEvent.WhatId.getSobjectType() == Account.getSobjectType())
				{
					strWhatId = objChildEvent.WhatId;
				}
				
				if(objChildEvent.WhatId.getSobjectType() == Account.getSobjectType() && objChildEvent.What.RecordTypeId == strIntermediaryRecordType)
					setWhatId.add(objChildEvent.WhatId);
			}
			
			List<Account> lstAccount = [SELECT Id, Name, Website, AUM__c, PE_Allocation__c, Description FROM Account WHERE Id =: strWhatId];
			if(!lstAccount.isEmpty())
			{
				objAccount = lstAccount[0];
				if(String.isNotEmpty(objAccount.Description))
					objAccount.Description = objAccount.Description.replaceAll('\n','<br/>');
			}
		}
	}
	
	/*
    * MethodName        : readFieldSet
    * param             : API names of both field set and the related object
    * Description       : This function will initialize the page variables.
    */
	private static String readFieldSet(String strFieldSetName, String strObjectAPIName)
	{
		String strQuery = 'SELECT Id';
		//Iterating over field set member object to fill the header list and field api list
        for(Schema.FieldSetMember objFieldSetMember : Schema.getGlobalDescribe().get(strObjectAPIName).getDescribe().FieldSets.getMap().get(strFieldSetName).getFields())
        {
           strQuery+= ','+ objFieldSetMember.getFieldPath();
        }        
        return strQuery;
	}
	
	/*
    * MethodName        : getTimeZoneCode
    * param             : NA
    * Description       : This function will return the time zone corresponding to the currently loggedin user.
    */
	public String getTimeZoneCode()
	{
		String strTimeZoneCode = '';
		TimeZone tz = TimeZone.getTimeZone(objUser.TimeZoneSidKey);
		List<String> lstSplittedTimeZone = tz.getDisplayName().split(' ');
		for(Integer i = 0 ; i < lstSplittedTimeZone.size(); i++)
		{
			strTimeZoneCode = String.format('{0}{1}', new List<String>{strTimeZoneCode, lstSplittedTimeZone[i].substring(0,1).toUpperCase()});
		}
		return strTimeZoneCode;
	}
	
	/*
    * MethodName        : getMostRecentFundName
    * param             : NA
    * Description       : This function is used to fetch the most recent fund name from the org.
    */
	public String getMostRecentFundName()
	{
		if(String.isNotBlank(strFundRaisingOpportunityId))
		{
			List<Fundraising_Opportunity__c> lstFund = [SELECT Fund__r.Acronym__c FROM Fundraising_Opportunity__c where id = :strFundRaisingOpportunityId];
			return !lstFund.isEmpty() && lstFund[0].Fund__r.Acronym__c!=NULL ? lstFund[0].Fund__r.Acronym__c.remove('WP').trim() : NULL;
		}
		return null;
	}
	
	/*
    * MethodName        : getFundRaisingOpportunity
    * param             : NA
    * Description       : This function is used to fetch the details of fund raising Opportunity corresponding to the child event record of current Event
    */
	public Fundraising_Opportunity__c getFundRaisingOpportunity()
	{		
		if(String.isNotBlank(strFundRaisingOpportunityId))
		{
			return [SELECT Probability__c, Target_Amount__c, Binary__c FROM Fundraising_Opportunity__c WHERE Id =: strFundRaisingOpportunityId];
		}		
		return null;
	}
	
	/*
    * MethodName        : getPreviousEvents
    * param             : NA
    * Description       : This function will pull the details of those 4 events whose whatid is equal to the Event's what id and activity date is less than current Event's activity date.
    */
	public List<Event> getPreviousEvents()
	{
		List<Event> lstEvent = new List<Event>();
		for(Event objPreviousEvent: [SELECT StartDateTime, EndDateTime, Subject, Description FROM Event WHERE WhatId =: strWhatId AND StartDateTime <: objEvent.StartDateTime AND What.Type=:'Account' AND IsDeleted = FALSE ORDER BY StartDateTime DESC LIMIT 4 ALL ROWS])
		{
			if(String.isNotEmpty(objPreviousEvent.Description))
				objPreviousEvent.Description = objPreviousEvent.Description.replaceAll('\n','<br/>');
			lstEvent.add(objPreviousEvent);
		}
		return lstEvent;
	}
	
	/*
    * MethodName        : getAssociatedEntities
    * param             : NA
    * Description       : This function will pull the details of associated entity records corresponding to the fundraising Opportunity id.
    */
	public List<Associated_Entity__c> getAssociatedEntities()
	{
		return Database.query(String.format('{0} FROM {1} WHERE Fundraising_Opportunity__c =: strFundRaisingOpportunityId', new List<String>{SL_TearSheetReportPDFController.readFieldSet(ASC_ENTITY_FIELDSET, ASC_ENTITY_OBJECTNAME), ASC_ENTITY_OBJECTNAME}));
	}
	
	/*
    * MethodName        : getFundRaisingOpprtunities
    * param             : NA
    * Description       : This function will pull the details of fundraising opportunity records corresponding to current event's what id and its child events what ids.
    */
	public List<FundRaisingOppWrapper> getFundRaisingOpprtunities()
	{
		List<FundRaisingOppWrapper> lstFundRaisingOpportunity = new List<FundRaisingOppWrapper>();
		for(Associated_Entity__c objAssociatedEntity : [SELECT Fundraising_Opportunity__r.Investor__r.Short_Name__c, Fundraising_Opportunity__r.Stage__c, Fundraising_Opportunity__r.Probability__c, Fundraising_Opportunity__r.Binary__c, Fundraising_Opportunity__r.Target_Amount__c FROM Associated_Entity__c WHERE Company__c IN:setWhatId])
		{
			Decimal amountValue = objAssociatedEntity.Fundraising_Opportunity__r.Target_Amount__c!=null ? (currencyConversionRate * objAssociatedEntity.Fundraising_Opportunity__r.Target_Amount__c) : 0.0;
			amountValue = amountValue.setScale(2);
			decAggregateFundraisingAmount+= amountValue;
			lstFundRaisingOpportunity.add(new FundRaisingOppWrapper(objAssociatedEntity,amountValue));
		}
		return lstFundRaisingOpportunity;
	}
	
	/*
    * MethodName        : getAssociatedCommitment
    * param             : NA
    * Description       : This function will pull the details of Associated_Commitment__c records corresponding to the whatid.
    */
	public List<Associated_Commitment__c> getAssociatedCommitment()
	{
		List<Associated_Commitment__c> lstAssCommitment = new List<Associated_Commitment__c>();
		String strQuery = SL_TearSheetReportPDFController.readFieldSet(ASC_COMMITMENT_FIELDSET, ASC_COMMITMENT_OBJECTNAME);
		
		if(!strQuery.contains('Commitment_Amount__c'))
			strQuery+=', Commitment_Amount__c';
		if(!strQuery.contains('Fund__r.Acronym__c'))
			strQuery+=', Fund__r.Acronym__c';
		 
		for(Associated_Commitment__c objAssCommitment : Database.query(String.format('{0} FROM {1} WHERE Investor__c =: strWhatId ORDER BY CreatedDate DESC ', new List<String>{strQuery, ASC_COMMITMENT_OBJECTNAME})))
		{
			Decimal amountValue = objAssCommitment.Commitment_Amount__c!=null ? (currencyConversionRate * objAssCommitment.Commitment_Amount__c) : 0.0;
			amountValue = amountValue.setScale(2);
			decAggregateSum+= amountValue;
			objAssCommitment.Commitment_Amount__c = amountValue;
			lstAssCommitment.add(objAssCommitment);
		}
		return lstAssCommitment;
	}
}