import { LightningElement, track } from 'lwc';

 
export default class simpleCalculator extends LightningElement {
    @track firstNumber;
    @track secondNumber;
    @track currentResult;
    @track operatorUsed;

    /**
   * This method will be called when either first number or second number is changed
   * Accordingly it will set the firstNumber or secondNumber property in javascript
   * @author Manish Choudhari
   * @param {} event 
   */
  onNumberChange(event) {
    //Getting input field name
    const inputFieldName = event.target.name;
    if (inputFieldName === "firstName") {
      //value of first number has changed, modifying the property value
      this.firstNumber = event.target.value;
    } else if(inputFieldName === "secondName") {
      //value of second number has changed, modifying the property value
      this.secondNumber = event.target.value;
    }
  }

  /**
   * This method will be called when add button is clicked
   * @author Manish Choudhari
   */
  onAdd() {
    this.currentResult = parseInt(this.firstNumber) + parseInt(this.secondNumber);
    this.operatorUsed = '+';
    //Check if both numbers are okay and operable 
  }
  
  /**
   * This method will be called when subtract button is clicked
   * @author Manish Choudhari
   */
  onSub() {
    this.currentResult = parseInt(this.firstNumber) - parseInt(this.secondNumber);
    this.operatorUsed = '-';
    //Check if both numbers are okay and operable 
  }
  /**
   * This method will be called when multiply button is clicked
   * @author Manish Choudhari
   */
  onMultiply() {
    this.currentResult = parseInt(this.firstNumber) * parseInt(this.secondNumber);
    this.operatorUsed = '*';
    //Check if both numbers are okay and operable 
  }
  /**
   * This method will be called when divide button is clicked
   * @author Manish Choudhari
   */
  onDivide() {
    this.currentResult = parseInt(this.firstNumber) / parseInt(this.secondNumber);
    this.operatorUsed = '%';
    //Check if both numbers are okay and operable 
  }


  /**
   * Property getter
   * This method will automatically be automatically called when currentResult value
   * is changed. This getter method can be easily accessed in template using {result}
   * @author Manish Choudhari
   */
  get result() {
    
    if(this.currentResult === 0 || this.currentResult){
      return `Result of ${this.firstNumber} ${this.operatorUsed} ${this.secondNumber} is ${this.currentResult}`;
    // eslint-disable-next-line no-else-return
    } 
  }
}