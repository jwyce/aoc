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

const locations = Array.from(map.keys()).filter((x) => x.endsWith("A"));
const starts = locations.slice();
const zs: number[][] = [[], [], [], [], [], []];
const diffs: number[] = [];

let steps = 0;
let output = 0;

function lcm(a: number, b: number): number {
  return (a * b) / gcd(a, b);
}

function gcd(a: number, b: number): number {
  return b === 0 ? a : gcd(b, a % b);
}

function leastCommonMultiple(numbers: number[]): number {
  return numbers.reduce((acc, num) => lcm(acc, num), 1);
}

while (true) {
  const instruction = instructions[steps % instructions.length];

  for (let i = 0; i < locations.length; i += 1) {
    if (instruction === "L") {
      locations[i] = map.get(locations[i])!.left;
    } else {
      locations[i] = map.get(locations[i])!.right;
    }

    if (locations[i].endsWith("Z")) {
      console.log(`@${i} = Z:`, steps);
      zs[i].push(steps);
    }

    if (locations[i] === starts[i]) {
      console.log(`@${i} RESET:`, steps);
    }
  }

  if (zs.every((z) => z.length > 2)) {
    for (const z of zs) {
      diffs.push(z[1] - z[0]);
    }
    output = leastCommonMultiple(diffs);
    break;
  }

  if (locations.every((loc) => loc.endsWith("Z"))) {
    output = steps;
    break;
  }

  steps++;
}

console.log("answer", output);
