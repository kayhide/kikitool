import { Howl, Howler } from "howler";

export default class Sound {
  static init() {
    const elms = document.querySelectorAll("[data-sound]");
    elms.forEach(elm => {
      elm.addEventListener("click", e => {
        e.preventDefault();
        const sound = new Howl({
          src: [elm.dataset.sound],
          html5: true,
          onplay: () => {
            elm.classList.add("playing");
            elm.disabled = true;
          },
          onend: () => {
            elm.classList.remove("playing");
            elm.disabled = false;
          },
        });
        sound.play();
      });
    });
  };
};
