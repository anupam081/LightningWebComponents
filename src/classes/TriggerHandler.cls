/*Common trigger handler for all trigger for Rule object*/

public class TriggerHandler implements ITriggerHandler{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled()
    {
        return TriggerDisabled;
    }
 
    public void BeforeInsert(List<SObject> newItems) 
    {
        
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        // call trigger utils method
        TriggerUtils tu = new TriggerUtils();
          //call method to get total
        tu.SUM(newItems.values());
        //call method to get average
        tu.AVG(newItems.values());
        //call method to get mininmum value
        tu.MIN(newItems.values());
        //call method to get maximum value
        tu.MAX(newItems.values());
        //call method to get count
        tu.COUNT(newItems.values());
        
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        // call trigger utils method
        TriggerUtils tu = new TriggerUtils();
        //call method to get total
        tu.SUM(newItems.values());
        //call method to get average
        tu.AVG(newItems.values());
        //call method to get mininmum value
        tu.MIN(newItems.values());
        //call method to get maximum value
        tu.MAX(newItems.values());
        //call method to get count
        tu.COUNT(newItems.values());
        
    }
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}

}