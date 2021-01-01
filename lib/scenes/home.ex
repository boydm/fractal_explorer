defmodule FractalExplorer.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  alias Scenic.ViewPort

  alias FractalExplorer.Component.Nav

  import Scenic.Primitives
  import Scenic.Components

  @text_size 24

  import IEx

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, opts) do
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} =
      opts[:viewport]
      |> ViewPort.info()

    nav_height = FractalExplorer.Component.Nav.height()
    image_w = vp_width
    image_h = vp_height - nav_height

    # get the first fractal from the list as the default
    [{ _, first_fractal } | _] = FractalExplorer.Fractal.Supervisor.fractals()

    # build the graph
    graph = Graph.build(font: :roboto, font_size: 16, theme: :dark)
    |> text(
      "Some Text",
      text_align: :center,
      translate: {vp_width / 2, @text_size}
    )
    |> rect(
      {image_w, image_h},
      id: :fractal_image,
      fill: {:dynamic, to_string(first_fractal)},
      translate: {0,nav_height}
    )

    # NavDrop and Notes are added last so that they draw on top
    |> Nav.add_to_graph()

    {:ok, graph, push: graph}
  end

  # --------------------------------------------------------
  def filter_event({:fractal, fractal}, _, graph) do
    graph = Graph.modify(graph, :fractal_image, &update_opts(&1, fill: {:dynamic, fractal}))
    {:halt, graph, push: graph}
  end


end
