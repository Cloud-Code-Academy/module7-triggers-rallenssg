trigger AccountTrigger on Account (before insert, after insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        for (Account acc : Trigger.new) {
            if (acc.Type == null) acc.Type = 'Prospect';
            
            if (acc.ShippingStreet != null) acc.BillingStreet = acc.ShippingStreet;
            if (acc.ShippingCity != null) acc.BillingCity = acc.ShippingCity;
            if (acc.ShippingState != null) acc.BillingState = acc.ShippingState;
            if (acc.ShippingPostalCode != null) acc.BillingPostalCode = acc.ShippingPostalCode;
            if (acc.ShippingCountry != null) acc.BillingCountry = acc.ShippingCountry;

            if (acc.Phone != null && acc.Website != null && acc.Fax != null) {
                acc.Rating = 'Hot';
            }
        }
    }
    
    if (Trigger.isAfter && Trigger.isInsert) {
        List<Contact> cons = new List<Contact>();
        for  (Account acc : Trigger.new) {
            cons.add(
                new Contact(
                    LastName = 'DefaultContact',
                    AccountId = acc.Id,
                    Email = 'default@email.com'
                )
            );
        }

        insert cons;
    }
}