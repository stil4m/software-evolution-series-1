package nl.mse.dup;

public class DuplicateFoo1 {

	public Class<?> whoami() {
		return DuplicateFoo1.class;
	}
	
	public int foo (int i) {
		i += 1;
		i *= 2;
		i -= 3;
		i += 2;
		return i;
	}
}
