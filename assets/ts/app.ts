// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import * as hooks from "./hooks"
import RogueGame from "./RogueGame";
import RoguePlayer from "./RoguePlayer";
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks },)

// connect if there are any LiveViews on the page
liveSocket.connect()

customElements.define("rogue-game", RogueGame, { extends: "canvas" })
customElements.define("rogue-player", RoguePlayer)