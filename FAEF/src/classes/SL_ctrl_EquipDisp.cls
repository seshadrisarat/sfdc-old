public with sharing class SL_ctrl_EquipDisp
{
    //public EquipWrapper[] eList {get;set;}
    public String EItemList {get;set;}
    public Id sId {get;set;}
    public String sName {get;set;}
    //public Id equipId {get;set;}
    //map<Id,EquipItemWrapper[]> eItemMap;


    public SL_ctrl_EquipDisp()
    {
        sId = apexpages.currentpage().getparameters().get('sid');
        scheduleInfo(sId);
        EItemList = makeEItemList();
    }

    public void scheduleInfo(Id schId)
    {
        Schedule__c s = [Select Id,Name From Schedule__c WHERE Id =: schId];

        sName = s.Name;        
    }

    public String makeEItemList()
    {
        System.debug(sId);
        Equipment_Item__c[] eItems = [Select Id,Serial__c,Equipment__r.Name
                                      From Equipment_Item__c
                                      Where Equipment__r.Schedule__c =: sId AND Equipment_Disposition_Item__c = null
                                      ORDER BY Equipment__r.Name,Serial__c];

        EquipItemWrapper[] itemWrap = new EquipItemWrapper[]{};

        for(Equipment_Item__c i : eItems)
        {
            itemWrap.add(new EquipItemWrapper(i.Id,i.Equipment__r.Name+'-'+i.Serial__c));
        }

        return JSON.serialize(itemWrap);
    }

    @RemoteAction
    public static String createDisp(String edString, Id[] eItemIds)
    {
        map<Equipment_Disposition_Item__c,Set<Equipment_Item__c>> eqMap = new map<Equipment_Disposition_Item__c,Set<Equipment_Item__c>>();

        EdWrapper e = (EdWrapper) JSON.deserialize(edString, EdWrapper.class);

        Equipment_Disposition__c ed = new Equipment_Disposition__c();

        ed.Description__c = e.description;
        ed.Status__c = e.status;
        ed.RecordType = new RecordType(Name = e.type);
        ed.Schedule__c = e.sId;
        ed.Full_Description__c = '';

        insert ed;

        Set<Id> eIds = new Set<Id>();

        eIds.addAll(eItemIds);

        Equipment_Item__c[] eItems = [Select Id,Serial__c,Equipment__c,Equipment__r.Name,Equipment__r.Equipment_Type__c,
                                      Equipment__r.Manufacturer__c,Equipment__r.Model__c,Equipment__r.Unit_Price__c
                                      From Equipment_Item__c
                                      Where Id IN: eIds];

        for(Equipment_Item__c eI : eItems)
        {
            
            Equipment_Disposition_Item__c edi = new Equipment_Disposition_Item__c(Name = eI.Equipment__r.Name,
                                                                                  Equipment_Disposition__c = ed.Id,
                                                                                  Equipment__c = eI.Equipment__c);

            if(eqMap.containsKey(edi))
            {
                eqMap.get(edi).add(new Equipment_Item__c(Id = eI.Id,Equipment__c = eI.Equipment__c));
            }else
            {
                eqMap.put(edi,new Set<Equipment_Item__c>{new Equipment_Item__c(Id = eI.Id,Equipment__c = eI.Equipment__c)});
            }

        }

        for(Equipment_Disposition_Item__c eq : eqMap.keyset())
        {
            ed.Full_Description__c = ed.Full_Description__c + eq.Name + '\n\n';
        }

        update ed;

        Equipment_Disposition_Item__c[] listEdi = new Equipment_Disposition_Item__c[]{};

        listEdi.addAll(eqMap.keyset());

        insert listEdi;

        Equipment_Item__c[] listEis = new Equipment_Item__c[]{};

        for(Set<Equipment_Item__c> eSet : eqMap.values())
        {
            listEis.addAll(eSet);
        }


        for(Integer i=0;i<listEdi.size();i++)
        {
            Id eqId = listEdi[i].Equipment__c;

            for(Integer j=0;j<listEis.size();j++)
            {
                if(listEis[j].Equipment__c == eqId)
                {
                    listEis[j].Equipment_Disposition_Item__c = listEdi[i].Id;
                }
            }
        }

        update listEis;

        return ed.Id;
    }

    public class EdWrapper
    {
        public String description;
        public String type;
        public String status;
        public Id sId;
    }

	public class EquipItemWrapper
    {
        public Id eItemId;
        //public String name {get;set;}
        public String serial;

        //public EquipItemWrapper(Id eItemId, String name, String serial)
        public EquipItemWrapper(Id eItemId, String serial)
        {
            this.eItemId = eItemId;
            //this.name = name;
            this.serial = serial;
        }
    }
}