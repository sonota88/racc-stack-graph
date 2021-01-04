const state = {
  align: "left"
};

function refresh() {
  document.querySelector("body").style["text-align"] = state.align;
}

function init() {
  document.body.addEventListener(
    "keydown",
    (ev)=>{
      if (ev.key === "a") { // TODO C-a などの場合は発火させない
        if (state.align === "left") {
          state.align = "right";
        } else {
          state.align = "left";
        }
        refresh();
      }
    }
  );

  refresh();
}

window.addEventListener("DOMContentLoaded", init);
