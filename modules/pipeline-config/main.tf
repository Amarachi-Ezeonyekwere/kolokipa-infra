
resource "aws_ssm_parameter" "this" {
  for_each = var.values

  name  = "/${var.name}/${each.key}"
  type  = "String"
  value = each.value

  tags = {
    Name = "${var.name}-${each.key}"
  }
}
