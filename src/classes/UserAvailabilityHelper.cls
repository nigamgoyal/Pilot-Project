/*
 * Description: class that filters a list of users and returns only those that are available at a given date & time.
*/
public with sharing class UserAvailabilityHelper {
    
	public Id absenceRecordType;//Event recordType
    public String absenceSubject;// Event subject
    public UserAvailabilityHelper(Id absenceRecordType, String absenceSubject){
        this.absenceRecordType = absenceRecordType;
        this.absenceSubject = absenceSubject;
    }
    //users: List of users to filter available users
    //gmtTime: specifies absence users date time
    public List<User> filterAvailableUsers(List<User> users, DateTime gmtTime){
       //gmtDate: get date from gmtTime
        Date gmtDate = date.newinstance(gmtTime.year(), gmtTime.month(), gmtTime.day());
      
        // Return list of users that are do not have an absence event for the specified GMT time
        // Check if event subject and event recordType is not null
        if((this.absenceSubject != Null) || this.absenceRecordType != Null){
        	//list of absence event for the specified gmtTime
         
					String evtQuery = 'Select Id, OwnerId From Event  Where ( ';
				     
				     if(this.absenceSubject != Null)  
					      evtQuery  +=          ' (Subject = :absenceSubject) ';
					 
					 if((this.absenceSubject != Null) && this.absenceRecordType != Null)	  
						  evtQuery  +=               ' OR ';
					
					 if(this.absenceRecordType != Null)  
						  evtQuery  +=      	' (RecordTypeId = :absenceRecordType) ';
						  
						  evtQuery  +=        ' ) AND ';
						  evtQuery  += 		  ' ( '; 
						  evtQuery  += 		  '  (StartDateTime <= :gmtTime AND EndDateTime >= :gmtTime) ';
						  evtQuery  +=	      ' OR ';
						  evtQuery  +=	      ' ( ';
						  evtQuery  +=			   ' (isAllDayEvent = TRUE) ';
						  evtQuery  +=				' AND ';
						  evtQuery  +=			' (DAY_ONLY(StartDateTime) <= :gmtDate AND DAY_ONLY(EndDateTime) >= :gmtDate) ';
						  evtQuery  +=			'   ) ';
						  evtQuery  +=		'  ) ';
						  evtQuery  +=				       '  AND OwnerId in :users ';
						 
			List<Event> eventList =	  Database.query(evtQuery);
			
			Set<Id> absenceEvtuserIds = new Set<Id>();
			for(Event eventObj: eventList){
				absenceEvtuserIds.add(eventObj.OwnerId);
			}
      
          
            // list of available users
			List<User> filterAvailableUserList = new List<User>();
	        for(user userObj: users){
	        	if(!absenceEvtuserIds.contains(userObj.Id)){
	        		filterAvailableUserList.add(userObj);
	        	}
	        }
	        
	        if(filterAvailableUserList.size() > 0)
            	return filterAvailableUserList;
        }
        
		// If neither are specified, just return the input list unmodified
		return users;
    }
}