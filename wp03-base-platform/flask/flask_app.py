import os
import requests
from flask import Flask, request, redirect, session, url_for, render_template_string
import webbrowser
import jwt

app = Flask(__name__)
app.secret_key = os.urandom(24)

# Hardcoded client information
client_id = 'account'
realm = 'master'

# Provided client information from environment variables
server_domain = os.getenv('SERVER_DOMAIN', 'localhost')
redirect_uri = f'https://{server_domain}/callback'
keycloak_base_url = f'https://{server_domain}/realms/{realm}/protocol/openid-connect'

@app.route('/')
def home():
    return '''
    <html>
    <head>
        <title>Keycloak Test Application</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background-color: #121212;
                color: #e0e0e0;
                margin: 0;
                padding: 0;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
            }
            .container {
                text-align: center;
                background: #1e1e1e;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
            }
            h1 {
                color: #ffffff;
            }
            p {
                color: #b0b0b0;
            }
            button {
                background-color: #6200ea;
                color: white;
                padding: 10px 20px;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-size: 16px;
            }
            button:hover {
                background-color: #3700b3;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Keycloak Test Application</h1>
            <p>Welcome to the Keycloak Test Application. Click the button below to log in or create an account.</p>
            <a href="/login"><button>Access Your Account</button></a>
        </div>
    </body>
    </html>
    '''

@app.route('/login')
def login():
    authorization_url = f"{keycloak_base_url}/auth"
    response_type = 'code'
    scope = 'openid profile email'  # Add your required scopes here
    prompt = 'login'
    return redirect(f"{authorization_url}?response_type={response_type}&client_id={client_id}&redirect_uri={redirect_uri}&scope={scope}&prompt={prompt}")

@app.route('/callback')
def callback():
    code = request.args.get('code')
    if not code:
        return "Error: No code provided", 400

    token_url = f"{keycloak_base_url}/token"
    headers = {'Content-Type': 'application/x-www-form-urlencoded'}
    data = {
        'grant_type': 'authorization_code',
        'client_id': client_id,
        'redirect_uri': redirect_uri,
        'code': code
    }
    response = requests.post(token_url, headers=headers, data=data)
    if response.status_code != 200:
        return f"Error: Unable to fetch tokens, status code {response.status_code}", 400

    tokens = response.json()
    session['tokens'] = tokens
    return redirect(url_for('dashboard'))

@app.route('/dashboard')
def dashboard():
    tokens = session.get('tokens')
    if not tokens:
        return redirect(url_for('login'))

    id_token = tokens.get('id_token')
    if not id_token:
        return "Error: No ID token found", 400

    try:
        user_info = jwt.decode(id_token.encode('utf-8'), options={"verify_signature": False})
    except jwt.DecodeError as e:
        return f"Error decoding token: {str(e)}", 400

    username = user_info.get('preferred_username')
    email = user_info.get('email')
    first_name = user_info.get('given_name')
    last_name = user_info.get('family_name')

    return render_template_string('''
    <html>
    <head>
        <title>Dashboard</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background-color: #121212;
                color: #e0e0e0;
                margin: 0;
                padding: 0;
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
            }
            .container {
                text-align: center;
                background: #1e1e1e;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
            }
            h1 {
                color: #ffffff;
            }
            p {
                color: #b0b0b0;
            }
            .details {
                text-align: left;
                margin-top: 20px;
            }
            button {
                background-color: #f44336;
                color: white;
                padding: 10px 20px;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-size: 16px;
                margin-top: 20px;
            }
            button:hover {
                background-color: #e53935;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Dashboard</h1>
            <p>You have successfully logged in using Keycloak.</p>
            <div class="details">
                <h2>Account Details</h2>
                <p><strong>Username:</strong> {{ username }}</p>
                <p><strong>Email:</strong> {{ email }}</p>
                <p><strong>First Name:</strong> {{ first_name }}</p>
                <p><strong>Last Name:</strong> {{ last_name }}</p>
            </div>
            <button onclick="window.location.href='/logout'">Logout</button>
        </div>
    </body>
    </html>
    ''', username=username, email=email, first_name=first_name, last_name=last_name)

@app.route('/logout')
def logout():
    session.pop('tokens', None)
    return redirect(url_for('home'))

def start_auth_flow():
    webbrowser.open('http://localhost:4200')
    app.run(port=4200, debug=True, use_reloader=False)

if __name__ == '__main__':
    start_auth_flow()