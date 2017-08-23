@isTest
public with sharing class UserAvailabilityTest {
    
    //Please Update recordType Name as per Existing in Org
    public static String  ABSENCE_RECORDTYPE = 'Absence';
    public static String  PRESENT_RECORDTYPE = 'Present';
    public static String  ABSENCE_SUBJECT  = 'Absence';
    public static String  PRESENT_SUBJECT  = 'Present';
    
    
    @testSetup static void setup(){
    	List<User> users = new List<User>();
		 String pid = [Select id from Profile where Name='System Administrator'].Id;
		for(integer i=1; i<=6; i++)
		{
		    String orgId = UserInfo.getOrganizationId();
		    String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
		    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
		    String uniqueName = orgId + dateString + randomInt;
		   
		    User tuser = new User(  firstname = 'test',
		                            lastName = 'user'+i,
		                            email = uniqueName + '@test' + orgId + '.org',
		                            Username = uniqueName + '@test' + orgId + '.org',
		                            EmailEncodingKey = 'ISO-8859-1',
		                            Alias = 'test',
		                            TimeZoneSidKey = 'America/Los_Angeles',
		                            LocaleSidKey = 'en_US',
		                            LanguageLocaleKey = 'en_US',
		                            ProfileId = pid);
		    users.add(tuser);
		                            
		}
		Test.startTest();
		insert users;
		Test.stopTest();
		
		createTestRecords(2, 1);
		
		
		 Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount1'];
		 List<User> userList = [SELECT Id FROM User WHERE Alias = 'test' Limit 10];
		 
		 List<Event> eventList = new List<Event>();
		 
		 DateTime startDateTime = DateTime.newInstance(2017,08,20,14,31,00);
         DateTime endDateTime = DateTime.newInstance(2017,08,21,14,31,00); 
         
         Id recordTypeIdPresentEvent;
         if(Schema.SObjectType.Event.getRecordTypeInfosByName().get(PRESENT_RECORDTYPE) != null)
         	recordTypeIdPresentEvent = Schema.SObjectType.Event.getRecordTypeInfosByName().get(PRESENT_RECORDTYPE).getRecordTypeId();
		 // For Present Event
		 Event EventObject = createEventInstance(userList[0].Id,acc.Id, startDateTime,endDateTime,TRue,PRESENT_SUBJECT,recordTypeIdPresentEvent);
	   	
	     eventList.add(EventObject);
		
		// For Subject = Absence Event Case
		 Event EventObject1 = createEventInstance(userList[1].Id,acc.Id, startDateTime,endDateTime,False,ABSENCE_SUBJECT,recordTypeIdPresentEvent);
	     eventList.add(EventObject1);
         
         // For Subject = Null Case
		 Event EventObject2 = createEventInstance(userList[2].Id,acc.Id, startDateTime,endDateTime,False,'',recordTypeIdPresentEvent);
	     eventList.add(EventObject2);
         
         // For RecordType Equals Absence Case
         Id recordTypeIdAbsenceEvent;
         if(Schema.SObjectType.Event.getRecordTypeInfosByName().get(ABSENCE_RECORDTYPE) != null) 
         	recordTypeIdAbsenceEvent = Schema.SObjectType.Event.getRecordTypeInfosByName().get(ABSENCE_RECORDTYPE).getRecordTypeId();
          
		 Event EventObject3 = createEventInstance(userList[3].Id,acc.Id, startDateTime,endDateTime,False,'',recordTypeIdAbsenceEvent);
	     eventList.add(EventObject3);
         
         // For AllEventTrue
          DateTime startDateTime1 = DateTime.newInstance(2017,08,15,14,31,00);
           DateTime endDateTime1 = DateTime.newInstance(2017,08,15,14,31,00);
         Event EventObject4 = createEventInstance(userList[4].Id,acc.Id, startDateTime1,endDateTime1,True,'',recordTypeIdAbsenceEvent);
         eventList.add(EventObject4);
         
         insert eventList; 
        
		
    }
    
    
    public static List<User> selectAllUsers(){
    	return [SELECT Id FROM User];
    }
    
    @isTest
    public static void checkAvailableUsersAbsenceSubject(){
    	
    	UserAvailabilityHelper helper = new UserAvailabilityHelper(null,ABSENCE_SUBJECT);
		List<User> usr = [Select Id from User WHERE Alias = 'test'];
		DateTime gmtTime =  DateTime.newInstanceGMT(2017,08,20,15,31,00);
		List<User> filterAvailableUsers = helper.filterAvailableUsers(usr, gmtTime);
		system.assertEquals(5,filterAvailableUsers.size());
	} 
	
	@isTest
	public static void checkAvailableUsersBothNullAbsenceEvents(){
		List<User> usr = [Select Id from User WHERE Alias = 'test'];
		DateTime gmtTime =  DateTime.newInstanceGMT(2017,08,20,15,31,00);
		UserAvailabilityHelper helper1 = new UserAvailabilityHelper(null,null);
		List<User> filterAvailableUsers1 = helper1.filterAvailableUsers(usr, gmtTime);
		system.assertEquals(6,filterAvailableUsers1.size());
	}
	
	@isTest
	public static void checkAvailableUsersAbsenceRecordType(){
		List<User> usr = [Select Id from User WHERE Alias = 'test'];
		DateTime gmtTime =  DateTime.newInstanceGMT(2017,08,20,15,31,00);
		
        if(Schema.SObjectType.Event.getRecordTypeInfosByName().get(ABSENCE_RECORDTYPE) != null){
          Id  recordTypeIdAbsenceEvent = Schema.SObjectType.Event.getRecordTypeInfosByName().get(ABSENCE_RECORDTYPE).getRecordTypeId();
            UserAvailabilityHelper helper1 = new UserAvailabilityHelper(recordTypeIdAbsenceEvent,null);
            List<User> filterAvailableUsers1 = helper1.filterAvailableUsers(usr, gmtTime);
            system.assertEquals(5,filterAvailableUsers1.size());
        }
			
	}
	
	@isTest
	public static void checkAvailableUsersBothAbsenceEvents(){
		List<User> usr = [Select Id from User WHERE Alias = 'test'];
		DateTime gmtTime =  DateTime.newInstanceGMT(2017,08,20,15,31,00);
		Id recordTypeIdAbsenceEvent;
        if(Schema.SObjectType.Event.getRecordTypeInfosByName().get(ABSENCE_RECORDTYPE) != null){
			recordTypeIdAbsenceEvent = Schema.SObjectType.Event.getRecordTypeInfosByName().get(ABSENCE_RECORDTYPE).getRecordTypeId();
            UserAvailabilityHelper helper1 = new UserAvailabilityHelper(recordTypeIdAbsenceEvent,ABSENCE_SUBJECT);
            List<User> filterAvailableUsers1 = helper1.filterAvailableUsers(usr, gmtTime);
            system.assertEquals(4,filterAvailableUsers1.size());            
        }
		 	
	}
	
	@isTest
	public static void checkAvailableUsersAllDatEvent(){
		List<User> usr = [Select Id from User WHERE Alias = 'test'];
		DateTime gmtTime =  DateTime.newInstanceGMT(2017,08,15,15,31,00);
		
        if(Schema.SObjectType.Event.getRecordTypeInfosByName().get(ABSENCE_RECORDTYPE) != null){
            Id recordTypeIdAbsenceEvent = Schema.SObjectType.Event.getRecordTypeInfosByName().get(ABSENCE_RECORDTYPE).getRecordTypeId();
            UserAvailabilityHelper helper1 = new UserAvailabilityHelper(recordTypeIdAbsenceEvent,null);
            List<User> filterAvailableUsers1 = helper1.filterAvailableUsers(usr, gmtTime);
            system.assertEquals(5,filterAvailableUsers1.size());
        }
			 
	}
    
    public static void createTestRecords(Integer numAccts, Integer numContactsPerAcct) {
        List<Account> accts = new List<Account>();  
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='TestAccount' + i);
            accts.add(a);
        }
        insert accts;
        
        List<Contact> cons = new List<Contact>();
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];            
            // For each account just inserted, add contacts
            for (Integer k=numContactsPerAcct*j;k<numContactsPerAcct*(j+1);k++) {
                cons.add(new Contact(firstname='Test'+k,
                                     lastname='Test'+k,
                                     AccountId=acct.Id));
            }
        }
        // Insert all contacts for all accounts
        insert cons;
    }
    
    public static Event createEventInstance(Id ownerId,Id accId,DateTime startDateTime, DateTime endDateTime,Boolean isAllDayEvent,String subject,Id recordTypeId){
    	// For Subject = Absence Event Case
		 Event EventObject = new Event();
	     EventObject.Type = 'Email';
	     EventObject.Description = ''; //string
	     EventObject.OwnerId = ownerId; //user id
	     EventObject.WhatId = accId; //record id
	     EventObject.Subject = subject;
         EventObject.IsAllDayEvent = isAllDayEvent;
         // recordTypeId APINAME is not available untill it not created.
         	EventObject.put('recordTypeId',recordTypeId); 
         EventObject.StartDateTime = startDateTime;
         EventObject.EndDateTime = endDateTime;
         return EventObject;
        
    } 
}