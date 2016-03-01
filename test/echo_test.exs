defmodule EchoTest do
use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Echo

  def input_method(input) do
   user_input = input
   fn -> user_input end
  end

  def output_method do
    fn(message) -> IO.puts message end
  end

  test "sender process spawned" do
    input = ""
    Echo.Sender.start(input_method(input), output_method)
    assert Process.alive?(:global.whereis_name(:sender))
  end

  test "get input from command line" do
   input = "Magic"
    capture_io([input: input, capture_prompt: false], fn ->
     assert Echo.Sender.input_method == input
    end)
  end

  test "create receiver process" do
    input = "HELLO"
    Echo.Sender.start(input_method(input), output_method)
    assert Echo.Sender.register_receiver(self) == {:register, self}
  end

  test "spawn a client" do
    assert Process.alive?(Echo.Sender.new_receiver(output_method))
  end

  test "gets user input and sends to self" do
    input = "Magic"
    Echo.Sender.start(input_method(input), output_method)
    Echo.Sender.register_receiver(self)
    assert_receive({:message, input})
  end

  test "receiver gets user input" do
    input = "WORK!!"
    client_pid = spawn(Echo.Sender, :receive_message, [output_method])
    message = send client_pid, {:message, input}
    assert message == {:message, input}
  end
end
