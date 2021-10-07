/******This class calculates the Payment totals for the accounts and contacts. Is run as a part of the Scheduled Job to roll up payment information to the Accounts and Contacts
 *   Called by AccountRollupJob scheduled class*/

public with sharing class StudentTermPaymentService {
  public static List<Contact> setRollupPaymentInformationForContacts(List<Contact> contacts) {
    List<Id> contactIds = new List<Id>();
    for (Contact c : contacts) {
      contactIds.add(c.Id);
    }
   
    Map<Id, AggregateResult> resultsMap = getPaymentResultsMapForContacts(contactIds);
    Map<Id, AggregateResult> currentTermResultsMap = getPaymentResultsMapForContactsCurrentTerm(contactIds);
    Map<Id, Student_term_Payments__c> currentTermPaymentsMap = getStudentTermPaymentMapForContactsCurrentTerm(contactIds);

    for (Contact c : contacts) {
      AggregateResult result = resultsMap.get(c.Id);
      AggregateResult currentTermResult = currentTermResultsMap.get(c.Id);
      Student_term_Payments__c currentTermPayment = currentTermPaymentsMap.get(c.Id);
  
      if (result == null) {
        c.Most_Recent_Payment_Date__c = null;
        c.First_Payment_Date__c = null;
        c.Most_Recent_Payment_Amount__c = null;
        c.First_Payment_Amount__c = null;
        c.Total_Payments_Amount_to_Date__c = null;
      } else {
        c.Most_Recent_Payment_Date__c = (Date)result.get('maxPaymentDate');
        c.First_Payment_Date__c = (Date)result.get('minPaymentDate');
        c.Most_Recent_Payment_Amount__c = (Decimal)result.get('maxPaymentAmount');
        c.First_Payment_Amount__c = (Decimal)result.get('minPaymentAmount');
        c.Total_Payments_Amount_to_Date__c = (Decimal)result.get('totalPaymentsAmount');
      }

      if (currentTermResult == null) {
        c.Total_Payments_Current_Term__c = null;
      } else {
        c.Total_Payments_Current_Term__c = (Decimal)currentTermResult.get('totalPaymentsAmount');
       }
        
        if (currentTermPayment != null)  {
            /*Update the Persistence Cohort and Named Scholarship on the contact*/
            if (currentTermPayment.Ispaid__c && currentTermPayment.Payment_Amount__c > 0 && currentTermPayment.Restricted_Fund_Name__c != null && !currentTermPayment.isRefund__c){
                c.Named_Scholarship_Selection__c = currentTermPayment.Restricted_Fund_Name__c;
            }
            /**If payment was made in the fall then update the Persistence Cohort , else for a refund made , then revert back the value*/
            if(currentTermPayment.Student_Term__r.Term_Semester__c =='Fall' && currentTermPayment.isPaid__c && currentTermPayment.isRefund__c == false 
               && currentTermPayment.Student_Term__r.Application__r.Student_Name__r.High_School_Class_of__c == String.Valueof(currentTermPayment.Payment_Date__c.Year())
               && currentTermPayment.Student_Term__r.Application__r.Student_Name__r.Cohort_text__c == String.valueOf(currentTermPayment.Payment_Date__c.Year())    
              ) {
                  c.Persistence_Cohort__c = currentTermPayment.Student_Term__r.Application__r.Student_Name__r.Cohort_text__c;
                  
              }
            /*if there was a refund made then revert back the persistence Cohort*/
            if(currentTermPayment.Student_Term__r.Term_Semester__c =='Fall' && currentTermPayment.isRefund__c == True && currentTermPayment.Refund_Amount__c > 0 
               && currentTermPayment.Refund_Type__c == 'Complete Refund'
               && currentTermPayment.Student_Term__r.Application__r.Student_Name__r.High_School_Class_of__c == String.Valueof(currentTermPayment.Payment_Date__c.Year())
               && currentTermPayment.Student_Term__r.Application__r.Student_Name__r.Cohort_text__c == String.valueOf(currentTermPayment.Payment_Date__c.Year())    
              ) {
                  c.Persistence_Cohort__c = '';
             }
         }
     }
  return contacts;
  }

  public static void rollupPaymentInformationForAccounts(List<Account> accounts) {
    List<Id> accountIds = new List<Id>();
    for (Account acct : accounts) {
      accountIds.add(acct.Id);
    }

    Map<Id, AggregateResult> accountCurrentTermResults = getPaymentResultsMapForAccountsCurrentTerm(accountIds);
    Map<Id, AggregateResult> accountLifetimeResults = getPaymentResultsMapForAccountsLifetime(accountIds);
    Map<Id, AggregateResult> accountCurrentTermScholarResults = getTotalScholarResultsForAccountsCurrentTerm(accountIds);
    Map<Id, AggregateResult> accountLifetimeScholarResults = getTotalScholarResultsForAccountsLifetime(accountIds);

    for (Account acct : accounts) {
      AggregateResult currentTermResult = accountCurrentTermResults.get(acct.Id);
      AggregateResult lifetimeResult = accountLifetimeResults.get(acct.Id);
      AggregateResult currentTermScholarResult = accountCurrentTermScholarResults.get(acct.Id);
      AggregateResult lifetimeScholarResult = accountLifetimeScholarResults.get(acct.Id);

      if (currentTermResult == null) {
        acct.Total_Dollars_Current_Term__c = null;
        acct.Scholar_Recipients_Current_Term__c = null;
      } else {
        acct.Total_Dollars_Current_Term__c = (Decimal)currentTermResult.get('totalDollars');
        acct.Scholar_Recipients_Current_Term__c = (Integer)currentTermResult.get('totalScholarRecipients');
      }

      if (lifetimeResult == null) {
        acct.Total_Dollars_Lifetime__c = null;
        acct.Scholar_Recipients_Lifetime__c = null;
      } else {
        acct.Total_Dollars_Lifetime__c = (Decimal)lifetimeResult.get('totalDollars');
        acct.Scholar_Recipients_Lifetime__c = (Integer)lifetimeResult.get('totalScholarRecipients');
      }

      acct.Scholars_Current_Term__c = currentTermScholarResult != null ? (Integer)currentTermScholarResult.get('totalScholars') : null;
      acct.Scholars_Lifetime__c = lifetimeScholarResult != null ? (Integer)lifetimeScholarResult.get('totalScholars') : null;
    }

    update accounts;
  }

  private static Map<Id, AggregateResult> getPaymentResultsMapForContacts(List<Id> contactIds) {
    List<AggregateResult> results = [SELECT MAX(Payment_Date__c) maxPaymentDate,
                                     MIN(Payment_Date__c) minPaymentDate,
                                     MAX(Payment_Value__c) maxPaymentAmount,
                                     MIN(Payment_Value__c) minPaymentAmount,
                                     SUM(Payment_Value__c) totalPaymentsAmount,
                                     Student_Term__r.Application__r.Student_Name__c contactId
                                     FROM Student_Term_Payments__c
                                     WHERE Student_Term__r.Application__r.Student_Name__c IN :contactIds
                                     GROUP BY Student_Term__r.Application__r.Student_Name__c
                                    ];

    Map<Id, AggregateResult> aggResultMap = new Map<Id, AggregateResult>();
    if (results == null || results.size() == 0) {
      return aggResultMap;
    }

    for (AggregateResult ar : results) {
      aggResultMap.put((Id)ar.get('contactId'), ar);
    }
    return aggResultMap;
  }

  private static Map<Id, AggregateResult> getPaymentResultsMapForContactsCurrentTerm(List<Id> contactIds) {
    List<AggregateResult> results = [SELECT SUM(Payment_Value__c) totalPaymentsAmount,
                                                    
                                     Student_Term__r.Application__r.Student_Name__c contactId
                                     FROM Student_Term_Payments__c
                                     WHERE Student_Term__r.Application__r.Student_Name__c IN :contactIds AND Student_Term__r.isCurrentTerm__c = TRUE
                                     GROUP BY Student_Term__r.Application__r.Student_Name__c
                                    ];

    Map<Id, AggregateResult> aggResultMap = new Map<Id, AggregateResult>();
    if (results == null || results.size() == 0) {
      return aggResultMap;
    }

    for (AggregateResult ar : results) {
      aggResultMap.put((Id)ar.get('contactId'), ar);
        
    }
    return aggResultMap;
  }

  private static Map<Id, AggregateResult> getPaymentResultsMapForAccountsCurrentTerm(List<Id> accountIds) {
    List<AggregateResult> results = [SELECT SUM(Payment_Value__c) totalDollars,
                                     COUNT_DISTINCT(Student_Term__c) totalScholarRecipients,
                                     Student_Term__r.College_or_University__c accountId
                                     FROM Student_Term_Payments__c
                                     WHERE Student_Term__r.College_or_University__c IN :accountIds AND Student_Term__r.isCurrentTerm__c = TRUE
                                         GROUP BY Student_Term__r.College_or_University__c
                                    ];

    Map<Id, AggregateResult> aggResultMap = new Map<Id, AggregateResult>();
    if (results == null || results.size() == 0) {
      return aggResultMap;
    }

    for (AggregateResult ar : results) {
      aggResultMap.put((Id)ar.get('accountId'), ar);
    }
    return aggResultMap;
  }

  private static Map<Id, AggregateResult> getPaymentResultsMapForAccountsLifetime(List<Id> accountIds) {
    List<AggregateResult> results = [SELECT SUM(Payment_Value__c) totalDollars,
                                     COUNT_DISTINCT(Student_Term__c) totalScholarRecipients,
                                     Student_Term__r.College_or_University__c accountId
                                     FROM Student_Term_Payments__c
                                     WHERE Student_Term__r.College_or_University__c IN :accountIds
                                     GROUP BY Student_Term__r.College_or_University__c
                                    ];

    Map<Id, AggregateResult> aggResultMap = new Map<Id, AggregateResult>();
    if (results == null || results.size() == 0) {
      return aggResultMap;
    }

    for (AggregateResult ar : results) {
      aggResultMap.put((Id)ar.get('accountId'), ar);
    }
    return aggResultMap;
  }

  private static Map<Id, AggregateResult> getTotalScholarResultsForAccountsCurrentTerm(List<Id> accountIds) {
    List<AggregateResult> results = [SELECT COUNT(Id) totalScholars,
                                     College_or_University__c accountId
                                     FROM Student_Term__c
                                     WHERE College_or_University__c IN :accountIds AND isCurrentTerm__c = TRUE
                                         GROUP BY College_or_University__c
                                    ];

    Map<Id, AggregateResult> aggResultMap = new Map<Id, AggregateResult>();
    if (results == null || results.size() == 0) {
      return aggResultMap;
    }

    for (AggregateResult ar : results) {
      aggResultMap.put((Id)ar.get('accountId'), ar);
    }
    return aggResultMap;
  }

  private static Map<Id, AggregateResult> getTotalScholarResultsForAccountsLifetime(List<Id> accountIds) {
    List<AggregateResult> results = [SELECT COUNT(Id) totalScholars,
                                     College_or_University__c accountId
                                     FROM Student_Term__c
                                     WHERE College_or_University__c IN :accountIds
                                     GROUP BY College_or_University__c
                                    ];

    Map<Id, AggregateResult> aggResultMap = new Map<Id, AggregateResult>();
    if (results == null || results.size() == 0) {
      return aggResultMap;
    }

    for (AggregateResult ar : results) {
      aggResultMap.put((Id)ar.get('accountId'), ar);
    }
    return aggResultMap;
  }
 
    //new method to update the Restricted Fund name from the Student Term payment and the persistence Cohort to the Contact
  private static Map<Id, Student_term_payments__c> getStudentTermPaymentMapForContactsCurrentTerm(List<Id> contactIds) {
      List<Student_term_payments__c> Stpmt = [SELECT Restricted_Fund_Name__c ,
                                              Ispaid__c ,
                                              Refund_Amount__c,
                                              Refund_Type__c,
                                              isRefund__c,
                                              Student_Term__r.Term_Semester__c,
                                              Student_Term__r.Application__r.Student_Name__r.Cohort_text__c,
                                              Student_Term__r.Application__r.Student_Name__c,
                                              Student_Term__r.Application__r.Student_Name__r.High_School_Class_of__c,
                                              Name,     
                                              Payment_Amount__c,
                                              Refund_Date__c,
                                              Payment_Date__c
                                              FROM Student_Term_Payments__c
                                              WHERE Student_Term__r.Application__r.Student_Name__c IN :contactIds AND Student_Term__r.isCurrentTerm__c = TRUE  
                                              AND  SystemModStamp >= LAST_N_DAYS:7
                                             ];
      Map<Id, Student_term_payments__c> stpmtMap = new Map<Id, Student_term_payments__c>();
      if (Stpmt == null || Stpmt.size() == 0) {
          return stpmtMap;
      }
      for (Student_term_payments__c st : Stpmt) {
          stpmtMap.put(st.Student_Term__r.Application__r.Student_Name__c, st);
      }
      return stpmtMap;
  }
}