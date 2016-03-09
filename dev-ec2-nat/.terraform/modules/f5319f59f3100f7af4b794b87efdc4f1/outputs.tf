output "common_sg" { value = "${aws_security_group.common.id}"}
output "bootstrap_profile" { value = "${aws_iam_instance_profile.bootstrap_profile.name}"}
