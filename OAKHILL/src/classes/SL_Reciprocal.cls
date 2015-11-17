/**
 
* \author Volodymyr Babin
 
* \date 08/20/2014
 
* \see http://silverline.jira.com/browse/LIB-227
 
* \brief Handles reciprocal triggers logic.
 
* \test SL_Test_Reciprocal - doesn't provide functionality test, only covers the lines, as much as possible.
 
*/
public without sharing class SL_Reciprocal {
    // Object relations fields
    private String objAType;
    private String objBType;
    private String objAIdField; // Refference to the object A from affiliation
    private String objBIdField; // Refference to the object B from affiliation
    
    // Joiner relations fields
    private String joinerType;  // Joiner object name
    private String joinerRefField;  // Joiner objects refference field
    
    private String joinerSameFieldsSet; // Set of fields values of which should be equal for the two joiner objects of a single affiliation.
    
    private String joinerInverse;   // A field on inverse object which acts as a inverse pair to Name field.
    private String joinerInvObjName; // An object which holds inverse values, Name-inverse__c pairs.
    private Map<String, String> inverse; // Map which holds inverse values.
    
    private String joinerRefFieldText; // Makes the proper undelete possible. Textual information of joinerRefField.
    
    /**
    * CONSTRUCTOR - full constractor.
     */
    public SL_Reciprocal (String AIdField, String BIdField, String jRefField, String jType, String jFieldsSet, String jInv, String jInvObj, String jRefFieldText) {
        this.objAIdField = AIdField;
        this.objBIdField = BIdField;
        this.joinerRefField = jRefField;
        this.joinerType = jType;
        this.joinerSameFieldsSet = jFieldsSet;
        this.joinerInverse = jInv;
        this.joinerInvObjName = jInvObj;
        this.joinerRefFieldText = jRefFieldText;
    }
    
    public SL_Reciprocal (String AIdField, String BIdField, String jRefField) {
        this(AIdField, BIdField, jRefField, '', '', '', '', null);
    }
    
    public SL_Reciprocal (String AIdField, String BIdField, String jRefField, String jType, String jFieldsSet) {
        this(AIdField, BIdField, jRefField, jType, jFieldsSet, '', '', null);
    }
    
    public SL_Reciprocal (String AIdField, String BIdField, String jRefField, String jType, String jFieldsSet, String jInv, String jInvObj) {
        this(AIdField, BIdField, jRefField, jType, jFieldsSet, jInv, jInvObj, null);
    }
    
    /**
    * Creates a reverse affiliation object to the one given.
     */
    private SObject createNewObject(SObject newSo){
        SObject so = newSo.getSObjectType().newSObject();
        so.put(objAIdField, newSo.get(objBIdField));
        so.put(objBIdField, newSo.get(objAIdField));
        so.put(joinerRefField, newSo.get('id'));
        so.put('id', newSo.get(joinerRefField));
        if(inverse!=null){
            so.put(joinerInverse, inverse.get((String)newSo.get(joinerInverse)));
        }
        if(joinerSameFieldsSet!=null && joinerSameFieldsSet!=''){
            List<Schema.FieldSetMember> sameFields =  SL_GenUtils.getFieldSetFlds(joinerSameFieldsSet, joinerType);
            for(Schema.FieldSetMember f : sameFields){
                so.put(f.getFieldPath(), newSo.get(f.getFieldPath()));
            }
        }
        return so;
    }
    
    public void OnAfterInsert(map<ID,SObject> newMap){
        if(isInverse()){fillInverseMap(newMap);}
        List<SObject> updateList = new List<SObject>();
        List<SObject> insertList = new List<SObject>();
        for(SObject newSo: newMap.values()){
            SObject so = createNewObject(newSo);
            if(joinerRefFieldText!=null){
                so.put(joinerRefFieldText, so.get(joinerRefField));
            }
            if(newSo.get(joinerRefField)==null){
                insertList.add(so);
            } else {
                updateList.add(so);
            }
        }
        if(!insertList.isEmpty()){
            Database.insert(insertList, false);
        }
        if(!updateList.isEmpty()){
            Database.update(updateList, false);
        }
    }
    
    public void OnAfterUpdate(map<ID,SObject> oldMap, map<ID,SObject> newMap){
        List<SObject> updateList = new List<SObject>();
        if(isInverse()){fillInverseMap(newMap);}
        for (SObject newSo: newMap.values()){
            // Check if inverse field has changed
            if(isInverse()){
                if(newSo.get(joinerInverse) != oldMap.get(newSo.Id).get(joinerInverse)){
                    updateList.add(createNewObject(newSo));
                    continue;
                }
            }
            
            // Check if same fields are changed
            if(joinerSameFieldsSet!=null && joinerSameFieldsSet!=''){
                List<Schema.FieldSetMember> sameFields =  SL_GenUtils.getFieldSetFlds(joinerSameFieldsSet, joinerType);
                boolean isContinue = false;
                for(Schema.FieldSetMember f : sameFields){
                    if(oldMap.get(newSo.Id).get(f.getFieldPath())!=newSo.get(f.getFieldPath())){
                        updateList.add(createNewObject(newSo));
                        isContinue = true;
                        break;
                    }
                }
                if(isContinue) continue;
            }
        }
        if(!updateList.isEmpty()){
            Database.update(updateList, false);
        }
    }

    public void OnAfterUnDelete(map<ID,SObject> newMap){
        if(joinerRefFieldText!=null){
            List<ID> ids = new List<ID>();
            Set<ID> restoredIds = newMap.keySet();
            for(SObject item : newMap.values()){
                ids.add((ID)item.get(joinerRefFieldText));
            }
            if(!ids.isEmpty()){
                Database.emptyRecycleBin(ids);
            }
        }
        OnAfterInsert(newMap);
    }
    
    // Delete all related affiliations
    public void OnAfterDelete(map<ID,SObject> oldMap){
        Set<ID> ids = new Set<ID>();
        for(SObject item : oldMap.values()){
            ids.add((ID)item.get(joinerRefField));
        }
        if(ids.size()>0){
            Database.delete(Database.query('select id from ' + oldMap.values().getSObjectType() + ' where id=:ids'), false);
        }
    }
    
    /**
    * Fills the inverse map, returns true if success, false if failed to fill the map.
     */
    private boolean fillInverseMap(map<ID,SObject> objMap){
        inverse = new Map<String, String>();
        if(joinerInverse!=null && joinerInverse!=''){
            List<String> iVals = new List<String>();
            for(SObject item: objMap.values()){
                iVals.add((String)item.get(joinerInverse));
            }
            try{
            	List<SObject> inv = Database.query('SELECT name, inverse__c from ' + joinerInvObjName + ' where name=:iVals OR inverse__c=:iVals');
                for(SObject i: inv){
                    inverse.put((String)i.get('name'), (String)i.get('inverse__c'));
                    inverse.put((String)i.get('inverse__c'), (String)i.get('name'));
                }
            } catch (Exception ex){
                System.debug('ERROR while filling the inverse map: ' + ex.getMessage());
                inverse = null;
                return false;
            }
        }
        return true;
    }
    
    /**
    * Return 'true' if the inverse information is given correctly.
     */
    private boolean isInverse(){
        return joinerInverse!=null && joinerInverse!='' && joinerInvObjName!=null && joinerInvObjName!='';
    }
    
}