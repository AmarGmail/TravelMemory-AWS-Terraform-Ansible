output "web_public_ip" {
  value = aws_instance.web.public_ip
}

output "web_public_dns" {
  value = aws_instance.web.public_dns
}

output "db_private_ip" {
  value = aws_instance.db.private_ip
}

output "selected_ami_id" {
  value = data.aws_ami.ubuntu.id
}

output "selected_ami_name" {
  value = data.aws_ami.ubuntu.name
}