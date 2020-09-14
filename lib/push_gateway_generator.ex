defmodule PushGatewayGenerator do
  @moduledoc false
  use GenServer
  require Logger

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(init_args) do
    host_address =
      Keyword.get(init_args, :address)
      |> String.to_charlist()
    {:ok, {:hostent, _hostname, _, :inet, 4, [address]}} = :inet.gethostbyname(host_address)

    port = Keyword.get(init_args, :port)
    rate = Keyword.get(init_args, :rate)

    Logger.info(fn -> "populating message loop with" end)

    message_loop =
      Keyword.get(init_args, :message_loop)
      |> Enum.map(&Kitt.encode!/1)

    Logger.info(fn -> "done populating message loop with #{length(message_loop)} messages" end)

    {:ok, socket} = :gen_udp.open(0)

    Logger.info(fn ->
      "scheduling to send a #{inspect(rate)} messages every second to #{inspect(address)}"
    end)

    startup_jitter = :rand.uniform(10_000)
    Logger.info(fn -> "starting with jitter of #{inspect(startup_jitter)}" end)
    Process.sleep(startup_jitter)

    :timer.send_interval(1000, :push_message)

    {:ok, %{socket: socket, address: address, port: port, rate: rate, message_loop: message_loop}}
  end

  def handle_info(:push_message, %{socket: socket, address: address, port: port, message_loop: message_loop, rate: rate} = state) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    Logger.debug(fn -> "sending #{inspect(rate)} messages to #{inspect(address)}" end)

    {messages, rest} = Enum.split(message_loop, rate)
    Enum.each(messages, fn message ->
      :gen_udp.send(
        socket,
        address,
        port,
        Jason.encode!(%{"timestamp" => timestamp, "deviceSource" => "udp-source-socket", "payloadData" => message})
      )
    end)
    Logger.debug(fn -> "done sending #{inspect(rate)} messages to #{inspect(address)}" end)

    {:noreply, %{state | message_loop: rest ++ messages}}
  end
end
