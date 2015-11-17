trigger BES_UpsertPropertyStaging on PropertyStaging__c (after insert, after update)
{
    if((Trigger.isAfter) && (Trigger.isInsert || Trigger.isUpdate))
    {
        set<String> setYardi = new set<String>();
        for(Integer i = 0; i < Trigger.new.size(); i++)
        {
            setYardi.add(Trigger.new[i].Yardi_ID__c);
            System.debug('setYardi=====' +setYardi);
        }
        Map<String,Property__c> MapIds = new Map<String,Property__c>();
        //List<Property__c> lstProperty = [select Id, LastModifiedDate, Yardi_ID__c from Property__c where Yardi_ID__c IN : setYardi];
        List<Property__c> lstProperty = [select Id, UnitStatusUpdateDate__c,Unit_Status_Changed_Date__c, LastModifiedDate, Yardi_ID__c from Property__c where Yardi_ID__c IN : setYardi];
        System.debug('lstProperty======' +lstProperty);
        set<String> setYard = new set<String>();
        for(Integer j = 0; j < lstProperty.size(); j++)
        {
            string temp = lstProperty[j].Yardi_ID__c;
            MapIds.put(temp,lstProperty[j]);
            setYard.add(lstProperty[j].Yardi_ID__c);
            System.debug('MapIds=====' +MapIds);
        }
        List<Property__c> lstPropertyUpdated = new List<Property__c>();
        for(Integer k = 0; k < Trigger.new.size(); k++)
        {
            System.debug('Trigger.new[k].Yardi_ID__c=====' +Trigger.new[k].Yardi_ID__c);
            string temp = Trigger.new[k].Yardi_ID__c;
            
            if(setYard.contains(temp))
            {
                System.debug('In here======');
                //Datetime dt = MapIds.get(Trigger.new[k].Yardi_ID__c).LastModifiedDate;
                if(MapIds.get(Trigger.new[k].Yardi_ID__c).Unit_Status_Changed_Date__c != null)
                {
                	Date dt = MapIds.get(Trigger.new[k].Yardi_ID__c).Unit_Status_Changed_Date__c;
                	Date dtLM = Date.newInstance(dt.year(), dt.month(), dt.day());
                	System.debug('dtLM======' +dtLM+ 'Trigger.new[k].UnitStatusUpdateDate__c====' +Trigger.new[k].UnitStatusUpdateDate__c);
                
                
	                System.debug('In here in UNIT');
	                System.debug('Trigger.new[k].Yardi_ID__c=====' +Trigger.new[k].Yardi_ID__c);
	                Property__c objProperty = new Property__c(Yardi_ID__c= Trigger.new[k].Yardi_ID__c);
	                objProperty.Name = Trigger.new[k].Name;
	                objProperty.Asking_Rent__c = Trigger.new[k].Asking_Rent__c;
	                objProperty.Availability_Date__c = Trigger.new[k].Availability_Date__c;
	                objProperty.Building_Name__c = Trigger.new[k].Building_Name__c;
	                
	                objProperty.Current_Rent__c = Trigger.new[k].Current_Rent__c;
	                objProperty.Current_Tenant_Email__c = Trigger.new[k].Current_Tenant_Email__c;
	                objProperty.Current_Tenant_Name__c = Trigger.new[k].Current_Tenant_Name__c;
	                objProperty.Current_Tenant_Notes__c = Trigger.new[k].Current_Tenant_Notes__c;
	                
	                objProperty.Current_Tenant_Phone__c = Trigger.new[k].Current_Tenant_Phone__c;
	                objProperty.Lease_Start_Date__c = Trigger.new[k].Lease_Start_Date__c;
	                objProperty.Lease_End_Date__c = Trigger.new[k].Lease_End_Date__c;
	                objProperty.Lease_Type__c = Trigger.new[k].Lease_Type__c;
	                
	                objProperty.Move_Out_Date__c = Trigger.new[k].Move_Out_Date__c;
	                objProperty.Number_Of_Days_Vacant__c = Trigger.new[k].Number_Of_Days_Vacant__c;
	                objProperty.Other_Charges__c = Trigger.new[k].Other_Charges__c;
	                objProperty.Sq_Feet__c = Trigger.new[k].Sq_Feet__c;
	                
	                objProperty.Unit_Description__c = Trigger.new[k].Unit_Description__c;
	                objProperty.Unit_Number__c = Trigger.new[k].Unit_Number__c;
	                objProperty.Unit_Type__c = Trigger.new[k].Unit_Type__c;
	                
	                //Srinivas code begins
	                objProperty.Unit_Rent__c = Trigger.new[k].Unit_Rent__c;
	                objProperty.Tennant_Code__c = Trigger.new[k].Tennant_Code__c;
	                objProperty.Last_Payment_Date__c = Trigger.new[k].Last_Payment_Date__c;
	                objProperty.Last_Payment_Amount__c = Trigger.new[k].Last_Payment_Amount__c;
	                objProperty.Last_Deposit_Amount__c = Trigger.new[k].Last_Deposit_Amount__c;
	                objProperty.Old_PSF__c = Trigger.new[k].Old_PSF__c;
	                objProperty.New_PSF__c = Trigger.new[k].New_PSF__c;
	                objProperty.Renovation_Status__c = Trigger.new[k].Renovation_Status__c;
	                objProperty.Building_Code__c = Trigger.new[k].Building_Code__c;
	                objProperty.Occupancy_Status__c = Trigger.new[k].Occupancy_Status__c;
	                objProperty.Renovation_Completion_Date__c = Trigger.new[k].Renovation_Completion_Date__c;
	                if(dtLM <= Trigger.new[k].UnitStatusUpdateDate__c)
	                {                   
	                    System.debug('In Changes here ############# dtLM = ' + dtLM + ' Trigger.new[k].UnitStatusUpdateDate__c = ' + Trigger.new[k].UnitStatusUpdateDate__c);
	                    objProperty.Unit_Status__c = Trigger.new[k].Unit_Status__c;
	                }                   
	                objProperty.OnsiteID__c = Trigger.new[k].OnsiteID__c;
	                
	                lstPropertyUpdated.add(objProperty);
	                System.debug('lstPropertyUpdated===='+lstPropertyUpdated);
                }              
            }
            else
            {
                    System.debug('In there');
                    Property__c objProperty = new Property__c();
                    objProperty.Name = trigger.new[k].Name;
                    objProperty.Yardi_ID__c=trigger.new[k].Yardi_ID__c;
                    objProperty.Asking_Rent__c = trigger.new[k].Asking_Rent__c;
                    objProperty.Availability_Date__c = trigger.new[k].Availability_Date__c;
                    objProperty.Building_Name__c = trigger.new[k].Building_Name__c;
                    
                    objProperty.Current_Rent__c = trigger.new[k].Current_Rent__c;
                    objProperty.Current_Tenant_Email__c = trigger.new[k].Current_Tenant_Email__c;
                    objProperty.Current_Tenant_Name__c = trigger.new[k].Current_Tenant_Name__c;
                    objProperty.Current_Tenant_Notes__c = trigger.new[k].Current_Tenant_Notes__c;
                    
                    objProperty.Current_Tenant_Phone__c = trigger.new[k].Current_Tenant_Phone__c;
                    objProperty.Lease_Start_Date__c = trigger.new[k].Lease_Start_Date__c;
                    objProperty.Lease_End_Date__c = trigger.new[k].Lease_End_Date__c;
                    objProperty.Lease_Type__c = trigger.new[k].Lease_Type__c;
                    
                    objProperty.Move_Out_Date__c = trigger.new[k].Move_Out_Date__c;
                    objProperty.Number_Of_Days_Vacant__c = trigger.new[k].Number_Of_Days_Vacant__c;
                    objProperty.Other_Charges__c = trigger.new[k].Other_Charges__c;
                    objProperty.Sq_Feet__c = trigger.new[k].Sq_Feet__c;
                    
                    objProperty.Unit_Description__c = trigger.new[k].Unit_Description__c;
                    objProperty.Unit_Number__c = trigger.new[k].Unit_Number__c;
                    objProperty.Unit_Type__c = trigger.new[k].Unit_Type__c;
                    
                    //Srinivas code begins
                    objProperty.Unit_Rent__c = trigger.new[k].Unit_Rent__c;
                    objProperty.Tennant_Code__c = trigger.new[k].Tennant_Code__c;
                    objProperty.Last_Payment_Date__c = trigger.new[k].Last_Payment_Date__c;
                    objProperty.Last_Payment_Amount__c = trigger.new[k].Last_Payment_Amount__c;
                    objProperty.Last_Deposit_Amount__c = trigger.new[k].Last_Deposit_Amount__c;
                    objProperty.Old_PSF__c = trigger.new[k].Old_PSF__c;
                    objProperty.New_PSF__c = trigger.new[k].New_PSF__c;
                    objProperty.Renovation_Status__c = trigger.new[k].Renovation_Status__c;
                    objProperty.Building_Code__c = trigger.new[k].Building_Code__c;
                    objProperty.Occupancy_Status__c = trigger.new[k].Occupancy_Status__c;
                    objProperty.Renovation_Completion_Date__c = trigger.new[k].Renovation_Completion_Date__c;
                    objProperty.Unit_Status__c = trigger.new[k].Unit_Status__c;
                    
                    lstPropertyUpdated.add(objProperty);
            }   
            
        }
        if(lstPropertyUpdated.size() > 0)
        {
            upsert lstPropertyUpdated Yardi_ID__c;
        }
                
    }
}