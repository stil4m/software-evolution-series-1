package nl.mse.complexity;

public class DoWhileStatement {

	public void doSomething() {
		int i = 0;

		do {
			if (i < 5) {
				i += 2;
			} else {
				i += 5;
			}
		} while (i < 10);
	}
}
