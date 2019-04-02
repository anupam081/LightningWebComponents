/*
 * Utility method to update the FLS for the fields on a specific object
 * Created By : Anupam Mani Tripathi
 * Date : 20th Sept 17
 * */

public class UpdateFLSonProfiles {
    
    public static void updateFlsonFields(Set<String> sObjectNames, Boolean onlyRead, Set<String> profileNames){
        //List<Profile> allProfiles = [select id, name from Profile];
        
        List<FieldPermissions> fieldstoUpdate = new List<FieldPermissions>() ;
        
        for(FieldPermissions fp : [SELECT Id, Field, SObjectType, PermissionsRead, PermissionsEdit 
                                   FROM FieldPermissions WHERE parentid in 
                                   (select id from permissionset where PermissionSet.Profile.Name in : profileNames /*= 'System Administrator'*/) 
                                   and SObjectType in :sObjectNames]){
                                       
                                       FieldPermissions fs = new FieldPermissions(id = fp.id);                                       
                                       fs.PermissionsRead = onlyRead;                                           
                                       fieldstoUpdate.add(fs);
       }
        
        if(fieldstoUpdate.size() > 0){
            try{
                update fieldstoUpdate;
            }catch(Exception e){
                System.debug('The Exception occured is '+e.getMessage());
            }
            
        }
        
    }
    
}