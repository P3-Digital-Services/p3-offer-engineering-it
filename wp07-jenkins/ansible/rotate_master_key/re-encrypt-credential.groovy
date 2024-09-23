import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import org.jenkinsci.plugins.plaincredentials.*
import org.jenkinsci.plugins.plaincredentials.impl.*
import hudson.util.Secret

def getSecretById(File file, id) {
    def result = ""

    file.eachLine { line ->
        String[] parts = line.split(',')

        if (parts[0].trim() == id) {
            result = parts[2].trim()
            return
        }
    }
    return result
}

def reEncryptCredentials() {
    File file = new File('/var/jenkins_home/rotate_master_key/credentials_backup.csv')
    if (!file.exists()) {
        return
    }

    def credentialsStore = jenkins.model.Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()
    def credentials = credentialsStore.getCredentials(Domain.global())

    credentials.each { credential ->
        def updatedCredential
        if (credential instanceof UsernamePasswordCredentials) {
            def password = getSecretById(file, credential.id)
            updatedCredential = new UsernamePasswordCredentialsImpl(
                credential.scope == CredentialsScope.GLOBAL ? CredentialsScope.GLOBAL : CredentialsScope.SYSTEM,
                credential.id,
                credential.description,
                credential.username,
                password
            )
        } else if (credential instanceof StringCredentials) {
            def secret = getSecretById(file, credential.id)
            updatedCredential = new StringCredentialsImpl(
                credential.scope == CredentialsScope.GLOBAL ? CredentialsScope.GLOBAL : CredentialsScope.SYSTEM,
                credential.id,
                credential.description,
                Secret.fromString(credential.secret.getPlainText())
            )
        } else {
            println("Skipping credential of type: ${credential.getClass().getName()}")
            return
        }

        // Add the new credential and remove the old one
        credentialsStore.removeCredentials(Domain.global(), credential)
        credentialsStore.addCredentials(Domain.global(), updatedCredential)
        println("Re-encrypted credential: ${credential.id}")
    }
}

reEncryptCredentials()