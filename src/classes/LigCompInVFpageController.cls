public with sharing class LigCompInVFpageController {
    public List<sObject> selectedLookUpRecords{get;set;}
    public String accName {get;set;}

    public LigCompInVFpageController(){
        selectedLookUpRecords = new List<sObject>();
    }


    public void saveaccount(){

        system.debug(selectedLookUpRecords);
        List<account> accList = (List<account>) selectedLookUpRecords;
    }

    public static void dynamicTypeCast(List<SObject> records)
    {
        Schema.SObjectType sObjectType = records.getSObjectType();
        if (sObjectType != null)
        {
            String listType = 'List<' + sObjectType + '>';
            List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
            castRecords.addAll(records);
            upsert castRecords;
        }
    }


}