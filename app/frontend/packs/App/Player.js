const  { Howl, Howler } = require("howler");


exports.create = urls => () =>
  new Howl({
    src: urls,
    html5: true
  });


exports.play = player => () =>
  player.play();

exports.pause = player => () =>
  player.pause();

exports.stop = player => () =>
  player.stop();

exports.seek = seek => player => () =>
  player.seek(seek);


exports.isPlaying = player => () =>
  player.playing();

exports.getDuration = player => () =>
  player.duration();

exports.getSeek = player => () =>
  player.seek();


exports.onLoad = listener => player => () =>
  player.on("load", e => listener());

exports.onPlay = listener => player => () =>
  player.on("play", e => listener());

exports.onPause = listener => player => () =>
  player.on("pause", e => listener());

exports.onStop = listener => player => () =>
  player.on("stop", e => listener());

exports.onEnd = listener => player => () =>
  player.on("end", e => listener());

exports.onSeek = listener => player => () =>
  player.on("seek", e => listener());
