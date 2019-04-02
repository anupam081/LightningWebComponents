declare module "@salesforce/apex/ExpenseController.getExpenses" {
  export default function getExpenses(): Promise<any>;
}
declare module "@salesforce/apex/ExpenseController.saveExpense" {
  export default function saveExpense(param: {expense: any}): Promise<any>;
}
