package nl.mse.loc;

public class ControlLoopWithComment {

	public void foo() {
		int total = 0;
		for(int i = 1; i <= 10; i++) {
			//This is a comment || && 
			if (true || false) { total+=i; } else { total-=i;};
		}
		System.out.println(total);
	}
	
}
