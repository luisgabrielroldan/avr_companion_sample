defmodule AVRCompanionSample.Arduino do
  use GenServer
  require Logger
  @hex_name "arduino.hex"
  @board :uno
  @port "ttyACM0"
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    send(self(), :update)
    {:ok, %{}}
  end

  def handle_info(:update, state) do
    hex_name()
    |> AVR.update(@port, @board)
    |> case do
      {:ok, _} ->
        Logger.info("Arduino updated!")
        send(self(), :ready)
        {:noreply, state}

      error ->
        Logger.error("Arduino update failed!")
        # Delay for not restart too quickly
        :timer.sleep(3000)
        {:stop, error, state}
    end
  end

  def handle_info(:ready, state) do
    {:noreply, state}
  end

  defp hex_name() do
    priv_dir = :code.priv_dir(:avr_companion_sample)
    "#{priv_dir}/#{@hex_name}"
  end
end
