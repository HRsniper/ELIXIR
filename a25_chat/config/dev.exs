use Mix.Config
config :a25_chat, remote_supervisor: fn(recipient) ->
    {A25Chat.TaskSupervisor, recipient}
  end
