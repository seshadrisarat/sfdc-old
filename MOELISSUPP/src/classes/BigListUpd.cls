//Account update!
public class BigListUpd {
   
    private String objectType = '';
    private integer listSize = 99;
    private integer itemsNum = 0;
    public List< List<Sobject> > oppQueue {get;set;}

    public BigListUpd(String inVal)
    {
    	objectType = inVal;
    	oppQueue = new List< List<Sobject> > ();
    }
   
    public void add(Sobject item)
    {
        integer activeList = itemsNum / listSize;
        integer newIndex = math.mod(itemsNum, listSize);
        if(newIndex == 0)
        {
        	if(objectType=='Account') oppQueue.add(new List<Account>());
        	else if(objectType=='Ibanking_Project__c') oppQueue.add(new List<Ibanking_Project__c>());
        	else return;
        }

        oppQueue.get(activeList).add(item);
        itemsNum++;
    } 
    
    public Sobject getLast()
    {
        integer activeList = (itemsNum-1) / listSize;
        integer lastIndex = math.mod((itemsNum-1), listSize);
        
        system.debug('Test activeList: ' + activeList);
        system.debug('Test lastIndex: ' + lastIndex);
        return oppQueue.get(activeList).get(lastIndex);
    }
    
    public void updateAll()
    {
        integer activeList = (itemsNum-1) / listSize;

        if (itemsNum>0) {
            for (integer i = 0; i <= activeList; i++) {
                update oppQueue.get(i);
            }
        }
    }
    
    public static testMethod void testQueue() {
        
        Account testOpp = new Account(
            name = 'Test Obj', 
            Type='Test Type',
            Industry='Other',
            Public_Private__c = 'Public', 
            RecordTypeID = [select ID,Name from RecordType where SobjectType='Account' Limit 1].ID
        );
        insert testOpp;
        

        BigListUpd testClass = new BigListUpd('Account');
        testClass.add(testOpp);
        system.assertEquals(testClass.getLast(), testOpp);
        testClass.updateAll();

    }
   
   

}