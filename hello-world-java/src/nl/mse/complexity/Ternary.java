package nl.mse.complexity;

public class Ternary {

	public int ternaryFoo(int i) {
		if((i < 1 ? 2 : 3) == 2) {
			return i * 5;
		}
		
		throw new RuntimeException("Worst condition ever");
	}
}
