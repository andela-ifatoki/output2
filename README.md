# Output 2: Databases and Loadbalancing

This repository contains code for the setup of a Postgresql Database Cluster with a Master server and 2 replicas. It also uses HAProxy to implement loadbalancing and monitoring within the cluster.

## TECHNOLOGY STACK

The following technologies were used in the set up:

* [Google Cloud](https://console.cloud.google.com): The whole infrastructure for the project is built on Google Cloud.
* [Terraform](https://www.terraform.io/): Terraform makes it easy to spin up and tear down complex infrastructure. It does this through Infrastructure As Code (IAC). The infrastructure for this project is built with Terraform.
* [Postgres](https://www.postgresql.org/about/): Postgres is an extensible Object Relation Database Management System (ORDBMS). The databases used in this project are Postgres databases.
* [HAProxy](http://www.haproxy.org/): HAProxy is a free, fast, and efficient open source software that provides high availability loadbalancing and proxy servers for TCP and HTTP-based applications. HAProxy is used to loadbalance and monitor the cluster.

## SETUP

### GOOGLE CLOUD

1. Create an account on [Google Cloud](https://cloud.google.com). Skip this step if you already have an account
2. Go to https://console.cloud.google.com
3. Click on the drop down shown in the image below


![image](https://user-images.githubusercontent.com/26189554/49220833-8afaa380-f3d7-11e8-8d3e-9db09f49d57c.png)


4. From the modal that pops up, copy the project ID of the project you want to create the instance in and paste it somewhere.
For a new Google Cloud account, a default project is automatically created for you. 
You can also create a new project by clicking on the NEW PROJECT button in the top right corner of the screen.


![image](https://user-images.githubusercontent.com/26189554/49221450-77e8d300-f3d9-11e8-86fe-065acf6ab651.png)

#### 5. CREATE A SERVICE ACCOUNT KEY
a. Click on the menu icon > APIs and Services > Credentials

![image](https://user-images.githubusercontent.com/26189554/49341115-5130d380-f649-11e8-8ece-6e5d10b86d38.png)

b. Click on Create credentials > Service account key

![image](https://user-images.githubusercontent.com/26189554/49341187-390d8400-f64a-11e8-9485-725f57dbb85d.png)

c. Click the Service account dropdown, then select New service account

![image](https://user-images.githubusercontent.com/26189554/49341240-e7b1c480-f64a-11e8-8a44-3a849a2ce798.png)


d. Give the service account a name. Select Project > Owner for role; this would give that service account full access.
Leave the JSON key type selected then click on the Create button to download the service key.

![image](https://user-images.githubusercontent.com/26189554/49341305-ad94f280-f64b-11e8-9e64-a7ef0eeb59b2.png)


### TERRAFORM


Go [here](https://www.terraform.io/intro/getting-started/install.html) for instructions on how to install Terraform. 
Proceed to the next stage once you have Terraform installed.


#### INFRASTRUCTURE BUILD

As stated in the Technology Stack section, Terraform is used to build the infrastructure for this project. There are 4 instances; 1 Master DB, 2 Replica DBs, and 1 NAT instance which doubles as the HAProxy server.
Follow the steps below to build the infrastructure.

1. Clone this project if you haven't done so already by running
    ``` CLONE PROJECT
    git clone https://github.com/baasbank/output2.git
    ```
2. Change directory into the terraform folder by running
```CHANGE DIRECTORY
cd output2/terraform
```
3. In the provider section of the `main.tf` file, replace `key.json` in credentials with the path to the Service account key  downloaded from the Google Cloud Setup section above. 

4. In the `variables.tf` file, replace the current project name with the one you copied from Step 4 of the Google Cloud setup above.

5. Make sure you are in the terraform directory, then run the following

```TERRAFORM BUILD
terraform init
terraform plan
terraform apply
```

Running the last command produces a prompt. Enter `yes`.

![image](https://user-images.githubusercontent.com/26189554/49341824-2f3c4e80-f653-11e8-9f69-9367edede29b.png)


6. You get the following message on a successful build
![image](https://user-images.githubusercontent.com/26189554/49700482-7d1afe80-fbdf-11e8-864b-c674ff17f700.png)


7. Go back to https://console.cloud.google.com

8. Click on the menu icon > Compute Engine > VM instances

![image](https://user-images.githubusercontent.com/26189554/49341983-fdc48280-f654-11e8-9622-65ce1263b582.png)

You should see the instances you just created, similar to the image below.

![image](https://user-images.githubusercontent.com/26189554/49718433-5bab2880-fc5a-11e8-9b68-1588c04ea51f.png)



#### DATABASE REPLICATION SETUP

As a matter of best practices, the databases are placed in a private subnet and do not have external IP addresses. The NAT(Network Address Translation) instance however, even though it is in the same VPC(Virtual Private Cloud), is in the public subnet. Hence, the only way to access the database instances is through the NAT instance.
Follow the steps below to set up the replica databases and HAProxy.


##### MASTER DB SETUP
There is no setup necessary for the MasterDB. The `master_db_setup.sh` script gets executed when the machine starts, and does the necessary setup on the MasterDB.
More information about the workings of this is available [here](https://docs.google.com/document/d/1rfxoyY1wu309Zchg1gkrU6-yBEXP0bLRQfhZXEQ-uzA/edit?usp=sharing).

##### REPLICA DB SETUP

1. From the list of instances, click on the `SSH` button for the nat-instance. This will open a new ssh connection to the nat-instance in the browser.

![image](https://user-images.githubusercontent.com/26189554/49719068-5d75eb80-fc5c-11e8-84f9-2914680a22a0.png)

2. 
  * Once you're in the nat-instance, run the following command to connect to replicationdb1.
```GCLOUD
gcloud beta compute ssh --internal-ip replicationdb1
```
  * Press `enter` at the prompts for passphrase, then type `Y` at the prompt for zone confirmation. Wait for a second a two, and it takes you into `replicationdb1`.
  
  
  ![image](https://user-images.githubusercontent.com/26189554/49719618-f3f6dc80-fc5d-11e8-9a27-50df0a7a464c.png)

  
3. Clone this repository by running
```GIT
git clone https://github.com/baasbank/output2.git
```

4. Change into the output2 directory by running
```GIT
cd output2
```

5. Execute the `replica_db_setup1.sh` script by running
```bash
. replica_db_setup1.sh
```

6. Run the following command to take a backup of the MasterDB. Make sure to replace `10.0.0.4` with the IP address for your masterdb
```bash
sudo su postgres -c "pg_basebackup -h 10.0.0.4 -D /var/lib/postgresql/9.6/main -P -U replication --xlog-method=stream;"
```
Running the above command prompts for a password. This is the replication user password which was set in `master_db_setup.sh`, which in this case is `password`. Type in the password and press Enter.
A backup of the MasterDB is created as shown in the image below

![image](https://user-images.githubusercontent.com/26189554/49723554-5accc380-fc67-11e8-821e-7361b5044ff4.png)

7. Execute the `replica_db_setup2.sh` script by running
```bash
. replica_db_setup2.sh
```

###### Repeat the above steps for replicaDB2. Be sure to change the name of the DB you're connecting to in step 2 to `replicationdb2`


##### HAPROXY SETUP
As stated below, the NAT instance doubles as the HAProxy server. Follow the steps below to set up HAProxy for loadbalancing and monitoring.

1. From the list of instances, click on the `SSH` button for the nat-instance. This will open a new ssh connection to the nat-instance in the browser.

![image](https://user-images.githubusercontent.com/26189554/49719068-5d75eb80-fc5c-11e8-84f9-2914680a22a0.png)

2. Clone this repository by running
```GIT
git clone https://github.com/baasbank/output2.git
```

3. Change into the output2 directory by running
```GIT
cd output2
```

4. Edit the `haproxy_setup.sh` script to make sure the IP addresses for the MasterDB and the ReplicaDBs match what you have on Google Cloud. The edit should be made in the `listen postgres` section of the file as shown below. Run the following command to open the file.
```bash
sudo vim haproxy_setup.sh
```

![image](https://user-images.githubusercontent.com/26189554/49726165-a5e9d500-fc6d-11e8-8b7a-c0674ab11b49.png)

When you're done editing, save and exit the file.


5. Execute the `haproxy_setup.sh` script by running
```bash
. haproxy_setup.sh
```

6. Copy the external IP address of the nat-instance, and open that in the browser. Ensure you use http and you specify port 7000. You should see the HAProxy Statistics Report Page, showing the status of the loadbalanced Databases.
The Report Page address for my setup is http://35.246.134.67:7000/ . Below is an image of the page.

![image](https://user-images.githubusercontent.com/26189554/49726768-0a596400-fc6f-11e8-82cb-7ea9aaf12052.png)

