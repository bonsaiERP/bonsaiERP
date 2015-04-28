
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

- Ruby 2.2.2
- Instalar PostgreSQL 9.4 y postgresql-contrib para habilitar Hstore
- Nodejs para compilar los assets
- Instalar imagemagick

### Instalar *bonsaiERP*

Despues de haber instalado los requerimientos (ruby, postgresql,etc.)
se puede empezar con *bonsaiERP*, corran

`rake db:migrate`

esto crea todas las tablas, si estan en ubuntu o debian es necesario editar
el archivo `/etc/hosts` y aumenten lo siguiente

```
127.0.0.1	app.localhost.bom
127.0.0.1	bonsai.localhost.bom
127.0.0.1	mycompany.localhost.bom

```
en desarrollo necesitaran editar el archivo `/etc/hosts` pero en produccion no sera
necesario editarlo para cada nuevo subdominio, inicia la app `rails s` y ve a
http://app.localhost.bom:3000/sign_up para crear una nueva cuenta,
es necesario capturar el email de registro usando [mailcatcher](http://mailcatcher.me/). Llene todos
los campos de registro y revise el mail que se genero en el registro, vaya a la url que hay en el
email cambiando el puerto.

> El sistema genera el subdominio automaticamente, si su empresa se llama Pepe genera
> el subdominio pepe, utiliza la siguiente funcion `name.to_s.downcase.gsub(/[^A-Za-z]/, '')[0...15]`
> por esta razon es necesario de que su subdominio este en el archivo
> `/etc/hosts`


### Sobre los archivos adjuntos (UPLOADS)

*bonsaiERP* usa la gema dragonfly para poder realizar subida de archivos al servidor, es posible configurar donde iran los archivos en:

`config/initialiazers/dragonfly.rb`
