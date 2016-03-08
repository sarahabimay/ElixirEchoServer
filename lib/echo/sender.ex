defmodule Echo.Sender do
  @sender_name :sender

  def start(input) do
   sender_pid = spawn(Echo.Sender, :sender, [[], input])
   :global.register_name(@sender_name, sender_pid)
  end

  def sender(clients, input) do
    Enum.map(clients, fn(pid) ->
      send pid, {:message, input.()}
      sender(clients, input)
    end)
    receive do
      {:register, receiver_pid} ->
        pid_as_string = inspect receiver_pid
        #send receiver_pid, {:message, input.()}
        sender([receiver_pid | clients], input)
    end
  end

  def register_receiver(client_pid) do
    send :global.whereis_name(@sender_name), {:register, client_pid}
  end

  def input_method do
    fn -> IO.gets "Send something to your receiver: " end
  end
end
