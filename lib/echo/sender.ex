defmodule Echo.Sender do
  @sender_name :sender

  def start_sender(clients, input, output) do
    receive do
      {:register, receiver} ->
        send receiver, {:message, input.()}
        start_sender([receiver | clients], input, output)
    end
  end

  def start(input, output) do
   sender_pid = spawn(Echo.Sender, :start_sender, [[], input, output])
   :global.register_name(@sender_name, sender_pid)
  end

  def register_receiver(client_pid) do
    send :global.whereis_name(@sender_name), {:register, client_pid}
  end

  def output_method(message) do
    IO.puts "Received: #{message}"
  end

  def new_receiver(output) do
    client_pid = spawn(Echo.Sender, :receive_message, [output])
  end

  def receive_message(output) do
    receive do
      {:message, message} -> output.(message)
    end
  end

  def input_method do
    IO.gets "Send something to your receiver: "
  end
end
