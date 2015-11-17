public class SL_ctrl_CandidateSrch
{
	public Map<String, Schema.SObjectField> fieldMap;
	List<Schema.FieldSetMember> filterFS;
	private static Map<String,String> mapFilterFieldAPIToName;
	private static Map<String,String> mapResultFieldAPIToName;
	private static String strAttachmentName;
	public List<Schema.FieldSetMember> resultFS {get;set;}
	public static String[] resFldNames;
	public qryFltrElements[] fltrRes {get;set;}
	public qryFltrElements[] resFlds {get;set;}
	public String strSearchType	{get;set;}
	public String strSearchId	{get;set;}
	public static qryFltrElements[] resFldsQry;
	public boolean isMobile;
	
	/* Start - Written By Pankaj Ganwani on 13 May, 2013*/
	static
	{
		mapFilterFieldAPIToName = new Map<String,String>();
		mapResultFieldAPIToName = new Map<String,String>();
		for(Schema.FieldSetMember f : Schema.SObjectType.Contact.fieldSets.tal_mgmt_filters.getFields())
		{
			mapFilterFieldAPIToName.put(f.getFieldPath(),f.getLabel());
		}
		
		for(Schema.FieldSetMember f : Schema.SObjectType.Contact.fieldSets.tal_mgmt_result.getFields())
		{
			if(f.getType() != Schema.DisplayType.Reference)
			    mapResultFieldAPIToName.put(f.getFieldPath(),f.getLabel());
			else
			    mapResultFieldAPIToName.put(getLkupFltrStrStatic(f.getFieldPath()),f.getLabel());
			
		}
	}
	/* End - Written By Pankaj Ganwani on 13 May, 2013*/
	
	public SL_ctrl_CandidateSrch()
	{
		fltrRes = new qryFltrElements[]{};
		resFlds = new qryFltrElements[]{};
		strAttachmentName = '';
		strSearchType = 'New Search';
		strSearchId = '';
		//isMobile = isS1();

		fieldMap = Schema.SObjectType.Contact.fields.getMap();

		resultFS = Schema.SObjectType.Contact.fieldSets.tal_mgmt_result.getFields();

		for(Schema.FieldSetMember f : resultFS)
		{
			qryFltrElements fe = new qryFltrElements();
			fe.labelName = f.getLabel();
			if(f.getType() == Schema.DisplayType.Picklist)
			{
				fe.apiName = f.getFieldPath();
			}

			if(f.getType() == Schema.DisplayType.MultiPicklist)
			{
				fe.apiName = f.getFieldPath();
			}

			if(f.getType() == Schema.DisplayType.Reference)
			{
				fe.apiName = getLkupFltrStr(f.getFieldPath());
			}
			
			/* Start - Written By Pankaj Ganwani on 13 May, 2013*/
			if(f.getType() == Schema.DisplayType.String || f.getType() == Schema.DisplayType.TextArea || f.getType() == Schema.DisplayType.Email || f.getType() == Schema.DisplayType.Date || f.getType() == Schema.DisplayType.DateTime || f.getType() == Schema.DisplayType.Integer || f.getType() == Schema.DisplayType.Double || f.getType() == Schema.DisplayType.Currency || f.getType() == Schema.DisplayType.Phone)
			{
				fe.apiName = f.getFieldPath();
			}
			/* End - Written By Pankaj Ganwani on 13 May, 2013*/
			
			if(f.getType() == Schema.DisplayType.URL)
			{
				fe.apiName = f.getFieldPath();
			}
			
			if(f.getType() == Schema.DisplayType.Boolean)
			{
				fe.apiName = f.getFieldPath();
			}
			
			resFlds.add(fe);
		}

		filterFS = Schema.SObjectType.Contact.fieldSets.tal_mgmt_filters.getFields();

		createQryFltrWrapper();
	}
	
	/* Start - Written By Pankaj Ganwani on 13 May, 2013*/
	public List<String> getChoiceOptions()
	{
		return new List<String>{'New Search','Previous Search'};
	}
	/* End - Written By Pankaj Ganwani on 13 May, 2013*/
	
	public Boolean isS1()
	{

		String retUrl = ApexPages.currentPage().getParameters().get('retURL');

		return String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
		String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
		ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
		(String.isNotBlank(retUrl) && retURL.contains('projectone'));

	}

	public void createQryFltrWrapper()
	{
		for(Schema.FieldSetMember f : filterFS)
		{
			qryFltrElements fe = new qryFltrElements();

			fe.labelName = f.getLabel();

			if(f.getType() == Schema.DisplayType.Picklist)
			{
				fe.apiName = f.getFieldPath();
				fe.fldType = 'picklist';
				fe.plValues = getPicklistValues(f.getFieldPath());
			}

			if(f.getType() == Schema.DisplayType.MultiPicklist)
			{
				fe.apiName = f.getFieldPath();
				fe.fldType = 'multipicklist';
				fe.plValues = getPicklistValues(f.getFieldPath());
			}

			if(f.getType() == Schema.DisplayType.Reference)
			{
				fe.apiName = getLkupFltrStr(f.getFieldPath());
				fe.fldType = 'reference';
				fe.lkupObj = getLkupObj(f.getFieldPath());
			}
			
			/* Start - Written By Pankaj Ganwani on 13 May, 2013*/
			if(f.getType() == Schema.DisplayType.String || f.getType() == Schema.DisplayType.URL || f.getType() == Schema.DisplayType.Phone || f.getType() == Schema.DisplayType.Email)
			{
				fe.apiName = f.getFieldPath();
				fe.fldType = 'string';
			}
			
			
			if(f.getType() == Schema.DisplayType.Boolean)
			{
				fe.apiName = f.getFieldPath();
				fe.fldType = 'boolean';
			}
			
			if(f.getType() == Schema.DisplayType.Date)
			{
				fe.apiName = f.getFieldPath();
				fe.fldType = 'date';
			}
			
			if(f.getType() == Schema.DisplayType.DateTime)
			{
				fe.apiName = f.getFieldPath();
				fe.fldType = 'datetime';
			}
			
			if(f.getType() == Schema.DisplayType.Currency || f.getType() == Schema.DisplayType.Integer || f.getType() == Schema.DisplayType.Double)
			{
				fe.apiName = f.getFieldPath();
				fe.fldType = 'number';
			}
			/* End - Written By Pankaj Ganwani on 13 May, 2013*/
			
			fltrRes.add(fe);
		}
	}

	public String[] getPicklistValues(String fldApiName)
	{
		String[] plValues = new String[]{};

		Schema.PicklistEntry[] plList = fieldMap.get(fldApiName).getDescribe().getPicklistValues();

		for(Schema.PicklistEntry pl : plList)
		{
			plValues.add(pl.getValue());
		}

		return plValues;
	}

	public String getLkupFltrStr(String fldApiName)
	{
		System.debug(fldApiName);
		return fieldMap.get(fldApiName).getDescribe().getRelationshipName()+'.Name';
	}

	public static String getLkupFltrStrStatic(String fldApiName)
	{
		System.debug(fldApiName);
		return Schema.SObjectType.Contact.fields.getMap().get(fldApiName).getDescribe().getRelationshipName()+'.Name';
	}

	public String getLkupObj(String fldApiName)
	{
		System.debug(fldApiName);
		return fieldMap.get(fldApiName).getDescribe().getReferenceTo()[0].getDescribe().getLocalName();
	}

	public static String getLkupObjStatic(String fldApiName)
	{
		System.debug(fldApiName);
		return Schema.SObjectType.Contact.fields.getMap().get(fldApiName).getDescribe().getRelationshipName();
	}

	@RemoteAction
	public static typeAheadRes[] typeAheadFunc(String rName, String sObjName)
	{
		typeAheadRes[] resList = new typeAheadRes[]{};
		sObject[] tempList = Database.query('Select Id,Name From ' + sObjName + ' WHERE Name Like \'' +'%' + rName + '%\' LIMIT 20');
		//sObject[] tempList = Database.query('Select Id,Name From Contact WHERE Name Like \'' + rName + '%\' LIMIT 5');
		for(sObject s : tempList)
		{
			resList.add(new typeAheadRes( (Id)s.get('Id'), (String)s.get('Name') ) );
		}
		return resList;
	}


	@RemoteAction
	public static String queryCandidates(String jsonStr, String attachmentId)
	{
		resFldsQry = new qryFltrElements[]{};
		List<map<String,Object>> crList = new List<map<String,Object>>();
		
		/* Start - Written By Pankaj Ganwani on 1 JUNE, 2013*/
		Jsongenerator gen = JSON.createGenerator(true);			
		gen.writeStartArray();
		/* End - Written By Pankaj Ganwani on 1 JUNE, 2013*/
		
		/* Start - Written By Pankaj Ganwani on 14 May, 2013*/
		if(String.isNotEmpty(attachmentId))
		{
			List<Attachment> lstAttachment = [SELECT Body FROM Attachment WHERE Id =:attachmentId.trim() LIMIT 1];
			if(!lstAttachment.isEmpty())
			{
				Attachment objAttachment = lstAttachment[0];
				jsonStr = objAttachment.Body.toString();
			}
		}	
		/* End - Written By Pankaj Ganwani on 14 May, 2013*/	
		
		if(jsonStr != null && jsonStr != '')
		{
			List<QueryFltrJSON> qFltrs = (List<QueryFltrJSON>) JSON.deserialize(jsonStr,List<QueryFltrJSON>.class);
			List<Schema.FieldSetMember> resultFS = Schema.SObjectType.Contact.fieldSets.tal_mgmt_result.getFields();
			
			sObject[] cList = buildQryStr(qFltrs,resultFS);
			
			/* Start - Written By Pankaj Ganwani on 14 May, 2013*/
			if(String.isEmpty(attachmentId) && [SELECT COUNT() FROM SL_Candidate_Search__c WHERE Search_Name__c =: strAttachmentName.trim()] == 0)
			{
				SL_Candidate_Search__c objCandidateSearch = new SL_Candidate_Search__c(Search_Name__c = strAttachmentName.length() > 255 ? strAttachmentName.substring(0,254) : strAttachmentName, Name = 'Search');
				insert objCandidateSearch;
				insert new Attachment(Name = 'Search', ParentId = objCandidateSearch.Id, Body = Blob.valueOf(jsonStr));
			}
			/* End - Written By Pankaj Ganwani on 14 May, 2013*/
			
			for(sObject c : cList)
			{
				
				/* Start - Modified By Pankaj Ganwani on 14 May, 2013*/
				//map<String,Object> r = new map<String,Object>();
				gen.writeStartObject();
				for(qryFltrElements f : resFldsQry)
				{
					System.debug(f.lkupObj);
					if(f.fldType == 'reference')
					{
						if(c.getSobject(f.lkupObj) != null)
						{
							//r.put(f.apiName,c.getSobject(f.lkupObj).get('Name'));
							gen.writeStringField(f.apiName,String.valueOf(c.getSobject(f.lkupObj).get('Name')));
						}
					}
					else if(f.fldType == 'url')
					{
						//r.put(f.apiName, c.get(f.apiName)!=NULL ? '<a href="'+c.get(f.apiName)+'" target="_parent">Click Here</a>' :'-');
						gen.writeStringField(f.apiName, c.get(f.apiName)!=NULL ? '<a href="'+c.get(f.apiName)+'" target="_parent">Click Here</a>' :'-');
					}
					else if(f.fldType == 'date' || f.fldType == 'datetime')
					{
						if(c.get(f.apiName)!=NULL)
						{
							Date dt = Date.valueOf(c.get(f.apiName));							
							//r.put(f.apiName,dt.month()+'/'+dt.day()+'/'+dt.year());
							gen.writeStringField(f.apiName,dt.month()+'/'+dt.day()+'/'+dt.year());
						}
						else
						{
							gen.writeNullField(f.apiName);
						}
					}
					else
					{
						//r.put(f.apiName,c.get(f.apiName));
						if(c.get(f.apiName)!=NULL)
							gen.writeStringField(f.apiName,String.valueOf(c.get(f.apiName)));
						else
							gen.writeNullField(f.apiName);
					}
				}
				
				//r.put('Id',c.get('Id'));
				gen.writeStringField('Id',String.valueOf(c.get('Id')));
				gen.writeEndObject();

				//crList.add(r);
			}
			gen.writeEndArray();
		}

		return gen.getAsString();
		/* End - Modified By Pankaj Ganwani on 14 May, 2013*/
	}

	public static List<Sobject> buildQryStr(List<QueryFltrJSON> qFltrs, List<Schema.FieldSetMember> resultFS)
	{
		String qryStr = 'Select ';
		String resFldStr = '';
		Date dtToday = Date.today();
		strAttachmentName = dtToday.month()+'-'+dtToday.day() +'-'+dtToday.year()+' - '+ Userinfo.getLastName()+' | ';
		for(Schema.FieldSetMember f : resultFS)
		{
			qryFltrElements resFldQry = new qryFltrElements();

			if(f.getType() == Schema.DisplayType.Picklist || f.getType() == Schema.DisplayType.Phone || f.getType() == Schema.DisplayType.Email || f.getType() == Schema.DisplayType.Currency || f.getType() == Schema.DisplayType.Integer || f.getType() == Schema.DisplayType.Double)
			{
				resFldStr = resFldStr + f.getFieldPath() + ',';

				resFldQry.apiName = f.getFieldPath();
			}
			
			if(f.getType() == Schema.DisplayType.Date)
			{
				resFldStr = resFldStr + f.getFieldPath() + ',';

				resFldQry.apiName = f.getFieldPath();
				resFldQry.fldType = 'date';
			}
			
			if(f.getType() == Schema.DisplayType.Boolean)
			{
				resFldStr = resFldStr + f.getFieldPath() + ',';

				resFldQry.apiName = f.getFieldPath();
				resFldQry.fldType = 'boolean';
			}
			
			if(f.getType() == Schema.DisplayType.DateTime)
			{
				resFldStr = resFldStr + f.getFieldPath() + ',';

				resFldQry.apiName = f.getFieldPath();
				resFldQry.fldType = 'datetime';
			}
			
			if(f.getType() == Schema.DisplayType.URL)
			{
				resFldStr = resFldStr + f.getFieldPath() + ',';

				resFldQry.apiName = f.getFieldPath();
				resFldQry.fldType = 'url';
			}
			
			if(f.getType() == Schema.DisplayType.MultiPicklist)
			{
				resFldStr = resFldStr + f.getFieldPath() + ',';
				resFldQry.apiName = f.getFieldPath();
			}

			if(f.getType() == Schema.DisplayType.Reference)
			{
				String lkupStr = getLkupFltrStrStatic(f.getFieldPath());
				resFldStr = resFldStr + lkupStr + ',';

				resFldQry.apiName = lkupStr;
				resFldQry.lkupObj = getLkupObjStatic(f.getFieldPath());
				resFldQry.fldType = 'reference';
			}

			if(f.getType() == Schema.DisplayType.String || f.getType() == Schema.DisplayType.TextArea)
			{
				resFldStr = resFldStr + f.getFieldPath() + ',';
				resFldQry.apiName = f.getFieldPath();
			}

			resFldsQry.add(resFldQry);
		}

		qryStr = qryStr + resFldStr + 'Id,Name From Contact';
		String fltStr = '';
		for(Integer i=0;i<qFltrs.size();i++)
		{
			if(qFltrs[i].fldType != 'boolean')
			{
				if(qFltrs[i].fltVal != null && qFltrs[i].fltVal != '')
				{				
					
					if((i != 0 && i < qFltrs.size() && fltStr != ''))
					{
						fltStr = fltStr + ' AND ';
					}
	
					if(qFltrs[i].fldType == 'picklist')
					{
						strAttachmentName+=qFltrs[i].fltVal+' | ';
						fltStr = fltStr + qFltrs[i].apiName + '=\'' + qFltrs[i].fltVal + '\'';
					}
	
					/* Start - Modified By Pankaj Ganwani on 14 May, 2013*/
					if(qFltrs[i].fldType == 'multipicklist')
					{
						strAttachmentName+=qFltrs[i].fltVal+' | ';					
						String strValue = '';
						String[] strArrayValues = qFltrs[i].fltVal.split(',');
						for(Integer j=0;j < strArrayValues.size();j++)
						{
							strValue+=String.isBlank(strValue) ? '\''+strArrayValues[j]+'\'' : ','+'\''+strArrayValues[j]+'\'';
						}
						fltStr = fltStr + qFltrs[i].apiName + ' IN(' +strValue+ ')';					
					}
					/* End - Modified By Pankaj Ganwani on 14 May, 2013*/
					
					if(qFltrs[i].fldType == 'string' || qFltrs[i].fldType == 'reference')
					{
						strAttachmentName+=qFltrs[i].fltVal+' | ';
						fltStr = fltStr + qFltrs[i].apiName + '=\'' + qFltrs[i].fltVal + '\'';
					}
					
					/* Start - Written By Pankaj Ganwani on 14 May, 2013*/
					if(qFltrs[i].fldType == 'date' || qFltrs[i].fldType == 'datetime')
					{
						String strAPIName = qFltrs[i].apiName;
						String [] dateParts = qFltrs[i].fltVal.split('/');						
						if(strAPIName.contains('_From'))
						{
							Date dtTo = Date.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
							strAPIName = qFltrs[i].apiName.substring(0,strAPIName.lastIndexOf('_From'));
							fltStr = fltStr + strAPIName + ' >=: dtTo';
							strAttachmentName+=qFltrs[i].fltVal+' | ';
						}
						else
						{
							Date dtFrom = Date.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
							strAPIName = qFltrs[i].apiName.substring(0,strAPIName.lastIndexOf('_To'));
							fltStr = fltStr + strAPIName + ' <=: dtFrom';
							strAttachmentName+=qFltrs[i].fltVal+' | ';
						}
					}
					
					if(qFltrs[i].fldType == 'number')
					{
						String strAPIName = qFltrs[i].apiName;
						if(strAPIName.contains('_High'))
						{
							strAPIName = qFltrs[i].apiName.substring(0,strAPIName.lastIndexOf('_High'));
							fltStr = fltStr + strAPIName + ' >='+qFltrs[i].fltVal;
							strAttachmentName+=qFltrs[i].fltVal+' | ';
						}
						else
						{
							strAPIName = qFltrs[i].apiName.substring(0,strAPIName.lastIndexOf('_Low'));
							fltStr = fltStr + strAPIName + ' <='+qFltrs[i].fltVal;
							strAttachmentName+=qFltrs[i].fltVal+' | ';
						}
					}					
				}
			}
			else
			{
				if(qFltrs[i].fltVal == 'true')
				{					
					strAttachmentName+= (qFltrs[i].apiName == 'Vetted__c' ? 'Vetted' : mapFilterFieldAPIToName.get(qFltrs[i].apiName)) +' | ';
					fltStr = String.isNotBlank(fltStr) ? fltStr + ' AND ' +qFltrs[i].apiName + '=' + qFltrs[i].fltVal : fltStr +qFltrs[i].apiName + '=' + qFltrs[i].fltVal;					
				}
			}
			/* End - Written By Pankaj Ganwani on 14 May, 2013*/
		}
		if(fltStr != '')
		{
			qryStr = qryStr + ' WHERE ' + fltStr + ' ORDER BY LastName ASC';
		}else
		{
			qryStr = qryStr + ' ORDER BY LastName ASC';
		}

		qryStr = qryStr + ' LIMIT 100';
		system.debug('=============qryStr==========='+Database.query(qryStr));
		return Database.query(qryStr);
	}
	
	/* Start - Written By Pankaj Ganwani on 14 May, 2013*/
	@RemoteAction
	public static String getSearchCriteria()
	{
		List<ExistingSearchWrapper> lstExistingSearch = new List<ExistingSearchWrapper>();
		
		for(SL_Candidate_Search__c objCandidateSearch : [SELECT Search_Name__c,(SELECT Id FROM Attachments LIMIT 1) FROM SL_Candidate_Search__c ORDER BY CreatedDate DESC])
		{
			if(!objCandidateSearch.Attachments.isEmpty())
			{
				Set<Id> setAttachmentIds = (new Map<Id,Attachment>(objCandidateSearch.Attachments)).keyset();
				lstExistingSearch.add(new ExistingSearchWrapper(objCandidateSearch.Search_Name__c, new List<Id>(setAttachmentIds)[0]));
			}
		}
		return json.serialize(lstExistingSearch);
	}
	/* End - Written By Pankaj Ganwani on 14 May, 2013*/
	
	/* Start - Written By Pankaj Ganwani on 14 May, 2013*/
	@RemoteAction
	public static String substituteFieldLabels(String json)
	{
		for(String strFieldAPI : mapResultFieldAPIToName.keyset())
		{
			if(json.contains(strFieldAPI))
				json=json.replaceAll(strFieldAPI, mapResultFieldAPIToName.get(strFieldAPI));
		}
		
		while(json.indexOf('Id')!=-1)
		{
			Integer idIndex = json.indexOf('"Id"');
			String subStr = json.substring(idIndex,idIndex+26);
			json = json.replace(subStr, '');
		}
		
		while(json.indexOf('undefined')!=-1)
		{
			json = json.replace(',"undefined":false', '');
		}
		return json;
	}
	/* End - Written By Pankaj Ganwani on 14 May, 2013*/
	
	public class typeAheadRes
	{
		public Id rId;
		public String rName;

		public typeAheadRes(Id rId, String rName)
		{
			this.rId = rId;
			this.rName = rName;
		}
	}

	public class CandidateResultJSON
	{
		public String apiName;
		public String fldLabel;
		public String fldVal;

		public CandidateResultJSON(String apiName, String fldLabel, String fldVal)
		{
			this.apiName = apiName;
			this.fldLabel = fldLabel;
			this.fldVal = fldVal;
		}
	}

	public class qryFltrElements
	{
		public String labelName {get;set;}
		public String apiName {get;set;}
		public String fldType {get;set;}
		public String lkupObj {get;set;}
		public String[] plValues {get;set;}
	}

	public class QueryFltrJSON
	{
		String apiName;
		String fltVal;
		String fldType;
	}
	
	/* Start - Written By Pankaj Ganwani on 14 May, 2013*/
	public class ExistingSearchWrapper
	{
		public String strSearchName	{get;set;}
		public String attachmentId		{get;set;}
		
		public ExistingSearchWrapper(String strSearchName,String attachmentId)
		{
			this.strSearchName = strSearchName;
			this.attachmentId = attachmentId;
		}
	}
	/* End - Written By Pankaj Ganwani on 14 May, 2013*/
}