package nl.stil4m.mse;

public class Robot {

	public void sayHello(String name) {
		System.out.println("Hello " + name);
	}
	
	/**
	 * This is a comment outside of a method
	 * @param name
	 */
	public void sayGoodbye(String name) {
		//This is a comment in a method
		System.out.println("Bye " + name);
	}
}
