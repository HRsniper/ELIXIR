defmodule A25Chat do
  @moduledoc """
  Documentation for `A25Chat`.
  """

  @doc """
  receive_message/1
    Então, A25Chat.receive_message("hi") é chamada no outro node remoto.
    isso faz com que a mensagem "hi" seja colocada no console desse nó
  """
  def receive_message(message) do
    IO.puts(message)
  end

  @doc """
  que exibe a mensagem recebida no console do nó bigdog e envia uma mensagem de volta para o remetente
  """
  def receive_message_for_bigdog(message, from) do
    IO.puts(message)
    send_message(from, "gyuniku?")
  end

  def send_message(:bigdog@localhost, message) do
    spawn_task(__MODULE__, :receive_message_for_bigdog, :bigdog@localhost, [message, Node.self()])
  end

  @doc """
  send_message/2
    recebe o nome do nó de processamento remoto no qual queremos executar nossas tarefas supervisionadas
    e a mensagem que queremos enviar para esse nó de processamento.
  """
  def send_message(recipient, message) do
    spawn_task(__MODULE__, :receive_message, recipient, [message])
  end

  @doc """
  spawn_task/4
    Estamos dizendo para A25Chat.TaskSupervisor para supervisionar uma tarefa que executa
    a função receive_message/1 que recebe como um argumento qualquer mensagem passada para
    spawn_task/4 a partir da função send_message/2.
  """
  def spawn_task(module, func, recipient, args) do
    recipient
    |> remote_supervisor()
    |> Task.Supervisor.async(module, func, args)
    |> Task.await()
  end

  @doc """
  remote_supervisor/1
  """
  defp remote_supervisor(recipient) do
    Application.get_env(:a25_chat, :remote_supervisor).(recipient)
  end
end
