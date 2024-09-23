import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import org.jenkinsci.plugins.plaincredentials.*
import org.jenkinsci.plugins.plaincredentials.impl.*
import hudson.util.Secret

def credentialsStore = jenkins.model.Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()
def credentials = credentialsStore.getCredentials(Domain.global())

// Define the directory path and file path
def directoryPath = "/var/jenkins_home/rotate_master_key"
def filePath = "${directoryPath}/credentials_backup.csv"

// Create the directory if it doesn't exist
def directory = new File(directoryPath)
if (!directory.exists()) {
    directory.mkdirs()
}

def file = new File(filePath)
file.withPrintWriter('UTF-8') { pw ->
    credentials.each { credential ->
        def builder = new StringBuilder(credential.id)

        if (credential instanceof UsernamePasswordCredentials) {
            builder.append(",UsernamePasswordCredentials")
            builder.append(",${credential.password.getPlainText()}")
        } else if (credential instanceof StringCredentials) {
            builder.append(",StringCredentials")
            builder.append(",${credential.secret.getPlainText()}")
        } else {
            println("Skipping credential of type: ${credential.getClass().getName()}")
            return
        }

        pw.println(builder.toString())
        println("Backup credential Id: ${credential.id}")
    }
}
