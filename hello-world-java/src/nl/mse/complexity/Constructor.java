package nl.mse.complexity;

public class Constructor {
	
	final String pkTable;
	final String fkTable;
	final String pk;
	final String fk;
	
	public Constructor(String pkTable, String pk, String fkTable, String fk){
		this.pkTable = pkTable;
		this.fkTable = fkTable;
		this.pk = pk;
		this.fk = fk;
	}
}
