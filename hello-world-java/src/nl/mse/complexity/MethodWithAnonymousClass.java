package nl.mse.complexity;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class MethodWithAnonymousClass {

	public void foo() {
		int total = 0;
		for (int i = 1; i <= 10; i++) {
			total += i;
		}

		List<String> strings = new ArrayList<String>();
		
		Collections.sort(strings, new Comparator<String>() {

			@Override
			public int compare(String o1, String o2) {
				if(o1 != null && o2 != null)
				{	
					return 0;
				}else {
					return o1.compareTo(o2);					
				}
			}
		});
		
		System.out.println(total);
	}
}
