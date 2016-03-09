output "public_subnet_id" { value = "${aws_subnet.public.id}"}
output "web_subnet_id" { value = "${aws_subnet.web.id}"}
output "app_subnet_id" { value = "${aws_subnet.app.id}"}
output "data_subnet_id" { value = "${aws_subnet.data.id}"}
