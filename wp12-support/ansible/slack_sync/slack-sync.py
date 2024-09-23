import os
import requests
import json
import substring
from slack_bolt import App
from slack_bolt.adapter.socket_mode import SocketModeHandler
from requests.auth import HTTPBasicAuth

zendesk_subdomain = os.environ["ZENDESK_SUBDOMAIN"]
zendesk_email = os.environ["ZENDESK_EMAIL"]
zendesk_api_token = os.environ["ZENDESK_API_TOKEN"]
group_id = os.environ["GROUP_ID_SLACK"]
slack_bot_token = os.environ["SLACK_BOT_TOKEN"]
slack_app_token = os.environ["SLACK_APP_TOKEN"]
URL = f'https://{zendesk_subdomain}.zendesk.com/api/v2/tickets.json'

# Initializes your app with your bot token and socket mode handler
app = App(token=slack_bot_token)

def check_user(user,ticket):
    headers = {
        'Content-Type': 'application/json'
    }
    URL = f'https://{zendesk_subdomain}.zendesk.com/api/v2/tickets/{ticket}.json'
    auth = HTTPBasicAuth(f'{zendesk_email}/token', zendesk_api_token)
    response = requests.get(URL,auth=auth,headers=headers)
    data = response.json()
    data2 = json.dumps(data)
    if data2.find(f'user:{user.lower()}') != -1:
        return bool(True) #if it is this users ticket
    else:
        return bool(False) #if it isn't

def check_if_exists(msgID,URL):
    headers = {
        'Content-Type': 'application/json'
    }
    auth = HTTPBasicAuth(f'{zendesk_email}/token', zendesk_api_token)
    response = requests.get(URL,auth=auth,headers=headers )
    data = response.json()
    data2 = json.dumps(data)
    data3 = str(data["next_page"])

    if data2.find(f'slack:{msgID}') != -1:
        return bool(True) #if it exists 
    elif data3.find("https") != -1:
        URL = data["next_page"]
        return check_if_exists(msgID,URL)
    else:
        return bool(False) #if does not exist

# Function to create a Zendesk ticket
def create_zendesk_ticket(subject, description,msgID,user):
    if check_if_exists(msgID,URL):
        return 'Ticket already exists'
    else:
        url = f'https://{zendesk_subdomain}.zendesk.com/api/v2/tickets.json'
        headers = {
            'Content-Type': 'application/json'
        }

        data = {
        "ticket": {
            "comment": {
            "body": description
            },
            "group_id": group_id,
            "tags": [
                "devops",
                f'slack:{msgID}',
                f'user:{user}'
                ],
            "priority": "low",
            "subject": subject
            }
        }
        payload=json.dumps(data)
        auth = HTTPBasicAuth(f'{zendesk_email}/token', zendesk_api_token)
        response = requests.post(url, auth=auth, headers=headers, json=json.loads(payload))
        if response.status_code == 201:
            
            odgovor = json.loads(response.text)['ticket']['id']
            odgovor2 = f'we successfully created ticket with id: <https://{zendesk_subdomain}.zendesk.com/agent/tickets/{odgovor}|{odgovor}> for you'
            return odgovor2
        else:
            return f'Failed to create ticket: {response.status_code}'

# Function to reply to Zendesk ticket
def reply_zendesk_ticket(description,ticketID,msgID,user):
    if check_if_exists(msgID,URL):
        return 'comment already exists'
    elif check_user(user,ticketID) == False:
        return 'unfortunately you do not have permissions to comment on this ticket'
    else: 
        replyURL = f'https://{zendesk_subdomain}.zendesk.com/api/v2/tickets/{ticketID}'
        data = {
            "ticket": {
            "comment": {
                "body": description,
                "public": "true"
                }
            }
        }
        headers = {
        "Content-Type": "application/json",
        }
        tagData = {
            "ticket": {
                "additional_tags":[
                    f'slack:{msgID}'
                ]
            }
        }
        payload=json.dumps(data)
        auth = HTTPBasicAuth(f'{zendesk_email}/token', zendesk_api_token)
        response = requests.put(replyURL,auth=auth,headers=headers,json=json.loads(payload))
        tagURL = f'https://example.zendesk.com/api/v2/tickets/update_many?ids={ticketID}'
        payload=json.dumps(tagData)
        requests.put(tagURL,auth=auth,headers=headers,json=json.loads(payload))
        if response.status_code == 200:   
                odgovor = json.loads(response.text)['ticket']['id']
                odgovor2 = f'you successfully replyed to ticket with id: <https://{zendesk_subdomain}.zendesk.com/agent/tickets/{odgovor}|{odgovor}>'
                return odgovor2
        else:
                return f'Failed to create ticket: {response.status_code}'

