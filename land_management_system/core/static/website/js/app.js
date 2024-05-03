$(document).ready(function(){
    var el = document.getElementById("wrapper");
    var toggleButton = document.getElementById("menu-toggle");

    toggleButton.onclick = function () {
        el.classList.toggle("toggled");
    };

});


function toggleArrow() {
  var arrow = document.getElementById("myArrow1");
  if (arrow.style.transform === "rotate(90deg)") {
    arrow.style.transform = "rotate(0deg)";
  } else {
    arrow.style.transform = "rotate(90deg)";
  }
}

function toggleArrow1() {
  var arrow = document.getElementById("myArrow2");
  if (arrow.style.transform === "rotate(90deg)") {
    arrow.style.transform = "rotate(0deg)";
  } else {
    arrow.style.transform = "rotate(90deg)";
  }
}
function toggleArrow2() {
  var arrow = document.getElementById("myArrow3");
  if (arrow.style.transform === "rotate(90deg)") {
    arrow.style.transform = "rotate(0deg)";
  } else {
    arrow.style.transform = "rotate(90deg)";
  }
}
function toggleArrow3() {
  var arrow = document.getElementById("myArrow4");
  if (arrow.style.transform === "rotate(90deg)") {
    arrow.style.transform = "rotate(0deg)";
  } else {
    arrow.style.transform = "rotate(90deg)";
  }
}


