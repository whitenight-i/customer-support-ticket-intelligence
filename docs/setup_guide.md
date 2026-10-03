# Comprehensive Setup & Implementation Guide

This guide provides the complete step-by-step instructions to replicate and deploy the **Customer Support Ticket Priority Prediction and Automated Assignment System** using Salesforce Flow and Agentforce.

---

## 1. Prerequisites & Custom Object Setup (Step 0)
Before configuring the automation, ensure your Salesforce Developer Org has the required data structure:
1. **Custom Object:** Create a custom object named **`Support_Ticket_Intelligence__c`**.
2. **Relationship Field:** Add a Lookup or Master-Detail relationship field named **`Customer__c`** pointing to the standard **`Account`** object.
3. **Description Field:** Ensure a text or text-area field exists to store the ticket issue descriptions.
4. **Standard Objects:** Verify access to standard objects: `Account`, `Task`, and `User`.

---

## 2. Variables Initialization in Flow Builder
Create the following variables in Salesforce Flow Builder before building the logic:
* `varAccountName` (Data Type: Text, Input/Output: Available for input)
* `varAccountId` (Data Type: Text, Input/Output: Available for output)
* `varTicketId` (Data Type: Text, Input/Output: Available for output)
* `varPriorityLevel` (Data Type: Text, Input/Output: Available for output)
* `varAssignedTo` (Data Type: Text, Input/Output: Available for output)
* `varActionMessage` (Data Type: Text, Input/Output: Available for output)

---

## 3. Step-by-Step Flow Configuration (`Support_Ticket_Intelligence`)

### Step A: Account & Ticket Retrieval
1. **Get Records (Get Account):** 
   - Object: `Account`
   - Condition: `Name` Equals `{!varAccountName}`
   - Sort: `CreatedDate` DESC | Store: *Only first record*
2. **Assignment (Store Account Id):** 
   - Set `varAccountId = {!Get_Account.Id}`
3. **Get Records (Get Ticket):** 
   - Object: `Support_Ticket_Intelligence__c`
   - Condition: `Customer__c` Equals `{!varAccountId}`
   - Sort: `CreatedDate` DESC | Store: *Only first record*
4. **Assignment (Store Ticket Id):** 
   - Set `varTicketId = {!Get_Ticket.Id}`

### Step B: Decision & Priority Analysis
5. **Decision (Analyze Description):**
   - **High Priority Outcome:** Description contains `"urgent"`, `"not working"`, `"failure"`
   - **Medium Priority Outcome:** Description contains `"issue"`, `"slow"`, `"delay"`
   - **Default Outcome:** Low Priority (catch-all)

6. **Assignments (Set Priority Level):**
   - High Path: `varPriorityLevel = "High"`
   - Medium Path: `varPriorityLevel = "Medium"`
   - Low Path: `varPriorityLevel = "Low"`

### Step C: Task Creation & Assignment Routing
7. **Decision (Is High Priority):** Check if `varPriorityLevel Equals "High"`.
8. **Create Records (Create Task):**
   - Object: `Task`
   - Field Values:
     - `Subject` = `"Urgent Ticket Handling"`
     - `WhatId` = `{!varTicketId}`
     - `Priority` = `High`
     - `Status` = `Not Started`
9. **Assignment (Set Assigned Agent):** Set `varAssignedTo = "Senior Support Agent"`.

### Step D: Final Messages Setup
10. **Assignments (Set Final Messages):**
    - High Path: `varActionMessage = "High priority ticket detected. Assigned to senior agent."`
    - Medium Path: `varActionMessage = "Ticket marked as medium priority. Will be handled shortly."`
    - Low Path: `varActionMessage = "Tickets are low priority and queued for processing."`

11. **Save & Activate:** Save the flow as `Support_Ticket_Intelligence` and click **Activate**.

---

## 4. Agentforce Subagent Integration
1. Go to **Agentforce Builder** in Salesforce Setup and create a new Subagent named **Support Ticket Priority Analysis**.
2. Set the **Classification Description** and **Scope** to handle support ticket evaluations strictly.
3. Link the flow action, mapping `varAccountName` as input and the response variables (`varActionMessage`, `varPriorityLevel`, `varAssignedTo`, `varTicketId`, `varAccountId`) as outputs.
4. Test the implementation using the **Conversation Preview** panel by entering a valid account name.
