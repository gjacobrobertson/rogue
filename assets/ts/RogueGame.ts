import { Game, WEBGL } from "phaser";
import { ViewHookInterface } from "phoenix_live_view";
import GridScene from "./scenes/GridScene"
import { Grid } from "matter";

export default class RogueGame extends HTMLCanvasElement {
  game: Phaser.Game;
  scene: Promise<GridScene>;
  hook: ViewHookInterface;

  constructor() {
    super();
    const gridWidth = parseInt(this.dataset.gridWidth, 10);
    const gridHeight = parseInt(this.dataset.gridHeight, 10);

    const game = new Game({
      type: WEBGL,
      parent: null,
      canvas: this,
      width: this.width,
      height: this.height,
      transparent: true,
    })

    this.scene = new Promise(resolve => {
      game.events.once(Phaser.Core.Events.READY, () =>
        resolve(game.scene.add("grid", GridScene, true, { gridWidth, gridHeight }) as GridScene)
      )
    })
  }

  setHook(hook: ViewHookInterface) {
    this.hook = hook;
  }
}