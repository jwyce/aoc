export const x = "";
const input = await Deno.readTextFile("./input.txt");

const universe = input.split("\n").filter((x) => x).map((s) => s.split(""));

const galaxies: number[][] = [];

const isEmptyColumn = (matrix: string[][], x: number) => {
  for (let y = 0; y < matrix.length; y += 1) {
    if (matrix[y][x] !== ".") {
      return false;
    }
  }
  return true;
};

const isEmptyRow = (matrix: string[][], y: number) => {
  for (let x = 0; x < matrix[y].length; x += 1) {
    if (matrix[y][x] !== ".") {
      return false;
    }
  }
  return true;
};

for (let y = 0; y < universe.length; y++) {
  for (let x = 0; x < universe[y].length; x++) {
    if (universe[y][x] === "#") {
      const loc = [x, y];
      galaxies.push([...loc, ...loc]);
    }
  }
}

let xExpansion = 0;

for (let x = 0; x < universe.length; x += 1) {
  if (isEmptyColumn(universe, x)) {
    xExpansion += 999_999; // Off by one!
  } else {
    for (const galaxy of galaxies) {
      if (galaxy[0] === x) {
        galaxy[2] = x + xExpansion;
      }
    }
  }
}

let yExpansion = 0;

for (let y = 0; y < universe.length; y += 1) {
  if (isEmptyRow(universe, y)) {
    yExpansion += 999_999;
  } else {
    for (const galaxy of galaxies) {
      if (galaxy[1] === y) {
        galaxy[3] = y + yExpansion;
      }
    }
  }
}

const distances: number[] = [];
for (let a = 0; a < galaxies.length - 1; a++) {
  for (let b = a + 1; b < galaxies.length; b++) {
    const [_aX, _aY, aBigX, aBigY] = galaxies[a];
    const [_bX, _bY, bBigX, bBigY] = galaxies[b];
    const dist = Math.abs(aBigX - bBigX) + Math.abs(aBigY - bBigY);
    distances.push(dist);
  }
}

console.log("answer", distances.reduce((a, b) => a + b, 0));
