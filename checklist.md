# Table of Contents

- [Project Submission - Truck Signs API](#project-submission---truck-signs-api)
  - [1. Repository](#1-repository)
    - [Existing Files](#existing-files)
    - [Dockerfile](#dockerfile)
    - [README.md](#readmemd)
  - [2. Documentation](#2-documentation)
  - [3. Notes](#3-notes)
    - [General Notes](#general-notes)
    - [Security Notes](#security-notes)
    - [Code Conventions](#code-conventions)
    - [Testing](#testing)

---

# Project Submission - Truck Signs API

Please fulfill all points on this list before submitting the project. If you have built in additional extras, mention them briefly so that the mentors can review them if needed.

## 1. Repository

### Existing Files

- [x] A Dockerfile has been created that describes the resulting container image. The Dockerfile meets the requirements formulated below
- [x] A file named README.md exists and has been extended according to the criteria below
- [x] There are no other files in the repository without them being explicitly named and described in the README.md

### Dockerfile

- [x] You have defined a suitable base image as the foundation of your own container image
- [x] You have exposed a port of the container so that the container is accessible from the internet
- [x] You have defined all necessary steps as part of the image build process so that the application starts without additional effort
  - [x] Your entrypoint handles the migrations, collectstatic, and createsuperuser commands

### README.md

- [x] The README should contain a table of contents (ToC)
  - [x] The individual sections are linked in the ToC
- [x] A section with a description of the repository must be present. This description should state what the essential contents are and what the purpose of the repository is
- [x] A "Quickstart" section should be included as part of the README. Here, the prerequisites should be briefly mentioned and a quick start guide should be described
  - [x] There should be a section on how-to-build-the-image
- [x] A detailed variant of the aforementioned section should be included as "Usage". Here, configuration and configurability should be discussed in more detail, i.e., it should also be explained how relevant passages can be modified to achieve different results
- [x] It must be documented how a container image can be created
- [x] The docker run command must be documented - environment variables or other sensitive information should be replaced with placeholders

## 2. Documentation

- [x] The documentation of the code and the project should be in the repository in the form of a README file
- [x] The documentation language for all projects (and associated documents) is English

## 3. Notes

### General Notes

- [x] In addition to your GitHub repository, you should record and provide a short Loom video (maximum 5 minutes) in which you briefly show your submission and present what you have done - you don't have to mention all details, but you should briefly address and show all relevant steps
- [x] The containers should NOT be started with docker compose
- [x] The database should also be operated in a container
  - [x] The backend should be able to communicate with the database; for this, the containers must be in the same network
  - [x] Containers in the same network can reach each other using the hostname/container name

### Security Notes

- [x] Do not store SSH keys in your Git repository workspace
- [x] Do not store passwords, tokens, or usernames in your code. Use environment variables instead
- [x] Do not store IP addresses or other sensitive information in a Git repository

### Code Conventions

- [x] For build-args, environment variables, and shell variables, the following naming convention applies: UPPER_CASE_WITH_UNDERSCORE
- [x] When referencing a variable, always use the {}-notation to avoid errors in interpretation: ${SOME_VAR_VALUE}, instead of: $SOME_VAR_VALUE
- [x] Default values should be configured for build-args or environment variables, but only when it makes sense
- [x] Critical configuration such as tokens, passwords, or similar should not be stored in the code repository, but should be passed into a container, e.g., through the use of a .env file

### Testing

Before you submit your project, you should ensure and have tested the following:

- [x] The Truck Signs API is accessible at the IP address of your cloud VM on port 8020
- [x] Your ENTRYPOINT starts the WSGI application, NOT a dev-server
- [x] After a restart of the setup, the configured data is still present and is not deleted or overwritten
- [x] The containers are restarted as soon as an error occurs that leads to the termination of the container

---

**Checklist - Trucks API 2024**
