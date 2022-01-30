# création d'une IP publique
resource "scaleway_lb_ip" "nextcloud_ip" {}

# création de la base de données et attribution des droits
resource "random_password" "db_admin_password" {
  length  = 16
  special = true
  min_numeric = 1
}
resource "scaleway_rdb_instance" "nextcloud_database_instance" {
  name          = "nextcloud_database_instance"
  node_type     = "DB-DEV-S"
  engine        = "PostgreSQL-11"
  is_ha_cluster = false
  user_name     = "nextcloud_db_admin"
  password      = random_password.db_admin_password.result
  disable_backup = true
  backup_schedule_frequency = 1
  backup_schedule_retention = 7
}
resource "scaleway_rdb_database" "nextcloud_db" {
  instance_id    = scaleway_rdb_instance.nextcloud_database_instance.id
  name           = "nextcloud_db"
}
resource "random_password" "db_password" {
  length  = 16
  special = true
  min_numeric = 1
}
resource "scaleway_rdb_user" "nextcloud_db_user" {
  instance_id = scaleway_rdb_instance.nextcloud_database_instance.id
  name        = "nextcloud_db_user"
  password    = random_password.db_password.result
  is_admin    = true
}
resource "scaleway_rdb_privilege" "nextcloud_privilege" {
  instance_id   = scaleway_rdb_instance.nextcloud_database_instance.id
  user_name     = "nextcloud_db_user"
  database_name = scaleway_rdb_database.nextcloud_db.name
  permission    = "all"
}

# création du cluster kubernetes et installation de nextcloud
resource "scaleway_k8s_cluster" "nextcloud_cluster" {
  name             = "nextcloud_cluster"
  version          = "1.23"
  cni              = "cilium"
  autoscaler_config {
    scale_down_delay_after_add = "5m"
  }
  auto_upgrade {
    enable = true
    maintenance_window_start_hour = 1
    maintenance_window_day = "sunday"
  }
}
resource "scaleway_k8s_pool" "nextcloud_pool" {
  cluster_id  = scaleway_k8s_cluster.nextcloud_cluster.id
  name        = "nextcloud_pool"
  node_type   = "DEV1-M"
  size        = 1
  autoscaling = true
  autohealing = true
  wait_for_pool_ready = true
  min_size    = 1
  max_size    = 5
}
resource "null_resource" "kubeconfig" {
  depends_on = [scaleway_k8s_pool.nextcloud_pool]
  triggers = {
    host                   = scaleway_k8s_cluster.nextcloud_cluster.kubeconfig[0].host
    token                  = scaleway_k8s_cluster.nextcloud_cluster.kubeconfig[0].token
    cluster_ca_certificate = scaleway_k8s_cluster.nextcloud_cluster.kubeconfig[0].cluster_ca_certificate
  }
}
provider "helm" {
  kubernetes {
    host = null_resource.kubeconfig.triggers.host
    token = null_resource.kubeconfig.triggers.token
    cluster_ca_certificate = base64decode(
    null_resource.kubeconfig.triggers.cluster_ca_certificate
    )
  }
}
resource "helm_release" "nextcloud" {
  name      = "nextcloud"
  repository = "https://nextcloud.github.io/helm/"
  chart = "nextcloud"
  set {
    name = "nextcloud.host"
    value = scaleway_lb_ip.nextcloud_ip.ip_address
  }
  set {
    name = "nextcloud.password"
    value = "epsi2021"
  }
  set {
    name = "externalDatabase.type"
    value = "postgresql"
  }
  set {
    name = "externalDatabase.host"
    value = scaleway_rdb_instance.nextcloud_database_instance.endpoint_ip
  }
  set {
    name = "externalDatabase.user"
    value = scaleway_rdb_user.nextcloud_db_user.name
  }
  set {
    name = "externalDatabase.password"
    value = scaleway_rdb_user.nextcloud_db_user.password
  }
  set {
    name = "externalDatabase.database"
    value = scaleway_rdb_database.nextcloud_db.name
  }
  set {
    name = "service.port"
    value = 80
  }
  set {
    name = "service.type"
    value = "LoadBalancer"
  }
  set {
    name = "service.loadBalancerIP"
    value = scaleway_lb_ip.nextcloud_ip.ip_address
  }
}
output "nextcloud_url" {
  depends_on = [helm_release.nextcloud]
  description = "Nextcloud Url"
  value = "http://${scaleway_lb_ip.nextcloud_ip.ip_address}"
}