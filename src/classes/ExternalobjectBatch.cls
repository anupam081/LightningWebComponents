global class ExternalobjectBatch implements Database.Batchable<sObject>{

    global ExternalobjectBatch(){
        System.debug('### ExternalobjectBatch()');
    }
/*
    global Iterable<SObject> start(Database.BatchableContext BC){
       System.debug('### ExternalobjectBatch start()');
        return [select Id from DEV_Innovation__OrderDetails__x order by id];
   }
*/
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('### ExternalobjectBatch start()');
        return Database.getQueryLocator('select Id from DEV_Innovation__OrderDetails__x order by id');
    }
	

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        DEV_Innovation__OrderDetails__x product1 = (DEV_Innovation__OrderDetails__x)scope.get(0);
        System.debug('### ExternalobjectBatch length: ' + scope.size() + ' id: '+product1.id);
    }

    global void finish(Database.BatchableContext BC){
        System.debug('### ExternalobjectBatch: finish() called');
    }
}