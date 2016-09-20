# emc-ssh-bosh-release

EMC SSH bosh package is used to

  - initilize users you defined in manifest
  - add authorized key to the specified users on bosh vms

EMC SSH bosh package was a part of [emc-postgresql-service-bosh-release] (pgsql service). In pgsql service, there are many situations that require to execute commands/scripts from a remote host. For example, if pgsql master node is failed and failover procedure is performing, pgpool(a remote host to standby node) will execute command "touch $trigger_file" on pgsql standby node over ssh. In this case, we expect the command can be executed smoothly, without password(or other) prompt, because the whole failover procedure should be performed automatically. To achieve this goal, we introduced ssh authorized keys to pgpool node and every pgsql node; with the keys, commands/scripts can be executed remotely without password prompt with a particular user.

When pgsql service was promoted, we decided to separate the ssh job from [emc-postgresql-service-bosh-release] to a brand new Bosh package(EMC SSH bosh package), so that other bosh packages can leverage if they have similar requirements.

## Deployment
Generally speaking, EMC SSH Bosh release is supposed to be deployed with other Bosh release. For example, to deploy [emc-postgresql-service-bosh-release], the SSH Bosh release should be added into "releases" section in deployment manifest, and "ssh" template should be added into postgresql and pgpool jobs respectively.

### Generating Keys
First step to deploy the ssh bosh release, you should generate authorized keys for every authorized user and host. On your workstation(Unix-like OS), run
```sh
$ ssh-keygen -t rsa
```
then you should be prompted,
```
Enter file in which to save the key (/Users/liuc11/.ssh/id_rsa):
```
input a file path where you want to save the key file, then
```
Enter passphrase (empty for no passphrase):
```
don't input anything for it, just press "enter", then you will get a couple of keys(id_rsa and id_rsa.pub).

### Editing Manifest File
We have a [sample deployment manifest file], you can simply edit it refer to your environment.

### Creating & Uploading the BOSH Release
```sh
$ bosh target BOSH_HOST
$ git clone https://github.com/emc-cloudfoundry/emc-ssh-bosh-release.git
$ cd emc-ssh-bosh-release
$ bosh create release --force
$ bosh create release --force --final
$ bosh upload release
```
### Deploying
Using the previous created deployment manifest, now we can deploy it:
```sh
bosh deployment path/to/manifest.yml
bosh -n deploy
```

   [emc-postgresql-service-bosh-release]: <https://github.com/emc-cloudfoundry/emc-postgresql-service-bosh-release>

   [sample deployment manifest file]: <https://github.com/emc-cloudfoundry/emc-ssh-bosh-release/blob/master/ssh.sample.yml>
