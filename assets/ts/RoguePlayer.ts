import RogueGame from "./RogueGame";

export default class RoguePlayer extends HTMLElement {
  game: RogueGame;

  constructor() {
    super();
    this.game = this.closest("[is=rogue-game]");
    this.sync();
  }

  private sync() {
    const x = parseInt(this.dataset.x, 10);
    const y = parseInt(this.dataset.y, 10);
    this.game.scene.then(scene => {
      scene.addPlayer(x, y);
    })
  }
}