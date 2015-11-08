package nl.mse.test;

import nl.mse.complexity.ComplexMethod;

public class MyTestFile extends BaseTestCase {
	
	private ComplexMethod instance = new ComplexMethod();
	
	public void testFooNullInput() {
		String in = "a";
		instance.foo(in);
		
		assert in.equals("a");
		assert "someMore" != null;
	}
	
	public void testFooEmptyInput() {
		instance.foo("");
		
		// method should not crash
		assert true;
	}
	
	public void testFooSomeInput() {
		instance.foo("someInput");
		
		// method should crash again
		assert false;
	}
	
	public void testFooNullPointer() {
		instance.foo(null);
		
		//method should crash
		assert false;
	}
	
	public void testFooNullPointerNoMessage() {
		instance.foo(null);
		
		//method should crash
		assert false;
	}
}
