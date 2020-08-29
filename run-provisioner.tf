
resource "null_resource" "ansible_playbook_run_on_java_host" {
  depends_on = [local_file.ansible-cfg-file]
  count      = length(var.vm_java_web_app)
  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("./dev01")
      host        = digitalocean_droplet.vm_java[count.index].ipv4_address
    }
  }
  provisioner "local-exec" {
    command = "export ANSIBLE_CONFIG=./ansible.cfg && time ansible-playbook -c paramiko deploy-javaWebApp.yml -vvv"
  }
}

