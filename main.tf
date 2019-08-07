module "haproxy_install" {
  source           = "devoptimist/habitat/chef"
  version          = "0.0.3"
  ips              = [var.haproxy_ip]
  instance_count   = 1
  user_name        = var.ssh_user_name
  user_private_key = var.ssh_user_private_key
  user_pass        = var.ssh_user_pass
  hab_sup_peers    = slice(var.postgresql_supervisor_ips, 0, 2)
  hab_services     = jsondecode(file("${path.module}/files/haproxy.json"))
}

module "pgbench_install" {
  source           = "devoptimist/habitat/chef"
  version          = "0.0.3"
  ips              = [var.pgbench_ip] 
  instance_count   = 1
  user_name        = var.ssh_user_name
  user_private_key = var.ssh_user_private_key
  user_pass        = var.ssh_user_pass
  hab_sup_peers    = slice(var.postgresql_supervisor_ips, 0, 2)
  hab_services     = jsondecode(file("${path.module}/files/pgbench.json"))
}

module "postgresql_install" {
  source           = "devoptimist/habitat/chef"
  version          = "0.0.3"
  ips              = var.postgresql_ssh_ips
  instance_count   = length(var.postgresql_ssh_ips)
  user_name        = var.ssh_user_name
  user_private_key = var.ssh_user_private_key
  user_pass        = var.ssh_user_pass
  hab_sup_peers    = slice(var.postgresql_supervisor_ips, 0, 2)
  hab_services     = jsondecode(file("${path.module}/files/postgresql.json"))
}
