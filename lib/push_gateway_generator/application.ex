defmodule PushGatewayGenerator.Application do
  @moduledoc false
  use Application
  require Logger

  def start(_type, _args) do
    rate =
      System.get_env("RATE")
      |> String.to_integer()

    destination_address = System.get_env("DESTINATION_ADDRESS")
    destination_port = System.get_env("DESTINATION_PORT")

    Logger.info(fn -> "Loading message loop from file" end)

    messages =
      System.get_env("MESSAGE_FILE")
      |> File.read!()
      |> :erlang.binary_to_term()

    Logger.info(fn -> "Done loading message loop from file" end)

    children =
      [
        {
          PushGatewayGenerator,
          [
            rate: rate,
            message_loop: messages,
            port: destination_port,
            address: destination_address
          ]
        }
      ]
      |> List.flatten()

    opts = [strategy: :one_for_one, name: PushGatewayGenerator.Generator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
