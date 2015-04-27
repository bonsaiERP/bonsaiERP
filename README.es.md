
# *bonsaiERP*

*bonsaiERP* es un ERP simple escrito con [Ruby on Rails](http://rubyonrails.org), incluye los siguientes módulos:

- Ventas
- Compras
- Gastos
- Cuentas
- Inventarios
- Manejo de archivos (en desarrollo)

El sistema permite utilizar multiples monedas

## Instalación

### Instalar todos los requisitos

- Ruby 2.2.1
- Instalar PostgreSQL 9.4 y postgresql-contrib para habilitar Hstore
- Nodejs para compilar los assets
- Instalar imagemagick

### Instalar *bonsaiERP*



### Sobre los archivos adjuntos (UPLOADS)

*bonsaiERP* usa la gema dragonfly para poder realizar subida de archivos al servidor, es posible configurar donde iran los archivos en:

`config/initialiazers/dragonfly.rb`
