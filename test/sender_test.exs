defmodule SenderTest do
use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Echo

  def input_method(input) do
   fn -> input end
  end

  test "sender process spawned" do
    input = ""
    Echo.Sender.start(input_method(input))
    assert Process.alive?(:global.whereis_name(:sender))
  end

  test "get input from command line" do
   input = "Magic"
    capture_io([input: input, capture_prompt: false], fn ->
     assert Echo.Sender.input_method.() == input
    end)
  end

  test "register self as a receiver" do
    input = "HELLO"
    Echo.Sender.start(input_method(input))
    assert Echo.Sender.register_receiver(self) == {:register, self}
  end

  test "gets user input and sends to self" do
    input = "Magic"
    Echo.Sender.start(input_method(input))
    Echo.Sender.register_receiver(self)
    assert_receive({:message, input})
  end
end
