public with sharing class AccountPagination 
{
 @AuraEnabled
    public static List<Case> getAccounts()
    {
        return [SELECT Id, subject,priority,status,CaseNumber FROM Case];
    }
}