import { Game, AUTO, Scale } from "phaser";

// const width = window.innerWidth;
// const height = window.innerHeight;
const width = 1280;
const height = 720;

const config = {
  type: AUTO,
  scale: {
    mode: Scale.FIT,
    width: width,
    height: height,
    autoCenter: Scale.CENTER_BOTH
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