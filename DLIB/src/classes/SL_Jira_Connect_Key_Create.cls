public class SL_Jira_Connect_Key_Create{
    double iterator = 1;
    Map<double, string> RN = new Map<double, string>();
    string previous = '';
	
    
    //called from outside to make the key
    public String MakeKey(String Name){
        String key;
        boolean single;
        SetMap();
        
        String[] nameBreak = Name.split(' ', 0);
        if(nameBreak.size() == 1){
            single = true;
            key = MakeFromSingle(Name);
        }else{
            single = false;
            key = MakeFromMultiple(nameBreak);
        }
        Key = CheckKeyAndFix(Key);
        
        return key;
    }
    
    //makes basic single key (first 3 letters all caps)
    private String MakeFromSingle(String Name){
        String key = Name.left(3);
        key = key.left(1).capitalize() + key.mid(1,1).capitalize() + key.mid(2,1).capitalize();
        return key;
    }
    
    //makes basic multi key (first letter of each word all caps)
    private String MakeFromMultiple(String[] Name){
        string key = '';
        for(integer i = 0; i < Name.size(); i++){
            key = key + Name[i].left(1).capitalize();
        }
        return key;
    }
    
    
    //checks for dupes and handles accordingly
    private String CheckKeyAndFix(String Key){
        boolean exists = false;
        
        List<Project__c> projectName = [SELECT Id, JIRA_Project_Name__c FROM Project__c WHERE Jira_Project_Name__c =:Key];
        if(projectName.isEmpty() == false){
            exists = true;
        }
        If(exists == true){
            iterator++;
            string temp = RN.get(iterator);
            if(temp == null){
                Key = Key.left(Key.length()-previous.length())+'X';
                iterator = 0;
                previous = '';
                Key = CheckKeyAndFix(Key);
            }else{
                Key = Key.left(Key.length()-previous.length())+temp;
                previous = temp;
                Key = CheckKeyAndFix(Key);
            }
        }
        return key;
    }
    
    
    //puts 1-9 into the roman numerals set
    private void SetMap(){
        RN.put(1,'I');
        RN.put(2,'II');
        RN.put(3,'III');
        RN.put(4,'IV');
        RN.put(5,'V');
        RN.put(6,'VI');
        RN.put(7,'VII');
        RN.put(8,'VIII');
        RN.put(9,'IX');
    }
}