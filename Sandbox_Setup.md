## ONAP Jenkins Sandbox Process:

ONAP Jenkins Sandbox provides you Jenkins Job testing/experimentation environment
that can be used before pushing job templates to the production
[Jenkins](https://jenkins.onap.org).

It is configured similar to the ONAP [ci-management] production instance;
however, it cannot publish artifacts or vote in Gerrit. Be aware that this is a
test environment, and as such there is a limited allotment of minions to test on
before pushing code to the ONAP repos.
Keep the following points in mind prior to beginning work on ONAP Jenkins Sandbox
environment:

- Jobs are automatically deleted every weekend
- Committers can login and configure Jenkins jobs in the sandbox directly
- Sandbox jobs CANNOT perform any upload tasks
- Sandbox jobs CANNOT vote on Gerrit
- Jenkins nodes are configured using ONAP openstack VMs and you can not access
  these VMs directly.

Before you proceed further, ensure you have a Linux Foundation ID (LFID), which is
required to access Gerrit & Jenkins. Also, to extend your permissions for uploading
Jenkins configurations to Sandbox environment, you must raise a ticket to
[Linux Foundation Help Center](https://support.linuxfoundation.org)

To download **ci-management**, execute the following command to clone the
**ci-management** repository.

`git clone https://gerrit.onap.org/r/ci-management && (cd ci-management && curl -Lo \
$(git rev-parse --git-dir)/hooks/commit-msg https://gerrit.onap.org/r/tools/hooks/commit-msg; \
chmod +x $(git rev-parse --git-dir)/hooks/commit-msg)`

Make sure to sync global-jjb submodule using:

`git submodule update --init`

Once you successfully clone the repository, next step is to install JJB
(Jenkins Job Builder) in order to experiment with Jenkins jobs.

### Execute the following commands to install JJB on your machine:

```
cd ci-management
pip install virtualenv
virtualenv onap_sandbox
source onap_sandbox/bin/activate
pip install jenkins-job-builder
jenkins-jobs --version
jenkins-jobs test --recursive jjb/
```

### Make a copy of the example JJB config file (in the ci-management/ directory)

Backup the jenkins.ini.example to jenkins.ini

`mkdir -p ~/.config/jenkins_jobs`
`cp jenkins.ini.example ~/.config/jenkins_jobs/jenkins_jobs.ini`

After copying the jenkins.ini.example, modify `jenkins.ini` with your
**Jenkins LFID username** and **API token**

```
[job_builder]
ignore_cache=True
keep_descriptions=False
include_path=.
recursive=True
retain_anchors=True

[jenkins]
user=jwagantall <Provide your Jenkins Sandbox username>
password= <Refer below steps to get API token>
url=https://jenkins.onap.org/sandbox
query_plugins_info=False
```
### How to retrieve username and API token?
Login to the [Jenkins Sandbox](https://jenkins.onap.org/sandbox/), go to your user
page by clicking on your username - `Jenkins User ID` on this page is your Jenkins
Sandbox username. Click **Configure** and then click **Add new Token**.
After that specify a token name (optional) and click on **Generate** to generate and show
new token. Please note down your token and store it securely.

To work on existing jobs or create new jobs, navigate to the `ci-management/jjb/` directory where you
will find all job templates for the project.  Follow the below commands to test,
update or delete jobs in your sandbox environment.

## To Test a Job:

After you modify or create jobs in the above environment, it's good practice
to test the job in sandbox environment before you submit this job to production CI environment.

`jenkins-jobs test jjb/ <job-name>`

**Example:** `jenkins-jobs test jjb/ sdc-master-verify-java`

If the job you’d like to test is a template with variables in its name, it must be
manually expanded before use. For example, the commonly used template `sdc-{stream}-verify-java`
might expand to `sdc-master-verify-java`.

A successful test will output the XML description of the Jenkins job described by the
specified JJB job name.

Execute the following command to pipe-out to a directory:

`jenkins-jobs test jjb/ <job-name> -o <directoryname>`

The output directory will contain files with the XML configurations.

## To Update a job:

Ensure you’ve configured your `jenkins_jobs.ini` and verified the changes by
outputting valid XML descriptions of the relevant Jenkins jobs. Upon successful
verification, execute the following command to update the job to the Jenkins sandbox.

`jenkins-jobs update jjb/ <job-name>`

**Example:** `jenkins-jobs update jjb/ sdc-master-verify-java`

## Trigger jobs from Jenkins Sandbox:

Once you push the Jenkins job configuration to the ONAP Sandbox environment,
run the job from Jenkins Sandbox webUI. Follow the below process to trigger the build:

Step 1: Login into the [Jenkins Sandbox WebUI](https://jenkins.onap.org/sandbox/)

Step 2: Click on the **job** which you want to trigger, then click
**Build with Parameters**, and finally click **Build**.

Step 3: Verify the **Build Executor Status** bar and make sure that the build is triggered
on the available executor. In Sandbox you may not see all platforms build executors and
you don't find many like in production CI environment.

Once the job is triggered, click on the build number to view the job
details and the console output.

## To Delete a Job:

Execute the following command to Delete a job from Sandbox:

`jenkins-jobs delete jjb/ <job-name>`

**Example:** `jenkins-jobs delete jjb/ sdc-master-verify-java`

The above command would delete the `sdc-master-verify-java` job.

## Modify an Existing Job:

In the ONAP Jenkins sandbox, you can directly edit or modify the job configuration
by selecting the job name and clicking on the **Configure** button. Then, click the
**Apply** and **Save** buttons to save the job.

However, it is recommended to simply modify the job in your terminal and then follow
the previously described steps in **To Test a Job** and **To Update a Job** to perform
your modifications.

## More online documentation:

https://docs.openstack.org/infra/jenkins-job-builder/
