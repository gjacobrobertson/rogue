import { Scene, GameObjects } from "phaser";

const scale = 32;
const fillColor = 0xd3d3d3
const playerColor = 0xff0000

type Data = {
  gridWidth: number;
  gridHeight: number;
}
export default class GridScene extends Scene {
  gridWidth: number;
  gridHeight: number;
  container: GameObjects.Container;

  constructor(opts: string | Phaser.Types.Scenes.SettingsConfig) {
    super(opts)
  }

  init(data: Data) {
    Object.assign(this, data);
  }

  create() {
    this.container = this.add.container(this.game.canvas.width / 2, this.game.canvas.height / 2);
    const grid = this.add.grid(0, 0, scale * this.gridWidth, scale * this.gridHeight, scale, scale, fillColor);
    grid.setOrigin(0, 0);
    this.container.add(grid);
  }

  addPlayer(x: number, y: number) {
    const player = this.add.circle(x * scale, y * scale, scale / 2, playerColor);
    player.setOrigin(0, 0);
    this.container.add(player);
    return player;
  }
}