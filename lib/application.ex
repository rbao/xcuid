defmodule XCUID.Application do
  use Application

  @impl true
  def start(_type, _args) do
    XCUID.Supervisor.start_link()
  end
end
