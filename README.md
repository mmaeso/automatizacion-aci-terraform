# Automatizacion de ACI con Terraform
Este repo contiene todos los archivos utilizados en mi articulo de LinkedIn.

# Como usar
Clona el repo a tu sistema, y desde `./prod` lanza los comandos `terraform init` y `terraform apply`. Cuando se hayan desplegado los recursos del tenant 'PROD', sigue las mismas instrucciones para levantar el entorno 'DEV'

# Credenciales de acceso al APIC
Debes configurar las credenciales de acceso al APIC en los ficheros `variables.tf`de cada carpeta (PROD y DEV). Dentro de estos ficheros hay una variable `locals` con el siguiente contenido:
```
locals {
  username = "<usuario>"
  password = "<password>"
  apic_url = "<url del apic>"
}
```
