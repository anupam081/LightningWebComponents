/*Einstein Intent API*/
Global class TrainDatasetResponse {

	webservice Integer datasetId;	//1001411
	webservice Integer datasetVersionId;	//0
	webservice String name;	//Weather Intent Model
	webservice String status;	//QUEUED
	webservice Decimal progress;	//0
	webservice String createdAt;	//2017-06-08T22:16:16.000+0000
	webservice String updatedAt;	//2017-06-08T22:16:16.000+0000
	webservice decimal learningRate;	//0.0
	webservice Integer epochs;	//0
	webservice Integer queuePosition;	//1
	//webservice String objects;	//training
	webservice String modelId;	//UCW5CHIJ7MXLZ7UYE5MO44TPPU
	webservice String trainParams;
	webservice cls_trainStats trainStats;
	webservice String modelType;	//text-intent
    
    global class cls_trainStats {
		webservice Integer labels;	//2
		webservice Integer examples;	//100
		webservice String totalTime;	//00:03:24:595
		webservice String transforms;
		webservice String trainingTime;	//00:03:19:607
		webservice boolean earlyStopping;
		webservice Integer lastEpochDone;	//33
		webservice String modelSaveTime;	//00:00:00:624
		webservice Integer testSplitSize;	//17
		webservice Integer trainSplitSize;	//83
		webservice String datasetLoadTime;	//00:00:04:987
		webservice String preProcessStats;
		webservice String postProcessStats;
	}

}