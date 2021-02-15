mix phx.new my_phoenix_app
# o Framework Phoenix tem uma tarefa Mix customizada para criar um novo projeto

# para criar uma tarefa customizadas pode criar um novo prejeto ou um ja pronto
# vamos usar o projeto example

# Agora, no arquivo lib/example.ex colocamos na função hello IO.puts("Hello, World!")

# os módulos de tarefa ficam dentro do lib/mix/tasks/
# https://hexdocs.pm/mix/Mix.Task.html#content

# dentro de tasks/ criamos example.ex

# A função run/1 receberá uma lista de todos os argumentos da linha de comando passados, de acordo com o terminal do usuário.

# Note que agora nós começamos o código do defmodule com Mix.Tasks e o nome que queremos usar para o
# nosso comando. Na segunda linha, colocamos use Mix.Task, que traz o comportamento Mix.Task para o namespace.
# Então, declaramos uma função run que ignora quaisquer argumentos por agora.
# Dentro dessa função, chamamos nosso módulo Example e a função hello.

# agora so escrever o comando mix example dentro da pasta do projeto
cli> mix example
# Compiling 2 files (.ex)
# Generated example app
# Hello, World!

# Inicializando sua aplicação
# O Mix não inicializa automaticamente nossa aplicação ou qualquer uma de suas dependências.
# Não há problema nisto para muitos dos casos de uso de tarefas Mix.
# Mas e se precisássemos criar uma tarefa que usa o Ecto e interage com o banco de dados?
# Existem 2 maneiras de lidar com isso: explicitamente inicializando uma determinada aplicação
# ou inicializando toda nossa aplicação, que por sua vez inicializará as outras de sua árvore de dependências.

# colocado dentro da funcção run() de modulo
# Isso inicializará nossa aplicação
Mix.Task.run("app.start")

# o atributo @shortdoc no módulo.Isto facilita quando a aplicação está pronta,
# como quando um usuário executa o comando mix help no terminal.

mix example               # Simply calls the Example.hello/0 function.

# Nota: Nosso código deve ser compilado antes que novas tarefas apareçam na saída do mix help.
# Podemos fazer isso executando o mix compile diretamente ou executando a nossa tarefa como fizemos
# com o mix example, o que acionará a compilação para nós.
