resource "null_resource" "initiate" {

  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ./ansible/inventory.yml ./ansible/initiate.yml"
  }

  depends_on = [
    local_file.inventory
  ]
}


resource "null_resource" "create_user" {

  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ./ansible/inventory.yml ./ansible/create_user.yml"
    on_failure = continue
  }

  depends_on = [
    null_resource.initiate
  ]
}
