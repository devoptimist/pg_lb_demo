########### connection details ##################

variable "ssh_user_name" {
  type    = string
}

variable "ssh_user_pass" {
  type    = string
  default = ""
}

variable "ssh_user_private_key" {
  type    = string
  default = ""
}

############ habitat variables ##################

# currently loading habitat services and service config from the files directory

variable "haproxy_ip" {
  description = "The ip address of the server to setup haproxy on"
  type        = string
}

variable "pgbench_ip" {
  description = "The ip address of the server to setup pgbench on"
  type        = string
}

variable "postgresql_ssh_ips" {
  description = "A list of ipaddresses where postgresql will be installed into a cluster. Has to be at least 3 ip addresses for supervisor quorum"
  type        = list(string)
}

variable "postgresql_supervisor_ips" {
  description = "A list of ip's (normally on a private lan) to be used for the supervisor ring peers"
  type        = list(string)
}
