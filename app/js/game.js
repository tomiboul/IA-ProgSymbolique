//starting the game
let startgame = false
let tour = 0
let vert = true


const start = document.getElementById("startgame");

start.addEventListener("click", function(){
    startgame = true;
    console.log(tour);
    console.log("ok");
    tour = 0;
    const images = document.querySelectorAll('img'); 
    images.forEach(image => {
        image.style.display = 'none';
    });
  });

//function to spawn an elf

function spawn () {
    if (startgame === true) {
        let couleur = "";
        if (tour % 4 === 0) couleur = "vert";
        else if (tour % 4 === 1) couleur = "rouge";
        else if (tour % 4 === 2) couleur = "jaune";
        else if (tour % 4 === 3) couleur = "bleu";
    

        const lutin = document.createElement("img");
        lutin.src = `/app/images/lutin_${couleur}.png`; 
        lutin.alt = `Lutin ${couleur}`;
        lutin.style.width = "100px";
        lutin.style.margin = "10px";
    

        const container = document.getElementById("lutin-container");
        container.appendChild(lutin);
        console.log(tour);
        tour ++;
    }
}

