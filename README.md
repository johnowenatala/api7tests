# Suite de tests para la Entrega 7 IIC2513-2016

Versión 1.0.0

## Instrucciones

1. Descargar o clonar el proyecto
2. Instalar las gemas (bundle install)
3. Crear un archivo **config.yml** (usar config.sample.yml como referencia)

Para ejecutar un tests en particular (por ejemplo, test 6):

``` bash

bundle exec rspec spec/tests/test6_spec.rb
```

Para ejecutar toda la suite:

``` bash

bundle exec rspec
```

Ademas, hay dos variables de entorno que se pueden usar: LOG_LEVEL y GROUP. Ejemplos:


``` bash

LOG_LEVEL=info GROUP=1 bundle exec rspec

LOG_LEVEL=debug GROUP=2 bundle exec rspec spec/tests/test2_spec.rb

GROUP=2 bundle exec rspec spec/tests/test1_spec.rb

LOG_LEVEL=debug bundle exec spec/tests/test4_spec.rb

```

2016 - John Owen
