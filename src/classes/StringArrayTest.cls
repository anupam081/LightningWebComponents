public class StringArrayTest {
public static list<string> generateStringArray(integer n)
{
    list<string> testList = new list<string>();
    for(integer i=0;i<n;i++)
        testList.add('test'+i);
    system.debug(testList);
    return testList;
}
    
}