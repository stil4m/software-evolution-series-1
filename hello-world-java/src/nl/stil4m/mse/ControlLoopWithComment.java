package nl.stil4m.mse;

public class ControlLoopWithComment {

	public void foo() {
		int total = 0;
		for(int i = 1; i <= 10; i++) {
			//This is a comment
			total+=i;
		}
		System.out.println(total);
	}
	
}
