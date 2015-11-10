package nl.mse.test;

import nl.mse.complexity.ComplexMethod;

public class MyShittyTestFile extends BaseTestCase {
	
	private ComplexMethod instance = new ComplexMethod();
	
	public void testFooNullPointerNoMessage() {
		instance.foo(null);
	}
}
