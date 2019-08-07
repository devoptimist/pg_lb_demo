output "loadbalancer_stats" {
  value = "http://${var.haproxy_ip}:9000/haproxy-stats"
}

output "benchmark_server" {
  value = var.pgbench_ip
}

output "database_servers" {
  value = var.postgresql_ssh_ips
}
