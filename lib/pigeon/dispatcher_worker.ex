defmodule Pigeon.DispatcherWorker do
  @moduledoc false

  use GenServer

  def start_link(opts) do
    opts[:adapter] || raise "adapter is not specified"
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    case opts[:adapter].init(opts) do
      {:ok, state} ->
        Pigeon.Registry.register(opts[:supervisor])
        {:ok, %{adapter: opts[:adapter], state: state, supervisor: opts[:supervisor]}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def handle_info({:"$push", notification}, %{adapter: adapter, state: state} = s) do
    case adapter.handle_push(notification, state) do
      {:noreply, new_state} ->
        {:noreply, %{s | state: new_state}}

      {:stop, reason, new_state} ->
        {:stop, reason, %{s | state: new_state}}
    end
  end

  def handle_info({:"$retry_push", notification}, %{supervisor: supervisor} = s) do
    Pigeon.retry(supervisor, notification)
    {:noreply, s}
  end

  def handle_info(msg, %{adapter: adapter, state: state} = s) do
    case adapter.handle_info(msg, state) do
      {:noreply, new_state} ->
        {:noreply, %{s | state: new_state}}

      {:stop, reason, new_state} ->
        {:stop, reason, %{s | state: new_state}}
    end
  end
end
