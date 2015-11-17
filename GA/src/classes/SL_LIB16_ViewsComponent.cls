public virtual without sharing class SL_LIB16_ViewsComponent {
    
    public SL_LIB16_ViewsParams params {get; set;}
    
    /******************************* for Views *******************************/
    public String strView {get;set;}
    public List<SelectOption> lstColumnsAndFiltersTemplate {get; set;}
    public Boolean isShowDeleteButton  {get;set;}
    public String strColumnsAndFiltersTemplate
    {
        get
        {
            if((strColumnsAndFiltersTemplate==null || strColumnsAndFiltersTemplate=='') && strView!=null && strView!='' && !isNewView) return strView;
            return strColumnsAndFiltersTemplate;
        }
        set;
    }
    public boolean editMode {get; set;}
    public boolean initialized {get; set;}
    public String selectedColumnsCallback {get; set;}
   
    private SL_Mass_Implementation__c currMainCusSettings {get{return params.currMainCusSettings;}}
    private String currTplColumns = '';
    public boolean isNewView {get; set;}

    public SL_LIB16_ViewsComponent()
    {
        isNewView = false;
        editMode = false;
	}

    public void init(){
        initialized = true;
        editMode = false;
        loadViews();
        Set<String> setSelectedColumn = new Set<String>();
        if(currTplColumns!=null && currTplColumns!=''){
            for(String item : currTplColumns.split(',')){ setSelectedColumn.add(item.toLowerCase());}
        }
    }
    
    public void loadViews()
    {
        String firstViewName = '';
        String firstViewColumns = '';
        ID firstId = null;
        lstColumnsAndFiltersTemplate = new List<SelectOption>();
        
        if(currMainCusSettings!=null && currMainCusSettings.searchObjectName__c!=null)
        {
            for(SL_View__c objColumnsAndFiltersTemplate:[Select Name, Id, Columns__c From SL_View__c where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' and (User__c=:UserInfo.getUserId() or IsDefault__c=true)])
            {
                lstColumnsAndFiltersTemplate.add(new selectOption(objColumnsAndFiltersTemplate.Name, objColumnsAndFiltersTemplate.Name));
                if(firstViewName == '')
                {
                    firstViewName = objColumnsAndFiltersTemplate.Name;
                    firstViewColumns = objColumnsAndFiltersTemplate.Columns__c;
                    firstId = objColumnsAndFiltersTemplate.Id;
                }
                if(objColumnsAndFiltersTemplate.Name == strColumnsAndFiltersTemplate)
                {
                    currTplColumns = objColumnsAndFiltersTemplate.Columns__c;
                    strColumnsAndFiltersTemplate = objColumnsAndFiltersTemplate.Name;
                    params.curViewId = objColumnsAndFiltersTemplate.Id;
                }
                if(strColumnsAndFiltersTemplate == null && objColumnsAndFiltersTemplate.Id == params.curViewId){
                    currTplColumns = objColumnsAndFiltersTemplate.Columns__c;
                    strColumnsAndFiltersTemplate = objColumnsAndFiltersTemplate.Name;
                }
            }
        }
        
        if(params.curViewId==null)
        {
            strColumnsAndFiltersTemplate = firstViewName;
            currTplColumns = firstViewColumns;
            params.curViewId = firstId;
        }
        
    }
    
    public void btnGo()
    {
        isNewView = false;
        loadViews();
    }
    
    public void fetchTemplateColumnAndFilterConditions()
    {
        strView = strColumnsAndFiltersTemplate;
    }
    public void deleteTemplateByname()
    {
        SL_View__c item2Delete = null;
        if(currMainCusSettings!=null)
        {
            for(SL_View__c item:[Select ID From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true) limit 1])
            {
                item2Delete = item;
            }
        }
        try
        {
        	if(item2Delete!=null){ delete item2Delete;}
        	this.params.curViewID = null;
        	btnGo();
        }
        catch(Exception ex)
        {
        	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''));
        }
    }
    public void lnkCreateNewView()
    {
        strView = strColumnsAndFiltersTemplate;
        isNewView = true;
        strColumnsAndFiltersTemplate = '';
    }
    public void saveSelectedColumns()
    {
        String colSaveVal = '';
        strView = '';
        if(selectedColumnsCallback!=null && selectedColumnsCallback!='')
        {
            map<string,string> mapFldName2FldLabel = new map<string,string>();
            for(SL_LIB16_ViewsParams.ColumnInfo item:params.columns){ mapFldName2FldLabel.put(item.name.toLowerCase(),item.label);}
            
            for(String item:selectedColumnsCallback.split(';'))
            {
                if(item!='' && mapFldName2FldLabel.containsKey(item)){ colSaveVal += ','+mapFldName2FldLabel.get(item);}
            }
        }
        if(colSaveVal!=''){ colSaveVal = colSaveVal.substring(1);}

        if(currMainCusSettings!=null)
        {
            SL_View__c viewItem2Insert = new SL_View__c(Name=strColumnsAndFiltersTemplate, RowsCount__c=20, Implementation__c=currMainCusSettings.ID, Implementation_Type__c='Search', User__c=UserInfo.getUserId());
            for(SL_View__c item:[Select RowsCount__c, Name, ID, Columns__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true) limit 1])
            {
                viewItem2Insert = item;
            }
            viewItem2Insert.Columns__c = colSaveVal;
            upsert viewItem2Insert;
            
            this.params.curViewID = viewItem2Insert.ID;
        }

        btnGo();
    }
    public void dummyFunction(){}
    public List<SelectOption> getUnselectedColumns()
    {
        List<SelectOption> res = new List<SelectOption>();
        set<String> setLabel = new set<string>();
        
        if(currMainCusSettings!=null)
        {
            for(SL_View__c template:[Select RowsCount__c, Name, ID, Columns__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true) limit 1])
            {
                if(template.Columns__c != null && template.Columns__c !='')
                {
                    setLabel.addAll(( template.Columns__c.replace('*',' ')).split(','));
                }
            }
        }
        //system.debug('UnselectedColumnsOrdered setLabel >>>>>>>>>>>>>> '+setLabel);
        //system.debug('params.columns >>>>>>>>>>>>>> '+params.columns);

        Set<String> setAlredyAdd = new Set<String>();
        if(params.columns!=null)
        {
            for (SL_LIB16_ViewsParams.ColumnInfo info : params.columns)
            {
                //system.debug('columns item: >>>>>>>>>>>>>> '+info);
                if (!setLabel.contains(info.label) && info.name!= null && info.label !=null && info.name!='' && !setAlredyAdd.contains(info.name.toLowerCase())) 
                {
                    res.add(new SelectOption(info.name, info.label));
                    setAlredyAdd.add(info.name.toLowerCase());
                }
            }
        }
        if(res == Null){ res.add(new SelectOption('', ''));}
        return res;
    }
    
    public List<SelectOption> getSelectColumnsOrdered()
    {
        List<SelectOption> res = new List<SelectOption>();
        List<String> setLabel = new List<string>();
        map<String,String> mapMassEditLabel2Name = new map<String,String>();
        if(currMainCusSettings!=null)
        {
        for(SL_View__c template:[Select RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c From SL_View__c  where Implementation__c=:currMainCusSettings.ID and Implementation_Type__c='Search' and Name =:strColumnsAndFiltersTemplate and (User__c=:UserInfo.getUserId() or IsDefault__c=true) limit 1])
        {
            if(template.Columns__c != null && template.Columns__c !='')
            {
                setLabel.addAll(( template.Columns__c.replace('*',' ')).split(','));
            }
        }
        }
        //system.debug('SelectColumnsOrdered setLabel >>>>>>>>>>>>>> '+setLabel);
        if(params.columns!=null)
        {
            for (SL_LIB16_ViewsParams.ColumnInfo item : params.columns){ mapMassEditLabel2Name.put(item.label, item.name);}
        }
        Set<String> setAlredyAdd = new Set<String>();
        for (String item : setLabel)
        {
            if(item!=null && item!='' && mapMassEditLabel2Name.containsKey(item) && mapMassEditLabel2Name.get(item)!=null 
                    && mapMassEditLabel2Name.get(item)!='' && !setAlredyAdd.contains(mapMassEditLabel2Name.get(item).toLowerCase()))
            {
                res.add(new SelectOption(mapMassEditLabel2Name.get(item), item)); //if (info.show)
                setAlredyAdd.add(mapMassEditLabel2Name.get(item).toLowerCase());
            }
        }
        return res;
    }
}