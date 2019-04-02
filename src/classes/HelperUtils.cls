/**
 * @Description : Class to hold all helper methods *
 * @author Anupam Tripathi
 * @since 05.02.2018 (dd.MM.yyyy)
 *
 */

public with sharing class HelperUtils{
	/**
    * Helper method to generate random string
	* @since 05.02.2018 (dd.MM.yyyy)
	* @param : length of random string
    */
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
     /**
        * @description : To deduce the query for all the fields for a specific object
        * @param1      : Object Name
        * @return      : Query with all the fields
    */
    private String getQueryForObject(String objectName){
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
        
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        
        return commaSepratedFields;
        
    }

    /**
    * @description : To get all picklist values for a field on the object
    * @param1      : Object api Name
    * @param1      : picklist field api name
    * @return      : Query with all the fields
*/        
   public static List<String> getPickListValuesIntoList(String objectType, String selectedField){
    List<String> pickListValuesList = new List<String>();
    Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
    Schema.DescribeSObjectResult res = convertToObj.getDescribe();
    Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry pickListVal : ple){
        pickListValuesList.add(pickListVal.getLabel());
    }     
    return pickListValuesList;
   }

       /**
    * @description : Generic method to query object with all field and criteria
    * @param1      : Object api Name
    * @param1      : List of field API name
    * @param1      : Filter criteria
    * @param1      : sortable fields
    * @param1      : sort order
    * @return      : Query with all the fields
    */        
    public static List<sObject> queryObjects(String theObject, List<String> theFields, String theFilter, String sortField, String sortOrder) {
        String theQuery = 'SELECT ' + string.join(theFields, ',');
        theQuery += ' FROM ' + theObject;
        if(!String.isEmpty(theFilter)) {
            theQuery += ' WHERE ' + theFilter;
        }
        if(!String.isEmpty(sortField)) {
            theQuery += ' ORDER BY ' + sortField;
            if(!String.isEmpty(sortOrder)) {
                theQuery += ' ' + sortOrder;
            }
        }
        return database.query(theQuery);
    }
    



}