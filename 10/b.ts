import { blue } from "https://deno.land/std/fmt/colors.ts";

export const x = "";
const input = await Deno.readTextFile("./input.txt");

const neighbors = [
  { type: "bottom", delta: [0, 1] },
  { type: "right", delta: [1, 0] },
  { type: "top", delta: [0, -1] },
  { type: "left", delta: [-1, 0] },
];

const typeToAllowedNeighbors = {
  "top": ["|", "F", "7"],
  "bottom": ["|", "J", "L"],
  "left": ["-", "L", "F"],
  "right": ["-", "J", "7"],
};

const pipeGrid = input.split("\n").filter((x) => x).map((s) => s.split(""));

type Position = { x: number; y: number };

let start: Position | undefined = undefined;
const seen: Map<string, boolean> = new Map();
const parents: Map<string, string | undefined> = new Map();
for (let y = 0; y < pipeGrid.length; y++) {
  for (let x = 0; x < pipeGrid[y].length; x++) {
    if (pipeGrid[y][x] === "S") {
      start = { x, y };
    }
  }
}

if (!start) throw new Error("no start");
let maxDepth = 0;
let maxDepthPos: Position | undefined = undefined;

// NOTE: cus tail call optimization is not a thing in deno we need to maintain our own stack
const stack: { pos: Position; parent: Position | undefined; depth: number }[] =
  [{
    pos: start,
    parent: undefined,
    depth: 0,
  }];

while (stack.length) {
  const { pos, parent, depth } = stack.pop()!;
  if (depth > maxDepth) {
    maxDepth = Math.max(depth, maxDepth);
    maxDepthPos = pos;
  }

  seen.set(JSON.stringify(pos), true);
  if (parent && JSON.stringify(parent) !== JSON.stringify(start)) {
    parents.set(JSON.stringify(pos), JSON.stringify(parent));
  }

  const { x, y } = pos;

  for (const { delta, type } of neighbors) {
    const [dx, dy] = delta;
    const nextPos = { x: x + dx, y: y + dy };
    if (
      nextPos.x < 0 || nextPos.x >= pipeGrid[0].length || nextPos.y < 0 ||
      nextPos.y >= pipeGrid.length
    ) {
      continue;
    }

    if (
      typeToAllowedNeighbors[type as keyof typeof typeToAllowedNeighbors]
        .includes(pipeGrid[nextPos.y][nextPos.x]) &&
      !seen.get(JSON.stringify(nextPos))
    ) {
      stack.push({ pos: nextPos, parent: pos, depth: depth + 1 });
    }
  }
}

const path: Position[] = [];
let curr = maxDepthPos;
while (curr !== undefined) {
  path.push(curr);
  const parent = parents.get(JSON.stringify(curr));
  curr = parent ? JSON.parse(parents.get(JSON.stringify(curr))!) : undefined;
}

console.log({ maxDepthPos, path, parents });

// NOTE: shoot a ray from each of the positions not in the main loop
// if it hits the main loop an odd number of times it's enclosed
// if it hits the main loop an even number of times it's outside
// run into issues if your ray is colinear with the path
// so in this case since pipes follow cardinal directions
// we can just shoot ray in a diagonal direction until we run of the grid
// NB: if the ray is tangent to the loop (hit a corner from outside) it crosses twice

let tileCount = 0;
const pathKeys = new Set(path.map((p) => JSON.stringify(p)));

const prettyGrid: string[][] = pipeGrid.map((row) => row.map((c) => c));

for (let y = 0; y < pipeGrid.length; y++) {
  for (let x = 0; x < pipeGrid[y].length; x++) {
    // we're a tile
    if (!pathKeys.has(JSON.stringify({ x, y }))) {
      // shoot diagonal-down ray and count how many times it hits the loop
      let crossings = 0;
      const ray = { x, y };
      while (ray.x < pipeGrid[0].length && ray.y < pipeGrid.length) {
        const tile = pipeGrid[ray.y][ray.x];
        if (pathKeys.has(JSON.stringify(ray)) && tile !== "L" && tile !== "7") {
          crossings++;
        }
        ray.x++;
        ray.y++;
      }

      tileCount += crossings % 2 === 1 ? 1 : 0;
    }
  }
}

path.forEach(({ x, y }) => {
  prettyGrid[y][x] = blue(prettyGrid[y][x]);
});

for (let y = 0; y < prettyGrid.length; y++) {
  let formattedRow = "";
  for (let x = 0; x < prettyGrid[y].length; x++) {
    formattedRow += prettyGrid[y][x];
  }
  console.log(formattedRow);
}

console.log("answer", tileCount);
