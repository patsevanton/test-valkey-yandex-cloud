resource "yandex_vpc_network" "my_network" {
  name = "my-network"
}

resource "yandex_vpc_subnet" "my_subnet" {
  name           = "my-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my_network.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

resource "yandex_mdb_redis_cluster" "my_redis" {
  name                = "my-redis-cluster"
  environment         = "PRODUCTION"
  network_id          = yandex_vpc_network.my_network.id
  tls_enabled         = true
  deletion_protection = false

  config {
    password = "supersecurepassword"
    version  = "7.2-valkey"
    # cluster_allow_pubsubshard_when_down = false
  }

  resources {
    resource_preset_id = "hm2.medium"
    disk_type_id       = "network-ssd"
    disk_size          = 50
  }

  host {
    zone             = "ru-central1-a"
    subnet_id        = yandex_vpc_subnet.my_subnet.id
    assign_public_ip = true
    replica_priority = 1
  }
}
