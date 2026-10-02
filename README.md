# customer-support-ticket-intelligence
Customer Support Ticket Priority Prediction and Automated Assignment System Using Agentforce
Hey there! 👋 Welcome to my repository. This project is part of my hands-on learning and implementation with Salesforce and Agentforce. Here, I've built an intelligent support ticket routing and prioritization system that minimizes manual work for support teams.

💡 What this project is about?
Handling a massive volume of customer support tickets manually can be overwhelming. To solve this, I designed an automated system using Salesforce Flow and Agentforce that reads incoming support tickets, analyzes what the customer is facing, predicts the priority (High, Medium, or Low), creates urgent tasks automatically, and routes them to the right support staff—all through a conversational interface!

🛠️ How I Built It (Key Components)
Salesforce Flow (Auto-Launched): The core backend engine that fetches account and ticket details, runs decision logic based on keywords, and handles record creations.

Keyword-Based Intelligence:

High Priority: Triggers on keywords like "urgent", "not working", or "failure".

Medium Priority: Triggers on "issue", "slow", or "delay".

Low Priority: Default catch-all category.

Automated Task Generation: For high-priority tickets, the system instantly creates an "Urgent Ticket Handling" task linked to the ticket and assigns a Senior Support Agent.

Agentforce Subagent: Configured a conversational subagent (Support Ticket Priority Analysis) so users can interact naturally to check ticket statuses and get instant automated feedback.

📂 Project Structure & Workflow
Get Account & Ticket: Takes the account name as input, retrieves the latest ticket, and stores the IDs.

Analyze Description: Evaluates the ticket description using decision elements.

Set Priority & Assign Tasks: Automatically updates priority levels, creates follow-up tasks for urgent issues, and sets appropriate response messages.

Agentforce Action: Connects the flow to the agent for seamless user interaction.

✨ What I Learned & Achieved
Automated the entire ticket prioritization workflow, reducing manual triage time.

Successfully bridged Salesforce backend automation (Flows) with modern conversational AI (Agentforce).

Handled error-free variable mapping and record creation inside Salesforce Developer Edition.

🚀 Future Improvements
Adding advanced SLA monitoring and automated escalation matrices.

Expanding keyword dictionaries and custom business rules for better categorization.

Building performance analytics dashboards for support trends.
