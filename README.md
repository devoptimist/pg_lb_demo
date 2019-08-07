# Overview
This module will provision 3 types of applications onto servers using `Chef Habitat`.

Under the hood this module uses a Chef `Effortless Infra` package to install and setup everything relating to the habitat supervisor and its running services.

#### Supported platform families:
 * Debian
 * SLES
 * RHEL

## Prerequisites
You will need to create 5 servers in total, that have ssh access. The access should be the same username and passwors (or ssh key) for each server (this is just a limitation of the demo).

 - 1 server to run pgbench
 - 1 server to run haproxy
 - 3 servers to run the postgresql cluster

The connections are as follows
```
internet ---- 9000 (tcp) ----> haproxy (for haproxy stats page)

pgbench  ---- 5432 (tcp) ----> haproxy (for simulated db traffic)

haproxy  ---- 5432 (tcp) ----> postgresql cluster (traffic that is proxied from pgbench)

habitat supervisor                               habitat supervisor
                   <---- 9638 (tcp && udp) ---->
                   <----    9631 (tcp)     ---->   
``` 
The habitat supervisor is present on all of the 5 servers so servers need to be able to comunicate on ports 9638 (tcp, udp) and 9631 (tcp) between each other.

Collect the ip address used for ssh for each server. These will be the inputs into the terrafrom module.
configure these inputs as shown in the usage section below. In the case of AWS public cloud the ssh ip addresses tend to be public ip addresses that are nat-ed to the private ip addresses of the actual servers. If your infrastructure is similar then also make a note of the postgresqls private ip addresses as well. These private ipaddresses will be the input for the postgresql_supervisor_ips variable. This keeps all the supervisor traffic on the private LAN and not over the internet. In this demo the postgresql_supervisor_ips act as the initial peers for the supervisor ring. In production a bastion ring would be created: https://www.habitat.sh/docs/best-practices/#the-bastion-ring

## Usage
In the root of the directory will be a file names `terraform.tfvars.example` copy this file to one called `terraform.tfvars`. Then enter all of the required values to the variables. Note only one of ssh_user_pass or ssh_user_private_key is needed.

```bash
cp terraform.tfvars.example terraform.tfvars
```
After you have filled in the values to `terrafrom.tfvars` it should look similar to the content below.
```hcl

ssh_user_name = "jdoe"
ssh_user_private_key = "~/.ssh/mycloud.pem"
# ssh_user_pass = "supersecret"

habproxy_ip = "35.178.124.73"
pgbench_ip = "35.176.115.167"

postgresql_ssh_ips = [
  "35.177.100.100",
  "3.9.12.109",
  "35.177.40.146",
] 

postgresql_supervisor_ips = [
  "10.0.1.7",
  "10.0.1.101",
  "10.0.1.223",
]
```

## Full List of Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|ssh_user_name|The ssh user name used to access the ips provided|string||yes|
|ssh_user_pass|The ssh user password used to access the ips (set ssh_user_pass or ssh_user_private_key)|string|""|no|
|ssh_user_private_key|The ssh user key used to access the ip addresses |string|""|no|
|habproxy_ip|The ssh accessible ip to be used to install haproxy|string||yes|
|pgbench_ip|The ssh accessible ip to be used to install pgbench|string||yes|
|postgresql_ssh_ips|A list of ssh accesible ip addresses to be used to install postgresql |list||yes|
|postgresql_supervisor_ips|A list of ip's (normally on a private lan) to be used for the supervisor ring peers |list||yes|

## Running
Once you have configured your input variables into the `terraform.tfvars` file, run the follwoing commands to create the database cluster, loadbalancer and postgresql benchmaring service.
``` bash
terraform init
terraform plan
terraform apply
```

### Output
After the terrafrom has finished runnig you should see some output similar to below
```bash
benchmark_server = 35.176.115.167
database_servers = [
  "35.177.100.100",
  "3.9.12.109",
  "35.177.40.146",
]
loadbalancer_stats = http://35.178.124.73:9000/haproxy-stats
```
If you browse to the url shown in the loadbalancer_stats output you can view the current state of the cluster.
The username for the stats page is admin and the password is password.

#### The Benchmark Server
The benchmark server runs a (very) basic service that just calls pgbench in a loop. by default it will run pgbench with the following options.
```bash
  pgbench -h <IP address of loadbalancer> \
    -p <port of loadbalancer> \
    -U <database user> \
    -c 40 \
    -j 2 \
    -T 1200 \
    bench1
```



before it runs this benchmark is does the following setup
```bash
  psql -h <IP address of loadbalancer> \
    -p <port of loadbalancer> \
    -U <database user> \
    -c "DROP DATABASE bench1" -d postgres

  psql -h <IP address of loadbalancer> \
    -p <port of loadbalancer> \
    -U <database user> \
    -c "CREATE DATABASE bench1" -d postgres

  psql -h <IP address of loadbalancer> \
    -p <port of loadbalancer> \
    -U <database user> \
    bench1 -i

```

notes:

 - The ip address of loadbalancer is read from the habitat supervisor ring. It is exposed to the supervisor ring by the haproxy habitat service
 - The port of loadbalancer is read from the habitat supervisor ring. It is exposed to the supervisor ring by the haproxy habitat service
 - The database user is read from the habitat supervisor ring. It is exposed to the supervisor ring by the postgresql habitat service

