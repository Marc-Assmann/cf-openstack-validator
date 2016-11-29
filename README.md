# CF OpenStack Validator

Is your OpenStack installation ready to run BOSH and install Cloud Foundry? Run this validator to find out.

* Roadmap: [Pivotal Tracker](https://www.pivotaltracker.com/epic/show/2156200) (click on Add/View Stories)
* [List of executed tests](docs/list_of_executed_tests.md)

## Prerequisites

### OpenStack

* Keystone v3
* Create an OpenStack project/tenant
* Create a network
  * Connect the network with a router to your external network
* Allocate a floating IP
* Allow ssh access in the `default` security group
* Create a key pair by executing
```bash
$ ssh-keygen -t rsa -b 4096 -N "" -f cf-validator.rsa_id
```
  * Upload the generated public key to OpenStack as `cf-validator`
  
* A public image available in glance
  * If your OpenStack installation doesn't yet provide any image, you can upload a [CirrOS test image](http://docs.openstack.org/image-guide/obtain-images.html#cirros-test)

### Environment

The validator runs on Mac and Linux.
Please ensure that the following list is installed on the Linux system
where the validator is executed:

* ruby 2.x
* make
* gcc
* zlib1g-dev
* libssl-dev
* ssh

To run on Mac the `Xcode` command line tools have to be installed.

## Usage

* `git clone https://github.com/cloudfoundry-incubator/cf-openstack-validator.git`
* `cd cf-openstack-validator`
* Copy the generated private key into the `cf-openstack-validator` folder.
* Copy [validator.template.yml](validator.template.yml) to `validator.yml` and replace occurrences of `<replace-me>` with appropriate values (see prerequisites)
```bash
$ cp validator.template.yml validator.yml
```
* Download OpenStack CPI from [OpenStack CPI bosh.io](http://bosh.io/releases/github.com/cloudfoundry-incubator/bosh-openstack-cpi-release?all=1)
* Download a stemcell from [OpenStack stemcells bosh.io](http://bosh.io/stemcells/bosh-openstack-kvm-ubuntu-trusty-go_agent)
* Install dependencies
```bash
$ sudo gem install bundler
$ bundle install
```
* Start validation
```bash
$ ./validate --cpi-release bosh-openstack-cpi-release-<xxx>.tgz --stemcell bosh-stemcell-<xxx>-openstack-kvm-ubuntu-trusty-go_agent.tgz --config validator.yml
```

### When using self compiled CPI

If you have an existing compiled CPI in your system you can make the validator aware of it by using the `OPENSTACK_CPI_BIN` environment variable.

```bash
OPENSTACK_CPI_BIN=/path/to/cpi/executable ./validate --stemcell bosh-stemcell-<xxx>-openstack-kvm-ubuntu-trusty-go_agent.tgz --config validator.yml
```

## Command line help

* To learn about available options run
```bash
$ ./validate --help
```

## Extensions

You can extend the validator with custom tests. For a detailed description and examples, please have a look at the [extension documentation](./docs/extensions.md).

## Troubleshooting
The validator does not run on your OpenStack? See [additional OpenStack related configuration options](docs/openstack_configurations.md) for possible solutions.
