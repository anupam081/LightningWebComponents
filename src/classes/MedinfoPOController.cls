public class MedinfoPOController{

    public List<MedDocument__c> Records {get; set;}
    
     public Id MoreRecordId {get; set; } 

    public MedDocument__c MoreRecord {get; set;}

    //constructor
    public MedinfoPOController(){
        Records = [Select id, Name,Document_Title__c, 
                    (Select Id, name, LastModifiedDate 
                     From Attachments 
                     Order By LastModifiedDate DESC) 
                 From MedDocument__c];
    }
    
    //show more method
    public PageReference showMore()
    {
        MoreRecord = new Map<Id, MedDocument__c>(Records).get(MoreRecordId);
        return null;
    }

}