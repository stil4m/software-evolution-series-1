package nl.mse.complexity;

public class InnerClass {

	public static class Inner1 {
		
		@Override
		protected Object clone() throws CloneNotSupportedException {
			long a = System.currentTimeMillis();
			
			if(a > 0)
			{
				System.out.println("CRAZY");
			}

			return super.clone();
		}
	}
	
	public static class Inner2 {
		
		@Override
		protected Object clone() throws CloneNotSupportedException {
			long a = System.currentTimeMillis();
			
			if(a > 0 && a > 1 && a > 2 || a > 3 || a < 1000000)
			{
				System.out.println("CRAZY");
			}

			return super.clone();
		}
	}

}

class Class2 {
	
}
