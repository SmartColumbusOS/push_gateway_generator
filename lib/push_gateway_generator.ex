defmodule PushGatewayGenerator do
  @moduledoc false
  use GenServer
  require Logger

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(init_args) do
    {:ok, address} = Keyword.get(init_args, :address) || "127.0.0.1"
    |> String.to_charlist()
    |> :inet.parse_address()
    port = Keyword.get(init_args, :port) || 5555
    rate = Keyword.get(init_args, :rate) || 10

    Logger.info(fn -> "populating message loop with" end)
    message_loop =
      Keyword.get(init_args, :message_loop)
      |> Enum.map(&Kitt.encode!/1)
    Logger.info(fn -> "done populating message loop with #{length(message_loop)} messages" end)

    {:ok, socket} = :gen_udp.open(port - 1)

    send_interval = trunc(1000 / rate)
    Logger.info(fn -> "scheduling to send a message every #{inspect(send_interval)} milliseconds to #{inspect(address)}" end)
    :timer.send_interval(send_interval, :push_message)

    {:ok, %{socket: socket, address: address, port: port, message_loop: message_loop}}
  end

  def handle_info(:push_message, %{socket: socket, address: address, port: port, message_loop: message_loop} = state) do
    [message | rest] = message_loop
    timestamp = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    Logger.debug(fn -> "sending a message to #{inspect(address)}" end)
    :gen_udp.send(
      socket,
      address,
      port,
      Jason.encode!(%{"timestamp" => timestamp, "deviceSource" => "udp-source-socket", "payloadData" => message})
    )

    {:noreply, %{state | message_loop: rest ++ [message]}}
  end
end
