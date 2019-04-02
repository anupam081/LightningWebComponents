//anupam081
//controller for autocomplete search for account name

public with sharing class AutoCompleteController {
    @AuraEnabled
    public static List<sObject> fetchValues(String searchKeyWord, String objectName, List<sObject> excludeitemsList) {
        String searchKey = '%' + searchKeyWord + '%';              
        
        // Dynamic SOQL Query   
        String sQuery =  'select id, Name from ' +objectName;
        sQuery += ' where Name LIKE: searchKey AND Id NOT IN : excludeitemsList order by createdDate DESC limit 5';
        List<sObject> lstOfRecords = new List<sObject>();
        lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery));             
        
        return lstOfRecords;
    }
}