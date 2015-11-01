package nl.mse.complexity;

public class ComplexMethod {

	public void foo(String a) {
		String b = a.trim();

		try {

			if (a != null && a.equals("someInput")) {
				a = null;
			} else if (b.equals("")) {
				return;
			}

			a.length();

		} catch (NullPointerException ex) {
			if (ex.getMessage() == null) {
				throw ex;
			}
		}

	}
}
