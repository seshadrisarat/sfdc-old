public with sharing class SL_LIB16_ViewsParams {
    public SL_Mass_Implementation__c currMainCusSettings {get; set;}
    public ID curViewID {get; set;}
    public List<SL_LIB16_ViewsParams.ColumnInfo> columns {get;set;}
    public String status {get; set;}
    public String rerenderId {get; set;}
    public String viewChangedJsTrigger {get; set;}
    
    public virtual class ColumnInfo
    {
        public String name {get; set;}
        public String styleName {get; set;}
        public String label {get; set;}
        public String sortExpression {get; set;}
        public Boolean show {get; set;}
        public Boolean isSortable {get; set;}
        public Boolean isEditable {get; set;}
        public Boolean allowMultiedit {get; set;}
        public Integer showOrder {get; set;}
        
        public ColumnInfo(String name, String sortE, String label, Boolean show){
            this.assignVals(name, sortE, label, show, true, true, true, '');
        }

        public ColumnInfo(String name, String sortE, String label, Boolean show, Boolean allowMulti, Boolean inIsSortable, Boolean inIsEditable, String inStyleName){
            this.assignVals(name, sortE, label, show, allowMulti, inIsSortable, inIsEditable, inStyleName);
        }
        
        public ColumnInfo(String name, String sortE, String label, Boolean show, Boolean allowMulti, Boolean inIsSortable, Boolean inIsEditable){
            this.assignVals(name, sortE, label, show, allowMulti, inIsSortable, inIsEditable, '');
        }
        
        public ColumnInfo(String name, String sortE, String label, Boolean show, Boolean allowMulti, Boolean inIsSortable){
            this.assignVals(name, sortE, label, show, allowMulti, inIsSortable, true, '');
        }
        
        public ColumnInfo(String name, String sortE, String label, Boolean show, Boolean allowMulti){
            this.assignVals(name, sortE, label, show, allowMulti, true, true, '');
        }
        
        public Boolean getIsEmpty(){
            return (label==null || label.trim().length()==0);
        }
        
        private void assignVals(String name, String sortE, String label, Boolean show, Boolean allowMulti, Boolean inIsSortable, Boolean inIsEditable, String inStyleName)
        {
            this.name = name;
            this.sortExpression = sortE;
            this.label = label;
            this.show = show;
            this.allowMultiedit = allowMulti;
            this.isSortable = inIsSortable;
            this.isEditable = inIsEditable;
            this.styleName = inStyleName;
        }
    }
}