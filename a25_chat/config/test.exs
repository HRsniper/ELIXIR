use Mix.Config
config :a25_chat, remote_supervisor: fn(_recipient) ->
    A25Chat.TaskSupervisor
  end
