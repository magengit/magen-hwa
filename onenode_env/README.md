# Demo Setup for 'Hello, World!' App


## Single Host Magen Demo


The setup consists of 6 containers running on a single *nix instance.

   1. id service
   2. key service
   3. ingestion service
   4. policy service
   1. mongo container shared by first 4 services
   4. "Hello, World!" app to demonstrate how the core services work
   together.

## Common Requirements across OS

0. ```python3 -V```: Python >= **3.6.3** 
1. ```pip3 -V```: pip **9.0.1**
2. ```docker -v```: Docker version **17.03.0-ce**, build 60ccb22
3. ```docker-compose -v```: docker-compose version **1.11.2**, build dfed245
   
## Requirements: MacOS X
0. ```make -v```: GNU Make **3.81**
1. A REST tool like [POSTMAN](https://www.getpostman.com/apps)

## Requirements: AWS EC2 Ubuntu 16.04
0. ```make -v```: GNU Make **4.1**
1. Your preferred REST Tool

## Installing HWA Demo

Clone this repo:

```
bash$ git clone --recursive https://github.com/magengit/magen-hwa.git
```

```cd``` to ```onenode_env``` directory. Command ```./onenode_install.sh install``` will display a usage of the script. Execute:

```
bash$ ./onenode_install.sh install --build-from {dockerimage|source|source_latest}
```

You can choose to build demo from ```dockerimage``` (will pull from dockerhub) and  ```source``` or ```source_latest``` (will clone git repos and build images locally).

When building from ```source``` a stable tags (v1.0) are used. By using ```source_latest``` option to ```onenode_install.sh``` script in order to build from latest source.
###### Note, that the demo is stable with tagged src and might not run correctly with latest code as we're under active development and changes of API.

After build is done follow the instructions of the output.

## The demo script will perform the next actions *by itself*:

1. Create directory tree rooted at ```~/magen_onenode```
   - directory tree contents:
     - ~/magen_onenode/magen_data/*
       - onenode.sh creates configuration files
       - above services create log files here
     - ~/magen_onenode/helper_scripts
2. If build from source, script will download all magen repos to directory tree above and build docker images from the source
3. If build from dockerimage - pulling will be performed in next steps

   NOTES:
     - This step is run from cloned repo and sets up a sandbox under
       ~/magen_onenode.
     - This script (onenode.sh) is copied to the sandbox
     - Steps below are run from the sandbox copy, e.g.
             ~/magen_onenode/onenode.sh
       since those subcommands may assume configuration files are at a
       known directory tree location relative to the location of the
       onenode.sh script.
     - An old sandbox must be deleted prior to creating a new sandbox.
       On Linux, this may require sudo, since the docker containers that
       mount directories in the sandbox and create log files run as root.
     - Browser access to hwa:
       - The -host argument affects browser access to the hwa app
         - Without the -host argument, only a local browser will be able to
           access the hwa app (e.g. where the magen instance is running
           on a Mac and the browser accesses https://localhost:5002)
         - With the -host argument supplying the public hostname (or public
           ip address) of the magen instance, a remote browser will
           be able to access the hwa app, e..g  https://<host>:5002
       - in this demo environment, hwa itself and the id service use
         self-signed certificates, so the browser will raise a security
	 warning that the app's certificate cannot be verified and needs
	 to be manually accepted.
       - manual acceptance is needed twice: one for hwa's self-signed cert
         and once for redirect to id service's self-signed cert.

## Running HWA

1. Run onenode.sh (from directory created by install in step 1) to
   - create docker images
   - start running hwa application, magen services, and mongod.

    ```
      bash$ ~/magen_onenode/onenode.sh start
    ```
    The --update flag causes a check on underlying dependencies, e.g.
   a check for updated docker images on the docker image repo
    ```
    bash$ ~/magen_onenode/onenode.sh start --update
    ```
    
## The HWA Demo


1. Navigate to https://&lt;host&gt;:5002 and accept any browser warnings

2. On the top menu click on **login** and accept any browser warnings. Now are logged into the system

3. Now on the top menu click on **ingestion** to ingest your first file. Go through the upload procedure 

4. Clicking on **repository** should show your ingested file(s)

5. Clicking on **view** should display an error message since user is not authorized

6. Using a tool like [POSTMAN](https://www.getpostman.com/apps) send the following HTTP POST Request to the URL: 

```
http://localhost:5000/magen/policy/v2/contracts/contract/:
```

Headers:

```
Content-Type:application/json
Accept:application/json
```

Body

```
{
    "policy_contract": [
        {   
            "name" : "eng policy",
            "principal": "wiley@acmebirdseed.com",
            "principal_group": "",
            "action": "open",
            "resource_doc": "",
            "resource_group": "architecture",
            "time_validity_pi" : 2592000
        }
    ]
}
```

7. Clicking on **view** now should display the file 
 
## Stopping HWA 
    
1. Shut down containers for above services (run from
   directory created by "onenode.sh create" in step 1)
   ```
   bash$ ~/magen_onenode/onenode.sh stop
   ```
2. Uninstall, including deleting ~/magen_onenode directory created in step 1)
   and onenode docker images created in step 2.
   ```
   bash$ ~/magen_onenode/onenode.sh uninstall
   ```

## Troubleshooting

If you see the message below just follow the instructions on creating a network.:

ERROR: Network magen_onenode_net declared as external, but could not be found. Please create the network manually using `docker network create magen_onenode_net` and try again.
REPENNO-M-J027:magen_onenode repenno$ docker network create magen_onenode_net
04aeec3eefcabe3bc3836d7a6e77069cb693b9ac30212d19ec3403fb7b4bfb88
