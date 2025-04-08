const board = document.getElementById("board");

const boardSize = 6;
const totalSize = boardSize * 2 - 1;

for (let col = 0; col < totalSize; col++) {
    for (let row = 0; row < totalSize; row++) {
        const div = document.createElement("div");

        if(col % 2 === 0 && row % 2 === 0) {
            div.className = "cell";
            div.id    = `${(col / 2)+1}-${(row / 2)+1}`; 
        }

        else if (col % 2 === 0 && row % 2 === 1) {
            div.className = "h-bridge-container";

        }

        else if (col % 2 === 1 && row % 2 === 0) {
            div.className = "v-bridge-container";
        }

        else {
            div.style.backgroundColor = "transparent"; // cases vides entre les ponts
          }


        board.appendChild(div);
    }
}