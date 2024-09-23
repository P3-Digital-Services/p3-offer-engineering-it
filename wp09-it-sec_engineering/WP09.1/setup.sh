#!/bin/sh


# Install
echo "****  Get up-to-date SCAP profiles from ComplianceAsCode   ****"

curl -L -O https://github.com/ComplianceAsCode/content/releases/download/v0.1.74/scap-security-guide-0.1.74.zip
unzip scap-security-guide-0.1.74.zip

#Scan and Remediate
#Before report
echo "*** Generate "before" report ***"
mkdir /tmp/reports
oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_level1_workstation --results-arf cis-benchmark-results.xml --report /tmp/reports/report-before.html ./scap-security-guide-0.1.74/ssg-ubuntu2204-ds.xml
sleep 5

#Remediate
echo "*** Run OpenSCAP remediation ***"
oscap xccdf eval --remediate --profile xccdf_org.ssgproject.content_profile_cis_level1_workstation --results-arf cis-benchmark-results.xml ./scap-security-guide-0.1.74/ssg-ubuntu2204-ds.xml || echo "Seems the scan finished with non-zero error code:      $?"
sleep 10

if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ] && { dpkg-query --show --showformat='${db:Status-Status}\n' 'postfix' 2>/dev/null | grep -q installed; }; then

var_postfix_inet_interfaces='loopback-only'


if [ -e "/etc/postfix/main.cf" ] ; then

    LC_ALL=C sed -i "/^\s*inet_interfaces\s\+=\s\+/Id" "/etc/postfix/main.cf"
else
    touch "/etc/postfix/main.cf"
fi
# make sure file has newline at the end
sed -i -e '$a\' "/etc/postfix/main.cf"

cp "/etc/postfix/main.cf" "/etc/postfix/main.cf.bak"
# Insert at the end of the file
printf '%s\n' "inet_interfaces=$var_postfix_inet_interfaces" >> "/etc/postfix/main.cf"
# Clean up after ourselves.
rm "/etc/postfix/main.cf.bak"

systemctl restart postfix

else
    >&2 echo 'Remediation is not applicable, nothing was done'
fi

#After report
echo "*** Generate "after" report ***"
oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_level1_workstation --results-arf cis-benchmark-results.xml --report /tmp/reports/report-after.html ./scap-security-guide-0.1.74/ssg-ubuntu2204-ds.xml
sleep 10