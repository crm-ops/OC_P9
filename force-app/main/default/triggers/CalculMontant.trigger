trigger CalculMontant on Order (before update) {

	List<Order> lo = new List<Oorder>();
	
	for (Order o : trigger.new) {

	if (o.TotalAmount!=null && o.ShipmentCost__c!=null ){
		o.NetAmount__c = o.TotalAmount - o.ShipmentCost__c;
		lo.add(o);
		}
	}
	
	update lo;

}