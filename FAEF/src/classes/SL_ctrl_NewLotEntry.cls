public class SL_ctrl_NewLotEntry
{
	public String lotItemStr {get;set;}

	public SL_ctrl_NewLotEntry()
	{
		Equipment_Item__c[] eiList = [SELECT Id,Equipment_Disposition_Item__c,
											 Equipment_Disposition_Item__r.Description__c,
			   								 Equipment_Disposition_Item__r.Equipment_Disposition__r.Name,
			   								 Equipment__r.Name,
			   								 Equipment_Disposition_Item__r.Equipment_Disposition__r.Schedule__r.Name,
			   								 Equipment_Disposition_Item__r.Equipment_Disposition__r.Schedule__r.Account_Lookup__r.Name,
			   								 Serial__c FROM Equipment_Item__c
			   								 WHERE Equipment_Disposition_Item__r.Equipment_Disposition__r.RecordType.Name = 'Return'];

		LotItemWrapper[] itemWrap = new LotItemWrapper[]{};

		for(Equipment_Item__c i : eiList)
        {
        	String itemName = i.Equipment_Disposition_Item__r.Equipment_Disposition__r.Name + ' - '+
        					  i.Equipment_Disposition_Item__r.Description__c + ' - '+
        					  i.Equipment_Disposition_Item__r.Equipment_Disposition__r.Schedule__r.Name + ' - '+
        					  i.Equipment_Disposition_Item__r.Equipment_Disposition__r.Schedule__r.Account_Lookup__r.Name + ' - '+
        					  i.Serial__c;

            itemWrap.add(new LotItemWrapper(i.Id,itemName));
        }


		lotItemStr = JSON.serialize(itemWrap);

		/*for(Equipment_Item__c e : eiList)
		{
			if(directors.containsKey(e.Equipment_Disposition_Item__r.Equipment_Disposition__r.Name))
			{
				directors.get(e.Equipment_Disposition_Item__r.Equipment_Disposition__r.Name).add(e.Equipment_Disposition_Item__r.Equipment_Disposition__r.Name + ' - ' + e.Equipment_Disposition_Item__r.Description__c + ' - ' + e.Serial__c);
			}else
			{
				directors.put(e.Equipment_Disposition_Item__r.Equipment_Disposition__r.Name, new String[]{e.Equipment_Disposition_Item__r.Equipment_Disposition__r.Name + ' - ' + e.Equipment_Disposition_Item__r.Description__c + ' - ' + e.Serial__c});
			}
		}*/
	}

	public class LotItemWrapper
    {
        public Id eItemId;
        //public String name {get;set;}
        public String itemDesc;

        //public EquipItemWrapper(Id eItemId, String name, String serial)
        public LotItemWrapper(Id eItemId, String itemDesc)
        {
            this.eItemId = eItemId;
            //this.name = name;
            this.itemDesc = itemDesc;
        }
    }
}