# https://hexdocs.pm/mix/Mix.Tasks.New.html
# Projetos Guarda-chuva
# Em determinados momentos um projeto pode ficar enorme, realmente enorme.
# A ferramenta de construção Mix nos permite dividir nosso código em vários aplicativos e fazer nossos
# projetos em Elixir mais manejáveis à medida que crescem.

# Para criar um projeto guarda-chuva nós iniciamos um projeto Mix normal, mas colocando o argumento --umbrella
# `mix new NAME --umbrella`

$ mix new machine_learning_toolkit --umbrella

# Seu projeto guarda-chuva foi criado com sucesso.
# Dentro do seu projeto, você encontrará um diretório apps/
# onde você pode criar e hospedar muitos aplicativos:
  # cd machine_learning_toolkit
  # cd apps
  # mix new my_app ou mix new my_app --sup (arvore de supervisão)

# apps/ - onde nossos sub-projetos (filhos) ficarão
# config/ - onde a nossa configuração dos projetos guarda-chuva permanecerá

# vamos criar 3 aplicações em machine_learning_toolkit/apps
$ mix new utilities
$ mix new datasets
$ mix new svm

# Agora vamos ver a árvore de projeto
$ tree
# `windows instalar msys2 depois abre o shell do msys2,
# cole esse comando no shell: pacman -S tree`
$ sh
sh-5.1$ tree # na raiz do projeto machine_learning_toolkit
.
├── README.md
├── apps
│   ├── datasets
│   │   ├── README.md
│   │   ├── lib
│   │   │   └── datasets.ex
│   │   ├── mix.exs
│   │   └── test
│   │       ├── datasets_test.exs
│   │       └── test_helper.exs
│   ├── svm
│   │   ├── README.md
│   │   ├── lib
│   │   │   └── svm.ex
│   │   ├── mix.exs
│   │   └── test
│   │       ├── svm_test.exs
│   │       └── test_helper.exs
│   └── utilities
│       ├── README.md
│       ├── lib
│       │   └── utilities.ex
│       ├── mix.exs
│       └── test
│           ├── test_helper.exs
│           └── utilities_test.exs
├── config
│   └── config.exs
└── mix.exs

# Se voltarmos para raíz do projeto guarda-chuva, vemos que podemos chamar todos os comandos típicos,
# tais como o de compilação. Como os sub-projetos são apenas aplicações normais,
# você pode entrar nos diretórios e fazer todas as mesmas coisas que usualmente o Mix permite fazer.

$ mix compile # na raiz do projeto machine_learning_toolkit
==> svm
Compiling 1 file (.ex)
Generated svm app
==> datasets
Compiling 1 file (.ex)
Generated datasets app
==> utilities
Compiling 1 file (.ex)
Generated utilities app

# IEx
# Você pode pensar que a interação com os aplicativos poderia ser um pouco diferente em um projeto guarda-chuva.
# se tiver mos no root e iniciar o IEx com o `iex -S mix` podemos interagir normalmente com todos os projetos.
# da pasta apps

# machine_learning_toolkit\apps\utilities\lib\utilities.ex
def hello do
  IO.puts("Hello, I'm the utilities")
end

# machine_learning_toolkit\apps\datasets\lib\datasets.ex
def hello do
  IO.puts("Hello, I'm the datasets")
end

# machine_learning_toolkit\apps\svm\lib\svm.ex
def hello do
  IO.puts("Hello, I'm the support vector machine")
end

$ iex -S mix
==> svm
Compiling 1 file (.ex)
==> datasets
Compiling 1 file (.ex)
==> utilities
Compiling 1 file (.ex)

iex> Datasets.hello
# Hello, I'm the datasets
# :ok
iex> Utilities.hello
# Hello, I'm the utilities
# :ok
iex> Svm.hello
# Hello, I'm the support vector machine
# :ok
