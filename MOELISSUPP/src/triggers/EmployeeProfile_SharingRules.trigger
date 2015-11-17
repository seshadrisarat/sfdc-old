trigger EmployeeProfile_SharingRules on Employee_Profile__c (before delete, after insert, before update) 
{
	Set<Id> List_Employee = new Set<Id>();
	List<Employee_Profile__c> Trigger_list;
	if(trigger.isInsert || trigger.isUpdate) Trigger_list = Trigger.new;
	if(trigger.isDelete) Trigger_list = Trigger.old;
	Boolean isFireTriggerPBI = false;
	Boolean isFireTriggerDeal = false;
	Boolean isFireTriggerCallLog = false;
	Id oneUser_Id;
	Id secondUser_Id;
	Id oneAssistant_Id;
	Id secondAssistant_Id;
	for (Employee_Profile__c item : Trigger_list) 
	{
		oneUser_Id = null;
		oneAssistant_Id = null;
		secondUser_Id = null;
		secondAssistant_Id = null;
		if(trigger.isInsert || trigger.isUpdate) 
		{
			oneUser_Id = Trigger.newMap.get(item.Id).User_ID__c;
			oneAssistant_Id = Trigger.newMap.get(item.Id).Assistant__c;
		}
		if(trigger.isDelete || trigger.isUpdate) 
		{
			secondUser_Id = Trigger.oldMap.get(item.Id).User_ID__c;
			secondAssistant_Id = Trigger.oldMap.get(item.Id).Assistant__c;
		}	
		system.debug('oneUser_Id----------------------->'+oneUser_Id);
		system.debug('secondUser_Id----------------------->'+secondUser_Id);
		if (oneUser_Id != secondUser_Id) 
		{	
			isFireTriggerPBI = true;
			isFireTriggerDeal = true;
			isFireTriggerCallLog = true;
			List_Employee.add(item.Id);	
		}
		if (oneAssistant_Id != secondAssistant_Id) 
		{	
			isFireTriggerCallLog = true;
			List_Employee.add(item.Id);	
		}
		
	}
	system.debug('List_Employee----------------------->'+List_Employee);
	
	List<Schedule_Data__c> List_toInsert = new List<Schedule_Data__c>();
	List<Id> List_Deal_Id = new List<Id>();
	/* sharing for Deal */
	if (isFireTriggerDeal) 
	{
		
		List<Project_Resource__c> List_PR1 = [	
				SELECT Id,Banker__r.User_ID__c,Banker__r.User_ID__r.IsActive, Banker__c, Project__c
				FROM Project_Resource__c
				WHERE Banker__c IN : List_Employee ];
				
		//for(Project_Resource__c item :[	
		//		SELECT Id,Banker__r.User_ID__c,Banker__r.User_ID__r.IsActive, Banker__c, Project__c
		//		FROM Project_Resource__c
		//		WHERE Banker__c IN : List_Employee ])
				
		for(Project_Resource__c item :List_PR1)
		{
				if(List_Employee.contains(item.Banker__c) && item.Banker__r.User_ID__r.IsActive )List_Deal_Id.add(item.Project__c);
		}
		if(List_Deal_Id.size() > 0)
		{
			for(Id itemId : List_Deal_Id)
			{
					Schedule_Data__c newSD = new Schedule_Data__c();
					newSD.Object_Id__c = itemId;
					newSD.Type__c = 'Deal';
					List_toInsert.add(newSD);
			}
			/*
			try{
				Batch_DealShareUPD batch = new Batch_DealShareUPD(List_Deal_Id);
				Database.executeBatch(batch, 100);
				//DealSharingRules.UpdateShare(List_Deal_Id);
				//throw new MyException('Please, wait. Previous batch process has not complited yet.');
			}catch(Exception e){throw new MyException('Please, wait. Previous batch process has not complited yet.');}	
			*/
		}
	}
	
	/* sharing for Potential Buyer/Investor*/
	if (isFireTriggerPBI) 
	{
		if(trigger.isDelete)
		{
			//List<Potential_Buyer_Investor_Deal_Team__c> List_To_delete = new List<Potential_Buyer_Investor_Deal_Team__c>();
			//for(Potential_Buyer_Investor_Deal_Team__c item : [	SELECT Id	FROM Potential_Buyer_Investor_Deal_Team__c WHERE Banker__c IN : List_Employee])	List_To_delete.add(item);
			List<Potential_Buyer_Investor_Deal_Team__c> List_To_delete = [	SELECT Id	FROM Potential_Buyer_Investor_Deal_Team__c WHERE Banker__c IN : List_Employee];
			if(!List_To_delete.isempty()) delete List_To_delete; 
		}
		else
		{	
			List<Id> List_PBI_Id = new List<Id>();
			List<Potential_Buyer_Investor_Deal_Team__c> List_PBIDT =[	
					SELECT Id,Banker__r.User_ID__c,Banker__r.User_ID__r.IsActive, Banker__c, Target_Buyer__c
					FROM Potential_Buyer_Investor_Deal_Team__c
					WHERE Banker__c IN : List_Employee  limit 1000];
			
			 
			//for(Potential_Buyer_Investor_Deal_Team__c item :[	
			//		SELECT Id,Banker__r.User_ID__c,Banker__r.User_ID__r.IsActive, Banker__c, Target_Buyer__c
			//		FROM Potential_Buyer_Investor_Deal_Team__c
			//		WHERE Banker__c IN : List_Employee  limit 1000])
					
			for(Potential_Buyer_Investor_Deal_Team__c item :List_PBIDT)					
			{
					if(List_Employee.contains(item.Banker__c) && item.Banker__r.User_ID__r.IsActive )List_PBI_Id.add(item.Target_Buyer__c);
			}
			/* The sharing rules for the Deal Team Membership will need to be amended to apply to related PBI as well. */
			List<Potential_Buyer_Investor__c> List_PBI = [	SELECT Id
											FROM Potential_Buyer_Investor__c
											WHERE Project__c IN :List_Deal_Id limit 1000];
											
			//for(Potential_Buyer_Investor__c item :[	SELECT Id
			//								FROM Potential_Buyer_Investor__c
			//								WHERE Project__c IN :List_Deal_Id limit 1000])
											
			for(Potential_Buyer_Investor__c item :List_PBI)
			{
	        	List_PBI_Id.add(item.Id);
			}
			if(List_PBI_Id.size() > 0)
			{
				for(Id itemId : List_PBI_Id)
				{
						Schedule_Data__c newSD = new Schedule_Data__c();
						newSD.Object_Id__c = itemId;
						newSD.Type__c = 'PBI';
						List_toInsert.add(newSD);
				}
				/*
				try{
					Batch_PBIShareUPD batch = new Batch_PBIShareUPD(List_PBI_Id);
					Database.executeBatch(batch, 100);
				}catch(Exception e){throw new MyException('Please, wait. Previous batch process has not complited yet.');}
				*/
			}
		}
	}

	
	/* sharing for Call Log */
	if (isFireTriggerCallLog) 
	{
		if(trigger.isDelete)
		{
			
			List<Project_Resource__c> List_To_delete = [	SELECT Id	FROM Project_Resource__c WHERE Banker__c IN : List_Employee];
			//List<Project_Resource__c> List_To_delete = new List<Project_Resource__c>();
			//for(Project_Resource__c item : [	SELECT Id	FROM Project_Resource__c WHERE Banker__c IN : List_Employee])	List_To_delete.add(item);
			if(!List_To_delete.isempty()) delete List_To_delete; 
			
			
			List<Call_Log_Moelis_Attendee__c> List_To_CLMAdelete = [	SELECT Id	FROM Call_Log_Moelis_Attendee__c WHERE Employee__c IN : List_Employee];
			//List<Call_Log_Moelis_Attendee__c> List_To_CLMAdelete = new List<Call_Log_Moelis_Attendee__c>();
			//for(Call_Log_Moelis_Attendee__c item : [	SELECT Id	FROM Call_Log_Moelis_Attendee__c WHERE Employee__c IN : List_Employee])	List_To_CLMAdelete.add(item);
			if(!List_To_CLMAdelete.isempty()) delete List_To_CLMAdelete; 
		}
		else
		{
			List<Id> List_CallLogId = new List<Id>();
			List<Call_Log__c> List_CL = [	SELECT Id, Organizer__r.User_ID__c,Organizer__r.User_ID__r.IsActive, Organizer__c,Organizer__r.Assistant__c,Organizer__r.Assistant__r.User_ID__c,Organizer__r.Assistant__r.User_ID__r.IsActive
									FROM Call_Log__c
									WHERE Organizer__c IN : List_Employee OR Organizer__r.Assistant__c IN : List_Employee];
			
			//for(Call_Log__c item :[	SELECT Id, Organizer__r.User_ID__c,Organizer__r.User_ID__r.IsActive, Organizer__c,Organizer__r.Assistant__c,Organizer__r.Assistant__r.User_ID__c,Organizer__r.Assistant__r.User_ID__r.IsActive
			//						FROM Call_Log__c
			//						WHERE Organizer__c IN : List_Employee OR Organizer__r.Assistant__c IN : List_Employee])
			for(Call_Log__c item: List_CL )
			{
				if(List_Employee.contains(item.Organizer__c) && item.Organizer__r.User_ID__r.IsActive )List_CallLogId.add(item.Id);
				if(List_Employee.contains(item.Organizer__r.Assistant__c) && item.Organizer__r.Assistant__r.User_ID__r.IsActive )List_CallLogId.add(item.Id);
			}
			
			List<Call_Log_Moelis_Attendee__c> List_CLMA = [	SELECT Id,Employee__r.User_ID__c,Employee__r.User_ID__r.IsActive, Employee__c, Call_Log__c,Employee__r.Assistant__c,Employee__r.Assistant__r.User_ID__c,Employee__r.Assistant__r.User_ID__r.IsActive
											FROM Call_Log_Moelis_Attendee__c
											WHERE Employee__c IN : List_Employee OR Employee__r.Assistant__c IN : List_Employee ];
											
			//for(Call_Log_Moelis_Attendee__c item :[	SELECT Id,Employee__r.User_ID__c,Employee__r.User_ID__r.IsActive, Employee__c, Call_Log__c,Employee__r.Assistant__c,Employee__r.Assistant__r.User_ID__c,Employee__r.Assistant__r.User_ID__r.IsActive
			//								FROM Call_Log_Moelis_Attendee__c
			//								WHERE Employee__c IN : List_Employee OR Employee__r.Assistant__c IN : List_Employee ])
											
			for(Call_Log_Moelis_Attendee__c item: List_CLMA)
			{
				if(List_Employee.contains(item.Employee__c) && item.Employee__r.User_ID__r.IsActive )List_CallLogId.add(item.Call_Log__c);
				if(List_Employee.contains(item.Employee__r.Assistant__c) && item.Employee__r.Assistant__r.User_ID__r.IsActive )List_CallLogId.add(item.Call_Log__c);
			}
			List<Id> List_DealId = new List<Id>();
			List<Project_Resource__c> List_PR = [	SELECT Project__c,Banker__r.User_ID__c,Banker__r.User_ID__r.IsActive, Banker__c 
											FROM Project_Resource__c
											WHERE Banker__c IN : List_Employee];
			
			//for(Project_Resource__c item :[	SELECT Project__c,Banker__r.User_ID__c,Banker__r.User_ID__r.IsActive, Banker__c 
			//								FROM Project_Resource__c
			//								WHERE Banker__c IN : List_Employee])
											
			for(Project_Resource__c item : List_PR)
			{
				if(item.Banker__r.User_ID__r.IsActive)  List_DealId.add(item.Project__c);
			}
			
			List<Call_Log_Deal__c> List_CLD = [	SELECT Deal__c, Call_Log__c
											FROM Call_Log_Deal__c
											WHERE Deal__c IN :List_DealId];
											
			//for(Call_Log_Deal__c item :[	SELECT Deal__c, Call_Log__c
			//								FROM Call_Log_Deal__c
			//								WHERE Deal__c IN :List_DealId])
											
			for(Call_Log_Deal__c item :List_CLD)
			{
	        	List_CallLogId.add(item.Call_Log__c);
			}
			if(List_CallLogId.size() > 0)
			{
				for(Id itemId : List_CallLogId)
				{
					Schedule_Data__c newSD = new Schedule_Data__c();
					newSD.Object_Id__c = itemId;
					newSD.Type__c = 'Call Log';
					List_toInsert.add(newSD);
				}
				/*
				try{
					Batch_CallLogShareUPD batch = new Batch_CallLogShareUPD(List_CallLogId);
					Database.executeBatch(batch, 100);
				}catch(Exception e){throw new MyException('Please, wait. Previous batch process has not complited yet.');}
				*/
			}
		}
	}
	// insert datas to the Schedule_Data__c
	//if(List_toInsert.size() > 0) insert List_toInsert;
	if(List_toInsert.size() > 0) 
	{
		if(List_toInsert.size() > (Limits.getLimitDMLRows() - Limits.getDMLRows() - 1000)){
			Batch_ScheduleData_UPD batch = new Batch_ScheduleData_UPD(List_toInsert); // 
			Database.executeBatch(batch, 100);
		}
		else{
			insert List_toInsert;
		}
	}
	

	
public class MyException extends Exception{}

}