
Plugin.define do
  name    "minimap"
  version "0.1"
  file    "lib", "minimap"
  object  "Redcar::Minimap"
  dependencies "redcar", ">0", "edit_view", ">0"
end