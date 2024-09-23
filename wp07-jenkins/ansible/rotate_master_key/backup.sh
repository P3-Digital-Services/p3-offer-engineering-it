#!/bin/bash

# Set variables
JENKINS_URL="http://localhost:8080"
JENKINS_USER=$1
JENKINS_API_TOKEN=$2
CLI_JAR_PATH="/var/jenkins_home/rotate_master_key/jenkins-cli.jar"
GROOVY_SCRIPT_PATH="/var/jenkins_home/rotate_master_key/backup-credentials.groovy"

# Check if the file exists
if [ ! -f "$CLI_JAR_PATH" ]; then
    # Download the Jenkins CLI JAR
    curl -fSL ${JENKINS_URL}/jnlpJars/jenkins-cli.jar -o ${CLI_JAR_PATH}
fi

# Check whoami
java -jar ${CLI_JAR_PATH} \
    -auth "$JENKINS_USER:$JENKINS_API_TOKEN" \
    -s ${JENKINS_URL} who-am-i

# Run the Jenkins CLI with Groovy script
java -jar "$CLI_JAR_PATH" \
    -auth "$JENKINS_USER:$JENKINS_API_TOKEN" \
    -s "$JENKINS_URL" \
    groovy = < "$GROOVY_SCRIPT_PATH"