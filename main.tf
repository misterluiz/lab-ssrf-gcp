
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = "terraform-gcp-437716"
}

variable "ssh_user" {
  default = "lab-user" # Coloque seu usuário aqui
}

variable "ssh_private_key_path" {
  default = "terraform-key"
}

variable "ssh_public_key_path" {
  default = "terraform-key.pub"
}


resource "google_compute_instance" "lab-ssrf" {
  name         = "lab-ssrf"
  machine_type = "e2-micro"  # Escolha o tipo de máquina
  zone         = "us-central1-a"

  # Define a imagem do SO
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"  # Ou outra distribuição como Ubuntu
    }
  }

  # Configurações de rede
  network_interface {
    network = "default"

    access_config {
     
    }
  }

   metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  # Script para instalar Apache2  com usuario com permissão
  provisioner "remote-exec" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get install -y apache2",
    "sudo apt-get install -y php",
    "sudo apt-get install -y php-curl",
    "sudo systemctl start apache2",
    "sudo systemctl enable apache2",
    "sudo chmod -R 777 /var/www/html",
    "sudo rm /var/www/html/index.html",
    "sudo systemctl restart apache2"
    
  ]
  connection {
    type        = "ssh"
    host        = google_compute_instance.lab-ssrf.network_interface[0].access_config[0].nat_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }
}

  # Tags para a regra de firewall
  tags = ["http-server"]

  # Configuração opcional de máquina
  service_account {
    scopes = [
    "https://www.googleapis.com/auth/compute.readonly", 
    "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  }
}

# Regras de firewall para liberar o tráfego HTTP
resource "google_compute_firewall" "default" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]  
  target_tags   = ["http-server", "https-server"]
}


resource "google_compute_firewall" "allow_outbound" {
  name    = "allow-outbound"
  network = "default"  # Troque para o nome da sua rede

  direction = "EGRESS"
  
  # Faixa de IPs que receberão as requisições
  destination_ranges = ["0.0.0.0/0"]

  # Permitir todas as portas e protocolos
    allow {
    protocol = "tcp"
    ports    = ["80", "443"] # HTTP e HTTPS
  }


  # Tag opcional para aplicar em instâncias específicas
  target_tags = ["allow-outbound-tag"]
}


resource "null_resource" "provision_files" {
  provisioner "file" {
    source      = "index.php"  # O arquivo PHP no diretório local
    destination = "/var/www/html/index.php"  # Local onde o arquivo será salvo na instância
   
   connection {
      type        = "ssh"
      host        = google_compute_instance.lab-ssrf.network_interface[0].access_config[0].nat_ip
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
    }  
  }

  provisioner "file" {
    source      = "scan.php"  # Um segundo arquivo, por exemplo, CSS
    destination = "/var/www/html/scan.php"
    
    connection {
      type        = "ssh"
      host        = google_compute_instance.lab-ssrf.network_interface[0].access_config[0].nat_ip
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
    } 
  }
depends_on = [google_compute_instance.lab-ssrf]

}

//Codiogo para mudar a role de conta de serviço
/*
resource "google_project_iam_binding" "my_project_viewer_binding" {
  project = "terraform-gcp-437716"
  role    = "roles/viewer"

  members = [
    "serviceAccount:120843842381-compute@developer.gserviceaccount.com"
  ]
}
*/
resource "google_storage_bucket" "my_bucket" {
  name     = "gabs_ssrf-gcp-gopher-easy"  # O nome deve ser único globalmente
  location = "US"  # Defina a localização do bucket

  # Controle de versão de objetos
  versioning {
    enabled = true
  }

  # Definir regras de ciclo de vida do bucket (opcional)
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
    }
  }

  # Controle de acesso (opcional)
  uniform_bucket_level_access = true
}
  