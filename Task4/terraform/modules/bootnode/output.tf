output "ip_address" {
  value = "${aws_instance.bootnode.*.public_ip}"
}
