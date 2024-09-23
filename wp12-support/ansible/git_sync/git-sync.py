from flask import Flask, request, jsonify
import requests
from requests.auth import HTTPBasicAuth
import re
import logging
import json
import os

app = Flask(__name__)

ZENDESK_SUBDOMAIN = os.environ["ZENDESK_SUBDOMAIN"]
ZENDESK_EMAIL = os.environ["ZENDESK_EMAIL"]
ZENDESK_API_TOKEN = os.environ["ZENDESK_API_TOKEN"]
ZENDESK_GROUP = os.environ["ZENDESK_GROUP"]

@app.route('/github-webhook', methods=['POST'])
def github_webhook():
    event = request.headers.get('X-GitHub-Event')
    payload = request.json

    logging.info(f"Received payload: {payload}")
    print(payload)

    if event == 'issues':
        issue = payload.get('issue')
        action = payload.get('action')

        if action == 'opened':
            create_ticket(issue)
        elif action == 'closed':
            close_ticket(issue)
        elif action == 'unlabeled':
            update_ticket_tags(issue)
        elif action == 'labeled':
            update_ticket_tags(issue)
        elif action == 'assigned':
            update_ticket_tags(issue)
        elif action == 'unassigned':
            update_ticket_tags(issue)


    elif event == 'issue_comment':
        comment = payload.get('comment')
        issue = payload.get('issue')
        action = payload.get('action')

        if action == 'created':
            add_comment_to_ticket(issue, comment)



    return jsonify({'status': 'success'}), 200

def create_ticket(issue):
    labels = [label['name'].replace(' ', '_') for label in issue['labels']]
    required_labels = ['bug', 'devops', 'good_first_issue']
    missing_labels = [label for label in required_labels if label not in labels]
    if missing_labels:
        labels.append('MISSING_LABELS')
    if not issue.get('assignees'):
        labels.append('NOT_ASSIGNED')
    url = f'https://{ZENDESK_SUBDOMAIN}.zendesk.com/api/v2/tickets.json'
    headers = {'Content-Type': 'application/json'}
    auth = HTTPBasicAuth(f'{ZENDESK_EMAIL}/token', ZENDESK_API_TOKEN)
    data = {
        "ticket": {
            "subject": issue['title'],
            "description": f"{issue['body']}\n\nIssue ID: {issue['id']}",
            "tags": labels,
            "status": "open",
            "group_id": ZENDESK_GROUP
        }
    }
    try:
        payload=json.dumps(data) 
        print(payload)
        response = requests.post(url, json=json.loads(payload), headers=headers, auth=auth)
        print(response)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        logging.error(f"Error creating ticket: {e}")
        return None

def extract_github_issue_id(issue_body):
    match = re.search(r'Issue ID: (\d+)', issue_body)
    return match.group(1) if match else None



def close_ticket(issue):
    issue_id = issue['id']
    search_url = f'https://{ZENDESK_SUBDOMAIN}.zendesk.com/api/v2/search.json?query=type:ticket+status:open'
    headers = {'Content-Type': 'application/json'}
    auth = HTTPBasicAuth(f'{ZENDESK_EMAIL}/token', ZENDESK_API_TOKEN)
    try:
        search_response = requests.get(search_url, headers=headers, auth=auth)
        search_response.raise_for_status()
        tickets = search_response.json().get('results', [])

        for ticket in tickets:
            ticket_issue_id = extract_github_issue_id(ticket['description'])
            if ticket_issue_id == str(issue_id):
                print(issue_id)
                ticket_id = ticket['id']
                print(ticket_id)
                close_url = f'https://{ZENDESK_SUBDOMAIN}.zendesk.com/api/v2/tickets/{ticket_id}.json'
                data = {'ticket': {'status': 'closed'}}
                payload=json.dumps(data)
                close_response = requests.put(close_url, json=json.loads(payload), headers=headers, auth=auth)
                close_response.raise_for_status()
                return close_response.json()
        return None
    except requests.exceptions.RequestException as e:
        print(f"Error closing ticket: {e}")
        return None
    
def add_comment_to_ticket(issue, comment):
    issue_id = issue['id']
    search_url = f'https://{ZENDESK_SUBDOMAIN}.zendesk.com/api/v2/search.json?query=type:ticket+status:open'
    headers = {'Content-Type': 'application/json'}
    auth = (f'{ZENDESK_EMAIL}/token', ZENDESK_API_TOKEN)
    search_response = requests.get(search_url, headers=headers, auth=auth)
    tickets = search_response.json().get('results', [])

    for ticket in tickets:
        ticket_issue_id = extract_github_issue_id(ticket['description'])
        if ticket_issue_id == str(issue_id):
            ticket_id = ticket['id']
            comment_url = f'https://{ZENDESK_SUBDOMAIN}.zendesk.com/api/v2/tickets/{ticket_id}.json'
            data = {
            "ticket": {
                "comment": {
                "body": comment['body']
                }
                
            }
            }
            payload=json.dumps(data)
            comment_response = requests.put(comment_url, headers=headers, auth=auth, json=json.loads(payload))
            return comment_response.json()
        
def update_ticket_tags(issue):
    issue_id = issue['id']
    labels = [label['name'].replace(' ', '_') for label in issue['labels']]
    required_labels = ['bug', 'devops', 'good_first_issue']
    missing_labels = [label for label in required_labels if label not in labels]
    if missing_labels:
        labels.append('MISSING_LABELS')
    if not issue.get('assignees'):
        labels.append('NOT_ASSIGNED')
    print(f"LABELE SU: {labels}")
    search_url = f'https://{ZENDESK_SUBDOMAIN}.zendesk.com/api/v2/search.json?query=status:open'
    headers = {'Content-Type': 'application/json'}
    auth = (f'{ZENDESK_EMAIL}/token', ZENDESK_API_TOKEN)
    search_response = requests.get(search_url, headers=headers, auth=auth)
    tickets = search_response.json().get('results', [])

    for ticket in tickets:
        ticket_issue_id = extract_github_issue_id(ticket['description'])
        if ticket_issue_id == str(issue_id):
            ticket_id = ticket['id']
            print(ticket)
            update_url = f'https://{ZENDESK_SUBDOMAIN}.zendesk.com/api/v2/tickets/{ticket_id}.json'
            clear_data = {"ticket": {"tags": []}}
            clear_payload = json.dumps(clear_data)
            requests.put(update_url, json=json.loads(clear_payload), headers=headers, auth=auth)            
            
            update_data = {"ticket": {"tags": labels}}
            update_payload = json.dumps(update_data)
            update_response = requests.put(update_url, json=json.loads(update_payload), headers=headers, auth=auth)
            return update_response.json()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000, ssl_context=('/home/app/selfsigned.crt', '/home/app/selfsigned.key'))
