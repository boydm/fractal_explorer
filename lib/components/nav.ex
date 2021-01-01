defmodule FractalExplorer.Component.Nav do
  use Scenic.Component

  alias Scenic.ViewPort
  alias Scenic.Graph

  import Scenic.Primitives, only: [{:text, 3}, {:rect, 3}]
  import Scenic.Components, only: [{:dropdown, 3}]
  # import Scenic.Clock.Components

  # import IEx
  @height 60

  # --------------------------------------------------------
  def verify(scene) when is_atom(scene), do: {:ok, scene}
  def verify({scene, _} = data) when is_atom(scene), do: {:ok, data}
  def verify(_), do: :invalid_data

  # --------------------------------------------------------
  def height(), do: @height

  # --------------------------------------------------------
  def init(current_scene, opts) do
    styles = opts[:styles] || %{}

    # Get the viewport width
    {:ok, %ViewPort.Status{size: {width, _}}} =
      opts[:viewport]
      |> ViewPort.info()

    # get the list of fractal servers
    fractals = FractalExplorer.Fractal.Supervisor.fractals()
    [{ _, first_fractal } | _] = fractals

    graph =
      Graph.build(styles: styles, font_size: 20)
      |> rect({width, @height}, fill: {48, 48, 48})
      |> dropdown(
        {fractals, first_fractal},
        id: :nav,
        translate: {13, 13}
      )
      # |> digital_clock(text_align: :right, translate: {width - 20, 35})

    {:ok, %{graph: graph, viewport: opts[:viewport]}, push: graph}
  end

  # --------------------------------------------------------
  def filter_event({:value_changed, :nav, fractal}, _, state) when is_atom(fractal) do
    send_event({:fractal, to_string(fractal)})
    {:halt, state}
  end

end
