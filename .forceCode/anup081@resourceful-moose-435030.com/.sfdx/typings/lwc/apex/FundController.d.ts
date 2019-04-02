declare module "@salesforce/apex/FundController.getFunds" {
  export default function getFunds(param: {filters: any, pageSize: any, pageNumber: any}): Promise<any>;
}
declare module "@salesforce/apex/FundController.getAssetClasses" {
  export default function getAssetClasses(): Promise<any>;
}
declare module "@salesforce/apex/FundController.getSectors" {
  export default function getSectors(): Promise<any>;
}
