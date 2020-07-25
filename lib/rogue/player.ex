defmodule Rogue.Player do
  alias Rogue.NameGenerator
  defstruct [:name]

  @type t() :: %__MODULE__{}

  def create() do
    %__MODULE__{
      name: NameGenerator.generate()
    }
  end
end
