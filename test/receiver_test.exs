defmodule ReceiverTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Echo

  def input_method(input) do
   fn -> IO.gets "value" end
  end

  def output_method do
    fn(message) -> IO.puts message end
  end

  test "receiver process spawned" do
    input = ""
    Echo.Sender.start(input_method(input))
    pid = Echo.Receiver.new_receiver(output_method)
    assert Process.alive?(pid)
  end

  test "create receiver process" do
    assert Process.alive?(Echo.Receiver.new_receiver(output_method))
  end

  test "register a receiver with a Sender" do
    input = "HELLO"
    Echo.Sender.start(input_method(input))
    pid = Echo.Receiver.new_receiver(output_method)
    assert Echo.Sender.register_receiver(pid) == {:register, pid}
  end

  test "receiver gets user input" do
    input = "WORK!!"
    client_pid = spawn(Echo.Receiver, :receive_message, [output_method])
    message = send client_pid, {:message, input}
    assert message == {:message, input}
  end
end

