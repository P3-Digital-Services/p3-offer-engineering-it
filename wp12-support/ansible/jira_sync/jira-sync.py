import logging
import asyncio
import aiohttp
import os

# Logging config
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Zendesk and Jira Information
ZENDESK_EMAIL = os.getenv("ZENDESK_EMAIL")
ZENDESK_API_TOKEN = os.getenv("ZENDESK_API_TOKEN")
ZENDESK_TICKET_URL = os.getenv("ZENDESK_TICKET_URL")
ZENDESK_SEARCH_URL = os.getenv("ZENDESK_SEARCH_URL")
ZENDESK_SUBDOMAIN = os.getenv("ZENDESK_SUBDOMAIN")

JIRA_EMAIL = os.getenv("JIRA_EMAIL")
JIRA_API_TOKEN = os.getenv("JIRA_API_TOKEN")
JIRA_SEARCH_URL = os.getenv("JIRA_SEARCH_URL")
JIRA_STATUS_FIELD_ID = os.getenv("JIRA_STATUS_FIELD_ID")
JIRA_ISSUE_KEY_FIELD_ID = os.getenv("JIRA_ISSUE_KEY_FIELD_ID")

# Mapping of statuses from Jira to Zendesk
STATUS_MAPPING = {
    "Open": "open",
    "Work in progress": "open",
    "Under investigation": "open",
    "Under review": "open",
    "Waiting for approval": "pending",
    "Review": "pending",
    "Pending": "pending",
    "Resolved": "solved",
    "Completed": "solved",
    "Declined": "solved",
    "Failed": "solved",
    "Canceled": "solved",
    "Closed": "solved"
}

# Async function to perform API requests
async def fetch_url(session, url, method='GET', **kwargs):
    async with session.request(method, url, **kwargs) as response:
        response.raise_for_status()
        return await response.json()

# Fetch issues from Jira and process each issue
async def fetch_jira_issues():
    logger.info(f"Fetching issues from Jira...")
    async with aiohttp.ClientSession(auth=aiohttp.BasicAuth(JIRA_EMAIL, JIRA_API_TOKEN)) as session:
        try:
            response = await fetch_url(session, JIRA_SEARCH_URL)
            return response['issues']
        except Exception as e:
            logger.error(f"Error fetching issues from Jira: {e}")
            return[]

# Function to check if a ticket with the Jira issue key already exists in Zendesk
async def jira_ticket_check(session, issue_key):
    search_query = f'type:ticket custom_field_{JIRA_ISSUE_KEY_FIELD_ID}:"{issue_key}"'
    url = f"{ZENDESK_SEARCH_URL}?query={search_query}"

    try:
        response = await fetch_url(session, url, auth=aiohttp.BasicAuth(ZENDESK_EMAIL, ZENDESK_API_TOKEN))
        results = response.get('results', [])
        if results:
            return results[0]['id'], results[0]['status']
        return None, None
    except Exception as e:
        logger.error(f"Error searching Zendesk for Jira issue {issue_key}: {e}")
        return None, None

# Async function to sync Jira issues to Zendesk
async def sync_jira_to_zendesk():
    issues = await fetch_jira_issues()
    if not issues:
        logger.info(f"No issues fetched from Jira. Exiting...")
        return

    async with aiohttp.ClientSession() as session:
        tasks = []
        for issue in issues:
            issue_key = issue['key']
            issue_assignee = issue['fields']['assignee']['displayName'] if issue['fields']['assignee'] else 'Unassigned'
            issue_requester = issue['fields']['reporter']['displayName']
            issue_summary = issue['fields']['summary']
            issue_description = issue['fields']['description']
            issue_status = issue['fields']['status']['name']

            # Async task to process the issue
            tasks.append(process_issue(session, issue_key, issue_summary, issue_description, issue_assignee, issue_status, issue_requester))

        # Run tasks concurrently
        await asyncio.gather(*tasks)

# Process an individual Jira issue
async def process_issue(session, issue_key, issue_summary, issue_description, issue_assignee, issue_status, issue_requester):
    logger.info(f"Processing issue {issue_key}")

    # Validate required fields
    if not issue_summary or not issue_description:
        logger.warning(f"Skipping Jira issue {issue_key} due to missing summary or description.")
        return

    # Check if the ticket already exists in Zendesk
    ticket_id, current_zendesk_status = await jira_ticket_check(session, issue_key)
    jira_mapped_status = STATUS_MAPPING.get(issue_status, "open")

    if ticket_id:
        logger.info(f"Jira issue {issue_key} already exists in Zendesk with ticket ID {ticket_id}.")

        # Compare statuses and update if there's a mismatch
        if current_zendesk_status != jira_mapped_status:
            logger.info(f"Status mismatch for ticket {ticket_id}: Jira status {issue_status} vs Zendesk status {current_zendesk_status}. Updating Zendesk ticket...")
            await update_zendesk_ticket_status(session, ticket_id, issue_status)
        else:
            logger.info(f"Ticket {ticket_id} for Jira issue {issue_key} already has the correct status.")
    else:
        logger.info(f"Creating new Zendesk ticket for Jira issue {issue_key}")
        await create_zendesk_ticket(session, issue_key, issue_summary, issue_description, issue_assignee, issue_status, issue_requester)

# Function to update Zendesk ticket status if there's a mismatch
async def update_zendesk_ticket_status(session, ticket_id, issue_status):
    zendesk_status = STATUS_MAPPING.get(issue_status, "open")

    ticket_data = {
        "ticket": {
            "status": zendesk_status,
            "custom_fields": [
                {
                    "id": JIRA_STATUS_FIELD_ID,
                    "value": issue_status
                }
            ]
        }
    }
    update_url = f"https://{ZENDESK_SUBDOMAIN}.zendesk.com/api/v2/tickets/{ticket_id}.json"
    try:
        await session.put(
            update_url,
            json=ticket_data,
            auth=aiohttp.BasicAuth(ZENDESK_EMAIL, ZENDESK_API_TOKEN),
            headers={'Accept': 'application/json'}
        )
        logger.info(f"Ticket {ticket_id} updated to status: {zendesk_status} in Zendesk!")
    except Exception as e:
        logger.error(f"Error updating ticket {ticket_id}: {e}")

# Function to create a ticket in Zendesk
async def create_zendesk_ticket(session, issue_key, issue_summary, issue_description, issue_assignee, issue_status, issue_requester):
    zendesk_status = STATUS_MAPPING.get(issue_status, "open")
    ticket_data = {
        "ticket": {
            "subject": f"Issue from Jira: {issue_summary}",
            "description": issue_description,
            "assignee": issue_assignee,
            "requester": issue_requester,
            "status": zendesk_status,
            "custom_fields": [
                {"id": JIRA_ISSUE_KEY_FIELD_ID,"value": issue_key},
                {"id": JIRA_STATUS_FIELD_ID,"value": issue_status}
            ]
        }
    }
    try:
        await session.post(
            ZENDESK_TICKET_URL,
            json=ticket_data,
            auth=aiohttp.BasicAuth(ZENDESK_EMAIL, ZENDESK_API_TOKEN),
            headers={'Accept': 'application/json'}
        )
        logger.info(f"Ticket created for Jira issue {issue_key}")
    except Exception as e:
        logger.error(f"Error creating ticket for {issue_key}: {e}")

# Main async function
async def main():
    await sync_jira_to_zendesk()

# Run the async loop
if __name__ == "__main__":
    asyncio.run(main())