

resource "random_password" "jwt" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "jwt" {
  name                    = "${var.name}/jwt-secret"
  description             = "HMAC key the backend signs login tokens with."
  recovery_window_in_days = 0 # delete immediately on destroy, so a re-apply never collides with a pending deletion
}

resource "aws_secretsmanager_secret_version" "jwt" {
  secret_id     = aws_secretsmanager_secret.jwt.id
  secret_string = random_password.jwt.result
}
