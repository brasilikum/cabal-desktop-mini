var { ipcRenderer } = window.require("electron");
const { Elm } = require("./Main");

var app = Elm.Main.init({ node: document.getElementById("app"), flags: 6 });

module.exports = app;
