/** 
* \author Vladimir Prishlyak
* \date 10/09/2012
* \see https://silverline.jira.com/browse/WP-4
* \details Expense Code Generation Trigger logic 
* \
*/
public without sharing class SL_Util_Generator
{
	/*
	public static boolean isValidExpenseCode(String inExpenseCode)
	{
		return true;
	}
	*/
	/*
	private static Map<String,String> mapInx2CharHx = new Map<String,String>{'30' => '0', '31' => '1', '32' => '2', 
		'33' => '3', '34' => '4', '35' => '5', '36' => '6', '37' => '7', '38' => '8', '39' => '9',
		'41' => 'A', '42' => 'B', '43' => 'C', '44' => 'D', '45' => 'E', '46' => 'F', '47' => 'G', '48' => 'H', '49' => 'I', '4A' => 'J',
		'4B' => 'K', 'AC '=> 'L', '4D' => 'M', '4E' => 'N', '4F' => 'O', '50' => 'P', '51' => 'Q', '52' => 'R', '53' => 'S', '54' => 'T', '55' => 'U',
		'56' => 'V', '57' => 'W', '58' => 'X', '59' => 'Y', '5A' => 'Z'};
	*/

	private static Map<Integer,String> mapInx2CharDec = new Map<Integer,String>{48 => '0', 49 => '1', 50 => '2', 
		51 => '3', 52 => '4', 53 => '5', 54 => '6', 55 => '7', 56 => '8', 57 => '9',
		65 => 'A', 66 => 'B', 67 => 'C', 68 => 'D', 69 => 'E', 70 => 'F', 71 => 'G', 72 => 'H', 73 => 'I', 74 => 'J',
		75 => 'K', 76 => 'L', 77 => 'M', 78 => 'N', 79 => 'O', 80 => 'P', 81 => 'Q', 82 => 'R', 83 => 'S', 84 => 'T', 85 => 'U',
		86 => 'V', 87 => 'W', 88 => 'X', 89 => 'Y', 90 => 'Z'};

	private static Map<String,Integer> mapChar2IndHx = new Map<String,Integer>{'0' => 48, '1' => 49, '2' => 50, 
		'3' => 51, '4' => 52, '5' => 53, '6' => 54, '7' => 55, '8' => 56, '9' => 57,
		'A' => 65, 'B' => 66, 'C' => 67, 'D' => 68, 'E' => 69, 'F' => 70, 'G' => 71, 'H' => 72, 'I' => 73, 'J' => 74,
		'K' => 75, 'L' => 76, 'M' => 77, 'N' => 78, 'O' => 79, 'P' => 80, 'Q' => 81, 'R' => 82, 'S' => 83, 'T' => 84, 'U' => 85,
		'V' => 86, 'W' => 87, 'X' => 88, 'Y' => 89, 'Z' => 90};
		
	
	public static string getNextExpenseCode(String inExpenseCode)
	{
		if(inExpenseCode==null || inExpenseCode.length()!=5) return 'AAAAAA';
		inExpenseCode = inExpenseCode.toUpperCase();
		
		String chPos1 = inExpenseCode.substring(0,1);
		String chPos2 = inExpenseCode.substring(1,2);
		String chPos3 = inExpenseCode.substring(2,3);
		String chPos4 = inExpenseCode.substring(3,4);
		String chPos5 = inExpenseCode.substring(4,5);
		
		String chNewPos1 = '';
		String chNewPos2 = '';
		String chNewPos3 = '';
		String chNewPos4 = '';
		String chNewPos5 = '';
		
		if(chPos5=='9'){ chNewPos5='A';}
		else if(chPos5=='Z'){ chNewPos5='0';}
		else
		{
			chNewPos5 = mapInx2CharDec.get(mapChar2IndHx.get(chPos5)+1);
			if(chNewPos5 == 'I') chNewPos5='K';
			if(chNewPos5 == 'O') chNewPos5='P';
		}
		
		if(chNewPos5=='0')
		{
			if(chPos4=='9'){ chNewPos4='A';}
			else if(chPos4=='Z'){ chNewPos4='0';}
			else chNewPos4 = mapInx2CharDec.get(mapChar2IndHx.get(chPos4)+1);
		}
		else chNewPos4 = chPos4;
		if(chNewPos4 == 'I') chNewPos4='K';
		if(chNewPos4 == 'O') chNewPos4='P';
		
		if(chNewPos5=='0' && chNewPos4=='0')
		{
			if(chPos3=='9'){ chNewPos3='A';}
			else if(chPos3=='Z'){ chNewPos3='0';}
			else chNewPos3 = mapInx2CharDec.get(mapChar2IndHx.get(chPos3)+1);
		}
		else chNewPos3 = chPos3;
		if(chNewPos3 == 'I') chNewPos3='K';
		if(chNewPos3 == 'O') chNewPos3='P';
		

		if(chNewPos5=='0' && chNewPos4=='0' && chNewPos3=='0')
		{
			if(chPos2=='9'){ chNewPos2='A';}
			else if(chPos2=='Z'){ chNewPos2='0';}
			else chNewPos2 = mapInx2CharDec.get(mapChar2IndHx.get(chPos2)+1);
		}
		else chNewPos2 = chPos2;
		if(chNewPos2 == 'I') chNewPos2='K';
		if(chNewPos2 == 'O') chNewPos2='P';
		
		if(chNewPos5=='0' && chNewPos4=='0' && chNewPos3=='0' && chNewPos2=='0')
		{
			if(chPos1=='9'){ chNewPos1='A';}
			else if(chPos1=='Z'){ chNewPos1='0';}
			else chNewPos1 = mapInx2CharDec.get(mapChar2IndHx.get(chPos1)+1);
		}
		else chNewPos1 = chPos1;
		if(chNewPos1 == 'I') chNewPos1='K';
		if(chNewPos1 == 'O') chNewPos1='P';

		return chNewPos1+chNewPos2+chNewPos3+chNewPos4+chNewPos5;
	}
	
	public static ID getSysAdminProfileID()
	{
		ID retVal = null;
		for(Profile item:[Select Id From Profile where Name='System Administrator'])
		{
			retVal = item.ID;
		}
		
		return retVal;
	}	

	public static void fillExpenseCodeInItems(list<Deal__c> newDeals, map<Id,Deal__c> oldDeals)
	{
		List<Deal__c> lst2Update = new List<Deal__c>();
		for(Deal__c item:newDeals)
		{
			if(item.Expense_Code__c==null || item.Expense_Code__c.trim()==''){ lst2Update.add(item);}
			/*
			if(oldDeals==null)
			{
				if(item.Expense_Code__c==null || item.Expense_Code__c.trim()==''){ lst2Update.add(item);}
				else if(item.Expense_Code__c.substring(0,1)!='J' && item.Expense_Code__c.substring(0,1)!='j'){ item.addError('Expense Code Value must start with the letter “J”');}
			}else{
				if((item.Expense_Code__c==null || item.Expense_Code__c.trim()=='') && (UserInfo.getProfileId()==SL_Util_Generator.getSysAdminProfileID() || oldDeals.get(item.ID).Expense_Code__c==null || oldDeals.get(item.ID).Expense_Code__c.trim()=='')){ lst2Update.add(item);}
				else if(item.Expense_Code__c!=oldDeals.get(item.ID).Expense_Code__c && oldDeals.get(item.ID).Expense_Code__c!=null && oldDeals.get(item.ID).Expense_Code__c!=''){ item.addError('Existing Expense Code should never be replaced');}
				else if(item.Expense_Code__c.substring(0,1)!='J' && item.Expense_Code__c.substring(0,1)!='j'){ item.addError('Expense Code Value must start with the letter “J”');}
			}
			*/
		}
		
		if(lst2Update.size()>0)
		{
			String 	strExpenseCode = '';
			for(Deal__c item: [Select Id, Expense_Code__c From Deal__c where Expense_Code__c!=null order by Expense_Code__c desc limit 1])
				strExpenseCode = item.Expense_Code__c;

			DealExpenseCode__c itemCS = [Select Value__c, Id From DealExpenseCode__c for update];
			// Get last Expense_Code__c
			if(itemCS.Value__c==null || itemCS.Value__c=='')
			{
				// WP-127
				/*
				for(Deal__c item: [Select Id, Expense_Code__c From Deal__c where Expense_Code__c!=null order by Expense_Code__c desc limit 1])
				{
					itemCS.Value__c = item.Expense_Code__c;
				}
				*/
				itemCS.Value__c = strExpenseCode;
			}

			if(itemCS.Value__c==null || itemCS.Value__c=='') itemCS.Value__c = 'J0000';
			//itemCS.Value__c = itemDealLast.Expense_Code__c;
			
			for(Deal__c item:lst2Update)
			{
				itemCS.Value__c = SL_Util_Generator.getNextExpenseCode(itemCS.Value__c);
				item.Expense_Code__c = itemCS.Value__c;
			}
			update itemCS;
		}
	}

}