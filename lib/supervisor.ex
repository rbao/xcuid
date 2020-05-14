defmodule XCUID.Supervisor do
  use Supervisor

  def start_link(opts \\ []) do
    opts = Keyword.merge([name: __MODULE__], opts)
    Supervisor.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(_) do
    children = [
      XCUID
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
