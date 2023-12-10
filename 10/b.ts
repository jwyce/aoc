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

// console.log({ pipeGrid });

type Position = { x: number; y: number };

let start: Position | undefined = undefined;
const seen: Map<string, boolean> = new Map();
for (let y = 0; y < pipeGrid.length; y++) {
  for (let x = 0; x < pipeGrid[y].length; x++) {
    if (pipeGrid[y][x] === "S") {
      start = { x, y };
    }
  }
}
// console.log({ start });
if (!start) throw new Error("no start");
let maxDepth = 0;

const stack = [{ pos: start, depth: 0 }];

while (stack.length) {
  const { pos, depth } = stack.pop()!;
  maxDepth = Math.max(depth, maxDepth);
  seen.set(JSON.stringify(pos), true);

  const { x, y } = pos;
  // console.log({ pos, depth });

  for (const { delta, type } of neighbors) {
    const [dx, dy] = delta;
    const nextPos = { x: x + dx, y: y + dy };
    if (
      nextPos.x < 0 || nextPos.x >= pipeGrid[0].length || nextPos.y < 0 ||
      nextPos.y >= pipeGrid.length
    ) {
      continue;
    }

    // console.log({ type, pipe: pipeGrid[nextPos.y][nextPos.x], seen });

    if (
      typeToAllowedNeighbors[type as keyof typeof typeToAllowedNeighbors]
        .includes(pipeGrid[nextPos.y][nextPos.x]) &&
      !seen.get(JSON.stringify(nextPos))
    ) {
      stack.push({ pos: nextPos, depth: depth + 1 });
    }
  }
}

console.log("answer", Math.round(maxDepth / 2));
