# PushGatewayGenerator
Takes a message file in ETF (elixir term format) and pushes those messages (should be `Kitt.Message.*` structs) in a continuous loop at the desired rate.

## Configuration
This is all configured via environment variables:

```bash
- `RATE` - the rate per second messages should be sent. Defaults to `10`
- `DESTINATION_PORT` - the UDP port to send messages to. Defaults to `5555`
- `DESTINATION_ADDRESS` - the IPv4 address to send message to. Defaults to `127.0.0.1`
- `MESSAGE_FILE` - the file from which to load messages for sending. Must be ETF that loads as an array of `Kitt.Message.*` messages
```

The only required value is the message file the generator will send.
