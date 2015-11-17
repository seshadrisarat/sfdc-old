public class searchResultBlock {

    public string contrName;
    
    public string getContrName()
    {
        return contrName;
    }
    
    public void setContrName(string cName)
    {
        contrName = cName;
    }
    
    
    static testMethod void testThis() {
    	searchResultBlock srb = new searchResultBlock();
    	srb.setContrName('test');
    	string s = srb.getContrName();
    }
}