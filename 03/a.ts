export const x = "";
const input = await Deno.readTextFile("./input.txt");

let output = 0;

const neighbors = [
  [-1, -1],
  [-1, 0],
  [-1, 1],
  [0, -1],
  [0, 1],
  [1, -1],
  [1, 0],
  [1, 1],
];

type Point = {
  x: number;
  y: number;
};

const validNums = "0123456789";

const schematic = input.split("\n").map((x) => x.split(""));
let number = "";
let isPartNumber = false;
for (let x = 0; x < schematic.length; x++) {
  const line = schematic[x];

  for (let y = 0; y < line.length; y++) {
    const point = { x, y };
    const value = schematic[x][y];

    if (validNums.includes(value)) {
      number += value;
      isPartNumber ||= checkNeightbors(schematic, point);
    } else {
      if (isPartNumber) {
        output += parseInt(number);
      }
      number = "";
      isPartNumber = false;
    }
  }
}

function checkNeightbors(schematic: string[][], point: Point): boolean {
  const { x, y } = point;
  let isPartNumber = false;

  neighbors.forEach((neighbor) => {
    const [dx, dy] = neighbor;
    const neighborPoint = { x: x + dx, y: y + dy };
    if (
      neighborPoint.x >= 0 && neighborPoint.y >= 0 &&
      neighborPoint.x < schematic.length &&
      neighborPoint.y < schematic[x].length
    ) {
      const neighborValue = schematic[neighborPoint.x][neighborPoint.y];
      if (
        neighborValue && neighborValue !== "." &&
        !validNums.includes(neighborValue)
      ) {
        isPartNumber = true;
      }
    }
  });

  return isPartNumber;
}

console.log("answer", output);
