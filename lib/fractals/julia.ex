defmodule FractalExplorer.Fractal.Julia do
  use GenServer

  alias Scenic.Utilities.Texture
  alias Scenic.Cache.Dynamic.Texture, as: Cache

  #============================================================================
  # external, client api

  #============================================================================
  # internal, server api

  def start_link( size ), do: GenServer.start_link(__MODULE__, size )
  def init( size ) do
    config = %{
      size: size,
      center: {0,0},
      zoom: 1
    }
    send(self(), :render)
    { :ok, config }
  end

  #--------------------------------------------------------
  # simple render on demand
  def handle_info( :render, config ) do
    generate( config )
    {:noreply, config}
  end

  #--------------------------------------------------------
  # render the fractal into a static set of pixels
  # you would replace this entire thing with something that just grabs the completed
  # image off the video card
  def generate( %{size: {w,h}, center: center, zoom: zoom} ) do
    # options are :g, :ga, :rgb, :rgba
    {:ok, pixels} = Texture.build( :rgb, w, h )
    pixels

    # iterate over each pixel and calculate it's value - this is slow
    pixels = Enum.reduce(0..(w - 1), pixels, fn(px, pixels) ->
      Enum.reduce(0..(h - 1), pixels, fn(py, pixels) ->
        Texture.put!( pixels, px, py,
          calculate_pixel( px, py, center, zoom )
        )
      end)
    end)

    # put the finished frame into the cache.
    # This makes it the currently drawn image
    Cache.put( to_string(__MODULE__), pixels, :global )
  end

  #--------------------------------------------------------
  # px,py are the pixel coordinates.
  def calculate_pixel( px, py, _center, _zoom ) do
    # cheater cheater pumpkin eater
    {px + 128, py + 128, trunc((px + py) / 2)}
  end


end