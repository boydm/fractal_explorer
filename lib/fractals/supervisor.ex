defmodule FractalExplorer.Fractal.Supervisor do
  @moduledoc false

  use Supervisor
  alias Scenic.ViewPort

  # import IEx

  @fractals Application.get_env(:fractal_explorer, :fractals)

  def fractals(), do: @fractals

  # ============================================================================
  # setup the viewport supervisor

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config)
  end

  def init(_config) do

    # prepare the size of the image. Height is the viewport height minus the height of the nav bar
    {w, h} = Application.get_env(:fractal_explorer, :viewport).size
    h = h - FractalExplorer.Component.Nav.height()

    # start the fractal servers
    fractals()
    |> Enum.map(fn({_, mod}) -> {mod, {w, h}} end)
    |> Supervisor.init(strategy: :one_for_one)
  end
end