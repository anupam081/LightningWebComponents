/*Trigger utils class to hold all common methods*/
public class TriggerUtils {

    //Method to add
    public void SUM(List<SObject> items){
        
        //method variables
        String objectType = '';
		String parentObjType = '';
		String childObjField = '';
        String childObject = '';
        String parentField = '';
        List<SObject> updateList;        
        Map<Id, Integer> calculationMap;

        //Fetch details from Rule object
        if(items.size() > 0){
            //get sobject type
            objectType = fetchSobjectType(items[0]);
            
            //fetch record from Rule object
            List<DEV_Innovation__Rule_Object__c> ruleObjList = getRules(objectType, 'SUM');
			
			//iterate and fetch relevant information
            if(ruleObjList != null && ruleObjList.size() > 0){
				parentObjType = ruleObjList[0].DEV_Innovation__Parent_Object__c;	
				childObjField = ruleObjList[0].DEV_Innovation__Child_Formula_Field__c;	
                childObject = ruleObjList[0].DEV_Innovation__Child_Object__c;
                parentField = ruleObjList[0].DEV_Innovation__Parent_Object_Field__c;
				
				if(parentObjType.contains('__c')){
					parentObjType = parentObjType.replace('__c', '__r');
				}
				
			}	
			
			//Get all parent id in set			
            System.debug('parentObjType == '+parentObjType);
			Set<ID> idSet = new Set<ID>();
            
            //fetch parent relationship field name
            String parentRelField = fetchParentRelFieldName(childObject, parentObjType);
            System.debug('parentRelField == '+parentRelField);            
            
			for(SObject s : items){              
                idSet.add((ID)s.get(parentRelField));
                
                /* 
                if(parentObjType == 'Account'){
					idSet.add((ID)s.get('AccountId'));
                }
                else{
                    idSet.add((ID)s.getSobject(parentObjType).get('ID')); 
                }
				*/
			}
			
            if(parentRelField.contains('__c')){
					parentRelField = parentRelField.replace('__c', '__r');
			}
            
            //Build query to fetch all child records
			String dynaQuery = 'select id ,' +childObjField +', '+parentRelField;
            if(parentRelField.contains('__r')){
            	dynaQuery += '.id from ' + childObject + ' where '+ parentRelField +'.id in:idSet';
            }else{                
                dynaQuery += ' from ' + childObject + ' where '+ parentRelField +' in:idSet';
            }
            
            System.debug('dynaQuery == '+dynaQuery);
			
            //Perform calculation for SUM
			calculationMap = new Map<Id, Integer>();			
			Integer i = 0;            
            for(SObject ss : database.query(dynaQuery)){
                Decimal dc = (Decimal)ss.get(childObjField);
                i = i + dc.intValue(); 
				if(parentRelField.contains('__r')){ 
                	calculationMap.put((ID)ss.getSobject(parentRelField).get('ID'), i);
                }else{
                    calculationMap.put((ID)ss.get(parentRelField), i);
                }
								
			}
            
        //populate list to update
            updateList = new List<SObject>();
        	for(ID recId : calculationMap.keySet()){
                SObjectType objType  = Schema.getGlobalDescribe().get(parentObjType);
                SObject obj = objType.newSObject();
                obj.put('ID', recId);
                obj.put(parentField, calculationMap.get(recId));
                updateList.add(obj);
        	}
        }
        
        
        // update the list
        try{
            if(updateList.size() > 0){
            	update updateList;
            }
        }catch(Exception e){
            System.debug('Exception occured in SUM Method is : ='+e.getMessage());
        }   
		
        
        
    }
    
    //Method to average
    public void AVG(List<SObject> items){
        
    }
    
    //Method to fetch minimum
    public void MIN(List<SObject> items){
        
    }
    
    //Method to fetch maximum
    public void MAX(List<SObject> items){
        
    }
    
    //Method to get count
    public void COUNT(List<SObject> items){
        
    }
    
    //Method to get Sobjectype
    private String fetchSobjectType(Sobject s){
        return s.getSObjectType().getDescribe().getName();
    }
    
    //Method to get rule object record
    private List<DEV_Innovation__Rule_Object__c> getRules(String objName, String calculate){
        
        List<DEV_Innovation__Rule_Object__c> ruleObjList = [select id, DEV_Innovation__Parent_Object__c,
																DEV_Innovation__Parent_Object_Field__c,
																DEV_Innovation__Child_Object__c,
																DEV_Innovation__Child_Formula_Field__c,
																DEV_Innovation__Calculation_Type__c from DEV_Innovation__Rule_Object__c
																where DEV_Innovation__Calculation_Type__c =: calculate and 
																DEV_Innovation__Child_Object__c =:objName];
        return ruleObjList;
    }
    
    //get relationship field name {Ex : accountid field on contact}
    private String fetchParentRelFieldName(String childSobject_type, String parentSobjectType){
            
        Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> object_fields_map = global_describe.get(childSobject_type).getDescribe().fields.getMap();
        System.debug(object_fields_map);
        for(Schema.SObjectField strFld: object_fields_map.values()){
            
            if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE &&
              strFld.getDescribe().getSObjectField().getDescribe().getName().containsIgnoreCase(parentSobjectType))
            {
                return (String)strFld.getDescribe().getSObjectField().getDescribe().getName();
                system.debug('==parent object='+strFld.getDescribe().getSObjectField());
            }     
		}	
        return null;
    }
    
    //check if passed object is valid or not?
    public SObjectType validSobject(String objName)
    {
        SObjectType ss = Schema.getGlobalDescribe().get(objName);
        return ss;
    }
    
    //check if passed field Name is valid or not?
    public Schema.SObjectField validSobjectField(String objName, String field)
    {
        Schema.SObjectField ss = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(field);
        return ss;
    }
    
     //check if framework trigger already created on SObject or not ?
    public Boolean isTriggerExist(String objName)
    {
        List<ApexTrigger> trgList = [select name, Body, TableEnumOrId from ApexTrigger where TableEnumOrId =:objName];
        if(trgList != null && trgList.size() > 0){
            for(ApexTrigger tr : trgList){
                if(tr.body.contains('Framework')){
                    return true;
                }                
            }            
        }
        return false;
    }
}