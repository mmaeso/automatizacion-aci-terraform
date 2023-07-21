# Automatizacion de ACI con Terraform
Este repo contiene todos los archivos utilizados en mi articulo de LinkedIn [Automatización de ACI con Terraform](https://www.linkedin.com/pulse/automatizaci%2525C3%2525B3n-de-aci-con-terraform-mikel-maeso%3FtrackingId=uQDhMi6CQyq6%252FK4t3q3QWw%253D%253D/?trackingId=uQDhMi6CQyq6%2FK4t3q3QWw%3D%3D).

# Instrucciones de uso
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
