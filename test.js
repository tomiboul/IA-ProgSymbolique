const gameState = {
    boardSize: 6,
  
    players: [
      {
        colour: "green",
        type: "human",
        elves: [
          { x: 0, y: 0, stuck: false},
          { x: 1, y: 0, stuck: false}
        ],
        eliminated: false
      },
      {
        colour: "blue",
        type: "AI",
        elves: [
          { x: 2, y: 1, stuck: false },
          { x: 2, y: 2, stuck: false }
        ],
        eliminated: false
      },
      {
        colour: "yellow",
        type: "human",
        elves: [
          { x: 3, y: 5, stuck: true  },
          { x: 3, y: 4, stuck: false }
        ],
        eliminated: false
      },
      {
        colour: "red",
        type: "AI",
        elves: [
          { x: 5, y: 5, stuck: false },
          { x: 4, y: 5, stuck: true  }
        ],
        eliminated: true
      }
    ],
  
    currentPlayerIndex: 0, // green's turn
    phase: "placement",
  
    bridges: new Set([
      "1,1-1,2",
      "1,1-2,1",
      "2,1-2,2",
      "3,4-3,5",
      "4,5-5,5"
    ]),
  
    doesBridgeExist(bridgeCoords) {
      if (Array.isArray(bridgeCoords)) {
        const [[x1, y1], [x2, y2]] = bridgeCoords;
        const key = this.bridgeKey(x1, y1, x2, y2);
        return this.bridges.has(key);
      }
  
      if (typeof bridgeCoords === "string") {
        return this.bridges.has(bridgeCoords);
      }
  
      console.warn("Error while trying to access bridge (", bridgeCoords, ")");
      return false;
    },
  
    bridgeKey(x1, y1, x2, y2) {
      const a = `${x1},${y1}`;
      const b = `${x2},${y2}`;
      return a < b ? `${a}-${b}` : `${b}-${a}`;
    },
  
    deleteBridge(bridgeCoords) {
      if (Array.isArray(bridgeCoords)) {
        const [[x1, y1], [x2, y2]] = bridgeCoords;
        const key = this.bridgeKey(x1, y1, x2, y2);
        return this.bridges.delete(key);
      }
  
      if (typeof bridgeCoords === "string") {
        return this.bridges.delete(bridgeCoords);
      }
  
      console.warn("Bridge (", bridgeCoords, ") deletion failed");
      return false;
    },
  
    selectedPawn: null
  };
  
  async function waitForClickOnCell() {
    console.log("       Entering waitForClickOnCell()");

    return new Promise((resolve) => {
        const handler = (e) => {
            const clickedCell = e.target.closest('.cell');
            console.log("clicked cell: " + clickedCell);
            if (!clickedCell) return; // Ignore clicks outside cells

                        document.querySelectorAll(".cell").forEach(cell => {
                cell.removeEventListener("click", handler);
            });

            resolve(clickedCell); // On retourne la cellule cliquée
        };

        document.querySelectorAll(".cell").forEach(cell => {
            cell.addEventListener("click", handler);
        });
    }); 
} 

function checkIfCellIsFree(x, y, state) {
    console.log("           Entering checkIfCellIsFree()");
    if(x < 0 || x > 6 || y < 0 || y > 6) {
        return null;
    }

    const elves = state.elves;
    console.log("Checking if cell is free on this position : ", x, y);
    
    for (const player of state.players) {
        for (const elf of player.elves) {
            if(elf.x === x && elf.y === y) {
                return false;
            }
        }
    }
    
    console.log("Cell is free on this position : ", x, y);
    return true;
}

async function handlePlacementTurn(state) {
    console.log("   Entering handlePlacementTurn()");
    let x, y;
    do {
        const clickedCell = await waitForClickOnCell();
        const id = clickedCell.id;
        const parts = id.split("-");
        x = parseInt(parts[0], 10);
        y = parseInt(parts[1], 10);
    } while (!checkIfCellIsFree(x, y, state));

    const currentPlayer = state.players[state.currentPlayerIndex];
    currentPlayer.elves.push([x, y, false]);

// Add elf to the board
    const cell = document.getElementById(`${x}-${y}`);
    const elfImage = document.createElement("img");
    elfImage.id = `lutin-${x}-${y}`;
    elfImage.className = "lutin";
    elfImage.draggable = true;

    switch (currentPlayer.colour) {
        case "green":
            elfImage.src = "images/lutin_vert.png";
            break;
        case "blue":
            elfImage.src = "images/lutin_bleu.png";
            break;
        case "yellow":
            elfImage.src = "images/lutin_jaune.png";
            break;
        case "red":
            elfImage.src = "images/lutin_rouge.png";
            break;
    }

    cell.appendChild(elfImage);
    elfImage.addEventListener("dragstart", dragStart);
}

function isValidMove(oldX, oldY, newX, newY, state) {
    // Vérifie si le déplacement est adjacent
    const dx = Math.abs(newX - oldX);
    const dy = Math.abs(newY - oldY);
    console.log("coords: " + oldX + "-" + oldY + " -> " + newX + "-" + newY);

    if ((dx === 1 && dy === 0) || (dx === 0 && dy === 1)) {
        // Vérifie s'il y a un pont entre les deux cases
        const bridgeExists = state.doesBridgeExist([[oldX, oldY], [newX, newY]]);
        console.log("Vérification bridge entre " + oldX+"-"+oldY+" et "+newX+"-"+newY);

        // Vérifie si la case de destination est libre
        const cellIsFree = checkIfCellIsFree(newX, newY,state);

        console.log("bridgeExists: " + bridgeExists);
        console.log("Bridges: ");
        console.log(state.bridges);
        console.log("cellIsFree: " + cellIsFree);
        return bridgeExists && cellIsFree;
    }
    return false; // Déplacement non adjacent
}


async function playTurn(state) {
    console.log("Entering playTurn()");
    if (state.phase === "placement") {
        console.log("Entering handlePlacementTurn()");
        await handlePlacementTurn(state);
    } 

    else {
        console.warn("Playing phase!");
    }
}

let i = 0; 

// async function pontuTest() {
//     while (i<50) {
//         await playTurn(gameState);
//         i++;
//     }
// }

// pontuTest();
console.log("&")
console.log(isValidMove(1,1,1,2,gameState));