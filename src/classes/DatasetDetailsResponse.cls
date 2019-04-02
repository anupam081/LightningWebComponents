/*Einstein Intent API*/
Global class DatasetDetailsResponse{
	webservice Long id;	//1001408
	webservice String name;	//weather
	webservice String createdAt;	//2017-06-05T20:33:56.000+0000
	webservice String updatedAt;	//2017-06-05T20:33:58.000+0000
	webservice cls_labelSummary labelSummary;
	webservice Integer totalExamples;	//73
	webservice Integer totalLabels;	//3
	webservice boolean available;
	webservice String statusMsg;	//SUCCEEDED
	webservice String type;	//text-intent
	//webservice String objects;	//dataset
	Global class cls_labelSummary {
		webservice list<cls_labels> labels;
	}
	Global class cls_labels {
		webservice Long id;	//13298
		webservice Long datasetId;	//1001408
		webservice String name;	//hourly-forecast
		webservice Integer numExamples;	//23
	}
	
}