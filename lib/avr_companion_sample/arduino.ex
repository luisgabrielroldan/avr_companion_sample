defmodule AVRCompanionSample.Arduino do
  use GenServer
  alias Circuits.UART
  require Logger

  @hex_name "arduino.hex"
  @board :uno
  @port "ttyACM0"
  @speed 9600

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def set_led(led_state) when is_boolean(led_state) do
    GenServer.cast(__MODULE__, {:set_led, led_state})
  end

  def init(_args) do
    send(self(), :update)
    {:ok, %{port: nil}}
  end

  def handle_cast({:set_led, led_state}, state) do
    value =
      case led_state do
        true -> 1
        false -> 0
      end

    UART.write(state.port, <<?L, value>>)
    {:noreply, state}
  end

  def handle_info(:update, state) do
    hex_name()
    |> AVR.update(@port, @board)
    |> case do
      {:ok, _} ->
        send(self(), :ready)
        {:noreply, state}

      error ->
        # Delay for not restart too quickly
        :timer.sleep(3000)
        {:stop, error, state}
    end
  end

  def handle_info(:ready, state) do
    {:ok, port} = UART.start_link()

    port_opts = [
      speed: @speed,
      framing: Circuits.UART.Framing.FourByte
    ]

    :ok = UART.open(port, @port, port_opts)
    state = %{state | port: port}
    Process.send_after(self(), :read, 1000)
    {:noreply, state}
  end

  def handle_info(:read, state) do
    UART.write(state.port, <<?A, 0>>)
    Process.send_after(self(), :read, 1000)
    {:noreply, state}
  end

  def handle_info({:circuits_uart, _, <<?A, analog_id, value::16-little>>}, state) do
    voltage = Float.round(value * (5.0 / 1023.0), 2)
    Logger.info("Voltage in A#{analog_id}: #{voltage}v")
    {:noreply, state}
  end

  def handle_info({:circuits_uart, _, <<?L, led_state, _::binary>>}, state) do
    led_state =
      case led_state do
        1 -> "ON"
        0 -> "OFF"
      end

    Logger.info("Led updated to: #{led_state}")
    {:noreply, state}
  end

  def handle_info({:circuits_uart, _, {:error, _} = error}, state) do
    # Delay for not restart too soon
    :timer.sleep(3000)
    {:stop, error, state}
  end

  defp hex_name() do
    priv_dir = :code.priv_dir(:avr_companion_sample)
    "#{priv_dir}/#{@hex_name}"
  end
end
