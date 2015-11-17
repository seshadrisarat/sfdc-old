public with sharing class ComboLookupController {

public string javascriptCallBackFunctionParms { get;set ; }
public string javascriptCallBackFunctionParmsString { get {
if (javascriptCallBackFunctionParms!=null && javascriptCallBackFunctionParms!='')
    return ', ' + javascriptCallBackFunctionParms;
    else return '';
 } private set; }

public static testMethod void testMe(   )
      {
      ComboLookupController x = new ComboLookupController();
boolean b = true;//x.ClearBoxAfterSelect;
b=x.HighlightValueAfterSelection;
x.HighlightValueAfterSelection=true;
b=x.PostIDUponSelect;
x.PostIDUponSelect=true;
b=x.FilterRequiredItems;
x.FilterRequiredItems=true;
b=x.IncludeAddNewOption;
x.IncludeAddNewOption=true;

integer ix = x.ResultCount ;
x.ResultCount = ix;

ix = x.RowLimit;
x.RowLimit = ix;
string s = 'abc';


x.MenuTopPosition=s;
x.MenuLeftPosition=s;
x.MenuBackColor=s;
x.ReadOnlyBackgroundColor=s;
s =x.MenuTopPosition;
s =x.MenuLeftPosition;
s =x.MenuBackColor;
s =x.ReadOnlyBackgroundColor;

x.bCheckedRequiredItems = false;
x.bRequiredItemsExist = false;





x.PromptClassName=s;
s = x.PromptClassName;
x.TextClassName=s;
s = x.TextClassName;
x.ButtonClassName=s;
s = x.ButtonClassName;
x.ButtonHeight=s;
s = x.ButtonHeight;
x.OutputFields=s;
s = x.OutputFields;
x.SourceObject=s;
s = x.SourceObject;
x.AdditionalWhereClause=s;
s = x.AdditionalWhereClause;
x.URLLinkTo=s;
s = x.URLLinkTo;
x.FilterField=s;
s = x.FilterField;
x.OrderByField=s;
s = x.OrderByField;
x.UpdatedText=s;
s = x.UpdatedText;
x.UpdatedID=s;
//s = x.UpdatedID;
x.TextWidth=s;
s = x.TextWidth;
x.TextHeight=s;
s = x.TextHeight;
x.PromptWidth=s;
s = x.PromptWidth;
x.PromptTextAlign=s;
s = x.PromptTextAlign;
x.ButtonTextAlign=s;
s = x.ButtonTextAlign;
x.TextTextAlign=s;
s = x.TextTextAlign;
x.RequiredItems=s;
s = x.RequiredItems;
x.TipText=s;
s = x.TipText;
x.Text=s;
s = x.Text;
x.cluID=s;
s = x.cluID;
x.ActionType=s;
s = x.ActionType;
x.MinKeyStrokes=s;
s = x.MinKeyStrokes;
x.SelectedRow=s;
s = x.SelectedRow;
x.JavascriptCallbackFunction=s;
s = x.JavascriptCallbackFunction;
x.JavascriptCallbackFunctionParms=s;
s = x.JavascriptCallbackFunctionParms;
x.PasteSelectedIDToHTMLElement=s;
s = x.PasteSelectedIDToHTMLElement;
x.ObjectFieldToUpdateUponSelect='LongName__c';
s = x.ObjectFieldToUpdateUponSelect;
//string s2 = [select o.Id from Deal__c o limit 1].Id;
//x.ObjectIDToUpdateUponSelect=[select o.Id from Deal__c o limit 1].Id;//'a0U80000002TuaF'; 
s = x.ObjectIDToUpdateUponSelect;
x.ObjectTypeToUpdateUponSelect='Deal__c';
s = x.ObjectTypeToUpdateUponSelect;
x.AddNewFields=s;
s = x.AddNewFields;
x.sAddNewPrompt=s;
s = x.sAddNewPrompt;
x.AddNewPrompt=s;
s = x.AddNewPrompt;
x.AddNewDefaults=s;
s = x.AddNewDefaults;
//x.postUpdateWithParms(s2,'b');
//s = x.TipTextExpr;
//postUpdateWithParms(s2, 'abc123') ;

}

public List<ComboLookupResult> queryResult { get {        return queryResult; }  set { queryResult = value ; }}
public string PromptClassName { get; set; }
public string TextClassName { get; set; }
public string ButtonClassName { get; set; }

public string ButtonHeight { get ; set ; }
public integer ResultCount { get { return (queryResult==null?0:queryResult.size());} set; }
public string OutputFields { get; set; }
public string SourceObject { get; set; }
public string AdditionalWhereClause { get; set; }

public string URLLinkTo { get; set; }
public integer RowLimit { get; set; }

public string FilterField { get; set; }
public string OrderByField { get; set; }

private string sUpdatedText = '';
private string sUpdatedID = '';
public string UpdatedText { get { return sUpdatedText;} set ; }
public string UpdatedID{ get { return sUpdatedID;} set ; }
public string TextWidth { get; set ; }
public string TextHeight { get; set ; }
public string PromptWidth { get; set ; }

public string PromptTextAlign { get; set; }
public string ButtonTextAlign { get; set; }
public string TextTextAlign { get; set; }
public string RequiredItems { get; set; }

public string TipText { get ; set; }
public string TipTextVal { get { return TipText==null? '' : TipText==' ' ? '': TipText.trim() ;} set; }
private string sText = '';
public string Text { get { return sText; } set { sText = value;} }
public string cluID { get; set; }
public string ActionType { get; set; }
public string MinKeyStrokes { get; set; }
public string SelectedRow { get; set; }

public string JavascriptCallbackFunction { get; set; } 
public boolean HighlightValueAfterSelection { get; set; }
public string PasteSelectedIDToHTMLElement { get; set; }
public boolean EnforceNonNullAddValues { get; set; }
public string ObjectFieldToUpdateUponSelect { get; set; }
public string ObjectIDToUpdateUponSelect { get; set; }
public string ObjectTypeToUpdateUponSelect { get; set; }
public boolean PostIDUponSelect { get; set; }
public boolean FilterRequiredItems { get; set; }
public string AddNewFields { get; set; }
public boolean IncludeAddNewOption { get; set; }
public string sAddNewPrompt { get; set; }
public string AddNewPrompt { get { return sAddNewPrompt; } set  { sAddNewPrompt = value; }}
public string AddNewDefaults { get { if (AddNewDefaults == null || AddNewDefaults=='') return '#'; else return AddNewDefaults; } set; }
public PageReference postUpdate() {    
    string sIDToPostUponSelect = Apexpages.currentPage().getParameters().get('sIDToPostUponSelect');
    string sTextToPostUponSelect = Apexpages.currentPage().getParameters().get('sTextToPostUponSelect');
    return postUpdateWithParms(sIDToPostUponSelect,sTextToPostUponSelect);
    }

public PageReference postUpdateWithParms(string sIdToPost, string sTextToPost) {        
    try {
    string sIDToPostUponSelect = sIdToPost;//Apexpages.currentPage().getParameters().get('sIDToPostUponSelect');
    string sTextToPostUponSelect = sTextToPost;//Apexpages.currentPage().getParameters().get('sTextToPostUponSelect');
    string sDataToPostUponSelect = PostIDUponSelect == true ? sIDToPostUponSelect : sTextToPostUponSelect ;
    if (
        ObjectFieldToUpdateUponSelect  != null && ObjectFieldToUpdateUponSelect   != '' &&
        ObjectTypeToUpdateUponSelect  != null && ObjectTypeToUpdateUponSelect  != '' &&
        ObjectIDToUpdateUponSelect  != null && ObjectIDToUpdateUponSelect  != '')
        {
    String qryString = 'SELECT ' + ObjectFieldToUpdateUponSelect  + ' FROM ' + ObjectTypeToUpdateUponSelect  
        + ' WHERE ' + ObjectTypeToUpdateUponSelect + '.ID = \'' + String.escapeSingleQuotes(ObjectIDToUpdateUponSelect  ) + '\'';
      System.debug ('  #### postupdate: soql->' + qryString);
        sObject oUpd = Database.query(qryString);

        oUpd.put(ObjectFieldToUpdateUponSelect ,sDataToPostUponSelect );
        Database.SaveResult SR = database.update(oUpd);
        for(Database.Error err: SR.getErrors())
        {
            System.debug ('  ###### error updating ' + ObjectTypeToUpdateUponSelect  + ' id ' +  ObjectIDToUpdateUponSelect  + ' ' + err.getMessage() );
        }
        }
        
    Text = sTextToPostUponSelect ;
    sUpdatedText = sTextToPostUponSelect;
    sUpdatedID = sIDToPostUponSelect ;
    }
    catch (DmlException e)
    {
         System.debug ('  ###### exception updating ' + ObjectTypeToUpdateUponSelect  + ' id ' +  ObjectIDToUpdateUponSelect + ' ' + e.getMessage()  );
            sUpdatedText = 'ERROR';
            sUpdatedID = 'ERROR' ;
    }
    return null;
}

public string MenuTopPosition { get { 
    string sMenuLocationTop = Apexpages.currentPage().getParameters().get('sQueryMenuLocationTop');
    if (sMenuLocationTop!=null && sMenuLocationTop!='')
        return sMenuLocationTop; 
     else
        return '100';
    } private set; }

public string MenuLeftPosition{ get { 
    string sMenuLocationLeft = Apexpages.currentPage().getParameters().get('sQueryMenuLocationLeft');
    if (sMenuLocationLeft!=null && sMenuLocationLeft!='')
        return sMenuLocationLeft; 
     else
        return '100';
    } private set; }
public string MenuBackColor { get { return '#DCDCDC'; } private set; }
public string ReadOnlyBackgroundColor { get { return '#E5E5E5'; } private set; }
static private List<string> lstOne = new List<string>{'a'};
public List<string> ListOfOne { get { return lstOne; } private set; }
private static List<ComboLookupResult> RequiredItemValues = new List<ComboLookupResult>();
private boolean bCheckedRequiredItems = false;
private boolean bRequiredItemsExist = false;


    }