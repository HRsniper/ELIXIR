defmodule Mix.Tasks.Example do
  use Mix.Task

  @shortdoc "Simply calls the Example.hello/0 function."
  # def run(args) do
  def run(_) do
    # Isso inicializará nossa aplicação
    Mix.Task.run("app.start")

    # Chamando a função Example.hello() definida anteriormente
    Example.hello()
  end
end
