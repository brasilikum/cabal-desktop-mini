var Cabal = require("cabal-core");
var ram = require("random-access-memory");
var swarm = require("cabal-core/swarm.js");
var { ipcRenderer } = window.require("electron");
const { Elm } = require("./Main");

var cabal;

var app = Elm.Main.init({ node: document.getElementById("app"), flags: 6 });

app.ports.startChat.subscribe(channelKey => {
  const key = channelKey
    .replace("cabal://", "")
    .replace("cbl://", "")
    .replace("dat://", "")
    .replace(/\//g, "");
  const storage = ram;
  cabal = Cabal(storage, key, { maxFeeds: 1000 });
  cabal.db.ready(() => {
    var s = swarm(cabal);

    //
    // Get all channels
    //
    cabal.channels.get(function(err, channels) {
      if (err) {
        console.log("Could not get channels");
        return;
      }
      console.log("Got Channels " + channels.length);
      app.ports.chatStarted.send(channelKey);
      channels.forEach(channel => {
        console.log("Added initial Channel");
        app.ports.channelAdded.send({
          chatID: channelKey,
          channelName: channel
        });
      });

      cabal.channels.events.on("add", function(channel) {
        console.log("Added Channel");
        app.ports.channelAdded.send({
          chatID: channelKey,
          channelName: channel
        });
      });
    });

    //
    // Get all users
    //
    cabal.users.getAll(function(err, users) {
      if (err) {
        console.log(err);
        return;
      }
      debugger;
      console.log("Got users " + users.length);

      cabal.users.events.on("update", function(key) {
        cabal.users.get(key, function(err, user) {
          if (err) {
            console.log(err);
            return;
          }
          app.ports.updateUser.send(key);
        });

        cabal.topics.events.on("update", function(msg) {
          debugger;
          //state.topic = msg.value.content.topic;
        });
      });

      cabal.on("peer-added", function(key) {
        app.ports.updateUser.send(key);
      });
      cabal.on("peer-dropped", function(key) {
        app.ports.updateUser.send(key);
      });

      function updateLocalKey() {}
    });
  });
});

module.exports = app;
