# Testar Fault Tolerance

Notas: Guião feito para script de geração de dados do python

[Windows User](#set-windows) |
[Problemas Comuns](#problemas-comuns)

- Copiar Pasta "replicaPISID" para a diretoria desejada.
- Abrir os servidores e os seus clientes.
- Designar o servidor Primário e os seus servidores Secundários.
- Receber dados do mqtt e enviar para o MongoDB através do servidor Primário.
- Usar fazer db.<collection_name>.find().count() nos clientes.
- Desligar o servidor Primário.
- Deixar passar algum tempo.
- Usar fazer db.<collection_name>.find().count() nos clientes com conexão.
- Ligar o servidor anteriormente desligado e o respetivo cliente.
- Usar fazer db.<collection_name>.find().count() nos clientes e reparar que dá o mesmo valor.

## Set up Geral

Mover pasta "replicaPISID" para <path_to_mongo>, resultando  
"<path_to_mongo>\replicaPISID".

Alterar ficheiros <path_to_mongo>\replicaPISID\serverX\mongod.conf

```bash
  storage:
    dbPath: C:\replicaPISID\serverX\data
  ->
  storage:
    dbPath: <path_to_mongo>\replicaPISID\serverX\data
```

```bash
  systemLog:
    destination: file
    logAppend: true
    path:  C:\replicaPISID\serverX\logs\mongo.log
  ->
  systemLog:
    destination: file
    logAppend: true
    path:  <path_to_mongo>\replicaPISID\serverX\logs\mongo.log
```

```bash
  security:
    authorization: "enabled"
    keyFile: C:\replicaPISID\keyFile
  ->
  security:
    authorization: "enabled"
    keyFile: <path_to_mongo>\replicaPISID\keyFile
```

## Testar no Geral

Rodar os Servidores

```bash
  mongod --config /replicaPISID/server1/mongod.conf
  mongod --config /replicaPISID/server2/mongod.conf
  mongod --config /replicaPISID/server3/mongod.conf
```

Esperar 1 a 2 segundos para iniciar próximo passo.

Rodar os Clientes

```bash
  mongosh --port 23017 --username root --password root_grupo12
  mongosh --port 25017 --username root --password root_grupo12
  mongosh --port 27017 --username root --password root_grupo12
```

Esperar um pouco para escolherem o servidor primário(automático) e depois carregar a tecla <Enter> nas janelas dos clientes, resultando "replicaPISID [direct: primary] test>" e anotar mentalmente a porta em <primary_port>.

Mudar para a base de dados correta
(Repetir para os 3 Clientes)

```bash
  use sensors
```

Ativar leitura nos servidores secundários
(Apenas fazer nos clientes com [direct: secondary])

```bash
  db.getMongo().setReadPref('secondary')
```

Colocar o código do python a executar

```bash
  Executar simulatemp.py & simulalabirinto.py
```

Verificar se os registos estão a ser enviados (Executar no [direct: primary] e em 1 dos [direct: secondary], devem dar praticamente o mesmo valor)

```bash
  db.MazeSensors.find().count()
```

Desligar o servidor primary com <primary_port>

Porta Server db1: 23017 | Número server: 1

Porta Server db2: 25017 | Número server: 2

Porta Server db3: 27017 | Número server: 3

Anotar mentalmente <numero_server>
(Pode demorar um pouco, executar mais que uma vez o comando)

```bash
  CTRL + C
```

Esperar alguns minutos para um dos servidores secundários se tornar no primário e receber dados para termos a certeza que o servidor desligado "perde" acesso aos dados.

Voltar a ligar o servidor desligado

```bash
  mongod --config <path>/replicaPISID/server<numero_server>/mongod.conf
```

Voltar a ligar o cliente anteriormente a baixo

```bash
  mongosh --port <primary_port>
```

Ainda na mesma consola

```bash
  db.getMongo().setReadPref('secondary')
```

Verificar se os registos estão a ser enviados (Executar no [direct: primary] e no servidor que acabaste de ligar, devem dar praticamente o mesmo valor)

```bash
  db.MazeSensors.find().count()
```

## Set Windows

Mover pasta "replicaPISID" para C:, resultando "C:\replicaPISID".

## Testar no Windows

Rodar os Servidores

```bash
  Duplo clique no StartServers.bat
```

Esperar 1 a 2 segundos para iniciar próximo passo.

Rodar os Clientes

```bash
  Duplo clique no StartClients.bat
```

Esperar um pouco para escolherem o servidor primário(automático) e depois carregar a tecla <Enter> nas janelas dos clientes, resultando "replicaPISID [direct: primary] test>" e anotar mentalmente a porta em <primary_port>.

Mudar para a base de dados correta
(Repetir para os 3 Clientes)

```bash
  use sensors
```

Ativar leitura nos servidores secundários
(Apenas fazer nos clientes com [direct: secondary])

```bash
  db.getMongo().setReadPref('secondary')
```

Colocar o código do python a executar

```bash
  Executar simulatemp.py & simulalabirinto.py
```

Verificar se os registos estão a ser enviados (Executar no [direct: primary] e em 1 dos [direct: secondary], devem dar praticamente o mesmo valor)

```bash
  db.MazeSensors.find().count()
```

Desligar o servidor primary com <primary_port>

Porta Server db1: 23017 | Número server: 1

Porta Server db2: 25017 | Número server: 2

Porta Server db3: 27017 | Número server: 3

Anotar mentalmente <numero_server>
(Pode demorar um pouco, executar mais que uma vez o comando)

```bash
  CTRL + C
```

Esperar alguns minutos para um dos servidores secundários se tornar no primário e receber dados para termos a certeza que o servidor desligado "perde" acesso aos dados.

Voltar a ligar o servidor desligado

```bash
  mongod --config /replicaPISID/server<numero_server>/mongod.conf
```

Voltar a ligar o cliente anteriormente a baixo

```bash
  mongosh --port <primary_port>
```

Ainda na mesma consola

```bash
  db.getMongo().setReadPref('secondary')
```

Verificar se os registos estão a ser enviados (Executar no [direct: primary] e no servidor que acabaste de ligar, devem dar praticamente o mesmo valor)

```bash
  db.MazeSensors.find().count()
```

## Problemas comuns

Cliente sem "replicaPISID [direct: primary] ou replicaPISID [direct: secondary]":

```bash
  Solução: Trocar de Port
```
