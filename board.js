const WS_PROTO = "ws://"
const WS_ROUTE = "/bridge"


let board = document.getElementById("board");

const boardSize = 6;
const totalSize = boardSize * 2 - 1;

for (let row = 0; row < totalSize; row++) { 
    for (let col = 0; col < totalSize; col++) {  
        const div = document.createElement("div");


        const adjustedRow = totalSize - row - 1; 

      
        if (col % 2 === 0 && (boardSize - adjustedRow) % 2 === 0) {
            div.className = "cell";

            div.id = `${Math.floor((col / 2) + 1)}-${Math.floor((adjustedRow / 2) + 1)}`;
        }

        else if (col % 2 === 0 && adjustedRow % 2 === 1) {
            div.className = "v-bridge-container";
            const aboveRow = adjustedRow - 1;  
            const belowRow = adjustedRow + 1;  

            div.id = `${Math.floor((col / 2) + 1)}-${Math.floor(aboveRow / 2) + 1} - ${Math.floor((col / 2) + 1)}-${Math.floor(belowRow / 2) + 1}`;

        }

        else if (col % 2 === 1 && adjustedRow % 2 === 0) {
            div.className = "h-bridge-container";
            const leftCol = col - 1; 
            const rightCol = col + 1; 
            div.id = `${Math.floor(leftCol / 2) + 1}-${Math.floor(adjustedRow / 2) + 1} to ${Math.floor(rightCol / 2) + 1}-${Math.floor(adjustedRow / 2) + 1}`;
        
        }

        else {
            div.style.backgroundColor = "transparent";
        }

        board.appendChild(div);
    }
}

