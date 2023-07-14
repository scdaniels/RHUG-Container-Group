# RHUG-Container-Group
Sample configuration files for creating an AAP Container Group on OCP

Instructions on creating the OCP Service Account can be found here:
https://docs.ansible.com/automation-controller/latest/html/administration/containers_instance_groups.html#ag-container-groups


Reference Material:
	- Ansible docs:  https://docs.ansible.com/automation-controller/latest/html/administration/containers_instance_groups.html
	- AAP on OCP Learnings (from Eric :  https://docs.google.com/document/d/1G6rEOr4-aH-JKbkqPcHv0ojPdnk59vcOXkWKtDkNH9Y/edit?pli=1#heading=h.66y4kqbj468a



Updated procedure from the Ansible docs:

To configure the controller:
1. To create a service account, you may download and use this sample service account, containergroup sa and modify it as needed to obtain the above credentials.
2. Login to OpenShift and set to the appropriate project

oc login --server ... --token … --certificate-authority=$HOME/ocp-xxxxx.ca.crt

Create a new project (and namespace) that relates to the location of the container group.  For example, if the CG will be in azure-useast use a name such as the following.

oc new-project aap-cg-azure-useast

3. Apply the configuration from containergroup-sa.yml:

oc apply -f containergroup-sa.yml

4. Set the Service Account name into and environment variable

export SA_NAME=aap-cg-sa

5. Get the secret name associated with the service account:
First, run the main portion of the command to see which secret will be captured.  We have observed that this could be the token secret that we desire or the dockercfg secret.  If the dockercfg secret is fetched then step 6 will be necessary

export SA_SECRET_0=$(oc get sa ${SA_NAME} -o json | jq '.secrets[0].name' | tr -d '"')

6. New!  The step above SOMETIMES retrieve the dockercfg secret and does not have the token value.  However, this secret has an owner secret value that we can use to lookup the token value.  In this new step we will retrieve the name of the owner (parent) secret for the subsequent steps.  Notice that we changed the name of the environment variable to be SA_SECRET_0 in the step above.

export SA_SECRET=$(oc get secret ${SA_SECRET_0} -o json | jq ".metadata.ownerReferences[].name" | tr -d '"' | xargs)

7. Get the token from the secret:

oc get secret $(echo ${SA_SECRET}) -o json | jq '.data.token' | xargs | base64 --decode > containergroup-sa.token

8. Get the CA cert:

oc get secret $SA_SECRET -o json | jq '.data["ca.crt"]' | xargs | base64 --decode > containergroup-ca.crt

9. Use the contents of containergroup-sa.token and containergroup-ca.crt to provide the information for the OpenShift or Kubernetes API Bearer Token required for the container group.
To create a container group:

10. Use the controller user interface to create an OpenShift or Kubernetes API Bearer Token credential that will be used with your container group, see Add a New Credential in the Automation Controller User Guide for detail.

11. Create a new container group by navigating to the Instance Groups configuration window by clicking Instance Groups from the left navigation bar.

12. Click the Add button and select Create Container Group.

13. Enter a name for your new container group and select the credential previously created to associate it to the container group.

From <https://docs.ansible.com/automation-controller/latest/html/administration/containers_instance_groups.html> 


