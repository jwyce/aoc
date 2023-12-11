export const x = "";
const input = await Deno.readTextFile("./input.txt");

type Point = { x: number; y: number };

const universe = input.split("\n").filter((x) => x).map((s) => s.split(""));
const expandedUniverse: string[][] = [];

for (let i = 0; i < universe.length; i++) {
  if (universe[i].every((x) => x === ".")) {
    expandedUniverse.push([...universe[i]]);
    expandedUniverse.push([...universe[i]]);
  } else {
    expandedUniverse.push([...universe[i]]);
  }
}

const colExpansionIndexes: number[] = [];
for (let x = 0; x < expandedUniverse[0].length; x++) {
  let colHasNoGalaxy = true;
  for (let y = 0; y < expandedUniverse.length; y++) {
    if (expandedUniverse[y][x] === "#") {
      colHasNoGalaxy = false;
    }
  }

  if (colHasNoGalaxy) {
    colExpansionIndexes.push(x);
  }
}

for (let y = 0; y < expandedUniverse.length; y++) {
  let adjustment = 0;
  colExpansionIndexes.forEach((x) => {
    expandedUniverse[y].splice(x + adjustment, 0, ".");
    adjustment++;
  });
}

const galaxies: Point[] = [];
for (let y = 0; y < expandedUniverse.length; y++) {
  for (let x = 0; x < expandedUniverse[y].length; x++) {
    if (expandedUniverse[y][x] === "#") {
      galaxies.push({ x, y });
    }
  }
}

const distances: number[] = [];
for (let a = 0; a < galaxies.length - 1; a++) {
  for (let b = a + 1; b < galaxies.length; b++) {
    const { x: aX, y: aY } = galaxies[a];
    const { x: bX, y: bY } = galaxies[b];
    const dist = Math.abs(aX - bX) + Math.abs(aY - bY);
    distances.push(dist);
  }
}

console.log("answer", distances.reduce((a, b) => a + b, 0));
