//starting the game
let startgame = false
let tour = 0
let matrix = [];

const start = document.getElementById("startgame");

start.addEventListener("click", function(){
    startgame = true;
    console.log(tour);
    console.log("ok");
    tour = 0;
    free = {};
    const images = document.querySelectorAll('img'); 
    images.forEach(image => {
        image.style.display = 'none';
    });
    //matrice a changer car represente pas les ponts
    matrix = 
    [[false, false, false, false, false, false],
    [false, false, false, false, false, false],
    [false, false, false, false, false, false],
    [false, false, false, false, false, false],
    [false, false, false, false, false, false],
    [false, false, false, false, false, false]];

  });
//function to retrieve the position of an elf 
function getData(form) {
    var formData = new FormData(form);
  
    for (var pair of formData.entries()) {
      console.log(pair[0] + ": " + pair[1]);
    }
    
    console.log(Object.fromEntries(formData));
    const data = Object.fromEntries(formData)

    const position = data.position.split('-');
    const x = position[0];
    const y = position[1];
    position_x_y = {x, y};
    return position_x_y;
  }
  
  


//function to spawn an elf
function spawn (position) {
    if (startgame === true) {
        let couleur = "";
        if (tour % 4 === 0) couleur = "vert";
        else if (tour % 4 === 1) couleur = "rouge";
        else if (tour % 4 === 2) couleur = "jaune";
        else if (tour % 4 === 3) couleur = "bleu";
    

        const lutin = document.createElement("img");
        lutin.src = `/app/images/lutin_${couleur}.png`; 
        lutin.alt = `Lutin ${couleur}`;
        lutin.className = "lutin";

        const x = position.x; 
        const y = position.y;
      


        if (matrix[x-1][y-1] == false) {
          const cell = document.getElementById(`${position.x}-${position.y}`);
          if (cell) {
            cell.append(lutin);
            matrix[x-1][y-1] = true;
            tour ++;
          }
          console.log(matrix);
        
        }
        
        document.getElementById("Tour").innerText = "Tour : " + tour;
        console.log(tour);
        
    }
}



document.getElementById("position").addEventListener("submit", function (e) {
    e.preventDefault();
    const position = getData(e.target);
    console.log("voila la position avant d'etre dans fct :", position);
    spawn (position);

  });
