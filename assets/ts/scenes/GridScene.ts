import { Scene, Types } from "phaser";

const scale = 32;
const width = 10;
const height = 10;
const fillColor = 0xd3d3d3

export default class GridScene extends Scene {
  constructor(config: Types.Scenes.SettingsConfig = {}) {
    super(config)
  }

  create() {
    this.add.grid(640, 360, scale * width, scale * height, scale, scale, fillColor)
  }
}