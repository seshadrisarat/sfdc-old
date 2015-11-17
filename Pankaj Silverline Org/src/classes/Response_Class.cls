public class Response_Class 
{
    public Attributes attributes {get;set;}
    
    public class Attributes
    {
        public typeInfo typeInforWrapper{get;set;}
        public String Name{get;set;}
        public String Id{get;set;}
    }
    
    public class typeInfo
    {
        public String type{get;set;}
        public String url{get;set;}
    }
}