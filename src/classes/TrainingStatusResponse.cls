/*Einstein Intent API*/
global class TrainingStatusResponse {
    
    webservice Integer datasetId;	//1001511
	webservice Integer datasetVersionId;	//1073
	webservice String name;	//Weather Intent Model
	webservice String status;	//SUCCEEDED
	webservice Integer progress;	//1
	webservice String createdAt;	//2017-06-09T19:05:37.000+0000
	webservice String updatedAt;	//2017-06-09T19:07:31.000+0000
	webservice Integer learningRate;	//0
	webservice Integer epochs;	//300
	//webservice String objects;	//training
	webservice String modelId;	//TUWBAIRLFB3KKEDZMEGIUR6COM
	webservice String trainParams;
	webservice cls_trainStats trainStats;
	webservice String modelType;	//text-intent
	
	global class cls_trainStats {
		webservice Integer labels;	//3
		webservice Integer examples;	//73
		webservice String totalTime;	//00:01:51:120
		webservice String trainingTime;	//00:01:49:959
		webservice boolean earlyStopping;
		webservice Integer lastEpochDone;	//186
		webservice String modelSaveTime;	//00:00:00:618
		webservice Integer testSplitSize;	//11
		webservice Integer trainSplitSize;	//62
		webservice String datasetLoadTime;	//00:00:01:161
	}
	

}