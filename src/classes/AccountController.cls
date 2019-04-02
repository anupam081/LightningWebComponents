public with sharing class AccountController {

    @AuraEnabled
    public static List<Account> findByParent(Id parentId) {
        //this is the testing for the vscode
        return [SELECT id, name, billingstreet, billingcity, billingstate, Location__Latitude__s, Location__Longitude__s, Picture_URL__c 
                FROM Account
                WHERE Id=:parentId OR ParentId=:parentId
                ORDER BY parentId, name
                LIMIT 50];
    }

}