/*
 * Utility method to update the FLS on the profile for the fields on a specific object 
 * Created By : Anupam Mani Tripathi
 * Date : 20th Sept 17
 * Update By : Nishant Bansal
 * Date : 21st Sept 17
 * 
 * Script to run this utility
 * //Note: Size of profNameSet * Size of allFieldNamesSet, should not be greater than 4999
	
	Set<String> profNameSet = new Set<String>{'Business Development Managers','Contract Manager','IT Technical Support','LCM Sales','LCM Service','Marketing User','Plan Installation','Premier Support User','Read Only','Service ID-Base Profile','Shared Services','Small/Mid Corporate Sales','Small/Mid Corporate Service','Solution Manager','Stable Value','Standard User','StarsService','STARS Service','System Administrator','System Power User - IT','TEM - Back Office Administrators','TEM - Divisional','TempStarsService','Temp-Webworks','TPA'};
	
	//Approx 200 Fields Can go at once
	Set<String> allFieldNamesSet = new Set<String>{'isApproved__c','Market__c','Merrill_Shipping_Code__c','Number_Of_Service_Team_Members__c','Opportunity_Amount__c','Opportunity_CloseDate__c','Opportunity_Id__c','Opportunity_Name__c','Opportunity_Owner__c','Opportunity_StageName__c','Plan_Highlight_Output__c','Plan_Highlight_Version__c','Product__c','Quote__c','Requestor__c','Requestor_City__c','Requestor_First_Name__c','Requestor_Last_Name__c','Requestor_Phone__c','Requestor_Postal_Code__c','Requestor_State__c','Requestor_Street__c','Shipping_City__c','Shipping_Postal_Code__c','Shipping_Recipient__c','Shipping_Recipient_Email__c','Shipping_Recipient_Phone__c','Shipping_State__c','Shipping_Street__c','Ship_Via__c'};	
	
	String objectName = 'Plan_Highlights_Request__c';
	
	setFLStoAllFields setFLS = new setFLStoAllFields(objectName, profNameSet, allFieldNamesSet);
 * */

public class setFLStoAllFields{
	
    public Map<String,FieldPermissions> existingFieldMap;
	public Set<String> allFieldSetWithObjName;
	public Set<String> allFieldNameSet;
	public String objName;
	public Set<String> permissionSetId;
	public Set<String> profileNames;
	public List<FieldPermissions> fieldstoUpdateList;
	
    public setFLStoAllFields(String objNameStr, Set<String> profileNameSet, Set<String> allFieldNamesSet){
		
		try{
			//Populate variable with objects and profiles
			objName = objNameStr; //'Quote';
			profileNames = profileNameSet; //new Set<String>{'System Administrator'}; 
			allFieldNameSet = allFieldNamesSet;
			//List of new/updated permissions
			fieldstoUpdateList = new List<FieldPermissions>();
			
			permissionSetId = new Set<String>();
			
			//Maps to hold the existing fields permission per object
			existingFieldMap = new Map<String,FieldPermissions>();

			//Set to hold all the fields per object
			allFieldSetWithObjName = new Set<String>();
			
			//Set to hold all read only fields per object
			//allReadOnlyFieldSet = new Set<String>();
			
			getObjectFields();
			getExistingPermissionRec();
			
			//Iterating Each Field
			for(String eachField : new List<String>(allFieldSetWithObjName)){
				System.debug('eachField###'+eachField);
				Set<String> eachFieldPsIDs = new Set<String>();
				//Iterating Each PermissionSetId Per Field
				for(String eachPSID : new List<String>(permissionSetId)){
					FieldPermissions fp;
					if(existingFieldMap != null && existingFieldMap.size() > 0 && existingFieldMap.containsKey(eachField+'###'+eachPSID) && existingFieldMap.get(eachField+'###'+eachPSID) != null){
						
						//Fetching exising Permission record Per Field Per PermissionSetID
						System.debug('eachField###'+eachField);
						System.debug('eachPSID###'+eachPSID);
						fp = existingFieldMap.get(eachField+'###'+eachPSID);
						fp.PermissionsRead = true;
						fieldstoUpdateList.add(fp);

					}else{
						//Creating New Permission record Per Field Per PermissionSetID
						System.debug('eachField###'+eachField);
						System.debug('eachPSID###'+eachPSID);
						fp = new FieldPermissions();
						fp.ParentId = eachPSID;
						fp.PermissionsRead = true;
						fp.PermissionsEdit = false;
						fp.SObjectType = objName;
						fp.Field = eachField;
						fieldstoUpdateList.add(fp);
					}
				}
			}
			
			System.debug('Upsert###'+fieldstoUpdateList);
			
			Database.UpsertResult[] srList = Database.upsert(fieldstoUpdateList, false);
			
			System.debug('Upserted###'+fieldstoUpdateList);
			
			fieldstoUpdateList.clear();
			
			for (Database.UpsertResult sr : srList) {
				if (sr.isSuccess()) {
					// Operation was successful, so get the ID of the record that was processed
					FieldPermissions fp = new FieldPermissions();
					fp.Id = sr.getId();
					fp.PermissionsEdit = true;
					fieldstoUpdateList.add(fp);
				}
			}
			System.debug('Update###'+fieldstoUpdateList);
			Database.SaveResult[] srUpdateList = Database.update(fieldstoUpdateList, false);
			System.debug('Updated###'+fieldstoUpdateList);
		}catch(Exception e){
			System.debug('The Exception occured is '+e.getMessage());
		}
	}
	
	//Method to Fetch existing Permissions for Object's Fields
    public void getExistingPermissionRec()
    {
		//Querying all Standard Permission Sets for All Specified Profiles
		for(permissionset eachPermissionSet : [select Id from permissionset where PermissionSet.Profile.Name in : profileNames]){
			if(!permissionSetId.contains(eachPermissionSet.Id))
			permissionSetId.add(eachPermissionSet.Id);
		}
		
		//Query all field permission for passed sobject and profiles, existing in Permission set
		for(FieldPermissions fp : [SELECT Id, Field, SObjectType, PermissionsRead, PermissionsEdit, ParentId 
								   FROM FieldPermissions WHERE parentid in :permissionSetId
								   and SObjectType =:objName and Field in :allFieldSetWithObjName]){
									system.debug('fp###'+fp);
									String field = fp.Field;
									field = field.toLowerCase();
									
									if(!existingFieldMap.containsKey(field+'###'+fp.ParentId)){
										existingFieldMap.put(field+'###'+fp.ParentId, fp);
									}
		}
	}
	
	//Method to Fetch Object's Field and prepare FieldMap
    public void getObjectFields()
    { 
		
		//Fetching Schema Map
		//Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		
		//Fetching Field Map for Particular Object
		//Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objName).getDescribe().fields.getMap();
		
		//Adding fields to query
		//for(String fieldName : fieldMap.keyset()){
		for(String fieldName : allFieldNameSet){
			String field = objName+'.'+fieldName;
			field = field.toLowerCase();
			allFieldSetWithObjName.add(field);
		}
		system.debug('allFieldSetWithObjName###'+allFieldSetWithObjName);
    }
}