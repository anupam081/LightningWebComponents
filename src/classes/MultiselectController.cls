public with sharing class MultiselectController {
    
    @AuraEnabled
    public static List<Contact> getcontactDetails(){

        List<Contact> lstContact=[Select Id, Name From Contact limit 100];

        //SObjectType conType = Schema.getGlobalDescribe().get('Contact');
        //List<Schema.PicklistEntry> mfields = conType.getDescribe().fields.getMap().get('LeadSource').getDescribe().getPicklistValues();

        return lstContact;

    }

    @AuraEnabled
    public static List<String> getpicklistvaluess(String objName, String fldName){

        List<String> optList = new List<String>();
        System.debug(objName+', '+fldName);
        try{
            if(!string.isblank(objName) && !string.isblank(fldName)){                
                SObjectType conType = Schema.getGlobalDescribe().get(objName);
                List<Schema.PicklistEntry> mfields = new List<Schema.PicklistEntry>();
                mfields = conType.getDescribe().fields.getMap().get(fldName).getDescribe().getPicklistValues();
                System.debug(mfields);
                if(mfields != null){
                    for(Schema.PicklistEntry pe : mfields){
                        optList.add(pe.getValue());
                    }
                }
                System.debug(optList);
            }
        }catch(Exception ex){
             throw new AuraHandledException(ex.getMessage());
        }

        return optList;

    }
}