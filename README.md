This is a workspace for learning the Saltstack configuration management tool
============================================================================

This workspace is being developed alongside a series of blog posts on badgerops.net. While it can be used as a stand alone framework, there will (hopefully!) be good value in following along with the blog series.

The following information should get you up and running on either OS X, Windows or Linux.

## Development Setup

### OS X

1. Install dependencies

    a. Install [Virtualbox](https://www.virtualbox.org)

    b. Install [Vagrant](https://www.vagrantup.com)
      - install vagrant plugin:
      ```bash
      vagrant plugin install vagrant-hostmanager
      ```
    c. Install [Docker for Mac](https://docs.docker.com/docker-for-mac/install/)

    d. Ensure Git is installed [Download Git](http://git-scm.com/download/mac). If already installed via xcode tools, you should be ready to go.

    e. ensure Homebrew is installed [Homebrew website](https://brew.sh/)

    f. Ensure pyaml is installed:

   ```bash
   brew install libyaml
   sudo python -m easy_install pyyaml
   ```

2. Clone the repo, build the project and run the tests (may take a while for the first time). DO NOT move on until dependencies are resolved.

    ```bash
    docker-machine start
    eval $(docker-machine env )
    git clone https://github.com/BadgerOps/salt-workspace.git
    cd salt-workspace
    make
    make test
    ```
    - if make test fails, its most likely because pyyaml is not installed

### Windows 7
(I don't use windows, but this should work)

1. Install dependencies

    a. Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads)    
    b. Install [Vagrant](https://www.vagrantup.com/downloads.html)    
    - install vagrant plugin:
    ```bash
    vagrant plugin install vagrant-hostmanager
    ```
    c. Install [boot2docker](https://github.com/boot2docker/windows-installer/releases)    
    d. Install [Download Git](https://git-scm.com/download/win)

When you install Git, you have the option to add Git and its Linux-style command line tools to your system Path.  Do this!

Select the Advanced context menu (git-cheetah plugin)

Select "Use Git and optional Unix tools from the Windows Command Prompt"

Select "Checkout Windows-style, commit Unix-style line endings"

For convenience  you’ll want to set up an elevated command prompt shortcut. - Create New Shortcut to : %windir%\system32\cmd.exe - Under the security tab confirm that it "Runs as Admin"

2. Setup boot2docker, clone the repo, build the project and run the tests (may take a while for the first time)

    ```bash
    boot2docker init
    boot2docker start
    boot2docker status # this should say "running"
    git clone https://github.com/BadgerOps/salt-workspace.git
    cd salt-workspace
    ```


## Salt development

Prior to testing your changes, make sure you build the project first. Vagrant will only expose the ./dist directory to the saltmaster's /srv directory. Running the command 'make' in the root directory should build the entire project for you.

#### *Make sure you re-run make after each local change or it will not be reflected in the virtual environment.*

This can be automated on your development machine using various tools such as [Watchman](https://facebook.github.io/watchman/). They will monitor your directory for changes and automatically run the make command for you.

Because development environment differ, this is not included in this repository.


### Linux

The Linux test hosts default to RHEL 6.x. If you want to test RHEL 7.x, set your environment variable RHEL_VERSION to 7 ```export RHEL_VERSION=7```

1. Launch the saltmaster and linux hosts ```vagrant up```. This may take a while when running for the very first time because the VM needs to be downloaded. Ensure that you're on a fast internet connection.
2. Log into the test Linux host ```vagrant ssh linux-1```. Here you can run ```sudo su -``` to become root. No password is required. (if prompted, it will be the vagrant default 'vagrant')
3. A highstate should get invoked during provisioning. To re-run a highstate, invoke ```sudo salt-call state.highstate``` from within the test VM.
4. To test a specific role, add a role to the grains file in ```/etc/salt/grains``` and re-run a highstate. For example, to test the role foo_bar, edit the grains file to match the following snippet.
```yaml
roles:
   - foo_bar
```

#### Multiple VM Testing

If testing a role/formula that requires multiple minions, you can increase the linux minion count by setting the LINUX_MINION_COUNT environment variable before running vagrant up. See below as an example.

```bash
export LINUX_MINION_COUNT=3
vagrant up /linux/
```
You should now have a linux-1, linux-2, and linux-3 machine.


####  Memory Settings

Some minions may require more than the default memory of 512MB. You may increase this before running vagrant up. The following example uses 1GB of memory per minion.

```bash
export LINUX_BOX_RAM=1024
vagrant up
```

### Windows

1. Launch the saltmaster and windows hosts ```vagrant up saltmaster```, ```vagrant up windows```. This may take a while when running for the very first time because the VM needs to be downloaded. Ensure that you are on a fast internet connection.
2. Log into the test Windows host ```vagrant rdp windows```. The username is Administrator and password is vagrant all lower case.
3. A highstate should get invoked during provisioning. To re-run a highstate, invoke ```c:\salt-call.bat state.highstate``` from within a terminal.
4. To test a specific role, add a role to the grains file in c:\salt\conf\grains and re-run a highstate. For example, to test the role foo_bar, edit the grains file to match the following snippet.
```yaml
roles:
  - foo_bar
```

## Workflow for making changes

Use the following workflow to submit a new feature or bug fix.

1. Clone the repository.
2. Ensure your user information is correct.
3. Create a new branch locally.
4. Make your changes and commit locally.
5. Push the changes to Stash to the new branch.
6. Submit a pull request.

Below is an example of steps 1-5.

```bash
git clone https://github.com/BadgerOps/salt-workspace.git
cd salt-workspace
git config user.name "Doe, John"
git config user.email john.doe@foo.tld
git checkout -b feature/some-new-feature
# Make your changes.
vim ./path/to/file.sls
# Commit your changes locally.
git add ./poth/to/file.sls
git commit -m 'Making a change to file.sls for reason foo'
# Push your changes to the Git server.
git push --set-upstream origin feature/some-new-feature
```
When you create a branch - You branch from a parent. You generally want the parent to always be an updated master. Thus before making any new branches or changes - you want to obtain an updated master. If you were to attempt to make a new branch with out running the following commands after doing the git push you would be creating a new branch that has a parent of the previous branch you just pushed.

```bash
git checkout master
git fetch
git pull origin master
git checkout -b feature/some-new-feature
```

See [Daniel Miessler's git Primer](https://danielmiessler.com/study/git/) for more help with using Git.


### Encrypting pillar values

It's possible to encrypt pillar values using the [GPG renderer](http://docs.saltstack.com/en/latest/ref/renderers/all/salt.renderers.gpg.html). This is highly advised for any sensitive information such as passwords and SSL keys.

You'll need to first install [GnuPG](https://www.gnupg.org/download/). Once installed, you can create and import the Salt key with the following command.

You can then follow [this guide](https://fedoraproject.org/wiki/Creating_GPG_Keys#Creating_GPG_Keys_Using_the_Command_Line) to create your GPG key, the following steps assume the name is 'Salt Master'

```bash
gpg --import salt_key.asc
```

You can encrypt a new password with the following command where 'mysecret' without quotes is your secret value.

```bash
echo -n 'mysecret' | gpg --armor --encrypt -r 'Salt Master'
```

Once you have this text, you can add to Pillar. Any pillar file must have the string '#!yaml|gpg' without quotes at the top in order for the GPG renderer to kick in.

When the pillar file is rendered, it will get decrypted on the master and your minion will receive the plain text value.
