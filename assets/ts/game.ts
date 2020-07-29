import { Game, AUTO, Scale } from "phaser";

const width = window.innerWidth;
const height = window.innerHeight;
// const width = 1920;
// const height = 1080;

const config = {
  type: AUTO,
  scale: {
    mode: Scale.RESIZE,
    width: width,
    height: height,
  },
  width: width,
  height: height,
  scene: {
    preload() {
      this.load.image('logo', 'images/phoenix.png')
    },
    create() {
      this.add.image(width / 2, height / 2, 'logo')
    }
  }
}

const game = new Phaser.Game(config);