#handling reply message(replying with form)
@app.message("reply")
def message_hello(message, say):
    blocks= """[
		{
			"type": "input",
            "block_id": "ticketid_block",
			"element": {
			    "type": "plain_text_input",
			    "action_id": "plain_text_input-reply1"
			},
			"label": {
			    "type": "plain_text",
			    "text": "Ticket ID"
			}
		},
		{
			"type": "input",
            "block_id": "comment_block",
			"element": {
			    "type": "plain_text_input",
			    "multiline": true,
			    "action_id": "plain_text_input-reply2"
			},
			"label": {
			    "type": "plain_text",
			    "text": "Comment"
			}
		},
		{
			"type": "actions",
            "block_id": "reply1",
			"elements": [
				{
				    "type": "button",
                    "action_id": "reply_ticket",
				    "text": {
					    "type": "plain_text",
					    "text": "Send"
					},
					"style": "primary",
					"value": "click_me_123"
				},
			]
		}
	]"""
    say(blocks=blocks,text="Ticket reply form")

#handling ticket message(replying with form)
@app.message("ticket")
def template(message,say):
    blocks= """[
		{
			"type": "input",
            "block_id": "subject_block",
			"element": {
			    "type": "plain_text_input",
			    "action_id": "plain_text_input-action1"
			},
			"label": {
			    "type": "plain_text",
			    "text": "Ticket Subject"
			}
		},
		{
			"type": "input",
            "block_id": "description_block",
			"element": {
			    "type": "plain_text_input",
			    "multiline": true,
			    "action_id": "plain_text_input-action2"
			},
			"label": {
			    "type": "plain_text",
			    "text": "Description"
			}
		},
		{
			"type": "actions",
            "block_id": "actions1",
			"elements": [
				{
				    "type": "button",
                    "action_id": "send_ticket",
				    "text": {
					    "type": "plain_text",
					    "text": "Send"
					},
					"style": "primary",
					"value": "click_me_123"
				},
			]
		}
	]"""
    say(blocks=blocks,text="Ticket subbmision form")

#when reply form is subbmited
@app.action("reply_ticket")
def handle_reply(ack, body, logger,say):
    ack()
    logger.info(body)
    ticketid = body['state']['values']['ticketid_block']['plain_text_input-reply1']['value']
    description = body['state']['values']['comment_block']['plain_text_input-reply2']['value']
    ts = body['message']['ts']
    user = body['user']['id']
    reply = reply_zendesk_ticket(description,ticketid,ts,user)
    say(f"Hey there, {reply}")

#when new ticket form is subbmited
@app.action("send_ticket")
def handle_ticket(ack, body, logger,say):
    ack()
    logger.info(body)
    subject = body['state']['values']['subject_block']['plain_text_input-action1']['value']
    description = body['state']['values']['description_block']['plain_text_input-action2']['value']
    ts = body['message']['ts']
    user = body['user']['id']
    reply = create_zendesk_ticket(subject, description,ts,user)
    say(f"Hey there, {reply}")

#when message is not something predefined
@app.event("message")
def handle_message_events(body, logger,say):
    logger.info(body)
    say("Hey there, I'm Ticket Bot, if you want to create a ticket, type 'ticket' and we will send you a submission form, if you want to reply to existing ticket type 'reply' and reply form will be sent to you.")

# Starting app
if __name__ == "__main__":
    SocketModeHandler(app, slack_app_token).start()