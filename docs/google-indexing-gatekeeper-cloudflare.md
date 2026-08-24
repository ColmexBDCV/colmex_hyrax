# Indexación de Google, gatekeeper de Turnstile y proxy de Cloudflare

## Resumen

El repositorio dejó de aparecer correctamente en Google después de activar un gatekeeper global basado en Cloudflare Turnstile dentro de Rails.

El problema no era inicialmente `robots.txt`, sino el flujo de acceso de los rastreadores:

```text
Googlebot → Cloudflare → Nginx → Puma/Rails
```

Cloudflare estaba entregando a Nginx la IP del proxy (`172.71.x.x`) en lugar de la IP real de Googlebot. Rails verificaba esa IP mediante DNS y rechazaba la solicitud, por lo que Google recibía la pantalla de CAPTCHA en vez de la ficha digital.

La solución quedó dividida en dos niveles:

1. **Rails:** omitir el gatekeeper únicamente para solicitudes de Google verificadas mediante DNS.
2. **Nginx:** recuperar la IP original desde `CF-Connecting-IP`, confiando sólo en rangos oficiales de Cloudflare.

---

## Síntoma observado

Google Search Console mostraba inicialmente:

- La URL disponible para Google.
- La página aparentemente indexable.
- Pero la captura renderizada mostraba:

```text
Verificación de acceso
Por favor, completa el CAPTCHA para continuar.
```

Esto parecía contradictorio, pero no lo era. Search Console podía obtener una respuesta HTTP, aunque el contenido obtenido era la pantalla del gatekeeper y no el objeto digital.

La evidencia definitiva apareció en el registro de Nginx:

```text
172.71.166.207 ... "Googlebot/2.1 ..."
```

El `User-Agent` de Google sí llegaba correctamente. La IP, sin embargo, era de Cloudflare.

Después de configurar el Real IP de Cloudflare, el registro pasó a mostrar una IP de Google:

```text
66.249.74.72 ... "Googlebot/2.1 ..."
```

Search Console empezó a renderizar correctamente:

- título del objeto;
- tipo `Audio`;
- estado público;
- reproductor;
- descarga;
- citas.

La página dejó de mostrar Turnstile y pasó a aparecer como disponible e indexable para Google.

---

## `robots.txt`

El archivo ya existe en:

```text
public/robots.txt
```

Contenido relevante:

```text
User-agent: *
Allow: /

Disallow: /users
Disallow: /admin
Disallow: /dashboard
Disallow: /jobs
Disallow: /notifications

Sitemap: /sitemap.xml.gz
```

`robots.txt` no bloqueaba las fichas públicas. Tampoco puede saltarse un `before_action` de Rails: sólo controla si un rastreador debe solicitar una URL, no lo que ocurre después de la solicitud.

---

## Problema adicional del sitemap

La configuración original generaba enlaces de objetos con esta forma:

```ruby
add "/catalog/#{doc['id']}", ...
```

Pero las rutas funcionales del repositorio son específicas por tipo de obra, por ejemplo:

```text
/concern/audios/0g354k871
/concern/books/...
/concern/articles/...
```

La URL `/catalog/` funciona como catálogo, pero `/catalog/:id` podía producir errores para fichas individuales. Además, Google no encontraba como referencia de sitemap las URL antiguas `/concern/...`.

La generación del sitemap se ajustó para consultar cada tipo de obra y construir su prefijo correspondiente:

```ruby
add_public_documents.call(
  work_models,
  ->(model_name) { "/concern/#{model_name.underscore.pluralize}" }
)
```

Para las colecciones se usa:

```ruby
add_public_documents.call(['Collection'], ->(_model_name) { '/collections' })
```

El sitemap debe regenerarse después de publicar cambios:

```bash
RAILS_ENV=production SEO_HOST=https://repositorio.colmex.mx bundle exec rake sitemap:refresh
```

El endpoint de ping antiguo de Google puede mostrar un `404` porque fue retirado. Eso no significa que la generación del sitemap haya fallado. El sitemap se registra y se reenvía desde Google Search Console.

---

## Protección original en Rails

El gatekeeper se ejecuta desde `ApplicationController`:

```ruby
before_action :enforce_startup_captcha, if: :startup_captcha_enabled?
```

El gatekeeper se aplica a solicitudes HTML de producción, excepto cuando:

- existe una sesión validada;
- la solicitud pertenece al controlador del CAPTCHA;
- la ruta está configurada en `STARTUP_CAPTCHA_SKIP_PATHS`;
- la IP pertenece a `STARTUP_CAPTCHA_SKIP_IPS`;
- la solicitud procede de un rastreador de Google verificado.

La activación general sigue siendo:

```ruby
ActiveModel::Type::Boolean.new.cast(
  ENV.fetch('ENABLE_STARTUP_CAPTCHA', 'true')
)
```

No se requiere una variable de entorno nueva para el bypass de Google.

---

## Bypass seguro para Googlebot

El bypass no confía únicamente en el `User-Agent`, porque cualquier bot puede falsificarlo.

Se aceptan estos agentes:

```text
Googlebot
Google-InspectionTool
```

`Google-InspectionTool` es el agente utilizado por la prueba en tiempo real de Search Console.

La comprobación completa es:

1. Leer `request.user_agent`.
2. Leer la IP mediante `request.remote_ip`.
3. Resolver la IP mediante reverse DNS.
4. Confirmar que el hostname termina en uno de estos dominios:

```text
.googlebot.com
.google.com
.googleusercontent.com
```

5. Resolver de nuevo el hostname.
6. Confirmar que el resultado contiene la IP original.
7. Guardar el resultado en `Rails.cache` durante una hora.

