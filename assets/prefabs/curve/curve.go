components {
  id: "curve"
  component: "/assets/prefabs/curve/curve.script"
}
embedded_components {
  id: "mesh"
  type: "mesh"
  data: "material: \"/assets/prefabs/curve/curve_m.material\"\n"
  "vertices: \"/assets/prefabs/curve/bb.buffer\"\n"
  "textures: \"/assets/c88.png\"\n"
  "primitive_type: PRIMITIVE_TRIANGLE_STRIP\n"
  "position_stream: \"position\"\n"
  "normal_stream: \"position\"\n"
  ""
  position {
    z: 10.0
  }
}
