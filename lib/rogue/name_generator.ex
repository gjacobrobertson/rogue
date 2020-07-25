defmodule Rogue.NameGenerator do
  @first [
    "Billy",
    "Jimmy",
    "Bimmy",
    "Jammy",
    "Keith",
    "Karen"
  ]

  @last [
    "the Red",
    "the Orange",
    "the Yellow",
    "the Green",
    "the Blue",
    "the Purple",
    "the Black",
    "the White"
  ]

  def generate do
    "#{Enum.random(@first)} #{Enum.random(@last)}"
  end
end
