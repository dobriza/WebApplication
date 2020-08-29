# # # --------------------------------------------------------------------------------------------------
# # # Create vms at Digital Ocean-----------------------------------------------------------------------
# # # --------------------------------------------------------------------------------------------------



variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

# create SSH key
resource "digitalocean_ssh_key" "key" {
  name       = "dobrizaKey-Dev01"
  public_key = file("./dev01.pub")
}

variable "vm_java_web_app" {
  type        = list(string)
  default     = ["java-web-App05"]
  description = "vm for java web app"

}

variable "vm_golang_web_app" {
  type        = list(string)
  default     = ["go-web-App05"]
  description = "vm for golang web app"

}

# Create vms 

resource "digitalocean_droplet" "vm_java" {
  count    = length(var.vm_java_web_app)
  image    = "debian-9-x64"
  ssh_keys = [digitalocean_ssh_key.key.id]
  name     = var.vm_java_web_app[count.index]
  size     = "s-1vcpu-1gb"
  region   = "nyc1"
  tags     = ["dev01", "dobriza_yandex_ru"]
}

resource "digitalocean_droplet" "vm_golang" {
  count    = length(var.vm_golang_web_app)
  image    = "debian-9-x64"
  ssh_keys = [digitalocean_ssh_key.key.id]
  name     = var.vm_golang_web_app[count.index]
  size     = "s-1vcpu-1gb"
  region   = "nyc1"
  tags     = ["dev01", "dobriza_yandex_ru"]
}



# # # --------------------------------------------------------------------------------------------------
# # # -------AWS Route53 configuration------------------------------------------------------------------
# # # --------------------------------------------------------------------------------------------------



# Declare variables that stores access keys 

variable "access_key" {}
variable "secret_key" {}

# Configure the AWS Provider

provider "aws" {
  version    = "~> 2.0"
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

# Fetch data from route53

data "aws_route53_zone" "devops" {
  name = "devops.rebrain.srwx.net."
}

# Create DNS A records at devops.rebrain.srwx.net. zone

resource "aws_route53_record" "java-vm" {
  zone_id = data.aws_route53_zone.devops.zone_id
  count   = length(digitalocean_droplet.vm_java)
  name    = digitalocean_droplet.vm_java[count.index].name
  type    = "A"
  ttl     = "300"
  records = [digitalocean_droplet.vm_java[count.index].ipv4_address]
}

resource "aws_route53_record" "golang-vm" {
  zone_id = data.aws_route53_zone.devops.zone_id
  count   = length(digitalocean_droplet.vm_golang)
  name    = digitalocean_droplet.vm_golang[count.index].name
  type    = "A"
  ttl     = "300"
  records = [digitalocean_droplet.vm_golang[count.index].ipv4_address]
}


locals {
  javaHost     = aws_route53_record.java-vm.*.name
  golangHost   = aws_route53_record.golang-vm.*.name
  domainSuffix = data.aws_route53_zone.devops.name

}

