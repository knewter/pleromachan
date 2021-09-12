defmodule Pleroma.ObanSentryReporter do
  @moduledoc """
  This Oban plugin attaches to all of the exception telemtry events from
  Oban and sends the errors to Sentry.
  """

  use GenServer

  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  @impl GenServer
  def init(_opts) do
    tracked_errors = [
      [:oban, :job, :exception],
      [:oban, :producer, :exception],
      [:oban, :circuit, :trip],
      [:oban, :plugin, :exception]
    ]

    :ok =
      :telemetry.attach_many(
        "oban-exception-reporter",
        tracked_errors,
        &__MODULE__.handle_event/4,
        nil
      )

    :ignore
  end

  @doc false
  def handle_event(event, measurements, metadata, _) do
    oban_exception = Enum.join(event, "_")
    metadata = Map.take(metadata, [:attempt, :error, :stacktrace, :queue, :worker])

    extra = %{
      measurements: "#{inspect(measurements, pretty: true)}",
      metadata: "#{inspect(metadata, pretty: true, width: 120)}"
    }

    sentry_event =
      Sentry.Event.create_event(
        message: "Oban Exception - #{inspect(oban_exception)}",
        extra: extra,
        level: "error"
      )

    Sentry.send_event(sentry_event)
  end
end
