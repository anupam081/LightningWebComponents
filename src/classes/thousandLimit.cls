public class thousandLimit
{
    private limitWrapper[] thousandBlocks = new limitWrapper[]{};
    
    private final integer listLimit;
    
    public thousandLimit()
    {
        listLimit = 999;
    }
    
    public limitWrapper[] getthousandBlocks()
    {
        thousandBlocks = new limitWrapper[]{};
        
        integer counter = 0;
        integer loopCount = 0;
        case[] tmpcase = new case[]{};
        
        for(case c:[select CaseNumber,owner.name,subject,Priority from Case
                 	order by owner.name])
        {
            if(counter < listLimit)
            {
                tmpcase.add(c);
                counter++;
            }
            else
            {
                loopCount++;
                thousandBlocks.add(new limitWrapper(tmpcase,loopCount));
                tmpcase = new case[]{};
                tmpcase.add(c);
                counter = 0;
            }            
        }
        
        if(thousandBlocks.size() == 0)
        {
            loopCount++;
            thousandBlocks.add(new limitWrapper(tmpcase,loopCount));
        }
        
        return thousandBlocks;
    }
    
    public class limitWrapper
    {
        public case [] cases {get;set;}
        public integer blockNumber {get;set;}
        public limitWrapper(case[] accs, integer i)
        {
            cases = accs;
            blockNumber = i;
        }
        
    }
}