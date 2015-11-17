public with sharing class SL_DealTeam_JSON
{
	public String inObj = '';
	public String inFilter = '';
	public String inText = '';
	public String nHm = '';
	public String nFrom = '0';
	public String bNext = 'false';
	public String inSelel = '';
	public String JSONResponse {set; get;}
	
	
	public SL_DealTeam_JSON()
	{
		inObj = ApexPages.currentPage().getParameters().get('obj');
		inFilter = ApexPages.currentPage().getParameters().get('filter');
		inText = ApexPages.currentPage().getParameters().get('text');
		nHm = ApexPages.currentPage().getParameters().get('hm');
		nFrom = ApexPages.currentPage().getParameters().get('page');
		inSelel = ApexPages.currentPage().getParameters().get('selel');

		JSONResponse = getJSONResponsePre();
		
	}
	
	
	public String getJSONResponsePre()
	{
		if(nHm==null || nHm=='') nHm = '8';
		
		integer iHm = 8;
		try{ iHm = integer.valueOf(nHm);}
		catch (Exception e){}

		integer iFrom = 0;
		try
		{
			iFrom = integer.valueOf(nFrom);
			iFrom = (iFrom/10)*8;
		}
		catch (Exception e){}


		List<SObject> resList = new List<SObject>();
		String addVal = '';
		
		Integer newPageFrom = iFrom+iHm+1;

		if(resList.size()>iFrom+iHm){ bNext = 'true';}
		integer nCounter = 0;
		
		if(inObj=='Contact')
		{
			String addSQLCond = '';
			if(inSelel!=null && inSelel.trim()!='')
			{
				for(String item:inSelel.split(','))
				{
					if(addSQLCond!='') addSQLCond += ',';
					addSQLCond += '\'' + item + '\''; 
				}
				addSQLCond = 'AND ID not in ('+addSQLCond+')';
			}
			
			//String strSQL = 'SELECT Id,Name,Account.Name FROM '+inObj+' where Status__c=\'Active\' and (Title like \'%Managing Director%\' or Title like \'%Principal%\') and (Name like \''+String.escapeSingleQuotes(inText)+'%\' or LastName like \''+String.escapeSingleQuotes(inText)+'%\') '+inFilter+' '+addSQLCond+'  LIMIT '+newPageFrom;
			String strSQL = 'SELECT Id,Name,Account.Name FROM '+inObj+' where Status__c=\'Active\' and Title!=\'\' and WP_Group__c!=\'\' and (Name like \''+String.escapeSingleQuotes(inText)+'%\' or LastName like \''+String.escapeSingleQuotes(inText)+'%\') '+inFilter+' '+addSQLCond+' Order BY Name LIMIT '+newPageFrom;
			System.debug('SQL >>>>>>>>>>> '+strSQL);
			resList = Database.query(strSQL);
			
			for(SObject item:resList)
			{
				Contact cItem = (Contact)item;
				nCounter++;
				if (nCounter <= iFrom)
				{
	            	continue;
		        }
		        if (nCounter > iFrom + iHm)
		        {
		            bNext = 'true';
		            break;
		        }
		        if(addVal=='') addVal = '{"id":"'+item.ID+'","name":"'+item.get('Name')+', '+cItem.Account.Name+'"}';
		        else addVal += ',{"id":"'+item.ID+'","name":"'+item.get('Name')+', '+cItem.Account.Name+'"}';
			}			
			
			
		}
		else if(inObj=='Fund__c')
		{
			String addSQLCond = '';
			if(inSelel!=null && inSelel.trim()!='')
			{
				for(String item:inSelel.split(','))
				{
					if(addSQLCond!='') addSQLCond += ',';
					addSQLCond += '\'' + item + '\''; 
				}
				addSQLCond = 'AND ID not in ('+addSQLCond+')';
			}
			
			String strSQL = 'SELECT Id,Name FROM '+inObj+' where Name like \''+String.escapeSingleQuotes(inText)+'%\' '+inFilter+' '+addSQLCond+'  LIMIT '+newPageFrom;
			System.debug('SQL >>>>>>>>>>> '+strSQL);
			resList = Database.query(strSQL);
			
			for(SObject item:resList)
			{
				Fund__c cItem = (Fund__c)item;
				nCounter++;
				if (nCounter < iFrom)
				{
	            	continue;
		        }
		        if (nCounter > iFrom + iHm)
		        {
		            bNext = 'true';
		            break;
		        }
		        if(addVal=='') addVal = '{"id":"'+item.ID+'","name":"'+item.get('Name')+'"}';
		        else addVal += ',{"id":"'+item.ID+'","name":"'+item.get('Name')+'"}';
			}
		}
		
		
		String retVal = '{"status":200,"list":['+addVal+'],"next":'+bNext+',"prev":'+(iFrom>0?'true':'false')+'}';

		return retVal;
	}

}