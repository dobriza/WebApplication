resource "local_file" "ansible-cfg-file" {
  depends_on = [local_file.inventory]
  filename  = "ansible.cfg"
  content   = <<-EOF
[defaults]
inventory = ./hosts.ini
host_key_checking = False
remote_tmp = ~/.ansible/tmp
remote_user = root
retry_files_enabled = True
retry_files_save_path = ./
  EOF
}



resource "local_file" "inventory" {
  filename = "hosts.ini"
  content  = <<-EOT
[java]
%{for name in local.javaHost~}
${name}.${local.domainSuffix}
%{endfor~}

[golang]
%{for name in local.golangHost~}
${name}.${local.domainSuffix}
%{endfor~}

[java:vars]
ansible_user = root
ansible_ssh_private_key_file = ./dev01

[golang:vars]
ansible_user = root
ansible_ssh_private_key_file = ./dev01
  EOT
}





