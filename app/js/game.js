//starting the game
let startgame = false
let tour = 0
let vert = true


const start = document.getElementById("startgame");

start.addEventListener("click", function(){
    startgame = true;
    console.log("ok");
    tour = 0;
    const images = document.querySelectorAll('img'); 
    images.forEach(image => {
        image.style.display = 'none';
    });
  });

//function to spawn an elf
function spawn () {
    const showImageButton = document.getElementById("show-image-button");
    
    let myImage;
    if(startgame == true){
        if (tour % 2 == 1) {
            if (tour % 4 === 1) {
                myImage = document.getElementById("lutin_vert");
                console.log("vert")

            }
            else if (tour % 4 === 3) {
                myImage = document.getElementById("lutin_jaune");
                console.log("jaune")
            }
            showImageButton.addEventListener("click", () => {
                myImage.style.display = "block";
            });
        }
    }   
    tour += 1;
}

document.getElementById("show-image-button").addEventListener("click", spawn);