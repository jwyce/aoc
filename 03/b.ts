export const x = "";
const input = await Deno.readTextFile("./input.txt");

let output = 0;

type Point = {
  x: number;
  y: number;
};

const validNums = "0123456789";

const schematic = input.split("\n").map((x) => x.split(""));

for (let y = 0; y < schematic.length; y++) {
  const line = schematic[y];

  for (let x = 0; x < line.length; x++) {
    const point = { x, y };
    const value = schematic[y][x];

    if (value === "*") {
      const parts = surroundingNums(schematic, point);
      if (parts.length === 2) {
        const gearRatio = parts[0] * parts[1];
        output += gearRatio;
      }
    }
  }
}

function surroundingNums(schematic: string[][], point: Point): number[] {
  const { x, y } = point;
  const nums: number[] = [];

  let num = "";
  let isNeighbor = false;
  for (let py = y - 1; py <= y + 1; py++) {
    for (let px = 0; px < schematic[0].length; px++) {
      const value = schematic[py][px];
      if (validNums.includes(value)) {
        num += value;

        if (Math.abs(px - x) <= 1 && Math.abs(py - y) <= 1) {
          isNeighbor = true;
        }
      } else {
        if (isNeighbor) {
          nums.push(parseInt(num));
        }
        num = "";
        isNeighbor = false;
      }
    }
  }

  return nums;
}

console.log("answer", output);
