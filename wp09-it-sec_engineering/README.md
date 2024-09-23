# CARIAD EngIT Frame – tech task – WP09 – IT Sec

## Overview
In this repos, we are focusing on resolving the challage engineering tasks from two parts:
- VM Image Hardening and Image Building with Packer
- Setup a Remote Access Service with Boundary

### VM Image Hardening and Image Building with Packer

- Build an Ubuntu 22.04 Azure image with Packer. Use the standard image from Canonical as the base image for Packer and apply the following hardening adaptations. Packer configuration and used scripts must be presented for result validation.
- Use OpenSCAP to perform CIS Level 1 Workstation benchmark hardening. Show before vs. after reports. In case exceptions are necessary, explain why and what are the resulting risks.
- Remove the Azure Agent from the image.

### Setup a Remote Access Service with Boundary
- Setup a local single-VM Boundary installation (no use of containers, or Boundary DEV mode, run controller and worker on the same VM). Create a single user with password authentication which can access a single target. This target points to a static dummy HTTPS website served by a local Apache (on localhost only). Secure the service. Choose FQDNs as necessary and create a self-signed, but proper TLS certificate.
- Create restrictive netfilter rules.
- Install an upstream Apache reverse proxy on the same VM to restrictively allow inbound API connections for authentication and connecting to the target.
- Adapt the Boundary client and the reverse proxy, such that the Auth Method ID is fetched per HTTPS from the Boundary endpoint (can be served hard-coded statically) and the user can log in without the need of starting the Boundary client with additional command-line parameters. Connect to the target.
  
## Folder structure
```
.
├── WP09.1
│   ├── WP09_IT-Sec_Engineering_part_1.md
│   ├── WP09_IT-Sec_Engineering_part_1.pdf
│   ├── ami-script.pkr.hcl
│   ├── cloud-init.yaml
│   ├── images -> contain images that used for documentation
│   ├── reports
│   │   ├── report-after.html
│   │   └── report-before.html
│   └── setup.sh
├── WP09.2
│   ├── WP09_IT-Sec_Engineering_part_2.md
│   ├── WP09_IT-Sec_Engineering_part_2.pdf
│   ├── apache2 -> Apache2 configuration file
│   │   ├── boundary.conf
│   │   ├── dummy.conf
│   │   └── ports.conf
│   ├── bin -> New Boundary binary with hardcode URL
│   │   └── boundary
│   ├── boundary
│   │   ├── boundary.hcl
│   │   └── worker.hcl
│   └── images -> contain images that used for documentation
└── readme.md
```