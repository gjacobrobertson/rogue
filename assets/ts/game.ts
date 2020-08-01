import { Game, Types, AUTO, Scale } from "phaser";
import GridScene from "./scenes/GridScene"
// const width = window.innerWidth;
// const height = window.innerHeight;
const width = 1280;
const height = 720;

const config: Types.Core.GameConfig = {
  type: AUTO,
  scale: {
    mode: Scale.FIT,
    width: width,
    height: height,
    autoCenter: Scale.CENTER_BOTH
  },
  width: width,
  height: height,
  scene: new GridScene(),
  render: {
    transparent: true
  }
}

const game = new Game(config);