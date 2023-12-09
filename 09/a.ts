export const x = "";
const input = await Deno.readTextFile("./input.txt");

const seqs = input.split("\n").filter((x) => x).map((s) =>
  s.split(" ").map(Number)
);

const output = seqs.map((seq) => {
  let curr = seq;
  const lastSeqValues = [];

  while (!curr.every((n) => n === 0)) {
    const diffs = [];
    for (let i = 0; i < curr.length - 1; i++) {
      diffs.push(curr[i + 1] - curr[i]);
    }

    lastSeqValues.push(curr[curr.length - 1]);
    curr = diffs;
  }

  return lastSeqValues.reduce((a, b) => a + b, 0);
});

console.log("answer", output.reduce((a, b) => a + b, 0));
