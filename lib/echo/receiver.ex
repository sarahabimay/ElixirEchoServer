defmodule Echo.Receiver do
  def start(output) do
    Echo.Sender.register_receiver(new_receiver(output))
  end

  def new_receiver(output) do
    spawn(Echo.Receiver, :receive_message, [output])
  end

  def receive_message(output) do
    receive do
      {:message, message} ->
        output.(message)
        receive_message(output)
    end
  end

  def output_method do
    fn(message) ->
      IO.puts "Received: #{message}"
    end
  end
end
