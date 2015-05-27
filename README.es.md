[![Code Climate](https://codeclimate.com/github/boriscy/bonsaiERP/badges/gpa.svg)](https://codeclimate.com/github/boriscy/bonsaiERP)
[![License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/boriscy/bonsaiERP/blob/dev/MIT-LICENSE.md)

# *bonsaiERP*

*bonsaiERP* es un ERP simple multiempresa escrito con [Ruby on Rails](http://rubyonrails.org) que incluye los siguientes módulos:

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

# Licencia

Por [Boris Barroso](https://github.com/boriscy) bajo licencia MIT:

> Copyright (c) 2015 Boris Barroso.
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to > deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or > sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
