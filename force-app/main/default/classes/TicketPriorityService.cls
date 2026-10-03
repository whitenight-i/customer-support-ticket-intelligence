/**
 * Project Name: Customer Support Ticket Priority Prediction and Automated Assignment
 * Description: Apex service mirroring the "Support Ticket Intelligence" flow workflow.
 *              Acts as an Invocable Action for Agentforce to process customer tickets.
 */
public with sharing class TicketPriorityService {

    public static final String PRIORITY_HIGH    = 'High';
    public static final String PRIORITY_MEDIUM = 'Medium';
    public static final String PRIORITY_LOW    = 'Low';

    public static final String AGENT_SENIOR = 'Senior Support Agent';

    public static final String MSG_HIGH        = 'High priority ticket detected. Assigned to senior agent.';
    public static final String MSG_MEDIUM      = 'Ticket marked as medium priority. Will be handled shortly.';
    public static final String MSG_LOW         = 'Tickets are low priority and queued for processing.';
    public static final String MSG_NO_ACCOUNT  = 'No account was found with that name. Please check the spelling.';
    public static final String MSG_NO_TICKET   = 'No support ticket was found for this account.';

    private static final List<String> HIGH_KEYWORDS   = new List<String>{ 'urgent', 'not working', 'failure' };
    private static final List<String> MEDIUM_KEYWORDS = new List<String>{ 'issue', 'slow', 'delay' };

    // ---------- Priority Evaluation Logic ----------
    public static String calculatePriority(String description) {
        if (String.isBlank(description)) {
            return PRIORITY_LOW;
        }
        String text = description.toLowerCase();
        if (containsAny(text, HIGH_KEYWORDS)) {
            return PRIORITY_HIGH;
        }
        if (containsAny(text, MEDIUM_KEYWORDS)) {
            return PRIORITY_MEDIUM;
        }
        return PRIORITY_LOW;
    }

    private static Boolean containsAny(String text, List<String> keywords) {
        for (String keyword : keywords) {
            if (text.contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    // ---------- Invocable Wrapper Classes ----------
    public class Request {
        @InvocableVariable(label='Account Name' description='Name of the customer account' required=true)
        public String accountName;
    }

    public class Result {
        @InvocableVariable(label='Account Id')
        public String accountId;
        @InvocableVariable(label='Ticket Id')
        public String ticketId;
        @InvocableVariable(label='Priority Level')
        public String priorityLevel;
        @InvocableVariable(label='Assigned Agent')
        public String assignedTo;
        @InvocableVariable(label='Action Message')
        public String actionMessage;
    }

    // ---------- Agentforce Invocable Method ----------
    @InvocableMethod(
        label='Analyze Support Ticket Priority'
        description='Finds the latest ticket of an account, sets its priority using keywords, and creates a Task for High priority tickets.'
    )
    public static List<Result> analyzeTickets(List<Request> requests) {
        if (requests == null || requests.isEmpty()) {
            return new List<Result>();
        }

        Set<String> names = new Set<String>();
        for (Request req : requests) {
            if (req != null && String.isNotBlank(req.accountName)) {
                names.add(req.accountName.trim());
            }
        }

        Map<String, Account> accountByName = new Map<String, Account>();
        for (Account acc : [
            SELECT Id, Name
            FROM Account
            WHERE Name IN :names
            ORDER BY CreatedDate DESC
        ]) {
            String key = acc.Name.toLowerCase();
            if (!accountByName.containsKey(key)) {
                accountByName.put(key, acc);
            }
        }

        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accountByName.values()) {
            accountIds.add(acc.Id);
        }

        Map<Id, Support_Ticket_Intelligence__c> latestTicket = new Map<Id, Support_Ticket_Intelligence__c>();
        for (Support_Ticket_Intelligence__c ticket : [
            SELECT Id, Customer__c, Description__c
            FROM Support_Ticket_Intelligence__c
            WHERE Customer__c IN :accountIds
            ORDER BY CreatedDate DESC
        ]) {
            if (!latestTicket.containsKey(ticket.Customer__c)) {
                latestTicket.put(ticket.Customer__c, ticket);
            }
        }

        List<Result> results = new List<Result>();
        List<Task> tasksToCreate = new List<Task>();

        for (Request req : requests) {
            Result res = new Result();

            if (req == null || String.isBlank(req.accountName)) {
                res.actionMessage = MSG_NO_ACCOUNT;
                results.add(res);
                continue;
            }

            Account acc = accountByName.get(req.accountName.trim().toLowerCase());
            if (acc == null) {
                res.actionMessage = MSG_NO_ACCOUNT;
                results.add(res);
                continue;
            }
            res.accountId = acc.Id;

            Support_Ticket_Intelligence__c ticket = latestTicket.get(acc.Id);
            if (ticket == null) {
                res.actionMessage = MSG_NO_TICKET;
                results.add(res);
                continue;
            }
            res.ticketId = ticket.Id;
            res.priorityLevel = calculatePriority(ticket.Description__c);

            if (res.priorityLevel == PRIORITY_HIGH) {
                tasksToCreate.add(new Task(
                    Subject  = 'Urgent Ticket Handling',
                    WhatId   = ticket.Id,
                    Priority = 'High',
                    Status   = 'Not Started'
                ));
                res.assignedTo    = AGENT_SENIOR;
                res.actionMessage = MSG_HIGH;
            } else if (res.priorityLevel == PRIORITY_MEDIUM) {
                res.actionMessage = MSG_MEDIUM;
            } else {
                res.actionMessage = MSG_LOW;
            }
            results.add(res);
        }

        if (!tasksToCreate.isEmpty()) {
            insert tasksToCreate;
        }
        
        return results;
    }
}
