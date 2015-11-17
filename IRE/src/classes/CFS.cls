public class CFS {
  //    public list<AggregateResult> lstAr = new list<AggregateResult>();
    public list<AggregateResult> lstAr {get;set;}
//    public list<AggregateResult> lstAr2 = new list<AggregateResult>();
      public list<AggregateResult> lstAr2 {get;set;}
   
    public Map<string,Map<integer,String>>MapPriorYearResults{get;set;}
    public Map<String,Map<integer,String>> MapIRESI_A {get; set;}
    public Map<String,Map<integer,String>> MapIRESI_T {get; set;}
    public Map<String,Map<integer,String>> MapIRESI_E {get; set;}
    public Map<String,Map<integer,String>> MapIREIT {get; set;}
    public Map<String,Map<integer,String>> MapIPCC {get; set;}
    public Map<String,Map<integer,String>> MapIDIV {get; set;}
    public Map<String,Map<integer,String>> MapITP {get; set;}
    public Map<String,Map<integer,String>> MapIOPF {get; set;}
    public Map<String,Map<integer,String>> MapIOPFII {get; set;}
    public Map<String,Map<integer,String>> MapRPAI {get; set;}
    public Map<String,Map<integer,String>> MapIRRETI{get; set;}
    public Map<String,Map<integer,String>> MapIREC{get; set;}
    public Map<String,Map<integer,String>> MapIRC{get; set;}
    //  public CFS ()   {        }  
    //Include ApexPages within the constractor so it will tie up with the specific ContactID
    public CFS(ApexPages.StandardController std){
       String contId = ApexPages.currentPage().getParameters().get('id');
        
        lstAr = [select Fund__r.Fund_Acronym__c fn, FISCAL_YEAR(Sales_Date__c) Ye, Sum(Amount__c) amt 
                from Daily_Sale__c 
                where Contact__c  = :contId and Sales_Date__c >=Last_N_YEARS:5
                Group BY Fund__r.Fund_Acronym__c, FISCAL_YEAR(Sales_Date__c) order by FISCAL_YEAR(Sales_Date__c) DESC]; 
    
    
        lstAr2=[Select Fund__r.Fund_Acronym__c fn, sum(Amount__c) amt
                from Daily_Sale__c
                Where Contact__c  =:contId and Sales_Date__c <LAST_N_YEARS:5
                Group BY Fund__r.Fund_Acronym__c];
    }
    
    public Map<string,Map<integer,String>>getresults2()
    {
        MapIRESI_A = new Map<String, Map<integer, String>>();
        MapIRESI_T = new Map<String, Map<integer, String>>();
        MapIRESI_E = new Map<String, Map<integer, String>>();
        MapIREIT = new Map<String, Map<integer, String>>();
        MapIPCC = new Map<String, Map<integer, String>>();
        MapIDIV = new Map<String, Map<integer, String>>();
        MapITP = new Map<String, Map<integer, String>>();
        MapIOPF = new Map<String, Map<integer, String>>();
        MapIOPFII = new Map<String, Map<integer, String>>();
        MapRPAI = new Map<String, Map<integer, String>>();
        MapIRRETI = new Map<String, Map<integer, String>>();
        MapIREC = new Map<String, Map<integer, String>>();
        MapIRC = new Map<String, Map<integer, String>>();
        MapPriorYearResults = new Map<String,Map<integer,String>>();
        
        integer currentYear = System.today().year();
        Double firstYearTotal = 0;
        
         for(AggregateResult ar:lstAr){
            
            string FundName = (string)ar.get('fn');
            
            if(FundName == 'IRESI-A'){
            
                if(MapIRESI_A.get(FundName) == null)
                {   
                    MapIRESI_A.put(FundName, new Map<integer, String>());
                }
           
            MapIRESI_A.get(FundName).put(currentYear-(integer)ar.get('Ye')+1,currency(string.valueOf(ar.get('amt'))));
          }   
       }
       
       for(AggregateResult ar:lstAr2){   
          
           string FundName = (string)ar.get('fn');
           
           if(FundName == 'IRESI-A'){
                      
            if(MapIRESI_A.get(FundName) == null)
            {
                MapIRESI_A.put(FundName, new Map<integer, String>());
            }
          
            MapIRESI_A.get(FundName).put(7,currency(string.valueOf(ar.get('amt'))));           
          }  
       }
       
       for(string loopFN:MapIRESI_A.keySet())
           {
    
             if(loopFN == 'IRESI-A'){         
             Double TA = 0;
             
             for (integer i = 0; i < 7 ; i++ )
                {
                    
                    if(MapIRESI_A.get(loopFN).get(i+1) == null)
                    {                       
                       MapIRESI_A.get(loopFN).put(i+1,'0');  
                    }
                    else
                    { 
                        TA = TA + Double.valueOf(MapIRESI_A.get(loopFn).get(i+1).replaceAll(',',''));                      
                                                  
                    } 
                }
                MapIRESI_A.get(loopFN).put(0,currency(string.valueOf(TA)));
            }
        }
       
       for(AggregateResult ar:lstAr){
            
            string FundName = (string)ar.get('fn');
            
            if(FundName == 'IRESI-T'){
            
                if(MapIRESI_T.get(FundName) == null)
                {   
                    MapIRESI_T.put(FundName, new Map<integer, String>());
                }
           
            MapIRESI_T.get(FundName).put(currentYear-(integer)ar.get('Ye')+1,currency(string.valueOf(ar.get('amt'))));
          }   
       }
       
       for(AggregateResult ar:lstAr2){   
          
           string FundName = (string)ar.get('fn');
           
           if(FundName == 'IRESI-T'){
                      
            if(MapIRESI_T.get(FundName) == null)
            {
                MapIRESI_T.put(FundName, new Map<integer, String>());
            }
          
            MapIRESI_T.get(FundName).put(7,currency(string.valueOf(ar.get('amt'))));           
          }  
       }
       
       for(string loopFN:MapIRESI_T.keySet())
           {
    
             if(loopFN == 'IRESI-T'){         
             Double TA = 0;
             
             for (integer i = 0; i < 7 ; i++ )
                {
                    
                    if(MapIRESI_T.get(loopFN).get(i+1) == null)
                    {                       
                       MapIRESI_T.get(loopFN).put(i+1,'0');  
                    }
                    else
                    { 
                        TA = TA + Double.valueOf(MapIRESI_T.get(loopFn).get(i+1).replaceAll(',',''));                      
                                                  
                    } 
                }
                MapIRESI_T.get(loopFN).put(0,currency(string.valueOf(TA)));
            }
        }
       
       for(AggregateResult ar:lstAr){
            
            string FundName = (string)ar.get('fn');
            
            if(FundName == 'IRESI-E'){
            
                if(MapIRESI_E.get(FundName) == null)
                {   
                    MapIRESI_E.put(FundName, new Map<integer, String>());
                }
           
            MapIRESI_E.get(FundName).put(currentYear-(integer)ar.get('Ye')+1,currency(string.valueOf(ar.get('amt'))));
          }   
       }
       
       for(AggregateResult ar:lstAr2){   
          
           string FundName = (string)ar.get('fn');
           
           if(FundName == 'IRESI-E'){
                      
            if(MapIRESI_E.get(FundName) == null)
            {
                MapIRESI_E.put(FundName, new Map<integer, String>());
            }
          
            MapIRESI_E.get(FundName).put(7,currency(string.valueOf(ar.get('amt'))));           
          }  
       }
       
       for(string loopFN:MapIRESI_E.keySet())
           {
    
             if(loopFN == 'IRESI-E'){         
             Double TA = 0;
             
             for (integer i = 0; i < 7 ; i++ )
                {
                    
                    if(MapIRESI_E.get(loopFN).get(i+1) == null)
                    {                       
                       MapIRESI_E.get(loopFN).put(i+1,'0');  
                    }
                    else
                    { 
                        TA = TA + Double.valueOf(MapIRESI_E.get(loopFn).get(i+1).replaceAll(',',''));                      
                                                  
                    } 
                }
                MapIRESI_E.get(loopFN).put(0,currency(string.valueOf(TA)));
            }
        } 
        
        for(AggregateResult ar:lstAr){
            
            string FundName = (string)ar.get('fn');
            
            if(FundName == 'IRRETI'){
            
                if(MapIRRETI.get(FundName) == null)
                {   
                    MapIRRETI.put(FundName, new Map<integer, String>());
                }
           
            MapIRRETI.get(FundName).put(currentYear-(integer)ar.get('Ye')+1,currency(string.valueOf(ar.get('amt'))));
          }   
       }
       
       for(AggregateResult ar:lstAr2){   
          
           string FundName = (string)ar.get('fn');
           
           if(FundName == 'IRRETI'){
                      
            if(MapIRRETI.get(FundName) == null)
            {
                MapIRRETI.put(FundName, new Map<integer, String>());
            }
          
            MapIRRETI.get(FundName).put(7,currency(string.valueOf(ar.get('amt'))));           
          }  
       }
       
       for(string loopFN:MapIRRETI.keySet())
           {
    
             if(loopFN == 'IRRETI'){         
             Double TA = 0;
             
             for (integer i = 0; i < 7 ; i++ )
                {
                    
                    if(MapIRRETI.get(loopFN).get(i+1) == null)
                    {                       
                       MapIRRETI.get(loopFN).put(i+1,'0');  
                    }
                    else
                    { 
                        TA = TA + Double.valueOf(MapIRRETI.get(loopFn).get(i+1).replaceAll(',',''));                      
                                                  
                    } 
                }
                MapIRRETI.get(loopFN).put(0,currency(string.valueOf(TA)));
            }
        }
        
        for(AggregateResult ar:lstAr){
            
            string FundName = (string)ar.get('fn');
            
            if(FundName == 'IPCC'){
            
                if(MapIPCC.get(FundName) == null)
                {   
                    MapIPCC.put(FundName, new Map<integer, String>());
                }
           
            MapIPCC.get(FundName).put(currentYear-(integer)ar.get('Ye')+1,currency(string.valueOf(ar.get('amt'))));
          }   
       }
       
       for(AggregateResult ar:lstAr2){   
          
           string FundName = (string)ar.get('fn');
           
           if(FundName == 'IPCC'){
                      
            if(MapIPCC.get(FundName) == null)
            {
                MapIPCC.put(FundName, new Map<integer, String>());
            }
          
            MapIPCC.get(FundName).put(7,currency(string.valueOf(ar.get('amt'))));           
          }  
       }
       
       for(string loopFN:MapIPCC.keySet())
           {
    
             if(loopFN == 'IPCC'){         
             Double TA = 0;
             
             for (integer i = 0; i < 7 ; i++ )
                {
                    
                    if(MapIPCC.get(loopFN).get(i+1) == null)
                    {                       
                       MapIPCC.get(loopFN).put(i+1,'0');  
                    }
                    else
                    { 
                        TA = TA + Double.valueOf(MapIPCC.get(loopFn).get(i+1).replaceAll(',',''));                      
                                                  
                    } 
                }
                MapIPCC.get(loopFN).put(0,currency(string.valueOf(TA)));
            }
        }
        
        for(AggregateResult ar:lstAr){
            
            string FundName = (string)ar.get('fn');
            
            if(FundName == 'IREC'){
            
                if(MapIREC.get(FundName) == null)
                {   
                    MapIREC.put(FundName, new Map<integer, String>());
                }
           
            MapIREC.get(FundName).put(currentYear-(integer)ar.get('Ye')+1,currency(string.valueOf(ar.get('amt'))));
          }   
       }
       
       for(AggregateResult ar:lstAr2){   
          
           string FundName = (string)ar.get('fn');
           
           if(FundName == 'IREC'){
                      
            if(MapIREC.get(FundName) == null)
            {
                MapIREC.put(FundName, new Map<integer, String>());
            }
          
            MapIREC.get(FundName).put(7,currency(string.valueOf(ar.get('amt'))));           
          }  
       }
       
       for(string loopFN:MapIREC.keySet())
           {
    
             if(loopFN == 'IREC'){         
             Double TA = 0;
             
             for (integer i = 0; i < 7 ; i++ )
                {
                    
                    if(MapIREC.get(loopFN).get(i+1) == null)
                    {                       
                       MapIREC.get(loopFN).put(i+1,'0');  
                    }
                    else
                    { 
                        TA = TA + Double.valueOf(MapIREC.get(loopFn).get(i+1).replaceAll(',',''));                      
                                                  
                    } 
                }
                MapIREC.get(loopFN).put(0,currency(string.valueOf(TA)));
            }
        } 
        
         for(AggregateResult ar:lstAr){
            
            string FundName = (string)ar.get('fn');
            
            if(FundName == 'RPAI'){
            
                if(MapRPAI.get(FundName) == null)
                {   
                    MapRPAI.put(FundName, new Map<integer, String>());
                }
           
            MapRPAI.get(FundName).put(currentYear-(integer)ar.get('Ye')+1,currency(string.valueOf(ar.get('amt'))));
          }   
       }
       
       for(AggregateResult ar:lstAr2){   
          
           string FundName = (string)ar.get('fn');
           
           if(FundName == 'RPAI'){
                      
            if(MapRPAI.get(FundName) == null)
            {
                MapRPAI.put(FundName, new Map<integer, String>());
            }
          
            MapRPAI.get(FundName).put(7,currency(string.valueOf(ar.get('amt'))));           
          }  
       }
       
       for(string loopFN:MapRPAI.keySet())
           {
    
             if(loopFN == 'RPAI'){         
             Double TA = 0;
             
             for (integer i = 0; i < 7 ; i++ )
                {
                    
                    if(MapRPAI.get(loopFN).get(i+1) == null)
                    {                       
                       MapRPAI.get(loopFN).put(i+1,'0');  
                    }
                    else
                    { 
                        TA = TA + Double.valueOf(MapRPAI.get(loopFn).get(i+1).replaceAll(',',''));                      
                                                  
                    } 
                }
                MapRPAI.get(loopFN).put(0,currency(string.valueOf(TA)));
            }
        } 
        
        for(AggregateResult ar:lstAr){
            
            string FundName = (string)ar.get('fn');
            
            if(FundName == 'IOPF'){
            
                if(MapIOPF.get(FundName) == null)
                {   
                    MapIOPF.put(FundName, new Map<integer, String>());
                }
           
            MapIOPF.get(FundName).put(currentYear-(integer)ar.get('Ye')+1,currency(string.valueOf(ar.get('amt'))));
          }   
       }
       
       for(AggregateResult ar:lstAr2){   
          
           string FundName = (string)ar.get('fn');
           
           if(FundName == 'IOPF'){
                      
            if(MapIOPF.get(FundName) == null)
            {
                MapIOPF.put(FundName, new Map<integer, String>());
            }
          
            MapIOPF.get(FundName).put(7,currency(string.valueOf(ar.get('amt'))));           
          }  
       }
       
       for(string loopFN:MapIOPF.keySet())
           {
    
             if(loopFN == 'IOPF'){         
             Double TA = 0;
             
             for (integer i = 0; i < 7 ; i++ )
                {
                    
                    if(MapIOPF.get(loopFN).get(i+1) == null)
                    {                       
                       MapIOPF.get(loopFN).put(i+1,'0');  
                    }
                    else
                    { 
                        TA = TA + Double.valueOf(MapIOPF.get(loopFn).get(i+1).replaceAll(',',''));                      
                                                  
                    } 
                }
                MapIOPF.get(loopFN).put(0,currency(string.valueOf(TA)));
            }
        }
        
        for(AggregateResult ar:lstAr){
            
            string FundName = (string)ar.get('fn');
            
            if(FundName == 'IOPF II'){
            
                if(MapIOPFII.get(FundName) == null)
                {   
                    MapIOPFII.put(FundName, new Map<integer, String>());
                }
           
            MapIOPFII.get(FundName).put(currentYear-(integer)ar.get('Ye')+1,currency(string.valueOf(ar.get('amt'))));
          }   
       }
       
       for(AggregateResult ar:lstAr2){   
          
           string FundName = (string)ar.get('fn');
           
           if(FundName == 'IOPF II'){
                      
            if(MapIOPFII.get(FundName) == null)
            {
                MapIOPFII.put(FundName, new Map<integer, String>());
            }
          
            MapIOPFII.get(FundName).put(7,currency(string.valueOf(ar.get('amt'))));           
          }  
       }
       
       for(string loopFN:MapIOPFII.keySet())
           {
    
             if(loopFN == 'IOPF II'){         
             Double TA = 0;
             
             for (integer i = 0; i < 7 ; i++ )
                {
                    
                    if(MapIOPFII.get(loopFN).get(i+1) == null)
                    {                       
                       MapIOPFII.get(loopFN).put(i+1,'0');  
                    }
                    else
                    { 
                        TA = TA + Double.valueOf(MapIOPFII.get(loopFn).get(i+1).replaceAll(',',''));                      
                                                  
                    } 
                }
                MapIOPFII.get(loopFN).put(0,currency(string.valueOf(TA)));
            }
        } 
        for(AggregateResult ar:lstAr){
            
            string FundName = (string)ar.get('fn');
            
            if(FundName == 'ITP'){
            
                if(MapITP.get(FundName) == null)
                {   
                    MapITP.put(FundName, new Map<integer, String>());
                }
           
            MapITP.get(FundName).put(currentYear-(integer)ar.get('Ye')+1,currency(string.valueOf(ar.get('amt'))));
          }   
       }
       
       for(AggregateResult ar:lstAr2){   
          
           string FundName = (string)ar.get('fn');
           
           if(FundName == 'ITP'){
                      
            if(MapITP.get(FundName) == null)
            {
                MapITP.put(FundName, new Map<integer, String>());
            }
          
            MapITP.get(FundName).put(7,currency(string.valueOf(ar.get('amt'))));           
          }  
       }
       
       for(string loopFN:MapITP.keySet())
           {
    
             if(loopFN == 'ITP'){         
             Double TA = 0;
             
             for (integer i = 0; i < 7 ; i++ )
                {
                    
                    if(MapITP.get(loopFN).get(i+1) == null)
                    {                       
                       MapITP.get(loopFN).put(i+1,'0');  
                    }
                    else
                    { 
                        TA = TA + Double.valueOf(MapITP.get(loopFn).get(i+1).replaceAll(',',''));                      
                                                  
                    } 
                }
                MapITP.get(loopFN).put(0,currency(string.valueOf(TA)));
            }
        }
        
         for(AggregateResult ar:lstAr){
            
            string FundName = (string)ar.get('fn');
            
            if(FundName == 'IDIV'){
            
                if(MapIDIV.get(FundName) == null)
                {   
                    MapIDIV.put(FundName, new Map<integer, String>());
                }
           
            MapIDIV.get(FundName).put(currentYear-(integer)ar.get('Ye')+1,currency(string.valueOf(ar.get('amt'))));
          }   
       }
       
       for(AggregateResult ar:lstAr2){   
          
           string FundName = (string)ar.get('fn');
           
           if(FundName == 'IDIV'){
                      
            if(MapIDIV.get(FundName) == null)
            {
                MapIDIV.put(FundName, new Map<integer, String>());
            }
          
            MapIDIV.get(FundName).put(7,currency(string.valueOf(ar.get('amt'))));           
          }  
       }
       
       for(string loopFN:MapIDIV.keySet())
           {
    
             if(loopFN == 'IDIV'){         
             Double TA = 0;
             
             for (integer i = 0; i < 7 ; i++ )
                {
                    
                    if(MapIDIV.get(loopFN).get(i+1) == null)
                    {                       
                       MapIDIV.get(loopFN).put(i+1,'0');  
                    }
                    else
                    { 
                        TA = TA + Double.valueOf(MapIDIV.get(loopFn).get(i+1).replaceAll(',',''));                      
                                                  
                    } 
                }
                MapIDIV.get(loopFN).put(0,currency(string.valueOf(TA)));
            }
        }
        
        for(AggregateResult ar:lstAr){
            
            string FundName = (string)ar.get('fn');
            
            if(FundName == 'IREIT'){
            
            if(MapIREIT.get(FundName) == null)
            {   
                MapIREIT.put(FundName, new Map<integer, String>());
            }
           
            MapIREIT.get(FundName).put(currentYear-(integer)ar.get('Ye')+1,currency(string.valueOf(ar.get('amt'))));
          }   
        }
       
                     
       for(AggregateResult ar:lstAr2){   
          
           string FundName = (string)ar.get('fn');
           
           if(FundName == 'IREIT'){
                      
            if(MapIREIT.get(FundName) == null)
            {
                MapIREIT.put(FundName, new Map<integer, String>());
            }
          
            MapIREIT.get(FundName).put(7,currency(string.valueOf(ar.get('amt'))));           
          }  
       }
       
       for(string loopFN:MapIREIT.keySet())
           {
    
             if(loopFN == 'IREIT'){         
             Double TA = 0;
             
             for (integer i = 0; i < 7 ; i++ )
                {
                    
                    if(MapIREIT.get(loopFN).get(i+1) == null)
                    {                       
                       MapIREIT.get(loopFN).put(i+1,'0');  
                    }
                    else
                    { 
                        TA = TA + Double.valueOf(MapIREIT.get(loopFn).get(i+1).replaceAll(',',''));                      
                                                  
                    } 
                }
                MapIREIT.get(loopFN).put(0,currency(string.valueOf(TA)));
            }
        }
        
        for(AggregateResult ar:lstAr){
            
            string FundName = (string)ar.get('fn');
            
            if(FundName == 'IRC'){
            
            if(MapIRC.get(FundName) == null)
            {   
                MapIRC.put(FundName, new Map<integer, String>());
            }
           
            MapIRC.get(FundName).put(currentYear-(integer)ar.get('Ye')+1,currency(string.valueOf(ar.get('amt'))));
          }   
        }
       
                     
       for(AggregateResult ar:lstAr2){   
          
           string FundName = (string)ar.get('fn');
           
           if(FundName == 'IRC'){
                      
            if(MapIRC.get(FundName) == null)
            {
                MapIRC.put(FundName, new Map<integer, String>());
            }
          
            MapIRC.get(FundName).put(7,currency(string.valueOf(ar.get('amt'))));           
          }  
       }
       
       for(string loopFN:MapIRC.keySet())
           {
    
             if(loopFN == 'IRC'){         
             Double TA = 0;
             
             for (integer i = 0; i < 7 ; i++ )
                {
                    
                    if(MapIRC.get(loopFN).get(i+1) == null)
                    {                       
                       MapIRC.get(loopFN).put(i+1,'0');  
                    }
                    else
                    { 
                        TA = TA + Double.valueOf(MapIRC.get(loopFn).get(i+1).replaceAll(',',''));                      
                                                  
                    } 
                }
                MapIRC.get(loopFN).put(0,currency(string.valueOf(TA)));
            }
        }
                
        MapPriorYearResults.put('Totals', new Map<integer, String>());

        for (integer i = 0; i <= 7 ; i++ )
           {
             Double TB = 0;
             
             for(string loopFN:MapIRESI_A.keySet())
                {
                    TB = TB + Double.valueOf(MapIRESI_A.get(loopFn).get(i).replaceAll(',',''));                      
                }
             for(string loopFN:MapIRESI_T.keySet())
                {
                    TB = TB + Double.valueOf(MapIRESI_T.get(loopFn).get(i).replaceAll(',',''));                      
                }
             for(string loopFN:MapIRESI_E.keySet())
                {
                    TB = TB + Double.valueOf(MapIRESI_E.get(loopFn).get(i).replaceAll(',',''));                      
                }   
             for(string loopFN:MapIRRETI.keySet())
                {
                    TB = TB + Double.valueOf(MapIRRETI.get(loopFn).get(i).replaceAll(',',''));                      
                }
                for(string loopFN:MapIREC.keySet())
                {
                    TB = TB + Double.valueOf(MapIREC.get(loopFn).get(i).replaceAll(',',''));                      
                }
                for(string loopFN:MapRPAI.keySet())
                {
                    TB = TB + Double.valueOf(MapRPAI.get(loopFn).get(i).replaceAll(',',''));                      
                }
                for(string loopFN:MapIOPF.keySet())
                {
                    TB = TB + Double.valueOf(MapIOPF.get(loopFn).get(i).replaceAll(',',''));                      
                }
                for(string loopFN:MapIOPFII.keySet())
                {
                    TB = TB + Double.valueOf(MapIOPFII.get(loopFn).get(i).replaceAll(',',''));                      
                }   
                for(string loopFN:MapITP.keySet())
                {
                    TB = TB + Double.valueOf(MapITP.get(loopFn).get(i).replaceAll(',',''));                      
                }
                for(string loopFN:MapIDIV.keySet())
                {
                    TB = TB + Double.valueOf(MapIDIV.get(loopFn).get(i).replaceAll(',',''));                      
                } 
                for(string loopFN:MapIPCC.keySet())
                {
                    TB = TB + Double.valueOf(MapIPCC.get(loopFn).get(i).replaceAll(',',''));                      
                } 
                for(string loopFN:MapIREIT.keySet())
                {
                    TB = TB + Double.valueOf(MapIREIT.get(loopFn).get(i).replaceAll(',',''));                      
                }
                for(string loopFN:MapIRC.keySet())
                {
                    TB = TB + Double.valueOf(MapIRC.get(loopFn).get(i).replaceAll(',',''));                      
                }
             
                MapPriorYearResults.get('Totals').put(i,currency(string.valueOf(TB)));
        } 
        
        system.debug('Rakesh ' +MapPriorYearResults);
        
        return MapPriorYearResults; 
        return MapIRESI_A;   
        return MapIRESI_T;
        return MapIRESI_E;
        return MapIRRETI;
        return MapIREC;
        return MapRPAI;
        return MapIOPF;
        return MapIOPFII;
        return MapITP;
        return MapIDIV;
        return MapIPCC;
        return MapIREIT;
        return MapIRC;
        
    }
    
    
    
    public static String currency(String i) {
    String s = ( decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
    return s.substring(0,s.length()-1);
    }

}