export const x = "";
const input = await Deno.readTextFile("./input.txt");

const lines = input.split("\n");
const instructions = lines[0];
type Neighbors = {
  left: string;
  right: string;
};

const map: Map<string, Neighbors> = new Map();

lines.slice(2).filter((x) => x).forEach((line) => {
  const trimmed = line.replace(/\s/g, "");
  const [value, neighbors] = trimmed.split("=");
  const [left, right] = neighbors.slice(1, -1).split(",");
  map.set(value, { left, right });
});

let step = 0;
let idx = 0;
let curr = "AAA";

while (curr !== "ZZZ") {
  const { left, right } = map.get(curr)!;
  if (instructions[idx] === "L") {
    curr = left;
  } else {
    curr = right;
  }

  idx = (idx + 1) % instructions.length;
  step++;
}

console.log("answer", step);
