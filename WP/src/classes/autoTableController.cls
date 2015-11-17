public with sharing class autoTableController { 
        
        public static testMethod void testMe(   )
        {
        autoTableController x = new autoTableController();
                        String s = x.TblID;
                        s = x.AutoTableDataSponsorID;
s = x.ContainingDiv;
s = x.QueryDelay;
s = x.FieldConfig;
s = x.DefaultColHeaderClass;
s = x.DefaultCellClass;
s = x.URLLinkPrefix;
s = x.funcNameDeleteRow;
s = x.funcNameTableStarting;
s = x.funcNameFuncRetrieveSOQLQuery;
s = x.TableClassName;
s = x.PrimaryObjectName;
s = x.PrimaryObjectType;
s = x.funcNameTableComplete;
s = x.funcNameCellComplete;
s = x.funcNameRowComplete;
s = x.funcNameColHeaderComplete;
s = x.objectName;

        }
        
    public String TblID { get; set; }
    public String AutoTableDataSponsorID { get; set; }
    public String ContainingDiv { get; set; }
    public String QueryDelay { get; set; }
    public String FieldConfig { get; set; }    
    public string DefaultCellClass { get; set; }
    public string DefaultColHeaderClass { get; set; } 
    public string URLLinkPrefix { get; set; }
    public integer NameField { get; set; }
    public Boolean IncludeDeleteColumn { get; set; }
    
    public string funcNameDeleteRow { get; set; }
    
    public string funcNameTableStarting { get; set; }
   
    public string funcNameFuncRetrieveSOQLQuery { get; set; }
    
    public string TableClassName { get; set; }
    
    public Boolean ShowColumnHeaders { get; set; }
    
    public string PrimaryObjectName { get; set; }
    public string PrimaryObjectType { get; set; }
    
    
    public String funcNameTableComplete { get; set; }
        
    public String funcNameCellComplete { get; set; }

    public String funcNameRowComplete { get; set; }

    public String funcNameColHeaderComplete  { get; set; }
 
public String objectName { get {return objectName ;} set{ objectName = value ;} }    


 
}