Si el DNS falla, se mantiene el CAPTCHA. El sistema falla de forma cerrada y no concede acceso por una comprobación incompleta.

La lógica se encuentra en:

```text
app/controllers/application_controller.rb
```

La decisión se integra en el flujo existente:

```ruby
return if startup_captcha_skip_googlebot?
```

No se deben aceptar solicitudes basándose únicamente en:

```ruby
request.user_agent.include?('Googlebot')
```

---

## Descubrimiento del proxy de Cloudflare

Aunque inicialmente se pensaba que sólo se usaba Turnstile dentro de Rails, el DNS del dominio estaba pasando por el proxy de Cloudflare.

La configuración inicial de Nginx enviaba a Puma:

```nginx
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

Sin Real IP de Cloudflare, `$remote_addr` era la IP del proxy Cloudflare, por ejemplo:

```text
172.71.166.207
```

Por eso el reverse DNS no podía identificar a Googlebot.

---

## Configuración de Nginx

Se creó un archivo incluido por Nginx:

```text
/etc/nginx/conf.d/cloudflare-realip.conf
```

El archivo contiene los rangos oficiales de Cloudflare mediante directivas `set_real_ip_from`, además de:

```nginx
real_ip_header CF-Connecting-IP;
real_ip_recursive on;
```

Los rangos deben mantenerse desde la lista oficial de Cloudflare:

```text
https://www.cloudflare.com/ips-v4
https://www.cloudflare.com/ips-v6
```

Una forma de regenerar el archivo es:

```bash
{
  curl -fsS https://www.cloudflare.com/ips-v4 \
    | sed 's/^/set_real_ip_from /; s/$/;/'
  curl -fsS https://www.cloudflare.com/ips-v6 \
    | sed 's/^/set_real_ip_from /; s/$/;/'
  printf '%s\n' \
    'real_ip_header CF-Connecting-IP;' \
    'real_ip_recursive on;'
} | sudo tee /etc/nginx/conf.d/cloudflare-realip.conf
```

Después de cualquier cambio:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

La configuración también puede declarar explícitamente el `User-Agent` en el `location /` principal:

```nginx
proxy_set_header User-Agent $http_user_agent;
```

Nginx normalmente reenvía este header aunque no se declare, pero la directiva explícita elimina cualquier ambigüedad.

La configuración de producción usa también:

```nginx
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-Host $host;
```

Después de activar Real IP, esos valores representan la IP original del cliente y no la IP del proxy Cloudflare.

---

## Verificación de Nginx

Confirmar que el archivo está cargado:

```bash
sudo nginx -T | grep 'cloudflare-realip.conf'
```

Confirmar las directivas:

```bash
sudo nginx -T | grep -E 'set_real_ip_from|real_ip_header|real_ip_recursive'
```

La salida debe incluir:

```nginx
real_ip_header CF-Connecting-IP;
real_ip_recursive on;
```

Revisar el log después de ejecutar una prueba en Search Console:

```bash
sudo tail -n 10 /var/log/nginx/repositorio-ssl_access.log
```

Antes de la corrección se observaba:

```text
172.71.166.207 ... Googlebot/2.1
```

Después de la corrección se observó:

```text
66.249.74.72 ... Googlebot/2.1
```

Esto confirmó simultáneamente que:

- Googlebot sí llegaba al servidor;
- Nginx sí recibía el `User-Agent`;
- Cloudflare estaba ocultando la IP original;
- Rails necesitaba la configuración Real IP para validar DNS.

---

## Verificación en Google Search Console

Para una ficha individual:

1. Abrir **Inspección de URLs**.
2. Introducir la URL real de la obra, por ejemplo:

```text
https://repositorio.colmex.mx/concern/audios/0g354k871
```

3. Ejecutar **Probar URL publicada**.
4. Revisar la captura renderizada.

Resultado correcto:

- “La URL está disponible para Google”.
- “La página se puede indexar”.
- La captura muestra la ficha real.
- No aparece la pantalla de Turnstile.
- Se observan título, tipo de objeto, reproductor y metadatos.

Después se puede usar **Solicitar indexación** para una muestra pequeña de fichas prioritarias. No es necesario solicitar manualmente las decenas de miles de objetos: el sitemap sirve para comunicar el inventario completo.

Que una URL esté disponible para Google no significa que ya esté indexada. La indexación puede tardar y Google puede decidir no mostrarla inmediatamente si todavía está procesando la URL, la canónica o sus señales de calidad.

---

## Mantenimiento

### Sitemap

Regenerar el sitemap después de:

- nuevas ingestas;
- publicación de objetos antes privados;
- cambios masivos de metadatos;
- cambios de rutas;
- cambios de dominio o configuración SEO.

Una ejecución diaria es razonable para este repositorio.

### Cloudflare

Los rangos oficiales de Cloudflare pueden cambiar. Si cambian, actualizar `cloudflare-realip.conf`, validar Nginx y recargarlo.

### Rails

Después de desplegar cambios en `ApplicationController`, reiniciar el proceso persistente de Rails para que Puma/Passenger/Unicorn cargue el código nuevo.

---

## Resultado final

La configuración final conserva el objetivo de protección contra cosechadores y bots de IA:

```text
Visitante normal o bot no verificado → Turnstile
Googlebot verificado → contenido público
Google-InspectionTool verificado → contenido público
IP interna permitida → contenido público
```

La seguridad no depende de una IP fija de Google ni de un `User-Agent` falsificable. Depende de:

- IP original restaurada desde Cloudflare;
- reverse DNS;
- forward DNS;
- caché temporal;
- comportamiento de denegación segura cuando la validación falla.
