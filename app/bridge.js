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
            const hBridge = document.createElement("img");

            hBridge.src = "images/bridge.png";
            hBridge.alt = "Pont vertical";

            hBridge.className = "h-bridge"

            // div.append(hBridge);
        }

        else if (col % 2 === 1 && row % 2 === 0) {
            div.className = "v-bridge-container";
            const hBridge = document.createElement("img");

            hBridge.src = "images/bridge.png";
            hBridge.alt = "Pont horizontal";

            hBridge.className = "v-bridge"

            // div.append(hBridge);
        }

        else {
            div.style.backgroundColor = "transparent"; // cases vides entre les ponts
          }


        board.appendChild(div);
    }
}