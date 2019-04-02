//Class to auto refresh the lightning component
public class AutoRefreshLigComponentClass {
	@AuraEnabled
    public static Integer getContactCount(String objName){
        String query = 'SELECT count(Id) totalCount FROM '+ objName;
         AggregateResult[] groupedResults = database.query(query);
		Object totalCount = groupedResults[0].get('totalCount');
        return (Integer) totalCount ;
    }
}