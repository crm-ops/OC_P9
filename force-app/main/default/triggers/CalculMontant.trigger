trigger CalculMontant on Order (before update) {
	
	Order newOrder= trigger.new[0];
	if (newOrder.TotalAmount!=null && newOrder.ShipmentCost__c!=null ){
	newOrder.NetAmount__c = newOrder.TotalAmount - newOrder.ShipmentCost__c;
	update newOrder;
	}	
}